#ifndef FUR_INCLUDED
#define FUR_INCLUDED

#ifndef FUR_OFFSET
#define FUR_OFFSET 0.0
#endif

// #define UNITY_BRDF_PBS Fabric_BRDF_PBS

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "FabricBRDF.cginc"
#include "UnityGlobalIllumination.cginc"
#include "UnityPBSLighting.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;

sampler2D _MaskTex;
float4 _MaskTex_ST;

half4 _Color;
half _Smoothness;
half _Metallic;
half _FurLength;
half4 _Gravity;
half4 _Wind;
half _Occlusion;
int _Layer;

struct appdata {
    float4 vertex    : POSITION;
    float3 normal    : NORMAL;
    float4 tangent   : TANGENT;
    float2 texcoord0 : TEXCOORD0;
};

struct v2f {
    float4 pos      : SV_POSITION;
    float4 uv       : TEXCOORD0;
    float4 normal   : TEXCOORD1; // [ 3:normal | 1:offset ]
    float4 worldPos : TEXCOORD2;
    float3 viewDir  : TEXCOORD3;
    #if defined(SHADOWS_CUBE)
    float3 vec : TEXCOORD4; // light vec
    #endif
    UNITY_FOG_COORDS(5)
    #ifdef SHADOWS_SCREEN
    UNITY_SHADOW_COORDS(6) // _ShadowCoord
    #endif

};

float3 Displacement (float3 worldPos, float3 worldNormal, float2 uv, float offset) {
    float3 gravity = _Gravity.xyz * offset;
    float3 wind = _Wind.xyz;
    wind *= 1 + sin(_Time.x * _Wind.w + uv.x * 6.2831853h) * sin(_Time.x * _Wind.w + uv.y * 6.2831853h);
    return worldPos + worldNormal * (_FurLength * offset) + (gravity + wind) * offset;
}

v2f VertexOutput (v2f o, float4 worldPos, float3 worldNormal) {
    #if defined(SHADOWS_CUBE)
    // Cube map shadow caster pass: Transfer the shadow vector.
    o.pos = UnityWorldToClipPos(worldPos);
    o.vec = worldPos.xyz - _LightPositionRange.xyz;

    #elif defined(SHADOWS_DEPTH)
    if (unity_LightShadowBias.z != 0.0) {
        float3 wLight = normalize(UnityWorldSpaceLightDir(worldPos.xyz));
        float shadowCos = dot(worldNormal, wLight);
        float normalBias = unity_LightShadowBias.z * sqrt(1 - shadowCos * shadowCos);
        worldPos.xyz -= worldNormal * normalBias;
    }
    float4 position = mul(UNITY_MATRIX_VP, worldPos);
    o.pos = UnityApplyLinearShadowBias(position);

    #else
    // color shader
    o.pos = UnityWorldToClipPos(worldPos);
    #endif

    return o;
}

v2f vert (appdata v) {
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f, o);

    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
    float3 worldNormal = UnityObjectToWorldNormal(v.normal);

    #ifndef GEOMETRY_SHADER
    worldPos.xyz = Displacement (worldPos.xyz, worldNormal, v.texcoord0.xy, FUR_OFFSET);
    o = VertexOutput (o, worldPos, worldNormal); // setup shadow caster data if need
    #endif

    o.uv.xy = TRANSFORM_TEX(v.texcoord0, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord0, _MaskTex);
    o.normal.xyz = worldNormal;
    o.normal.w = FUR_OFFSET;
    o.worldPos = worldPos;
    o.viewDir = _WorldSpaceCameraPos - worldPos;

    #ifdef SHADOWS_SCREEN
    TRANSFER_SHADOW(o);
    #endif
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
}

[maxvertexcount(42)]
void geom (triangle v2f input[3], uint pid : SV_PrimitiveID, inout TriangleStream<v2f> outStream) {
    v2f v0 = input[0];
    v2f v1 = input[1];
    v2f v2 = input[2];

    float3 worldPos0 = v0.worldPos;
    float3 worldPos1 = v1.worldPos;
    float3 worldPos2 = v2.worldPos;

    int layer = min(14, _Layer);
    float offset_per_layer = 1.0 / layer;
    float offset = 0;
    for(int i = 0; i < layer; i++) {
        v0.worldPos.xyz = Displacement (worldPos0, v0.normal, v0.uv.xy, offset);
        v0 = VertexOutput (v0, v0.worldPos, v0.normal); // setup shadow caster data if need
        v0.normal.w = offset;
        #ifdef SHADOWS_SCREEN
        TRANSFER_SHADOW(v0);
        #endif
        UNITY_TRANSFER_FOG(v0, v0.pos);

        v1.worldPos.xyz = Displacement (worldPos1, v1.normal, v1.uv.xy, offset);
        v1 = VertexOutput (v1, v1.worldPos, v1.normal); // setup shadow caster data if need
        v1.normal.w = offset;
        #ifdef SHADOWS_SCREEN
        TRANSFER_SHADOW(v1);
        #endif
        UNITY_TRANSFER_FOG(v1, v1.pos);
        
        v2.worldPos.xyz = Displacement (worldPos2, v2.normal, v2.uv.xy, offset);
        v2 = VertexOutput (v2, v2.worldPos, v2.normal); // setup shadow caster data if need
        v2.normal.w = offset;
        #ifdef SHADOWS_SCREEN
        TRANSFER_SHADOW(v2);
        #endif
        UNITY_TRANSFER_FOG(v2, v2.pos);
        
        outStream.Append(v0);
        outStream.Append(v1);
        outStream.Append(v2);
        outStream.RestartStrip();
        offset += offset_per_layer;
    }
}

UnityGI FragmentGI (float3 worldPos, float3 worldNormal, float3 viewDir, half occlusion, half smoothness, half3 specColor, half3 ambient, half atten, UnityLight light) {
    UnityGIInput d;
    d.light = light;
    d.worldPos = worldPos;
    d.worldViewDir = viewDir;
    d.atten = atten;
    d.ambient = ambient;
    d.lightmapUV = 0;

    d.probeHDR[0] = unity_SpecCube0_HDR;
    d.probeHDR[1] = unity_SpecCube1_HDR;
    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    d.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
    d.boxMax[0] = unity_SpecCube0_BoxMax;
    d.probePosition[0] = unity_SpecCube0_ProbePosition;
    d.boxMax[1] = unity_SpecCube1_BoxMax;
    d.boxMin[1] = unity_SpecCube1_BoxMin;
    d.probePosition[1] = unity_SpecCube1_ProbePosition;
    #endif

    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(smoothness, viewDir, worldNormal, specColor);
    return UnityGlobalIllumination (d, occlusion, worldNormal, g);
}

UnityLight MainLight () {
    UnityLight l;
    l.color = _LightColor0.rgb;
    l.dir = _WorldSpaceLightPos0.xyz;
    return l;
}

UnityLight AdditiveLight (half3 lightDir, half atten) {
    UnityLight l;
    l.color = _LightColor0.rgb;
    l.dir = lightDir;
    #ifndef USING_DIRECTIONAL_LIGHT
    l.dir = normalize(l.dir);
    #endif
    l.color *= atten;
    return l;
}

UnityIndirect DummyIndirect () {
    UnityIndirect i;
    i.diffuse = 0;
    i.specular = 0;
    return i;
}

half4 FragmentBase (v2f i, half offset, half4 color) {
    half3 worldPos = i.worldPos;
    half3 worldNormal = normalize(i.normal.xyz);
    half3 viewDir = normalize(i.viewDir);

    // lighting
    half occlusion = lerp(1 - _Occlusion, 1, offset);
    half smoothness = _Smoothness;
    half metallic = _Metallic;
    half3 ambient = 0; // TODO: light probe

    half3 diffColor, specColor;
    half oneMinusReflectivity;
    diffColor = DiffuseAndSpecularFromMetallic(color.rgb * _Color.rgb, metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
    #ifdef UNITY_PASS_FORWARDBASE
    // FORWARDBASE
    UnityLight light = MainLight ();
    UnityGI gi = FragmentGI(worldPos, worldNormal, viewDir, occlusion, smoothness, specColor, ambient, atten, light);
    half4 c = UNITY_BRDF_PBS(diffColor, specColor, oneMinusReflectivity, smoothness, worldNormal, viewDir, gi.light, gi.indirect);
    #else
    // FORWARDADD
    half3 lightDir = _WorldSpaceLightPos0.xyz - worldPos * _WorldSpaceLightPos0.w;
    #ifndef USING_DIRECTIONAL_LIGHT
    lightDir = normalize(lightDir);
    #endif
    UnityLight light = AdditiveLight (lightDir, atten);
    UnityIndirect dummyIndirect = DummyIndirect ();
    half4 c = UNITY_BRDF_PBS(diffColor, specColor, oneMinusReflectivity, smoothness, worldNormal, viewDir, light, dummyIndirect);
    #endif

    #ifdef UNITY_PASS_FORWARDBASE
    UNITY_APPLY_FOG(i.fogCoord, c.rgb);
    #else
    UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0,0,0,0));
    #endif
    
    return c;
}

half4 frag (v2f i) : SV_Target {
    half offset = i.normal.w;
    half4 color = tex2D(_MainTex, i.uv.xy);
    half4 mask = tex2D(_MaskTex, i.uv.zw);
    clip(mask.r * color.a - offset - 1.0e-6h);

    #ifdef UNITY_PASS_SHADOWCASTER
    SHADOW_CASTER_FRAGMENT(i)
    #else
    return FragmentBase(i, offset, color);
    #endif
}

#endif // FUR_INCLUDED
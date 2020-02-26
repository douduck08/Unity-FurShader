#ifndef TOON_FUR_INCLUDED
#define TOON_FUR_INCLUDED

#ifndef FUR_OFFSET
#define FUR_OFFSET 0.0
#endif

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "UnityGlobalIllumination.cginc"
// #include "FabricBRDF.cginc" // FIXME: Fabric BRDF has bugs in linear color space
#include "UnityPBSLighting.cginc"

// ----------------------------- //
// material property and uniform //
// ----------------------------- //
sampler2D _MainTex;
float4 _MainTex_ST;
half4 _Color;
half _Smoothness;
half _Metallic;

sampler2D _MaskTex;
float4 _MaskTex_ST;
half _FurLength;
half4 _Gravity;
half4 _Wind;
half _Occlusion;
int _Layer;

half4 _RimColor;
half _RimPow;
half _RimBoost;
half4 _TranslucencyColor;
half _Translucency;
sampler2D _NoiseTex;
float _NoiseStrength;

// ------------------------ //
// vertex input and varying //
// ------------------------ //
#ifndef UNITY_PASS_SHADOWCASTER
struct appdata {
    float4 vertex    : POSITION;
    float3 normal    : NORMAL;
    float4 tangent   : TANGENT;
    float2 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f {
    float4 pos      : SV_POSITION;
    float4 uv       : TEXCOORD0;
    float4 normal   : TEXCOORD1; // world space normal (without normal map)
    float4 worldPos : TEXCOORD2;
    float3 viewDir  : TEXCOORD3;
    half3 ambient   : TEXCOORD4;

    UNITY_FOG_COORDS(5) // fog, need #include "UnityCG.cginc"
    UNITY_LIGHTING_COORDS(6,7) // shadow and light cookie, need #include "AutoLight.cginc"
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#else // UNITY_PASS_SHADOWCASTER
struct appdata {
    float4 vertex    : POSITION;
    float3 normal    : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f {
    float4 pos : SV_POSITION;
    #if defined(SHADOWS_CUBE)
    float3 vec : TEXCOORD0; // light vec
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
#endif // UNITY_PASS_SHADOWCASTER

// ------------------------ //
// helper functions of PBS  //
// ------------------------ //
#ifndef UNITY_PASS_SHADOWCASTER
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

UnityLight AdditiveLight (half3 worldPos, half atten) {
    UnityLight l;
    l.color = _LightColor0.rgb;
    l.dir = _WorldSpaceLightPos0.xyz - worldPos * _WorldSpaceLightPos0.w;
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
#endif // UNITY_PASS_SHADOWCASTER

// -------------------------- //
// vertex and fragment shader //
// -------------------------- //
float3 Displacement (float3 worldPos, float3 worldNormal, float offset) {
    float offset2 = offset * offset;
    // float offset3 = offset * offset2;
    float3 gravity = _Gravity.xyz;
    float windStrength = 1 + sin(_Time.x * _Wind.w + dot(_Wind.xyz, worldPos));
    float3 wind = _Wind.xyz * windStrength;
    return worldPos + worldNormal * (_FurLength * offset) + gravity * offset2 + wind * offset;
}

#ifdef UNITY_PASS_SHADOWCASTER
v2f VertexShadowCaster (appdata v, v2f o) {
    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
    float3 worldNormal = UnityObjectToWorldNormal(v.normal);

    #if defined(SHADOWS_CUBE)
    // Cube map shadow caster pass: Transfer the shadow vector.
    o.pos = UnityWorldToClipPos(worldPos);
    o.vec = worldPos.xyz - _LightPositionRange.xyz;

    #elif defined(SHADOWS_DEPTH)
    // directional lighting shadow caster pass
    if (unity_LightShadowBias.z != 0.0) {
        float3 wLight = normalize(UnityWorldSpaceLightDir(worldPos.xyz));
        float shadowCos = dot(worldNormal, wLight);
        float normalBias = unity_LightShadowBias.z * sqrt(1 - shadowCos * shadowCos);
        worldPos.xyz -= worldNormal * normalBias;
    }
    float4 position = mul(UNITY_MATRIX_VP, worldPos);
    o.pos = UnityApplyLinearShadowBias(position);
    #endif

    return o;
}
#else
v2f VertexInternal (appdata v, v2f o) {
    o.pos = UnityObjectToClipPos(v.vertex);
    UNITY_TRANSFER_LIGHTING(o, 0);

    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
    float3 worldNormal = UnityObjectToWorldNormal(v.normal);

    #ifndef GEOMETRY_SHADER
    worldPos.xyz = Displacement (worldPos.xyz, worldNormal, FUR_OFFSET);
    o.pos = UnityWorldToClipPos(worldPos);
    o.viewDir = _WorldSpaceCameraPos - worldPos.xyz;
    #endif

    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _MaskTex);
    o.normal.xyz = worldNormal;
    o.normal.w = FUR_OFFSET;
    o.worldPos = worldPos;

    #ifdef UNITY_SHOULD_SAMPLE_SH
    #ifdef VERTEXLIGHT_ON
    o.ambient.rgb = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb, unity_4LightAtten0, worldPos, worldNormal);
    #endif
    o.ambient.rgb = ShadeSHPerVertex(worldNormal, o.ambient.rgb);
    #endif

    #ifndef GEOMETRY_SHADER
    // UNITY_TRANSFER_LIGHTING(o, 0);
    UNITY_TRANSFER_FOG(o, o.pos);
    #endif
    return o;
}
#endif // UNITY_PASS_SHADOWCASTER

v2f vert (appdata v) {
    UNITY_SETUP_INSTANCE_ID(v);
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

    #ifdef UNITY_PASS_SHADOWCASTER
    return VertexShadowCaster(v, o);
    #else
    return VertexInternal(v, o);
    #endif
}


#ifdef GEOMETRY_SHADER
[maxvertexcount(30)]
void geom (triangle v2f input[3], uint pid : SV_PrimitiveID, inout TriangleStream<v2f> outStream) {
    v2f v0 = input[0];
    v2f v1 = input[1];
    v2f v2 = input[2];

    // outStream.Append(v0);
    // outStream.Append(v1);
    // outStream.Append(v2);
    // outStream.RestartStrip();

    float3 worldPos0 = v0.worldPos;
    float3 worldPos1 = v1.worldPos;
    float3 worldPos2 = v2.worldPos;
    float3 worldNormal0 = v0.normal;
    float3 worldNormal1 = v1.normal;
    float3 worldNormal2 = v2.normal;

    int layer = min(10, _Layer);
    float offset_per_layer = 1.0 / layer;
    float offset = offset_per_layer;
    for(int i = 0; i < layer; i++) {
        v0.worldPos.xyz = Displacement (worldPos0, worldNormal0, offset);
        v0.pos = UnityWorldToClipPos(v0.worldPos.xyz);
        v0.normal.w = offset;
        v0.viewDir = _WorldSpaceCameraPos - v0.worldPos.xyz;
        UNITY_TRANSFER_FOG(v0, v0.pos);

        v1.worldPos.xyz = Displacement (worldPos1, worldNormal1, offset);
        v1.pos = UnityWorldToClipPos(v1.worldPos.xyz);
        v1.normal.w = offset;
        v1.viewDir = _WorldSpaceCameraPos - v1.worldPos.xyz;
        UNITY_TRANSFER_FOG(v1, v1.pos);

        v2.worldPos.xyz = Displacement (worldPos2, worldNormal2, offset);
        v2.pos = UnityWorldToClipPos(v2.worldPos.xyz);
        v2.normal.w = offset;
        v2.viewDir = _WorldSpaceCameraPos - v2.worldPos.xyz;
        UNITY_TRANSFER_FOG(v2, v2.pos);
        
        outStream.Append(v0);
        outStream.Append(v1);
        outStream.Append(v2);
        outStream.RestartStrip();
        offset += offset_per_layer;
    }
}
#endif

#ifndef UNITY_PASS_SHADOWCASTER
#ifdef UNITY_PASS_FORWARDBASE
// FORWARDBASE
half4 CustomLighting (v2f i, half3 albedo, half3 worldPos, half3 worldNormal, half3 viewDir, half occlusion, half smoothness, half metallic, half3 ambient) {
    worldNormal = normalize(worldNormal);
    viewDir = normalize(viewDir);

    half3 diffColor, specColor;
    half oneMinusReflectivity;
    diffColor = DiffuseAndSpecularFromMetallic(albedo, metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
    UnityLight light = MainLight ();
    UnityGI gi = FragmentGI(worldPos, worldNormal, viewDir, occlusion, smoothness, specColor, ambient, atten, light);

    half4 c = 0;
    c.rgb += diffColor * gi.light.color * (saturate(dot(gi.light.dir, worldNormal) + _Translucency * occlusion) * occlusion);

    half fresnel = pow(1 - max(0, dot(worldNormal, viewDir)), _RimPow);
    c.rgb += _RimColor.rgb * gi.light.color * (fresnel * occlusion * occlusion * _RimBoost);
    c.rgb += lerp (_RimColor.rgb * gi.indirect.diffuse, gi.indirect.diffuse, occlusion);

    return c;
}

#else
// FORWARDADD
half4 CustomLighting (v2f i, half3 albedo, half3 worldPos, half3 worldNormal, half3 viewDir, half occlusion, half smoothness, half metallic, half3 ambient) {
    worldNormal = normalize(worldNormal);
    viewDir = normalize(viewDir);

    half3 diffColor, specColor;
    half oneMinusReflectivity;
    diffColor = DiffuseAndSpecularFromMetallic(albedo, metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
    UnityLight light = AdditiveLight (worldPos, atten);

    half4 c = 0;
    c.rgb += diffColor * gi.light.color * (saturate(dot(light.dir, worldNormal) + _Translucency * occlusion) * occlusion);

    return c;
}
#endif // UNITY_PASS_FORWARDBASE

half4 FragmentColor (v2f i) {
    half4 albedo = tex2D(_MainTex, i.uv.xy);
    albedo.rgb *= _Color.rgb;

    half offset = i.normal.w;
    half mask = tex2D(_MaskTex, i.uv.zw).r;
    half noise = tex2D(_NoiseTex, i.uv.xy).r;
    half alpha = (mask - noise * _NoiseStrength * offset) * albedo.a - offset * offset;
    #ifndef TRANSPARENT
    clip(alpha - 1.0e-6h);
    #endif

    half occlusion = lerp(1 - _Occlusion, 1, offset);
    half3 ambient = lerp(0, i.ambient, offset * offset);
    half4 c = CustomLighting(i, albedo.rgb, i.worldPos, i.normal.xyz, i.viewDir, occlusion, _Smoothness, _Metallic, ambient);

    UNITY_APPLY_FOG(i.fogCoord, c.rgb);
    #ifdef TRANSPARENT
    c.a = saturate(alpha);
    #endif
    return c;
}
#endif // UNITY_PASS_SHADOWCASTER

half4 frag (v2f i) : SV_Target {
    #ifdef UNITY_PASS_SHADOWCASTER
    SHADOW_CASTER_FRAGMENT(i)
    #else
    return FragmentColor(i);
    #endif
}

#endif // TOON_FUR_INCLUDED
#ifndef FUR_INCLUDED
#define FUR_INCLUDED

#ifndef FUR_OFFSET
#define FUR_OFFSET _FurOffset
#endif

#define UNITY_BRDF_PBS Fabric_BRDF_PBS

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "FabricBRDF.cginc"
#include "UnityGlobalIllumination.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;

sampler2D _MaskTex;
float4 _MaskTex_ST;

half4 _Color;
half _Smoothness;
half _Metallic;
half _FurLength;
half _FurOffset;
half4 _Gravity;
half4 _Wind;
half _Occlusion;

struct appdata {
    float4 vertex    : POSITION;
    float3 normal    : NORMAL;
    float4 tangent   : TANGENT;
    float2 texcoord0 : TEXCOORD0;
    float2 texcoord1 : TEXCOORD1;
};

struct v2f {
    float4 pos      : SV_POSITION;
    float4 uv       : TEXCOORD0;
    float3 normal   : TEXCOORD1;
    float4 worldPos : TEXCOORD2;
    float3 viewDir  : TEXCOORD3;
    UNITY_SHADOW_COORDS(4)
    UNITY_FOG_COORDS(5)
};

float3 Displacement (float3 vertex, float3 normal, float2 uv) {
    float3 gravity = mul((float3x3)unity_WorldToObject, _Gravity.xyz) * FUR_OFFSET;
    float3 wind = mul((float3x3)unity_WorldToObject, _Wind.xyz); 
    wind *= 1 + sin(_Time.x * _Wind.w + uv.x * 6.2831853h) * sin(_Time.x * _Wind.w + uv.y * 6.2831853h);
    return vertex + normal * (_FurLength * FUR_OFFSET) + (gravity + wind) * FUR_OFFSET;
}

v2f vert (appdata v) {
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f, o);

    float3 vertex = Displacement(v.vertex.xyz, v.normal, v.texcoord0.xy);
    o.pos = UnityObjectToClipPos(vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord0, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord0, _MaskTex);

    o.normal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.viewDir = _WorldSpaceCameraPos - o.worldPos.xyz;

    UNITY_TRANSFER_LIGHTING(o, v.texcoord1);
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
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

half4 frag (v2f i) : SV_Target {
    half4 color = tex2D(_MainTex, i.uv.xy);
    half4 mask = tex2D(_MaskTex, i.uv.zw);
    clip(mask.r * color.a - FUR_OFFSET);

    half3 worldPos = i.worldPos;
    half3 worldNormal = normalize(i.normal);
    half3 viewDir = normalize(i.viewDir);

    // lighting
    half occlusion = lerp(1 - _Occlusion, 1, FUR_OFFSET);
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

struct appdata_shadow {
    float4 vertex    : POSITION;
    float3 normal    : NORMAL;
    float2 texcoord  : TEXCOORD0;
};

struct v2f_shadow {
    V2F_SHADOW_CASTER;
    float4 uv        : TEXCOORD1;
    #if defined (_ALPHATESTMODE_DITHER4) || defined (_ALPHATESTMODE_DITHER8)
    float4 screenPos : TEXCOORD2;
    #endif
    #if defined (_ALPHATESTMODE_HASHED)
    float4 objPos    : TEXCOORD3;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

v2f_shadow vert_shadow(appdata_shadow v) {
    v2f_shadow o;
    UNITY_INITIALIZE_OUTPUT(v2f_shadow, o);
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

    v.vertex.xyz = Displacement(v.vertex.xyz, v.normal, v.texcoord.xy);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _MaskTex);

    TRANSFER_SHADOW_CASTER(o)

    #if defined (_ALPHATESTMODE_DITHER4) || defined (_ALPHATESTMODE_DITHER8)
    o.screenPos = ComputeScreenPos(o.pos);
    #endif
    #if defined (_ALPHATESTMODE_HASHED)
    o.objPos = v.vertex;
    #endif
    return o;
}

half4 frag_shadow(v2f_shadow i) : SV_Target {
    UNITY_SETUP_INSTANCE_ID(i);

    half4 color = tex2D(_MainTex, i.uv.xy);
    half4 mask = tex2D(_MaskTex, i.uv.zw);
    clip(mask.r * color.a - FUR_OFFSET);

    SHADOW_CASTER_FRAGMENT(i)
}

#endif // FUR_INCLUDED
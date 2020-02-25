Shader "Custom/Toon Fur(DX11)" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        [Gamma] _Metallic ("Metallic", Range(0,1)) = 0.0
        _SpecColor ("Spec Color", Color) = (1,1,1,1)
        _SpecPow ("Spec Pow", float) = 1.0
        _SpecBoost ("Spec Boost", float) = 1.0

        _TranslucencyColor ("Translucency Color", Color) = (1,1,1,1)
        _Translucency ("Translucency", Range(0,1)) = 0.2

        _MaskTex ("Fur Mask (R)", 2D) = "white" {}
        _NoiseTex ("Noise Mask (R)", 2D) = "white" {}
        _NoiseStrength ("Noise Strength", Range(0,1)) = 0.2
        _Layer("Fur Layers (1-13)", Int) = 10
        _FurLength ("Fur Length", float) = 1.0

        _Gravity("Gravity (XYZ)", Vector) = (0,0,0,0)
        _Wind("Wind (XYZ), Speed (W)", Vector) = (0,0,0,0)
        _Occlusion ("Occlusion", Range(0,1)) = 1.0
        [HideInInspector] _FabricScatterScale("Fabric Scatter", Range(0,10)) = 5.0
    }
    SubShader {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
        Cull Off

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma target 4.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #define GEOMETRY_SHADER
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma target 4.0
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog

            #define GEOMETRY_SHADER
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode"="ShadowCaster" }
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma multi_compile_shadowcaster noshadowmask nodynlightmap nodirlightmap nolightmap

            #define GEOMETRY_SHADER
            #include "ToonFur.cginc"
            ENDCG
        }
        
    }
    FallBack "Diffuse"
}

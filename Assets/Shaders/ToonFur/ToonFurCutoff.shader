Shader "Custom/ToonFur(Cutoff)" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        // _Smoothness ("Smoothness", Range(0,1)) = 0.5
        // [Gamma] _Metallic ("Metallic", Range(0,1)) = 0.0

        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPow ("Rim Pow", float) = 1.0
        _RimBoost ("Rim Boost", float) = 1.0
        _TranslucencyColor ("Translucency Color", Color) = (1,1,1,1)
        _Translucency ("Translucency", Range(0,0.5)) = 0.2
        [NoScaleOffset]_NoiseTex ("Noise Mask (R)", 2D) = "white" {}
        _NoiseStrength ("Noise Strength", Range(0,1)) = 0.2

        _MaskTex ("Fur Mask (R)", 2D) = "white" {}
        _FurLength ("Fur Length", float) = 1.0

        _Gravity("Gravity (XYZ)", Vector) = (0,0,0,0)
        _Wind("Wind (XYZ), Speed (W)", Vector) = (0,0,0,0)
        _Occlusion ("Occlusion", Range(0,1)) = 1.0
        // [HideInInspector] _FabricScatterScale("Fabric Scatter", Range(0,10)) = 5.0
    }
    SubShader {
        Tags { "Queue"="Transparent" "RenderType"="TransparentCutout" }
        Cull Back

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 0.1
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 0.2
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 0.3
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 0.4
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 0.5
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 0.6
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 0.7
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 0.8
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 0.9
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FUR_OFFSET 1.0
            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }

        // Without ForwardAdd Pass, point light will become vertex light
        // Pass {
            //     Tags { "LightMode" = "ForwardAdd" }
            //     Blend One One
            //     ZWrite Off
            //     ZTest LEqual

            //     CGPROGRAM
            //     #pragma target 3.0
            //     #pragma multi_compile_fwdadd_fullshadows
            //     #pragma multi_compile_fog
            //     #pragma multi_compile_instancing

            //     #pragma vertex vert
            //     #pragma fragment frag
            //     #include "ToonFur.cginc"
            //     ENDCG
        // }

        Pass {
            Tags { "LightMode"="ShadowCaster" }
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag
            #include "ToonFur.cginc"
            ENDCG
        }
    }
}
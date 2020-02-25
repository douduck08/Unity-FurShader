Shader "Custom/Toon Fur(30 Layer) Transparent" {
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
        _FurLength ("Fur Length", float) = 1.0

        _Gravity("Gravity (XYZ)", Vector) = (0,0,0,0)
        _Wind("Wind (XYZ), Speed (W)", Vector) = (0,0,0,0)
        _Occlusion ("Occlusion", Range(0,1)) = 1.0
        [HideInInspector] _FabricScatterScale("Fabric Scatter", Range(0,10)) = 5.0
    }
    SubShader {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Cull Back

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.0
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.0333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.0667
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.1
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.1333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.1667
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.2
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.2333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.2667
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.3
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.3333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.3667
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.4
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.4333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.4667
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.5
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.5333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.5667
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.6
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.6333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.6667
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.7
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.7333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.7667
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.8
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.8333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.8667
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.9
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.9333
            #include "ToonFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdbase nolightmap
            #pragma multi_compile_fog
            #pragma skip_variants SHADOWS_SCREEN

            #define TRANSPARENT
            #define FUR_OFFSET 0.9667
            #include "ToonFur.cginc"
            ENDCG
        }
    }
    FallBack "Diffuse"
}

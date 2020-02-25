Shader "Template" {
    Properties {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(0,1)) = 1.0

        // _Smoothness ("Smoothness", Range(0,1)) = 0.5
        // [Gamma] _Metallic ("Metallic", Range(0,1)) = 0.0
        // _OcclusionMap("Occlusion", 2D) = "white" {}
        // _OcclusionStrength("Strength", Range(0,1)) = 1.0
    }

    SubShader {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        // Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
        // Tags { "Queue"="Transparent" "RenderType"="Transparent" }

        Pass {
            Tags { "LightMode" = "ForwardBase" }
            Blend One Zero
            ZWrite On
            ZTest LEqual
            // Blend SrcAlpha OneMinusSrcAlpha // Transparent
            // ZWrite Off

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag
            #include "Template.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            ZWrite Off
            ZTest LEqual
            // Blend SrcAlpha One // Transparent

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag
            #include "Template.cginc"
            ENDCG
        }

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
            #include "Template.cginc"
            ENDCG
        }
    }
}

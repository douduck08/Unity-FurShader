Shader "Custom/StandardFur" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        [Gamma] _Metallic ("Metallic", Range(0,1)) = 0.0

        _MaskTex ("Fur Mask (R)", 2D) = "white" {}
        _FurLength ("Fur Length", float) = 1.0

        _Gravity("Gravity (XYZ)", Vector) = (0,0,0,0)
        _Wind("Wind (XYZ), Speed (W)", Vector) = (0,0,0,0)
        _Occlusion ("Occlusion", Range(0,1)) = 1.0
        // [HideInInspector] _FabricScatterScale("Fabric Scatter", Range(0,10)) = 5.0
    }
    SubShader {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
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
            #include "StandardFur.cginc"
            ENDCG
        }

        Pass {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag
            #include "StandardFur.cginc"
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
            #include "StandardFur.cginc"
            ENDCG
        }
    }
}
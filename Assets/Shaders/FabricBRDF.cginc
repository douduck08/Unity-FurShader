#ifndef FABRIC_BRDF_INCLUDED
#define FABRIC_BRDF_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityStandardBRDF.cginc"

half _FabricScatterScale;

inline float FabricD (float NdotH, float roughness) { 
    return 0.96 * (1 - NdotH) * (1 - NdotH) + 0.057;
}

inline half FabricScatterFresnelLerp(half nv, half scale) {
    half t0 = Pow4 (1 - nv);
    half t1 = 0.4 * (1 - nv);
    return (t1 - t0) * scale + t0; 
}

half4 Fabric_BRDF_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, float3 normal, float3 viewDir, UnityLight light, UnityIndirect gi) {
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

    half nv = abs(dot(normal, viewDir));    // This abs allow to limit artifact
    half nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));
    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    // Diffuse term
    half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

    // Specular term
    // HACK: theoretically we should divide diffuseTerm by Pi and not multiply specularTerm!
    // BUT 1) that will make shader look significantly darker than Legacy ones
    // and 2) on engine side "Non-important" lights have to be divided by Pi too in cases when they are injected into ambient SH
    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    roughness = max(roughness, 0.002);

    half V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    float D = FabricD (nh, roughness); // original: GGXTerm (nh, roughness);
    half specularTerm = V * D * UNITY_PI; // Torrance-Sparrow model, Fresnel is applied later

    #ifdef UNITY_COLORSPACE_GAMMA
    specularTerm = sqrt(max(1e-4h, specularTerm));
    #endif

    // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
    specularTerm = max(0, specularTerm * nl);
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
    #endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
    #ifdef UNITY_COLORSPACE_GAMMA
    surfaceReduction = 1.0 - 0.28 * roughness * perceptualRoughness;  // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
    #else
    surfaceReduction = 1.0 / (roughness*roughness + 1.0);  // fade in [0.5;1]
    #endif

    // To provide true Lambert lighting, we need to be able to kill specular completely.
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color = diffColor * (gi.diffuse + light.color * diffuseTerm);
    color += specularTerm * light.color * FresnelTerm (specColor, lh);
    // color += surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
    color += surfaceReduction * gi.specular * FabricScatterFresnelLerp (specColor, _FabricScatterScale);

    return half4(color, 1);
}

#endif // FABRIC_BRDF_INCLUDED

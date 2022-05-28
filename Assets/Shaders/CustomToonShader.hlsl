#ifndef CUSTOM_TOON_INCLUDED
#define CUSTOM_TOON_INCLUDED

void MainLight_float(in float3 WorlPos, out float3 Direction, out float3 Color, out float DistanceAtten, out float ShadowAtten)
{
    #ifdef SHADERGRAPH_PREVIEW
        Direction = float3(0.5, 0.5, 0);
        Color = 1;
        DistanceAtten = 1;
        ShadowAtten = 1;
    #else
        #if SHADOWS_SCREEN
            half4 clipPos = TransformWorldToHClip(WorldPos);
            half4 shadowCoord = ComputeScreenPos(clipPos);
        #else
            float4 shadowCoord = TransformWorldToShadowCoord(WorlPos);
        #endif
        Light mainLight = GetMainLight(shadowCoord);
        Direction = mainLight.direction;
        Color = mainLight.color;
        DistanceAtten = mainLight.distanceAttenuation;
        ShadowAtten = mainLight.shadowAttenuation;
    #endif
}

void AdditionalLights_float(float3 WorlPosition, float3 WorldNormal, float3 WorldView, float MainDiffuse, float3 MainColor,
    out float Diffuse, out float3 Color)
{
    Diffuse = MainDiffuse;
    Color = MainColor;

    # ifndef SHADERGRAPH_PREVIEW
        float hightestDiffuse = Diffuse;
            
        int pixelLightCount = GetAdditionalLightsCount();
        for (int i = 0; i < pixelLightCount; i++)
        {
            Light light = GetAdditionalLight(i, WorlPosition);
            half NdotL = saturate(dot(WorldNormal, light.direction));
            half atten = light.distanceAttenuation * light.shadowAttenuation;
            half thisDiffuse = atten * NdotL;
            Diffuse += thisDiffuse;

            if (thisDiffuse > hightestDiffuse)
            {
                hightestDiffuse = thisDiffuse;
                Color = light.color;
            }
        }
    #endif
}

#endif

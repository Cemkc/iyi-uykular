#ifndef PAINTING_INCLUDED
#define PAINTING_INCLUDED

void CalcRegion_float(UnityTexture2D MainTexture, float2 lower, float2 upper, int samples, float2 UV, out float3 mean, out float varience)
{
    mean = 0;
    varience = 0;
    float3 sum = 0.0;
    float3 squareSum = 0.0;

    for (int x = lower.x; x <= upper.x; x++)
    {
        for (int y = lower.y; y <= upper.y; y++)
        {
            float2 offset = float2(MainTexture.texelSize.x * x, MainTexture.texelSize.y * y);
            float3 tex = tex2D(MainTexture, UV + offset);
            sum += tex;
            squareSum += tex * tex;
        }
    }

    mean = sum / samples;
    float3 var = abs((squareSum / samples) - (mean * mean));
    varience = length(var);    
}

#endif
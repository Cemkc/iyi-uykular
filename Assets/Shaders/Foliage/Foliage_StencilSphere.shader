Shader "Foliage_StencilSphere"
{
    Properties
    {
        [NoScaleOffset]_MainTex("MainTexture", 2D) = "white" {}
        _Color("Color", Color) = (0.4640236, 0.8867924, 0.3806515, 0)
        _Color2("Color 2", Color) = (0.1653696, 0.5471698, 0.06968673, 0)
        _Speed("Speed", Float) = 2
        _Frequency("Frequency", Float) = 8
        _Multiplier("Multiplier", Float) = 0.04
        Vector1_685522cab1ea4765a3c319f68628cef4("NoiseScale", Float) = 80
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="AlphaTest"
        }
        Stencil
        {
            Ref 2
            Comp LEqual
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 texCoord0;
            float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpacePosition;
            float3 AbsoluteWorldSpacePosition;
            float4 uv0;
            float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.color = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _Color2;
        float _Speed;
        float _Frequency;
        float _Multiplier;
        float Vector1_685522cab1ea4765a3c319f68628cef4;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float _GLOBALMaskRadius;
        float _GLOBALMaskSoftness;
        float3 _GLOBALMaskPosition;

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        // d6039bf5db3a014b8f312e0aaf341d78
        #include "Assets/Shaders/CustomToonShader.hlsl"

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_InverseLerp_float(float A, float B, float T, out float Out)
        {
            Out = (T - A)/(B - A);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void SphereMask_float3(float3 Coords, float3 Center, float Radius, float Hardness, out float3 Out)
        {
        	Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }

        struct Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9
        {
            float3 WorldSpacePosition;
        };

        void SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(float2 Vector2_860fecb99dd8469c94a157e18302757c, float Vector1_f3b0be825b4a4e8b8a1d44b19f195492, float Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc, float3 Vector3_7f8a7326d21a4081909e48f6df3882ae, float Vector1_cebde72c666944a6b6d43c95321c2f7e, Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 IN, out float3 Out_1)
        {
            float3 _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0 = Vector3_7f8a7326d21a4081909e48f6df3882ae;
            float _Property_0e27a5be77c04d78991259a37169d1ce_Out_0 = Vector1_cebde72c666944a6b6d43c95321c2f7e;
            float _Property_4baee326c6324d06bc649e8622621235_Out_0 = Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc;
            float2 _Property_070fd8affded4148b321c111773c1929_Out_0 = Vector2_860fecb99dd8469c94a157e18302757c;
            float _Property_b47c729f6b944937853171cc810eac25_Out_0 = Vector1_f3b0be825b4a4e8b8a1d44b19f195492;
            float _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2;
            Unity_SimpleNoise_float(_Property_070fd8affded4148b321c111773c1929_Out_0, _Property_b47c729f6b944937853171cc810eac25_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2);
            float _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2;
            Unity_Multiply_float(_Property_4baee326c6324d06bc649e8622621235_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2, _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2);
            float _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1;
            Unity_Saturate_float(_Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1);
            float3 _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
            SphereMask_float3(IN.WorldSpacePosition, _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0, _Property_0e27a5be77c04d78991259a37169d1ce_Out_0, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1, _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4);
            Out_1 = _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_280cab5a265f49c8ba686e78f16f16f5_Out_0 = _Multiplier;
            float _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0 = _Speed;
            float _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0, _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2);
            float _Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0 = _Frequency;
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_R_1 = IN.WorldSpacePosition[0];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2 = IN.WorldSpacePosition[1];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3 = IN.WorldSpacePosition[2];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_A_4 = 0;
            float _Add_5b202f752f2f4576a1561a64281b539b_Out_2;
            Unity_Add_float(_Split_f4c2a2cca6d141638b1f41365d3c2922_R_1, _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2, _Add_5b202f752f2f4576a1561a64281b539b_Out_2);
            float _Add_63728449eeec4ab89dd5288cf1e39837_Out_2;
            Unity_Add_float(_Add_5b202f752f2f4576a1561a64281b539b_Out_2, _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2);
            float _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2;
            Unity_Multiply_float(_Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2);
            float _Add_d0900374e5704cd3b13a1ed074db2345_Out_2;
            Unity_Add_float(_Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2, _Add_d0900374e5704cd3b13a1ed074db2345_Out_2);
            float _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1;
            Unity_Sine_float(_Add_d0900374e5704cd3b13a1ed074db2345_Out_2, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1);
            float _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2;
            Unity_Multiply_float(_Property_280cab5a265f49c8ba686e78f16f16f5_Out_0, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0 = float3(_Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2, 0, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0, _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2);
            float3 _Transform_8d8c67bca6534d548a9886302068239e_Out_1 = TransformWorldToObject(_Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2.xyz);
            description.Position = _Transform_8d8c67bca6534d548a9886302068239e_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2092c3807daf44a9b7997429f59da8b4_Out_0 = _Color;
            float4 _Property_0eafaf269dfb4a1ba4b4a3ce3d9affd4_Out_0 = _Color2;
            float3 _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Direction_1;
            float3 _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Color_2;
            float _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_DistanceAttenuation_3;
            float _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_ShadowAttenuation_4;
            MainLight_float(IN.AbsoluteWorldSpacePosition, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Direction_1, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Color_2, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_DistanceAttenuation_3, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_ShadowAttenuation_4);
            float _DotProduct_4cfc53375f13476881e0b17c100cc415_Out_2;
            Unity_DotProduct_float3(IN.WorldSpaceNormal, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Direction_1, _DotProduct_4cfc53375f13476881e0b17c100cc415_Out_2);
            float _InverseLerp_9142fdd7eb30435eb388029413b1e417_Out_3;
            Unity_InverseLerp_float(-1, 1, _DotProduct_4cfc53375f13476881e0b17c100cc415_Out_2, _InverseLerp_9142fdd7eb30435eb388029413b1e417_Out_3);
            float4 _Lerp_cbef5b84008e41d99df249f512a73559_Out_3;
            Unity_Lerp_float4(_Property_2092c3807daf44a9b7997429f59da8b4_Out_0, _Property_0eafaf269dfb4a1ba4b4a3ce3d9affd4_Out_0, (_InverseLerp_9142fdd7eb30435eb388029413b1e417_Out_3.xxxx), _Lerp_cbef5b84008e41d99df249f512a73559_Out_3);
            float4 _Multiply_b1a12c9807664a70b9df9c1325d8750c_Out_2;
            Unity_Multiply_float(_Lerp_cbef5b84008e41d99df249f512a73559_Out_3, IN.VertexColor, _Multiply_b1a12c9807664a70b9df9c1325d8750c_Out_2);
            UnityTexture2D _Property_997f94814ec34821a477acd1c62275e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0 = SAMPLE_TEXTURE2D(_Property_997f94814ec34821a477acd1c62275e8_Out_0.tex, _Property_997f94814ec34821a477acd1c62275e8_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_R_4 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.r;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.g;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_B_6 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.b;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_A_7 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.a;
            float _Split_c096579b00a04711933daf6719eeb4cf_R_1 = IN.WorldSpacePosition[0];
            float _Split_c096579b00a04711933daf6719eeb4cf_G_2 = IN.WorldSpacePosition[1];
            float _Split_c096579b00a04711933daf6719eeb4cf_B_3 = IN.WorldSpacePosition[2];
            float _Split_c096579b00a04711933daf6719eeb4cf_A_4 = 0;
            float2 _Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0 = float2(_Split_c096579b00a04711933daf6719eeb4cf_R_1, _Split_c096579b00a04711933daf6719eeb4cf_B_3);
            float _Property_3e133a2438394beaa749e7ee90470504_Out_0 = Vector1_685522cab1ea4765a3c319f68628cef4;
            float _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0 = _GLOBALMaskSoftness;
            float3 _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0 = _GLOBALMaskPosition;
            float _Property_815581c1cd164d0da0f349945dc7adbe_Out_0 = _GLOBALMaskRadius;
            Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6;
            _SphereMasking_1208f54a0da2420897e3317aad3f9aa6.WorldSpacePosition = IN.WorldSpacePosition;
            float3 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1;
            SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(_Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0, _Property_3e133a2438394beaa749e7ee90470504_Out_0, _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0, _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0, _Property_815581c1cd164d0da0f349945dc7adbe_Out_0, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1);
            float3 _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2;
            Unity_Multiply_float((_SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5.xxx), _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1, _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2);
            float _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0 = 0.5;
            surface.BaseColor = (_Multiply_b1a12c9807664a70b9df9c1325d8750c_Out_2.xyz);
            surface.Alpha = (_Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2).x;
            surface.AlphaClipThreshold = _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpacePosition =          input.positionWS;
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
            output.uv0 =                         input.texCoord0;
            output.VertexColor =                 input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _Color2;
        float _Speed;
        float _Frequency;
        float _Multiplier;
        float Vector1_685522cab1ea4765a3c319f68628cef4;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float _GLOBALMaskRadius;
        float _GLOBALMaskSoftness;
        float3 _GLOBALMaskPosition;

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void SphereMask_float3(float3 Coords, float3 Center, float Radius, float Hardness, out float3 Out)
        {
        	Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }

        struct Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9
        {
            float3 WorldSpacePosition;
        };

        void SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(float2 Vector2_860fecb99dd8469c94a157e18302757c, float Vector1_f3b0be825b4a4e8b8a1d44b19f195492, float Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc, float3 Vector3_7f8a7326d21a4081909e48f6df3882ae, float Vector1_cebde72c666944a6b6d43c95321c2f7e, Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 IN, out float3 Out_1)
        {
            float3 _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0 = Vector3_7f8a7326d21a4081909e48f6df3882ae;
            float _Property_0e27a5be77c04d78991259a37169d1ce_Out_0 = Vector1_cebde72c666944a6b6d43c95321c2f7e;
            float _Property_4baee326c6324d06bc649e8622621235_Out_0 = Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc;
            float2 _Property_070fd8affded4148b321c111773c1929_Out_0 = Vector2_860fecb99dd8469c94a157e18302757c;
            float _Property_b47c729f6b944937853171cc810eac25_Out_0 = Vector1_f3b0be825b4a4e8b8a1d44b19f195492;
            float _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2;
            Unity_SimpleNoise_float(_Property_070fd8affded4148b321c111773c1929_Out_0, _Property_b47c729f6b944937853171cc810eac25_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2);
            float _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2;
            Unity_Multiply_float(_Property_4baee326c6324d06bc649e8622621235_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2, _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2);
            float _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1;
            Unity_Saturate_float(_Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1);
            float3 _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
            SphereMask_float3(IN.WorldSpacePosition, _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0, _Property_0e27a5be77c04d78991259a37169d1ce_Out_0, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1, _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4);
            Out_1 = _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_280cab5a265f49c8ba686e78f16f16f5_Out_0 = _Multiplier;
            float _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0 = _Speed;
            float _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0, _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2);
            float _Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0 = _Frequency;
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_R_1 = IN.WorldSpacePosition[0];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2 = IN.WorldSpacePosition[1];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3 = IN.WorldSpacePosition[2];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_A_4 = 0;
            float _Add_5b202f752f2f4576a1561a64281b539b_Out_2;
            Unity_Add_float(_Split_f4c2a2cca6d141638b1f41365d3c2922_R_1, _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2, _Add_5b202f752f2f4576a1561a64281b539b_Out_2);
            float _Add_63728449eeec4ab89dd5288cf1e39837_Out_2;
            Unity_Add_float(_Add_5b202f752f2f4576a1561a64281b539b_Out_2, _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2);
            float _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2;
            Unity_Multiply_float(_Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2);
            float _Add_d0900374e5704cd3b13a1ed074db2345_Out_2;
            Unity_Add_float(_Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2, _Add_d0900374e5704cd3b13a1ed074db2345_Out_2);
            float _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1;
            Unity_Sine_float(_Add_d0900374e5704cd3b13a1ed074db2345_Out_2, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1);
            float _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2;
            Unity_Multiply_float(_Property_280cab5a265f49c8ba686e78f16f16f5_Out_0, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0 = float3(_Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2, 0, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0, _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2);
            float3 _Transform_8d8c67bca6534d548a9886302068239e_Out_1 = TransformWorldToObject(_Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2.xyz);
            description.Position = _Transform_8d8c67bca6534d548a9886302068239e_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_997f94814ec34821a477acd1c62275e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0 = SAMPLE_TEXTURE2D(_Property_997f94814ec34821a477acd1c62275e8_Out_0.tex, _Property_997f94814ec34821a477acd1c62275e8_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_R_4 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.r;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.g;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_B_6 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.b;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_A_7 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.a;
            float _Split_c096579b00a04711933daf6719eeb4cf_R_1 = IN.WorldSpacePosition[0];
            float _Split_c096579b00a04711933daf6719eeb4cf_G_2 = IN.WorldSpacePosition[1];
            float _Split_c096579b00a04711933daf6719eeb4cf_B_3 = IN.WorldSpacePosition[2];
            float _Split_c096579b00a04711933daf6719eeb4cf_A_4 = 0;
            float2 _Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0 = float2(_Split_c096579b00a04711933daf6719eeb4cf_R_1, _Split_c096579b00a04711933daf6719eeb4cf_B_3);
            float _Property_3e133a2438394beaa749e7ee90470504_Out_0 = Vector1_685522cab1ea4765a3c319f68628cef4;
            float _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0 = _GLOBALMaskSoftness;
            float3 _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0 = _GLOBALMaskPosition;
            float _Property_815581c1cd164d0da0f349945dc7adbe_Out_0 = _GLOBALMaskRadius;
            Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6;
            _SphereMasking_1208f54a0da2420897e3317aad3f9aa6.WorldSpacePosition = IN.WorldSpacePosition;
            float3 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1;
            SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(_Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0, _Property_3e133a2438394beaa749e7ee90470504_Out_0, _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0, _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0, _Property_815581c1cd164d0da0f349945dc7adbe_Out_0, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1);
            float3 _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2;
            Unity_Multiply_float((_SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5.xxx), _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1, _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2);
            float _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0 = 0.5;
            surface.Alpha = (_Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2).x;
            surface.AlphaClipThreshold = _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _Color2;
        float _Speed;
        float _Frequency;
        float _Multiplier;
        float Vector1_685522cab1ea4765a3c319f68628cef4;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float _GLOBALMaskRadius;
        float _GLOBALMaskSoftness;
        float3 _GLOBALMaskPosition;

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void SphereMask_float3(float3 Coords, float3 Center, float Radius, float Hardness, out float3 Out)
        {
        	Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }

        struct Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9
        {
            float3 WorldSpacePosition;
        };

        void SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(float2 Vector2_860fecb99dd8469c94a157e18302757c, float Vector1_f3b0be825b4a4e8b8a1d44b19f195492, float Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc, float3 Vector3_7f8a7326d21a4081909e48f6df3882ae, float Vector1_cebde72c666944a6b6d43c95321c2f7e, Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 IN, out float3 Out_1)
        {
            float3 _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0 = Vector3_7f8a7326d21a4081909e48f6df3882ae;
            float _Property_0e27a5be77c04d78991259a37169d1ce_Out_0 = Vector1_cebde72c666944a6b6d43c95321c2f7e;
            float _Property_4baee326c6324d06bc649e8622621235_Out_0 = Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc;
            float2 _Property_070fd8affded4148b321c111773c1929_Out_0 = Vector2_860fecb99dd8469c94a157e18302757c;
            float _Property_b47c729f6b944937853171cc810eac25_Out_0 = Vector1_f3b0be825b4a4e8b8a1d44b19f195492;
            float _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2;
            Unity_SimpleNoise_float(_Property_070fd8affded4148b321c111773c1929_Out_0, _Property_b47c729f6b944937853171cc810eac25_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2);
            float _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2;
            Unity_Multiply_float(_Property_4baee326c6324d06bc649e8622621235_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2, _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2);
            float _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1;
            Unity_Saturate_float(_Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1);
            float3 _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
            SphereMask_float3(IN.WorldSpacePosition, _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0, _Property_0e27a5be77c04d78991259a37169d1ce_Out_0, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1, _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4);
            Out_1 = _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_280cab5a265f49c8ba686e78f16f16f5_Out_0 = _Multiplier;
            float _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0 = _Speed;
            float _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0, _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2);
            float _Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0 = _Frequency;
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_R_1 = IN.WorldSpacePosition[0];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2 = IN.WorldSpacePosition[1];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3 = IN.WorldSpacePosition[2];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_A_4 = 0;
            float _Add_5b202f752f2f4576a1561a64281b539b_Out_2;
            Unity_Add_float(_Split_f4c2a2cca6d141638b1f41365d3c2922_R_1, _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2, _Add_5b202f752f2f4576a1561a64281b539b_Out_2);
            float _Add_63728449eeec4ab89dd5288cf1e39837_Out_2;
            Unity_Add_float(_Add_5b202f752f2f4576a1561a64281b539b_Out_2, _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2);
            float _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2;
            Unity_Multiply_float(_Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2);
            float _Add_d0900374e5704cd3b13a1ed074db2345_Out_2;
            Unity_Add_float(_Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2, _Add_d0900374e5704cd3b13a1ed074db2345_Out_2);
            float _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1;
            Unity_Sine_float(_Add_d0900374e5704cd3b13a1ed074db2345_Out_2, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1);
            float _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2;
            Unity_Multiply_float(_Property_280cab5a265f49c8ba686e78f16f16f5_Out_0, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0 = float3(_Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2, 0, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0, _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2);
            float3 _Transform_8d8c67bca6534d548a9886302068239e_Out_1 = TransformWorldToObject(_Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2.xyz);
            description.Position = _Transform_8d8c67bca6534d548a9886302068239e_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_997f94814ec34821a477acd1c62275e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0 = SAMPLE_TEXTURE2D(_Property_997f94814ec34821a477acd1c62275e8_Out_0.tex, _Property_997f94814ec34821a477acd1c62275e8_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_R_4 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.r;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.g;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_B_6 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.b;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_A_7 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.a;
            float _Split_c096579b00a04711933daf6719eeb4cf_R_1 = IN.WorldSpacePosition[0];
            float _Split_c096579b00a04711933daf6719eeb4cf_G_2 = IN.WorldSpacePosition[1];
            float _Split_c096579b00a04711933daf6719eeb4cf_B_3 = IN.WorldSpacePosition[2];
            float _Split_c096579b00a04711933daf6719eeb4cf_A_4 = 0;
            float2 _Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0 = float2(_Split_c096579b00a04711933daf6719eeb4cf_R_1, _Split_c096579b00a04711933daf6719eeb4cf_B_3);
            float _Property_3e133a2438394beaa749e7ee90470504_Out_0 = Vector1_685522cab1ea4765a3c319f68628cef4;
            float _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0 = _GLOBALMaskSoftness;
            float3 _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0 = _GLOBALMaskPosition;
            float _Property_815581c1cd164d0da0f349945dc7adbe_Out_0 = _GLOBALMaskRadius;
            Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6;
            _SphereMasking_1208f54a0da2420897e3317aad3f9aa6.WorldSpacePosition = IN.WorldSpacePosition;
            float3 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1;
            SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(_Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0, _Property_3e133a2438394beaa749e7ee90470504_Out_0, _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0, _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0, _Property_815581c1cd164d0da0f349945dc7adbe_Out_0, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1);
            float3 _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2;
            Unity_Multiply_float((_SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5.xxx), _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1, _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2);
            float _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0 = 0.5;
            surface.Alpha = (_Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2).x;
            surface.AlphaClipThreshold = _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="AlphaTest"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 texCoord0;
            float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpacePosition;
            float3 AbsoluteWorldSpacePosition;
            float4 uv0;
            float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.color;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.color = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _Color2;
        float _Speed;
        float _Frequency;
        float _Multiplier;
        float Vector1_685522cab1ea4765a3c319f68628cef4;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float _GLOBALMaskRadius;
        float _GLOBALMaskSoftness;
        float3 _GLOBALMaskPosition;

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        // d6039bf5db3a014b8f312e0aaf341d78
        #include "Assets/Shaders/CustomToonShader.hlsl"

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_InverseLerp_float(float A, float B, float T, out float Out)
        {
            Out = (T - A)/(B - A);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void SphereMask_float3(float3 Coords, float3 Center, float Radius, float Hardness, out float3 Out)
        {
        	Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }

        struct Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9
        {
            float3 WorldSpacePosition;
        };

        void SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(float2 Vector2_860fecb99dd8469c94a157e18302757c, float Vector1_f3b0be825b4a4e8b8a1d44b19f195492, float Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc, float3 Vector3_7f8a7326d21a4081909e48f6df3882ae, float Vector1_cebde72c666944a6b6d43c95321c2f7e, Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 IN, out float3 Out_1)
        {
            float3 _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0 = Vector3_7f8a7326d21a4081909e48f6df3882ae;
            float _Property_0e27a5be77c04d78991259a37169d1ce_Out_0 = Vector1_cebde72c666944a6b6d43c95321c2f7e;
            float _Property_4baee326c6324d06bc649e8622621235_Out_0 = Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc;
            float2 _Property_070fd8affded4148b321c111773c1929_Out_0 = Vector2_860fecb99dd8469c94a157e18302757c;
            float _Property_b47c729f6b944937853171cc810eac25_Out_0 = Vector1_f3b0be825b4a4e8b8a1d44b19f195492;
            float _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2;
            Unity_SimpleNoise_float(_Property_070fd8affded4148b321c111773c1929_Out_0, _Property_b47c729f6b944937853171cc810eac25_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2);
            float _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2;
            Unity_Multiply_float(_Property_4baee326c6324d06bc649e8622621235_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2, _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2);
            float _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1;
            Unity_Saturate_float(_Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1);
            float3 _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
            SphereMask_float3(IN.WorldSpacePosition, _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0, _Property_0e27a5be77c04d78991259a37169d1ce_Out_0, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1, _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4);
            Out_1 = _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_280cab5a265f49c8ba686e78f16f16f5_Out_0 = _Multiplier;
            float _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0 = _Speed;
            float _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0, _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2);
            float _Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0 = _Frequency;
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_R_1 = IN.WorldSpacePosition[0];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2 = IN.WorldSpacePosition[1];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3 = IN.WorldSpacePosition[2];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_A_4 = 0;
            float _Add_5b202f752f2f4576a1561a64281b539b_Out_2;
            Unity_Add_float(_Split_f4c2a2cca6d141638b1f41365d3c2922_R_1, _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2, _Add_5b202f752f2f4576a1561a64281b539b_Out_2);
            float _Add_63728449eeec4ab89dd5288cf1e39837_Out_2;
            Unity_Add_float(_Add_5b202f752f2f4576a1561a64281b539b_Out_2, _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2);
            float _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2;
            Unity_Multiply_float(_Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2);
            float _Add_d0900374e5704cd3b13a1ed074db2345_Out_2;
            Unity_Add_float(_Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2, _Add_d0900374e5704cd3b13a1ed074db2345_Out_2);
            float _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1;
            Unity_Sine_float(_Add_d0900374e5704cd3b13a1ed074db2345_Out_2, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1);
            float _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2;
            Unity_Multiply_float(_Property_280cab5a265f49c8ba686e78f16f16f5_Out_0, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0 = float3(_Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2, 0, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0, _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2);
            float3 _Transform_8d8c67bca6534d548a9886302068239e_Out_1 = TransformWorldToObject(_Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2.xyz);
            description.Position = _Transform_8d8c67bca6534d548a9886302068239e_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2092c3807daf44a9b7997429f59da8b4_Out_0 = _Color;
            float4 _Property_0eafaf269dfb4a1ba4b4a3ce3d9affd4_Out_0 = _Color2;
            float3 _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Direction_1;
            float3 _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Color_2;
            float _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_DistanceAttenuation_3;
            float _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_ShadowAttenuation_4;
            MainLight_float(IN.AbsoluteWorldSpacePosition, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Direction_1, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Color_2, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_DistanceAttenuation_3, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_ShadowAttenuation_4);
            float _DotProduct_4cfc53375f13476881e0b17c100cc415_Out_2;
            Unity_DotProduct_float3(IN.WorldSpaceNormal, _MainLightCustomFunction_dcf7735c0a454c5bbca4cf3b82693f19_Direction_1, _DotProduct_4cfc53375f13476881e0b17c100cc415_Out_2);
            float _InverseLerp_9142fdd7eb30435eb388029413b1e417_Out_3;
            Unity_InverseLerp_float(-1, 1, _DotProduct_4cfc53375f13476881e0b17c100cc415_Out_2, _InverseLerp_9142fdd7eb30435eb388029413b1e417_Out_3);
            float4 _Lerp_cbef5b84008e41d99df249f512a73559_Out_3;
            Unity_Lerp_float4(_Property_2092c3807daf44a9b7997429f59da8b4_Out_0, _Property_0eafaf269dfb4a1ba4b4a3ce3d9affd4_Out_0, (_InverseLerp_9142fdd7eb30435eb388029413b1e417_Out_3.xxxx), _Lerp_cbef5b84008e41d99df249f512a73559_Out_3);
            float4 _Multiply_b1a12c9807664a70b9df9c1325d8750c_Out_2;
            Unity_Multiply_float(_Lerp_cbef5b84008e41d99df249f512a73559_Out_3, IN.VertexColor, _Multiply_b1a12c9807664a70b9df9c1325d8750c_Out_2);
            UnityTexture2D _Property_997f94814ec34821a477acd1c62275e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0 = SAMPLE_TEXTURE2D(_Property_997f94814ec34821a477acd1c62275e8_Out_0.tex, _Property_997f94814ec34821a477acd1c62275e8_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_R_4 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.r;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.g;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_B_6 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.b;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_A_7 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.a;
            float _Split_c096579b00a04711933daf6719eeb4cf_R_1 = IN.WorldSpacePosition[0];
            float _Split_c096579b00a04711933daf6719eeb4cf_G_2 = IN.WorldSpacePosition[1];
            float _Split_c096579b00a04711933daf6719eeb4cf_B_3 = IN.WorldSpacePosition[2];
            float _Split_c096579b00a04711933daf6719eeb4cf_A_4 = 0;
            float2 _Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0 = float2(_Split_c096579b00a04711933daf6719eeb4cf_R_1, _Split_c096579b00a04711933daf6719eeb4cf_B_3);
            float _Property_3e133a2438394beaa749e7ee90470504_Out_0 = Vector1_685522cab1ea4765a3c319f68628cef4;
            float _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0 = _GLOBALMaskSoftness;
            float3 _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0 = _GLOBALMaskPosition;
            float _Property_815581c1cd164d0da0f349945dc7adbe_Out_0 = _GLOBALMaskRadius;
            Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6;
            _SphereMasking_1208f54a0da2420897e3317aad3f9aa6.WorldSpacePosition = IN.WorldSpacePosition;
            float3 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1;
            SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(_Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0, _Property_3e133a2438394beaa749e7ee90470504_Out_0, _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0, _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0, _Property_815581c1cd164d0da0f349945dc7adbe_Out_0, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1);
            float3 _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2;
            Unity_Multiply_float((_SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5.xxx), _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1, _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2);
            float _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0 = 0.5;
            surface.BaseColor = (_Multiply_b1a12c9807664a70b9df9c1325d8750c_Out_2.xyz);
            surface.Alpha = (_Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2).x;
            surface.AlphaClipThreshold = _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpacePosition =          input.positionWS;
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
            output.uv0 =                         input.texCoord0;
            output.VertexColor =                 input.color;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _Color2;
        float _Speed;
        float _Frequency;
        float _Multiplier;
        float Vector1_685522cab1ea4765a3c319f68628cef4;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float _GLOBALMaskRadius;
        float _GLOBALMaskSoftness;
        float3 _GLOBALMaskPosition;

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void SphereMask_float3(float3 Coords, float3 Center, float Radius, float Hardness, out float3 Out)
        {
        	Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }

        struct Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9
        {
            float3 WorldSpacePosition;
        };

        void SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(float2 Vector2_860fecb99dd8469c94a157e18302757c, float Vector1_f3b0be825b4a4e8b8a1d44b19f195492, float Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc, float3 Vector3_7f8a7326d21a4081909e48f6df3882ae, float Vector1_cebde72c666944a6b6d43c95321c2f7e, Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 IN, out float3 Out_1)
        {
            float3 _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0 = Vector3_7f8a7326d21a4081909e48f6df3882ae;
            float _Property_0e27a5be77c04d78991259a37169d1ce_Out_0 = Vector1_cebde72c666944a6b6d43c95321c2f7e;
            float _Property_4baee326c6324d06bc649e8622621235_Out_0 = Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc;
            float2 _Property_070fd8affded4148b321c111773c1929_Out_0 = Vector2_860fecb99dd8469c94a157e18302757c;
            float _Property_b47c729f6b944937853171cc810eac25_Out_0 = Vector1_f3b0be825b4a4e8b8a1d44b19f195492;
            float _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2;
            Unity_SimpleNoise_float(_Property_070fd8affded4148b321c111773c1929_Out_0, _Property_b47c729f6b944937853171cc810eac25_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2);
            float _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2;
            Unity_Multiply_float(_Property_4baee326c6324d06bc649e8622621235_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2, _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2);
            float _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1;
            Unity_Saturate_float(_Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1);
            float3 _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
            SphereMask_float3(IN.WorldSpacePosition, _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0, _Property_0e27a5be77c04d78991259a37169d1ce_Out_0, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1, _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4);
            Out_1 = _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_280cab5a265f49c8ba686e78f16f16f5_Out_0 = _Multiplier;
            float _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0 = _Speed;
            float _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0, _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2);
            float _Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0 = _Frequency;
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_R_1 = IN.WorldSpacePosition[0];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2 = IN.WorldSpacePosition[1];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3 = IN.WorldSpacePosition[2];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_A_4 = 0;
            float _Add_5b202f752f2f4576a1561a64281b539b_Out_2;
            Unity_Add_float(_Split_f4c2a2cca6d141638b1f41365d3c2922_R_1, _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2, _Add_5b202f752f2f4576a1561a64281b539b_Out_2);
            float _Add_63728449eeec4ab89dd5288cf1e39837_Out_2;
            Unity_Add_float(_Add_5b202f752f2f4576a1561a64281b539b_Out_2, _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2);
            float _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2;
            Unity_Multiply_float(_Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2);
            float _Add_d0900374e5704cd3b13a1ed074db2345_Out_2;
            Unity_Add_float(_Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2, _Add_d0900374e5704cd3b13a1ed074db2345_Out_2);
            float _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1;
            Unity_Sine_float(_Add_d0900374e5704cd3b13a1ed074db2345_Out_2, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1);
            float _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2;
            Unity_Multiply_float(_Property_280cab5a265f49c8ba686e78f16f16f5_Out_0, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0 = float3(_Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2, 0, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0, _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2);
            float3 _Transform_8d8c67bca6534d548a9886302068239e_Out_1 = TransformWorldToObject(_Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2.xyz);
            description.Position = _Transform_8d8c67bca6534d548a9886302068239e_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_997f94814ec34821a477acd1c62275e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0 = SAMPLE_TEXTURE2D(_Property_997f94814ec34821a477acd1c62275e8_Out_0.tex, _Property_997f94814ec34821a477acd1c62275e8_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_R_4 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.r;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.g;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_B_6 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.b;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_A_7 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.a;
            float _Split_c096579b00a04711933daf6719eeb4cf_R_1 = IN.WorldSpacePosition[0];
            float _Split_c096579b00a04711933daf6719eeb4cf_G_2 = IN.WorldSpacePosition[1];
            float _Split_c096579b00a04711933daf6719eeb4cf_B_3 = IN.WorldSpacePosition[2];
            float _Split_c096579b00a04711933daf6719eeb4cf_A_4 = 0;
            float2 _Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0 = float2(_Split_c096579b00a04711933daf6719eeb4cf_R_1, _Split_c096579b00a04711933daf6719eeb4cf_B_3);
            float _Property_3e133a2438394beaa749e7ee90470504_Out_0 = Vector1_685522cab1ea4765a3c319f68628cef4;
            float _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0 = _GLOBALMaskSoftness;
            float3 _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0 = _GLOBALMaskPosition;
            float _Property_815581c1cd164d0da0f349945dc7adbe_Out_0 = _GLOBALMaskRadius;
            Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6;
            _SphereMasking_1208f54a0da2420897e3317aad3f9aa6.WorldSpacePosition = IN.WorldSpacePosition;
            float3 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1;
            SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(_Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0, _Property_3e133a2438394beaa749e7ee90470504_Out_0, _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0, _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0, _Property_815581c1cd164d0da0f349945dc7adbe_Out_0, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1);
            float3 _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2;
            Unity_Multiply_float((_SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5.xxx), _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1, _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2);
            float _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0 = 0.5;
            surface.Alpha = (_Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2).x;
            surface.AlphaClipThreshold = _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _Color2;
        float _Speed;
        float _Frequency;
        float _Multiplier;
        float Vector1_685522cab1ea4765a3c319f68628cef4;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float _GLOBALMaskRadius;
        float _GLOBALMaskSoftness;
        float3 _GLOBALMaskPosition;

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }


        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }

        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void SphereMask_float3(float3 Coords, float3 Center, float Radius, float Hardness, out float3 Out)
        {
        	Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }

        struct Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9
        {
            float3 WorldSpacePosition;
        };

        void SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(float2 Vector2_860fecb99dd8469c94a157e18302757c, float Vector1_f3b0be825b4a4e8b8a1d44b19f195492, float Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc, float3 Vector3_7f8a7326d21a4081909e48f6df3882ae, float Vector1_cebde72c666944a6b6d43c95321c2f7e, Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 IN, out float3 Out_1)
        {
            float3 _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0 = Vector3_7f8a7326d21a4081909e48f6df3882ae;
            float _Property_0e27a5be77c04d78991259a37169d1ce_Out_0 = Vector1_cebde72c666944a6b6d43c95321c2f7e;
            float _Property_4baee326c6324d06bc649e8622621235_Out_0 = Vector1_95f0d7d366c04eb7b17fc3c05b9c1ebc;
            float2 _Property_070fd8affded4148b321c111773c1929_Out_0 = Vector2_860fecb99dd8469c94a157e18302757c;
            float _Property_b47c729f6b944937853171cc810eac25_Out_0 = Vector1_f3b0be825b4a4e8b8a1d44b19f195492;
            float _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2;
            Unity_SimpleNoise_float(_Property_070fd8affded4148b321c111773c1929_Out_0, _Property_b47c729f6b944937853171cc810eac25_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2);
            float _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2;
            Unity_Multiply_float(_Property_4baee326c6324d06bc649e8622621235_Out_0, _SimpleNoise_e2e18fa6a94b49cb97fe60ba91571282_Out_2, _Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2);
            float _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1;
            Unity_Saturate_float(_Multiply_1c4d00fb4ff8477da8cc2cc82b231e5d_Out_2, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1);
            float3 _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
            SphereMask_float3(IN.WorldSpacePosition, _Property_034565ade5f140f0bbe236aaefa34dd5_Out_0, _Property_0e27a5be77c04d78991259a37169d1ce_Out_0, _Saturate_a427185b93e045cfbeafa529dd4f6320_Out_1, _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4);
            Out_1 = _SphereMask_16b909956bbd46b1979a659ade0580f3_Out_4;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_280cab5a265f49c8ba686e78f16f16f5_Out_0 = _Multiplier;
            float _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0 = _Speed;
            float _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_4ef7d1f4ebf145bbb82db6ea3f1ade0b_Out_0, _Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2);
            float _Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0 = _Frequency;
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_R_1 = IN.WorldSpacePosition[0];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2 = IN.WorldSpacePosition[1];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3 = IN.WorldSpacePosition[2];
            float _Split_f4c2a2cca6d141638b1f41365d3c2922_A_4 = 0;
            float _Add_5b202f752f2f4576a1561a64281b539b_Out_2;
            Unity_Add_float(_Split_f4c2a2cca6d141638b1f41365d3c2922_R_1, _Split_f4c2a2cca6d141638b1f41365d3c2922_G_2, _Add_5b202f752f2f4576a1561a64281b539b_Out_2);
            float _Add_63728449eeec4ab89dd5288cf1e39837_Out_2;
            Unity_Add_float(_Add_5b202f752f2f4576a1561a64281b539b_Out_2, _Split_f4c2a2cca6d141638b1f41365d3c2922_B_3, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2);
            float _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2;
            Unity_Multiply_float(_Property_e8ec641eeaaf4f19ba733baab7b23da1_Out_0, _Add_63728449eeec4ab89dd5288cf1e39837_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2);
            float _Add_d0900374e5704cd3b13a1ed074db2345_Out_2;
            Unity_Add_float(_Multiply_b7977ae3d7b449a5b61d3b5586279941_Out_2, _Multiply_02c22d9e6bbf4d77a6d14bf6358a89a7_Out_2, _Add_d0900374e5704cd3b13a1ed074db2345_Out_2);
            float _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1;
            Unity_Sine_float(_Add_d0900374e5704cd3b13a1ed074db2345_Out_2, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1);
            float _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2;
            Unity_Multiply_float(_Property_280cab5a265f49c8ba686e78f16f16f5_Out_0, _Sine_5bae3649bbc74e0f8085ca6b61c2018b_Out_1, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0 = float3(_Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2, 0, _Multiply_6be5f09a58d84c3f8447068cc8e8353f_Out_2);
            float3 _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, _Vector3_4d1ae79da89b494eb0177867ecc1af0e_Out_0, _Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2);
            float3 _Transform_8d8c67bca6534d548a9886302068239e_Out_1 = TransformWorldToObject(_Add_5232a8a5b7aa4ebf9f9ccbad714c1119_Out_2.xyz);
            description.Position = _Transform_8d8c67bca6534d548a9886302068239e_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_997f94814ec34821a477acd1c62275e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0 = SAMPLE_TEXTURE2D(_Property_997f94814ec34821a477acd1c62275e8_Out_0.tex, _Property_997f94814ec34821a477acd1c62275e8_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_R_4 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.r;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.g;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_B_6 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.b;
            float _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_A_7 = _SampleTexture2D_f20c2140e02a47309f9a41553a7df644_RGBA_0.a;
            float _Split_c096579b00a04711933daf6719eeb4cf_R_1 = IN.WorldSpacePosition[0];
            float _Split_c096579b00a04711933daf6719eeb4cf_G_2 = IN.WorldSpacePosition[1];
            float _Split_c096579b00a04711933daf6719eeb4cf_B_3 = IN.WorldSpacePosition[2];
            float _Split_c096579b00a04711933daf6719eeb4cf_A_4 = 0;
            float2 _Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0 = float2(_Split_c096579b00a04711933daf6719eeb4cf_R_1, _Split_c096579b00a04711933daf6719eeb4cf_B_3);
            float _Property_3e133a2438394beaa749e7ee90470504_Out_0 = Vector1_685522cab1ea4765a3c319f68628cef4;
            float _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0 = _GLOBALMaskSoftness;
            float3 _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0 = _GLOBALMaskPosition;
            float _Property_815581c1cd164d0da0f349945dc7adbe_Out_0 = _GLOBALMaskRadius;
            Bindings_SphereMasking_98123e9cb74f368499e8942b46d4a2e9 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6;
            _SphereMasking_1208f54a0da2420897e3317aad3f9aa6.WorldSpacePosition = IN.WorldSpacePosition;
            float3 _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1;
            SG_SphereMasking_98123e9cb74f368499e8942b46d4a2e9(_Vector2_33d853815d9a4ebf94bf79b43da1467d_Out_0, _Property_3e133a2438394beaa749e7ee90470504_Out_0, _Property_cfc2bf1c418347b4b585a23345bc0d53_Out_0, _Property_f8e31367ac0149da9f99e990e4dd6af8_Out_0, _Property_815581c1cd164d0da0f349945dc7adbe_Out_0, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6, _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1);
            float3 _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2;
            Unity_Multiply_float((_SampleTexture2D_f20c2140e02a47309f9a41553a7df644_G_5.xxx), _SphereMasking_1208f54a0da2420897e3317aad3f9aa6_Out_1, _Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2);
            float _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0 = 0.5;
            surface.Alpha = (_Multiply_64a57ec2ab444b95b64ddcd75b4b7280_Out_2).x;
            surface.AlphaClipThreshold = _Float_de7ad7e24ded4222a1bcb9ab65ddf3d1_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}
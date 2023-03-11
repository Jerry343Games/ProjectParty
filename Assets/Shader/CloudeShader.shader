Shader "Cloud"
{
    Properties
    {
        _Rotate_Property("Rotate Property", Vector) = (1, 0, 0, 0)
        _Noise_Scale("Noise Scale", Float) = -29.6
        _Speed("Speed", Float) = 0.1
        _Cloud_Height("Cloud Height", Float) = 0
        _In_Min_Max("In Min Max", Vector) = (0, 1, 0, 0)
        _Out_Min_Max("Out Min Max", Vector) = (-1, 1, 0, 0)
        _Top_Color("Top Color", Color) = (1, 1, 1, 0)
        _Bottom_Color("Bottom Color", Color) = (0.6156462, 0.764151, 0.7559535, 0)
        _Smooth("Smooth", Vector) = (0, 1, 0, 0)
        _Power("Power", Float) = 1
        _BaseNoise_Scale("BaseNoise Scale", Float) = 5
        _BaseNoise_Speed("BaseNoise Speed", Float) = 0.5
        _BaseNoise_Strength("BaseNoise Strength", Float) = 1
        _Emission("Emission", Float) = 0.71
        _Fresnel_Power("Fresnel Power", Float) = 1.54
        _Fresnel_Opacity("Fresnel Opacity", Float) = 2.77
        _Density("Density", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
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
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
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

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz = input.sh;
            #endif
            output.interp7.xyzw = input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw = input.shadowCoord;
            #endif
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

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
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
        float4 _Rotate_Property;
        float _Noise_Scale;
        float _Speed;
        float _Cloud_Height;
        float2 _In_Min_Max;
        float2 _Out_Min_Max;
        float4 _Top_Color;
        float4 _Bottom_Color;
        float2 _Smooth;
        float _Power;
        float _BaseNoise_Scale;
        float _BaseNoise_Speed;
        float _BaseNoise_Strength;
        float _Emission;
        float _Fresnel_Power;
        float _Fresnel_Opacity;
        float _Density;
        CBUFFER_END

            // Object and Global properties

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif

        // Graph Functions

        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);

            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;

            Axis = normalize(Axis);

            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
            float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
            float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
            float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
            float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
            float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
            float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
            float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
            float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
            float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
            float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
            Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
            float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
            float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
            float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
            float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
            float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
            float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
            Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
            float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
            Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
            float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
            float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
            Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
            float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
            float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
            float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
            Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
            float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
            Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
            float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
            Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
            float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
            float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
            float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
            float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
            float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
            float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
            float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
            Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
            float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
            Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
            float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
            Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
            float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
            Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
            float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
            float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
            float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
            Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
            float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
            description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0 = _Bottom_Color;
            float4 _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0 = _Top_Color;
            float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
            float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
            float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
            float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
            float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
            float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
            float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
            float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
            float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
            float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
            Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
            float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
            float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
            float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
            float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
            float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
            float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
            Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
            float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
            Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
            float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
            float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
            Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
            float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
            float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
            float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
            Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
            float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
            Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
            float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
            Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
            float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
            float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
            float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
            float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
            float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
            float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
            float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
            Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
            float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
            Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
            float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
            Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
            float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
            Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
            float4 _Lerp_16f9701748ff4980936cc58aa19de661_Out_3;
            Unity_Lerp_float4(_Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0, _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxxx), _Lerp_16f9701748ff4980936cc58aa19de661_Out_3);
            float _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0 = _Fresnel_Power;
            float _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3);
            float _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2;
            Unity_Multiply_float_float(_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3, _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2);
            float _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0 = _Fresnel_Opacity;
            float _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2;
            Unity_Multiply_float_float(_Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2, _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0, _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2);
            float4 _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2;
            Unity_Add_float4(_Lerp_16f9701748ff4980936cc58aa19de661_Out_3, (_Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2.xxxx), _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2);
            float _Property_c362b4b09f5f401e9a18414784876557_Out_0 = _Emission;
            float4 _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2;
            Unity_Multiply_float4_float4(_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2, (_Property_c362b4b09f5f401e9a18414784876557_Out_0.xxxx), _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2);
            float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
            float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
            float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
            float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
            float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
            float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
            float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
            Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
            float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
            Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
            float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
            float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
            Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
            surface.BaseColor = (_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal = input.normalOS;
            output.ObjectSpaceTangent = input.tangentOS.xyz;
            output.ObjectSpacePosition = input.positionOS;
            output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
            output.TimeParameters = _TimeParameters.xyz;

            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

        #endif



            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif

        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off

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
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>

            // Defines

            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SHADOW_COORD
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
            #define _FOG_FRAGMENT 1
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv1 : TEXCOORD1;
                 float4 uv2 : TEXCOORD2;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 tangentWS;
                 float3 viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                 float2 staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                 float2 dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                 float3 sh;
                #endif
                 float4 fogFactorAndVertexLight;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                 float4 shadowCoord;
                #endif
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
                 float3 TangentSpaceNormal;
                 float3 WorldSpaceViewDirection;
                 float3 WorldSpacePosition;
                 float4 ScreenPosition;
                 float3 TimeParameters;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
                 float3 WorldSpacePosition;
                 float3 TimeParameters;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float3 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                 float3 interp3 : INTERP3;
                 float2 interp4 : INTERP4;
                 float2 interp5 : INTERP5;
                 float3 interp6 : INTERP6;
                 float4 interp7 : INTERP7;
                 float4 interp8 : INTERP8;
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

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz = input.positionWS;
                output.interp1.xyz = input.normalWS;
                output.interp2.xyzw = input.tangentWS;
                output.interp3.xyz = input.viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                output.interp4.xy = input.staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                output.interp5.xy = input.dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp6.xyz = input.sh;
                #endif
                output.interp7.xyzw = input.fogFactorAndVertexLight;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                output.interp8.xyzw = input.shadowCoord;
                #endif
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

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.tangentWS = input.interp2.xyzw;
                output.viewDirectionWS = input.interp3.xyz;
                #if defined(LIGHTMAP_ON)
                output.staticLightmapUV = input.interp4.xy;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                output.dynamicLightmapUV = input.interp5.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp6.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp7.xyzw;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                output.shadowCoord = input.interp8.xyzw;
                #endif
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
            float4 _Rotate_Property;
            float _Noise_Scale;
            float _Speed;
            float _Cloud_Height;
            float2 _In_Min_Max;
            float2 _Out_Min_Max;
            float4 _Top_Color;
            float4 _Bottom_Color;
            float2 _Smooth;
            float _Power;
            float _BaseNoise_Scale;
            float _BaseNoise_Speed;
            float _BaseNoise_Strength;
            float _Emission;
            float _Fresnel_Power;
            float _Fresnel_Opacity;
            float _Density;
            CBUFFER_END

                // Object and Global properties

                // Graph Includes
                // GraphIncludes: <None>

                // -- Property used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
            {
                Rotation = radians(Rotation);

                float s = sin(Rotation);
                float c = cos(Rotation);
                float one_minus_c = 1.0 - c;

                Axis = normalize(Axis);

                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                        };

                Out = mul(rot_mat,  In);
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }


            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                // need full precision, otherwise half overflows when p > 1
                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            {
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }

            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }

            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            void Unity_Absolute_float(float In, out float Out)
            {
                Out = abs(In);
            }

            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }

            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }

            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }

            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
            {
                Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                if (unity_OrthoParams.w == 1.0)
                {
                    Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                }
                else
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
            }

            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0 = _Bottom_Color;
                float4 _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0 = _Top_Color;
                float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                float4 _Lerp_16f9701748ff4980936cc58aa19de661_Out_3;
                Unity_Lerp_float4(_Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0, _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxxx), _Lerp_16f9701748ff4980936cc58aa19de661_Out_3);
                float _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0 = _Fresnel_Power;
                float _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3;
                Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3);
                float _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2;
                Unity_Multiply_float_float(_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3, _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2);
                float _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0 = _Fresnel_Opacity;
                float _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2;
                Unity_Multiply_float_float(_Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2, _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0, _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2);
                float4 _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2;
                Unity_Add_float4(_Lerp_16f9701748ff4980936cc58aa19de661_Out_3, (_Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2.xxxx), _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2);
                float _Property_c362b4b09f5f401e9a18414784876557_Out_0 = _Emission;
                float4 _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2;
                Unity_Multiply_float4_float4(_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2, (_Property_c362b4b09f5f401e9a18414784876557_Out_0.xxxx), _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2);
                float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                surface.BaseColor = (_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2.xyz);
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = (_Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2.xyz);
                surface.Metallic = 0;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                output.TimeParameters = _TimeParameters.xyz;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif



                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

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
                #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
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
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
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

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
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

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
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
                float4 _Rotate_Property;
                float _Noise_Scale;
                float _Speed;
                float _Cloud_Height;
                float2 _In_Min_Max;
                float2 _Out_Min_Max;
                float4 _Top_Color;
                float4 _Bottom_Color;
                float2 _Smooth;
                float _Power;
                float _BaseNoise_Scale;
                float _BaseNoise_Speed;
                float _BaseNoise_Strength;
                float _Emission;
                float _Fresnel_Power;
                float _Fresnel_Opacity;
                float _Density;
                CBUFFER_END

                    // Object and Global properties

                    // Graph Includes
                    // GraphIncludes: <None>

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                // -- Properties used by SceneSelectionPass
                #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
                #endif

                // Graph Functions

                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);

                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;

                    Axis = normalize(Axis);

                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };

                    Out = mul(rot_mat,  In);
                }

                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }

                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }


                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }

                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }

                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }

                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }

                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }

                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }

                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }

                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }

                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }

                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }

                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }

                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }

                // Custom interpolators pre vertex
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                    float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                    float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                    float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                    float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                    float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                    float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                    Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                    float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                    float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                    float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                    float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                    float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                    float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                    Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                    float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                    Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                    float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                    float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                    Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                    float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                    float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                    float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                    Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                    float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                    Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                    float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                    Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                    float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                    float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                    float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                    float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                    float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                    float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                    float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                    Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                    float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                    Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                    float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                    Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                    float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                    Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                    float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                    float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                    float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                    float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                    description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }

                // Custom interpolators, pre surface
                #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                #endif

                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };

                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                    float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                    float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                    float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                    float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                    float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                    float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                    Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                    float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                    Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                    float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                    float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                    Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                    surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                    return surface;
                }

                // --------------------------------------------------
                // Build Graph Inputs
                #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                #endif
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                    output.ObjectSpaceNormal = input.normalOS;
                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                    output.ObjectSpacePosition = input.positionOS;
                    output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                    output.TimeParameters = _TimeParameters.xyz;

                    return output;
                }
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                #endif







                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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

                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                // --------------------------------------------------
                // Visual Effect Vertex Invocations
                #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                #endif

                ENDHLSL
                }
                Pass
                {
                    Name "DepthNormals"
                    Tags
                    {
                        "LightMode" = "DepthNormals"
                    }

                    // Render State
                    Cull Back
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
                    #pragma multi_compile _ DOTS_INSTANCING_ON
                    #pragma vertex vert
                    #pragma fragment frag

                    // DotsInstancingOptions: <None>
                    // HybridV1InjectedBuiltinProperties: <None>

                    // Keywords
                    // PassKeywords: <None>
                    // GraphKeywords: <None>

                    // Defines

                    #define _NORMALMAP 1
                    #define _NORMAL_DROPOFF_TS 1
                    #define ATTRIBUTES_NEED_NORMAL
                    #define ATTRIBUTES_NEED_TANGENT
                    #define ATTRIBUTES_NEED_TEXCOORD1
                    #define VARYINGS_NEED_POSITION_WS
                    #define VARYINGS_NEED_NORMAL_WS
                    #define VARYINGS_NEED_TANGENT_WS
                    #define FEATURES_GRAPH_VERTEX
                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                    #define SHADERPASS SHADERPASS_DEPTHNORMALS
                    #define REQUIRE_DEPTH_TEXTURE
                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                    // custom interpolator pre-include
                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                    // Includes
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                    // --------------------------------------------------
                    // Structs and Packing

                    // custom interpolators pre packing
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                    struct Attributes
                    {
                         float3 positionOS : POSITION;
                         float3 normalOS : NORMAL;
                         float4 tangentOS : TANGENT;
                         float4 uv1 : TEXCOORD1;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : INSTANCEID_SEMANTIC;
                        #endif
                    };
                    struct Varyings
                    {
                         float4 positionCS : SV_POSITION;
                         float3 positionWS;
                         float3 normalWS;
                         float4 tangentWS;
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
                         float3 TangentSpaceNormal;
                         float3 WorldSpacePosition;
                         float4 ScreenPosition;
                    };
                    struct VertexDescriptionInputs
                    {
                         float3 ObjectSpaceNormal;
                         float3 ObjectSpaceTangent;
                         float3 ObjectSpacePosition;
                         float3 WorldSpacePosition;
                         float3 TimeParameters;
                    };
                    struct PackedVaryings
                    {
                         float4 positionCS : SV_POSITION;
                         float3 interp0 : INTERP0;
                         float3 interp1 : INTERP1;
                         float4 interp2 : INTERP2;
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

                    PackedVaryings PackVaryings(Varyings input)
                    {
                        PackedVaryings output;
                        ZERO_INITIALIZE(PackedVaryings, output);
                        output.positionCS = input.positionCS;
                        output.interp0.xyz = input.positionWS;
                        output.interp1.xyz = input.normalWS;
                        output.interp2.xyzw = input.tangentWS;
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

                    Varyings UnpackVaryings(PackedVaryings input)
                    {
                        Varyings output;
                        output.positionCS = input.positionCS;
                        output.positionWS = input.interp0.xyz;
                        output.normalWS = input.interp1.xyz;
                        output.tangentWS = input.interp2.xyzw;
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
                    float4 _Rotate_Property;
                    float _Noise_Scale;
                    float _Speed;
                    float _Cloud_Height;
                    float2 _In_Min_Max;
                    float2 _Out_Min_Max;
                    float4 _Top_Color;
                    float4 _Bottom_Color;
                    float2 _Smooth;
                    float _Power;
                    float _BaseNoise_Scale;
                    float _BaseNoise_Speed;
                    float _BaseNoise_Strength;
                    float _Emission;
                    float _Fresnel_Power;
                    float _Fresnel_Opacity;
                    float _Density;
                    CBUFFER_END

                        // Object and Global properties

                        // Graph Includes
                        // GraphIncludes: <None>

                        // -- Property used by ScenePickingPass
                        #ifdef SCENEPICKINGPASS
                        float4 _SelectionID;
                        #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                    {
                        Rotation = radians(Rotation);

                        float s = sin(Rotation);
                        float c = cos(Rotation);
                        float one_minus_c = 1.0 - c;

                        Axis = normalize(Axis);

                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                };

                        Out = mul(rot_mat,  In);
                    }

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }


                    float2 Unity_GradientNoise_Dir_float(float2 p)
                    {
                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                        p = p % 289;
                        // need full precision, otherwise half overflows when p > 1
                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                        x = (34 * x + 1) * x % 289;
                        x = frac(x / 41) * 2 - 1;
                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                    }

                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                    {
                        float2 p = UV * Scale;
                        float2 ip = floor(p);
                        float2 fp = frac(p);
                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                    }

                    void Unity_Add_float(float A, float B, out float Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Divide_float(float A, float B, out float Out)
                    {
                        Out = A / B;
                    }

                    void Unity_Power_float(float A, float B, out float Out)
                    {
                        Out = pow(A, B);
                    }

                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                    {
                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                    }

                    void Unity_Absolute_float(float In, out float Out)
                    {
                        Out = abs(In);
                    }

                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                    {
                        Out = smoothstep(Edge1, Edge2, In);
                    }

                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                    {
                        if (unity_OrthoParams.w == 1.0)
                        {
                            Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                        }
                        else
                        {
                            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                        }
                    }

                    void Unity_Subtract_float(float A, float B, out float Out)
                    {
                        Out = A - B;
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                        float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                        float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                        float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                        float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                        float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                        float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                        Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                        float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                        float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                        float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                        float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                        float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                        float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                        Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                        float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                        Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                        float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                        float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                        Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                        float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                        float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                        float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                        Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                        float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                        Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                        float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                        Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                        float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                        float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                        float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                        float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                        float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                        float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                        float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                        Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                        float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                        Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                        float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                        Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                        float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                        Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                        float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                        Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                        float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                        float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                        Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                        float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                        description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 NormalTS;
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                        float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                        float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                        float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                        float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                        float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                        float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                        Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                        float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                        Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                        float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                        float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                        Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;
                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                        output.TimeParameters = _TimeParameters.xyz;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif





                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.WorldSpacePosition = input.positionWS;
                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "Meta"
                        Tags
                        {
                            "LightMode" = "Meta"
                        }

                        // Render State
                        Cull Off

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        #pragma shader_feature _ EDITOR_VISUALIZATION
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define ATTRIBUTES_NEED_TEXCOORD1
                        #define ATTRIBUTES_NEED_TEXCOORD2
                        #define VARYINGS_NEED_POSITION_WS
                        #define VARYINGS_NEED_NORMAL_WS
                        #define VARYINGS_NEED_TEXCOORD0
                        #define VARYINGS_NEED_TEXCOORD1
                        #define VARYINGS_NEED_TEXCOORD2
                        #define VARYINGS_NEED_VIEWDIRECTION_WS
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_META
                        #define _FOG_FRAGMENT 1
                        #define REQUIRE_DEPTH_TEXTURE
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                             float4 uv1 : TEXCOORD1;
                             float4 uv2 : TEXCOORD2;
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
                             float4 texCoord1;
                             float4 texCoord2;
                             float3 viewDirectionWS;
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
                             float3 WorldSpaceViewDirection;
                             float3 WorldSpacePosition;
                             float4 ScreenPosition;
                             float3 TimeParameters;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                             float3 WorldSpacePosition;
                             float3 TimeParameters;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                             float3 interp1 : INTERP1;
                             float4 interp2 : INTERP2;
                             float4 interp3 : INTERP3;
                             float4 interp4 : INTERP4;
                             float3 interp5 : INTERP5;
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

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.positionWS;
                            output.interp1.xyz = input.normalWS;
                            output.interp2.xyzw = input.texCoord0;
                            output.interp3.xyzw = input.texCoord1;
                            output.interp4.xyzw = input.texCoord2;
                            output.interp5.xyz = input.viewDirectionWS;
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

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.positionWS = input.interp0.xyz;
                            output.normalWS = input.interp1.xyz;
                            output.texCoord0 = input.interp2.xyzw;
                            output.texCoord1 = input.interp3.xyzw;
                            output.texCoord2 = input.interp4.xyzw;
                            output.viewDirectionWS = input.interp5.xyz;
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
                        float4 _Rotate_Property;
                        float _Noise_Scale;
                        float _Speed;
                        float _Cloud_Height;
                        float2 _In_Min_Max;
                        float2 _Out_Min_Max;
                        float4 _Top_Color;
                        float4 _Bottom_Color;
                        float2 _Smooth;
                        float _Power;
                        float _BaseNoise_Scale;
                        float _BaseNoise_Speed;
                        float _BaseNoise_Strength;
                        float _Emission;
                        float _Fresnel_Power;
                        float _Fresnel_Opacity;
                        float _Density;
                        CBUFFER_END

                            // Object and Global properties

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                        // -- Properties used by SceneSelectionPass
                        #ifdef SCENESELECTIONPASS
                        int _ObjectId;
                        int _PassValue;
                        #endif

                        // Graph Functions

                        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                        {
                            Rotation = radians(Rotation);

                            float s = sin(Rotation);
                            float c = cos(Rotation);
                            float one_minus_c = 1.0 - c;

                            Axis = normalize(Axis);

                            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                    };

                            Out = mul(rot_mat,  In);
                        }

                        void Unity_Multiply_float_float(float A, float B, out float Out)
                        {
                            Out = A * B;
                        }

                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                        {
                            Out = UV * Tiling + Offset;
                        }


                        float2 Unity_GradientNoise_Dir_float(float2 p)
                        {
                            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                            p = p % 289;
                            // need full precision, otherwise half overflows when p > 1
                            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                            x = (34 * x + 1) * x % 289;
                            x = frac(x / 41) * 2 - 1;
                            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                        }

                        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                        {
                            float2 p = UV * Scale;
                            float2 ip = floor(p);
                            float2 fp = frac(p);
                            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                        }

                        void Unity_Add_float(float A, float B, out float Out)
                        {
                            Out = A + B;
                        }

                        void Unity_Divide_float(float A, float B, out float Out)
                        {
                            Out = A / B;
                        }

                        void Unity_Power_float(float A, float B, out float Out)
                        {
                            Out = pow(A, B);
                        }

                        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                        {
                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                        }

                        void Unity_Absolute_float(float In, out float Out)
                        {
                            Out = abs(In);
                        }

                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                        {
                            Out = smoothstep(Edge1, Edge2, In);
                        }

                        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                        {
                            Out = A + B;
                        }

                        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                        {
                            Out = lerp(A, B, T);
                        }

                        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                        {
                            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                        }

                        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                        {
                            Out = A + B;
                        }

                        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                        {
                            if (unity_OrthoParams.w == 1.0)
                            {
                                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                            }
                            else
                            {
                                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                            }
                        }

                        void Unity_Subtract_float(float A, float B, out float Out)
                        {
                            Out = A - B;
                        }

                        // Custom interpolators pre vertex
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                            float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                            float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                            float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                            float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                            float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                            float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                            Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                            float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                            float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                            float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                            float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                            float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                            float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                            Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                            float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                            Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                            float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                            float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                            Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                            float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                            float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                            float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                            Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                            float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                            Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                            float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                            Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                            float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                            float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                            float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                            float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                            float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                            float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                            float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                            Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                            float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                            Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                            float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                            Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                            float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                            Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                            float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                            float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                            float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                            Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                            float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                            description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                            description.Normal = IN.ObjectSpaceNormal;
                            description.Tangent = IN.ObjectSpaceTangent;
                            return description;
                        }

                        // Custom interpolators, pre surface
                        #ifdef FEATURES_GRAPH_VERTEX
                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                        {
                        return output;
                        }
                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                        #endif

                        // Graph Pixel
                        struct SurfaceDescription
                        {
                            float3 BaseColor;
                            float3 Emission;
                            float Alpha;
                        };

                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                        {
                            SurfaceDescription surface = (SurfaceDescription)0;
                            float4 _Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0 = _Bottom_Color;
                            float4 _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0 = _Top_Color;
                            float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                            float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                            float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                            float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                            float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                            float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                            Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                            float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                            float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                            float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                            float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                            float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                            float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                            Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                            float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                            Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                            float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                            float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                            Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                            float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                            float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                            float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                            Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                            float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                            Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                            float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                            Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                            float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                            float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                            float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                            float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                            float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                            float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                            Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                            float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                            Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                            float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                            Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                            float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                            Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                            float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                            Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                            float4 _Lerp_16f9701748ff4980936cc58aa19de661_Out_3;
                            Unity_Lerp_float4(_Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0, _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxxx), _Lerp_16f9701748ff4980936cc58aa19de661_Out_3);
                            float _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0 = _Fresnel_Power;
                            float _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3;
                            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3);
                            float _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2;
                            Unity_Multiply_float_float(_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3, _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2);
                            float _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0 = _Fresnel_Opacity;
                            float _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2;
                            Unity_Multiply_float_float(_Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2, _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0, _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2);
                            float4 _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2;
                            Unity_Add_float4(_Lerp_16f9701748ff4980936cc58aa19de661_Out_3, (_Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2.xxxx), _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2);
                            float _Property_c362b4b09f5f401e9a18414784876557_Out_0 = _Emission;
                            float4 _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2;
                            Unity_Multiply_float4_float4(_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2, (_Property_c362b4b09f5f401e9a18414784876557_Out_0.xxxx), _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2);
                            float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                            float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                            float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                            float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                            float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                            float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                            float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                            Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                            float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                            Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                            float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                            float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                            Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                            surface.BaseColor = (_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2.xyz);
                            surface.Emission = (_Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2.xyz);
                            surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                            return surface;
                        }

                        // --------------------------------------------------
                        // Build Graph Inputs
                        #ifdef HAVE_VFX_MODIFICATION
                        #define VFX_SRP_ATTRIBUTES Attributes
                        #define VFX_SRP_VARYINGS Varyings
                        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                        #endif
                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                        {
                            VertexDescriptionInputs output;
                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                            output.ObjectSpaceNormal = input.normalOS;
                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                            output.ObjectSpacePosition = input.positionOS;
                            output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                            output.TimeParameters = _TimeParameters.xyz;

                            return output;
                        }
                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                        {
                            SurfaceDescriptionInputs output;
                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                        #ifdef HAVE_VFX_MODIFICATION
                            // FragInputs from VFX come from two places: Interpolator or CBuffer.
                            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                        #endif



                            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                            float3 unnormalizedNormalWS = input.normalWS;
                            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
                            output.WorldSpacePosition = input.positionWS;
                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                        // --------------------------------------------------
                        // Visual Effect Vertex Invocations
                        #ifdef HAVE_VFX_MODIFICATION
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                        #endif

                        ENDHLSL
                        }
                        Pass
                        {
                            Name "SceneSelectionPass"
                            Tags
                            {
                                "LightMode" = "SceneSelectionPass"
                            }

                            // Render State
                            Cull Off

                            // Debug
                            // <None>

                            // --------------------------------------------------
                            // Pass

                            HLSLPROGRAM

                            // Pragmas
                            #pragma target 4.5
                            #pragma exclude_renderers gles gles3 glcore
                            #pragma vertex vert
                            #pragma fragment frag

                            // DotsInstancingOptions: <None>
                            // HybridV1InjectedBuiltinProperties: <None>

                            // Keywords
                            // PassKeywords: <None>
                            // GraphKeywords: <None>

                            // Defines

                            #define _NORMALMAP 1
                            #define _NORMAL_DROPOFF_TS 1
                            #define ATTRIBUTES_NEED_NORMAL
                            #define ATTRIBUTES_NEED_TANGENT
                            #define VARYINGS_NEED_POSITION_WS
                            #define FEATURES_GRAPH_VERTEX
                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                            #define SHADERPASS SHADERPASS_DEPTHONLY
                            #define SCENESELECTIONPASS 1
                            #define ALPHA_CLIP_THRESHOLD 1
                            #define REQUIRE_DEPTH_TEXTURE
                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                            // custom interpolator pre-include
                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                            // Includes
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                            // --------------------------------------------------
                            // Structs and Packing

                            // custom interpolators pre packing
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                            struct Attributes
                            {
                                 float3 positionOS : POSITION;
                                 float3 normalOS : NORMAL;
                                 float4 tangentOS : TANGENT;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : INSTANCEID_SEMANTIC;
                                #endif
                            };
                            struct Varyings
                            {
                                 float4 positionCS : SV_POSITION;
                                 float3 positionWS;
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
                                 float4 ScreenPosition;
                            };
                            struct VertexDescriptionInputs
                            {
                                 float3 ObjectSpaceNormal;
                                 float3 ObjectSpaceTangent;
                                 float3 ObjectSpacePosition;
                                 float3 WorldSpacePosition;
                                 float3 TimeParameters;
                            };
                            struct PackedVaryings
                            {
                                 float4 positionCS : SV_POSITION;
                                 float3 interp0 : INTERP0;
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

                            PackedVaryings PackVaryings(Varyings input)
                            {
                                PackedVaryings output;
                                ZERO_INITIALIZE(PackedVaryings, output);
                                output.positionCS = input.positionCS;
                                output.interp0.xyz = input.positionWS;
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

                            Varyings UnpackVaryings(PackedVaryings input)
                            {
                                Varyings output;
                                output.positionCS = input.positionCS;
                                output.positionWS = input.interp0.xyz;
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
                            float4 _Rotate_Property;
                            float _Noise_Scale;
                            float _Speed;
                            float _Cloud_Height;
                            float2 _In_Min_Max;
                            float2 _Out_Min_Max;
                            float4 _Top_Color;
                            float4 _Bottom_Color;
                            float2 _Smooth;
                            float _Power;
                            float _BaseNoise_Scale;
                            float _BaseNoise_Speed;
                            float _BaseNoise_Strength;
                            float _Emission;
                            float _Fresnel_Power;
                            float _Fresnel_Opacity;
                            float _Density;
                            CBUFFER_END

                                // Object and Global properties

                                // Graph Includes
                                // GraphIncludes: <None>

                                // -- Property used by ScenePickingPass
                                #ifdef SCENEPICKINGPASS
                                float4 _SelectionID;
                                #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions

                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                            {
                                Rotation = radians(Rotation);

                                float s = sin(Rotation);
                                float c = cos(Rotation);
                                float one_minus_c = 1.0 - c;

                                Axis = normalize(Axis);

                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                        };

                                Out = mul(rot_mat,  In);
                            }

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }


                            float2 Unity_GradientNoise_Dir_float(float2 p)
                            {
                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                p = p % 289;
                                // need full precision, otherwise half overflows when p > 1
                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                x = (34 * x + 1) * x % 289;
                                x = frac(x / 41) * 2 - 1;
                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                            }

                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                            {
                                float2 p = UV * Scale;
                                float2 ip = floor(p);
                                float2 fp = frac(p);
                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                            }

                            void Unity_Add_float(float A, float B, out float Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Divide_float(float A, float B, out float Out)
                            {
                                Out = A / B;
                            }

                            void Unity_Power_float(float A, float B, out float Out)
                            {
                                Out = pow(A, B);
                            }

                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                            {
                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                            }

                            void Unity_Absolute_float(float In, out float Out)
                            {
                                Out = abs(In);
                            }

                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                            {
                                Out = smoothstep(Edge1, Edge2, In);
                            }

                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                            {
                                if (unity_OrthoParams.w == 1.0)
                                {
                                    Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                }
                                else
                                {
                                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                }
                            }

                            void Unity_Subtract_float(float A, float B, out float Out)
                            {
                                Out = A - B;
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;
                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                output.TimeParameters = _TimeParameters.xyz;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif







                                output.WorldSpacePosition = input.positionWS;
                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "ScenePickingPass"
                                Tags
                                {
                                    "LightMode" = "Picking"
                                }

                                // Render State
                                Cull Back

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define VARYINGS_NEED_POSITION_WS
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                #define SCENEPICKINGPASS 1
                                #define ALPHA_CLIP_THRESHOLD 1
                                #define REQUIRE_DEPTH_TEXTURE
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 positionWS;
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
                                     float4 ScreenPosition;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                     float3 WorldSpacePosition;
                                     float3 TimeParameters;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 interp0 : INTERP0;
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

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.interp0.xyz = input.positionWS;
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

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.positionWS = input.interp0.xyz;
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
                                float4 _Rotate_Property;
                                float _Noise_Scale;
                                float _Speed;
                                float _Cloud_Height;
                                float2 _In_Min_Max;
                                float2 _Out_Min_Max;
                                float4 _Top_Color;
                                float4 _Bottom_Color;
                                float2 _Smooth;
                                float _Power;
                                float _BaseNoise_Scale;
                                float _BaseNoise_Speed;
                                float _BaseNoise_Strength;
                                float _Emission;
                                float _Fresnel_Power;
                                float _Fresnel_Opacity;
                                float _Density;
                                CBUFFER_END

                                    // Object and Global properties

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                // -- Properties used by SceneSelectionPass
                                #ifdef SCENESELECTIONPASS
                                int _ObjectId;
                                int _PassValue;
                                #endif

                                // Graph Functions

                                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                {
                                    Rotation = radians(Rotation);

                                    float s = sin(Rotation);
                                    float c = cos(Rotation);
                                    float one_minus_c = 1.0 - c;

                                    Axis = normalize(Axis);

                                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                            };

                                    Out = mul(rot_mat,  In);
                                }

                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                {
                                    Out = UV * Tiling + Offset;
                                }


                                float2 Unity_GradientNoise_Dir_float(float2 p)
                                {
                                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                    p = p % 289;
                                    // need full precision, otherwise half overflows when p > 1
                                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                    x = (34 * x + 1) * x % 289;
                                    x = frac(x / 41) * 2 - 1;
                                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                }

                                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                {
                                    float2 p = UV * Scale;
                                    float2 ip = floor(p);
                                    float2 fp = frac(p);
                                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                }

                                void Unity_Add_float(float A, float B, out float Out)
                                {
                                    Out = A + B;
                                }

                                void Unity_Divide_float(float A, float B, out float Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Power_float(float A, float B, out float Out)
                                {
                                    Out = pow(A, B);
                                }

                                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                {
                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                }

                                void Unity_Absolute_float(float In, out float Out)
                                {
                                    Out = abs(In);
                                }

                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                {
                                    Out = smoothstep(Edge1, Edge2, In);
                                }

                                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                {
                                    Out = A + B;
                                }

                                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                {
                                    if (unity_OrthoParams.w == 1.0)
                                    {
                                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                    }
                                    else
                                    {
                                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                    }
                                }

                                void Unity_Subtract_float(float A, float B, out float Out)
                                {
                                    Out = A - B;
                                }

                                // Custom interpolators pre vertex
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                    float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                    float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                    float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                    float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                    float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                    float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                    Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                    float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                    float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                    float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                    Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                    float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                    float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                    Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                    float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                    Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                    float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                    Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                    float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                    float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                    Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                    float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                    float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                    float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                    Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                    float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                    Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                    float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                    Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                    float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                    float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                    float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                    float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                    float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                    float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                    Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                    float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                    Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                    float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                    Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                    float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                    Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                    float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                    Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                    float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                    float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                    float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                    Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                    float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                    description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                    description.Normal = IN.ObjectSpaceNormal;
                                    description.Tangent = IN.ObjectSpaceTangent;
                                    return description;
                                }

                                // Custom interpolators, pre surface
                                #ifdef FEATURES_GRAPH_VERTEX
                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                {
                                return output;
                                }
                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                #endif

                                // Graph Pixel
                                struct SurfaceDescription
                                {
                                    float Alpha;
                                };

                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                {
                                    SurfaceDescription surface = (SurfaceDescription)0;
                                    float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                    float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                    float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                    float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                    float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                    float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                    float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                    Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                    float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                    Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                    float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                    float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                    Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                    surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                    return surface;
                                }

                                // --------------------------------------------------
                                // Build Graph Inputs
                                #ifdef HAVE_VFX_MODIFICATION
                                #define VFX_SRP_ATTRIBUTES Attributes
                                #define VFX_SRP_VARYINGS Varyings
                                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                #endif
                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                {
                                    VertexDescriptionInputs output;
                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                    output.ObjectSpaceNormal = input.normalOS;
                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                    output.ObjectSpacePosition = input.positionOS;
                                    output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                    output.TimeParameters = _TimeParameters.xyz;

                                    return output;
                                }
                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                {
                                    SurfaceDescriptionInputs output;
                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                #ifdef HAVE_VFX_MODIFICATION
                                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                #endif







                                    output.WorldSpacePosition = input.positionWS;
                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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

                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                // --------------------------------------------------
                                // Visual Effect Vertex Invocations
                                #ifdef HAVE_VFX_MODIFICATION
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                #endif

                                ENDHLSL
                                }
                                Pass
                                {
                                    // Name: <None>
                                    Tags
                                    {
                                        "LightMode" = "Universal2D"
                                    }

                                    // Render State
                                    Cull Back
                                    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                    ZTest LEqual
                                    ZWrite Off

                                    // Debug
                                    // <None>

                                    // --------------------------------------------------
                                    // Pass

                                    HLSLPROGRAM

                                    // Pragmas
                                    #pragma target 4.5
                                    #pragma exclude_renderers gles gles3 glcore
                                    #pragma vertex vert
                                    #pragma fragment frag

                                    // DotsInstancingOptions: <None>
                                    // HybridV1InjectedBuiltinProperties: <None>

                                    // Keywords
                                    // PassKeywords: <None>
                                    // GraphKeywords: <None>

                                    // Defines

                                    #define _NORMALMAP 1
                                    #define _NORMAL_DROPOFF_TS 1
                                    #define ATTRIBUTES_NEED_NORMAL
                                    #define ATTRIBUTES_NEED_TANGENT
                                    #define VARYINGS_NEED_POSITION_WS
                                    #define VARYINGS_NEED_NORMAL_WS
                                    #define VARYINGS_NEED_VIEWDIRECTION_WS
                                    #define FEATURES_GRAPH_VERTEX
                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                    #define SHADERPASS SHADERPASS_2D
                                    #define REQUIRE_DEPTH_TEXTURE
                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                    // custom interpolator pre-include
                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                    // Includes
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                    // --------------------------------------------------
                                    // Structs and Packing

                                    // custom interpolators pre packing
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                    struct Attributes
                                    {
                                         float3 positionOS : POSITION;
                                         float3 normalOS : NORMAL;
                                         float4 tangentOS : TANGENT;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : INSTANCEID_SEMANTIC;
                                        #endif
                                    };
                                    struct Varyings
                                    {
                                         float4 positionCS : SV_POSITION;
                                         float3 positionWS;
                                         float3 normalWS;
                                         float3 viewDirectionWS;
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
                                         float3 WorldSpaceViewDirection;
                                         float3 WorldSpacePosition;
                                         float4 ScreenPosition;
                                         float3 TimeParameters;
                                    };
                                    struct VertexDescriptionInputs
                                    {
                                         float3 ObjectSpaceNormal;
                                         float3 ObjectSpaceTangent;
                                         float3 ObjectSpacePosition;
                                         float3 WorldSpacePosition;
                                         float3 TimeParameters;
                                    };
                                    struct PackedVaryings
                                    {
                                         float4 positionCS : SV_POSITION;
                                         float3 interp0 : INTERP0;
                                         float3 interp1 : INTERP1;
                                         float3 interp2 : INTERP2;
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

                                    PackedVaryings PackVaryings(Varyings input)
                                    {
                                        PackedVaryings output;
                                        ZERO_INITIALIZE(PackedVaryings, output);
                                        output.positionCS = input.positionCS;
                                        output.interp0.xyz = input.positionWS;
                                        output.interp1.xyz = input.normalWS;
                                        output.interp2.xyz = input.viewDirectionWS;
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

                                    Varyings UnpackVaryings(PackedVaryings input)
                                    {
                                        Varyings output;
                                        output.positionCS = input.positionCS;
                                        output.positionWS = input.interp0.xyz;
                                        output.normalWS = input.interp1.xyz;
                                        output.viewDirectionWS = input.interp2.xyz;
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
                                    float4 _Rotate_Property;
                                    float _Noise_Scale;
                                    float _Speed;
                                    float _Cloud_Height;
                                    float2 _In_Min_Max;
                                    float2 _Out_Min_Max;
                                    float4 _Top_Color;
                                    float4 _Bottom_Color;
                                    float2 _Smooth;
                                    float _Power;
                                    float _BaseNoise_Scale;
                                    float _BaseNoise_Speed;
                                    float _BaseNoise_Strength;
                                    float _Emission;
                                    float _Fresnel_Power;
                                    float _Fresnel_Opacity;
                                    float _Density;
                                    CBUFFER_END

                                        // Object and Global properties

                                        // Graph Includes
                                        // GraphIncludes: <None>

                                        // -- Property used by ScenePickingPass
                                        #ifdef SCENEPICKINGPASS
                                        float4 _SelectionID;
                                        #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions

                                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                    {
                                        Rotation = radians(Rotation);

                                        float s = sin(Rotation);
                                        float c = cos(Rotation);
                                        float one_minus_c = 1.0 - c;

                                        Axis = normalize(Axis);

                                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                };

                                        Out = mul(rot_mat,  In);
                                    }

                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }


                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                    {
                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                        p = p % 289;
                                        // need full precision, otherwise half overflows when p > 1
                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                        x = (34 * x + 1) * x % 289;
                                        x = frac(x / 41) * 2 - 1;
                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                    }

                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                    {
                                        float2 p = UV * Scale;
                                        float2 ip = floor(p);
                                        float2 fp = frac(p);
                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                    }

                                    void Unity_Add_float(float A, float B, out float Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Divide_float(float A, float B, out float Out)
                                    {
                                        Out = A / B;
                                    }

                                    void Unity_Power_float(float A, float B, out float Out)
                                    {
                                        Out = pow(A, B);
                                    }

                                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                    {
                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                    }

                                    void Unity_Absolute_float(float In, out float Out)
                                    {
                                        Out = abs(In);
                                    }

                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                    {
                                        Out = smoothstep(Edge1, Edge2, In);
                                    }

                                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                    {
                                        Out = lerp(A, B, T);
                                    }

                                    void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                                    {
                                        Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                                    }

                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                    {
                                        if (unity_OrthoParams.w == 1.0)
                                        {
                                            Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                        }
                                        else
                                        {
                                            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                        }
                                    }

                                    void Unity_Subtract_float(float A, float B, out float Out)
                                    {
                                        Out = A - B;
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                        float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                        float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                        float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                        float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                        float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                        float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                        Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                        float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                        float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                        float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                        Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                        float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                        float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                        Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                        float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                        Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                        float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                        Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                        float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                        float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                        Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                        float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                        float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                        float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                        Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                        float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                        Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                        float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                        Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                        float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                        float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                        float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                        float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                        float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                        float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                        Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                        float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                        Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                        float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                        Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                        float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                        Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                        float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                        Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                        float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                        Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                        float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                        float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                        Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                        float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                        description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float3 BaseColor;
                                        float Alpha;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        float4 _Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0 = _Bottom_Color;
                                        float4 _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0 = _Top_Color;
                                        float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                        float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                        float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                        float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                        float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                        float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                        Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                        float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                        float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                        float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                        Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                        float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                        float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                        Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                        float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                        Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                        float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                        Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                        float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                        float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                        Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                        float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                        float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                        float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                        Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                        float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                        Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                        float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                        Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                        float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                        float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                        float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                        float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                        float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                        float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                        Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                        float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                        Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                        float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                        Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                        float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                        Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                        float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                        Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                        float4 _Lerp_16f9701748ff4980936cc58aa19de661_Out_3;
                                        Unity_Lerp_float4(_Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0, _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxxx), _Lerp_16f9701748ff4980936cc58aa19de661_Out_3);
                                        float _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0 = _Fresnel_Power;
                                        float _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3;
                                        Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3);
                                        float _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2;
                                        Unity_Multiply_float_float(_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3, _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2);
                                        float _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0 = _Fresnel_Opacity;
                                        float _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2;
                                        Unity_Multiply_float_float(_Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2, _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0, _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2);
                                        float4 _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2;
                                        Unity_Add_float4(_Lerp_16f9701748ff4980936cc58aa19de661_Out_3, (_Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2.xxxx), _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2);
                                        float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                        float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                        float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                        float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                        float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                        float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                        float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                        Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                        float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                        Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                        float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                        float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                        Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                        surface.BaseColor = (_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2.xyz);
                                        surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;
                                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                        output.TimeParameters = _TimeParameters.xyz;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif



                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                        float3 unnormalizedNormalWS = input.normalWS;
                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                        output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
                                        output.WorldSpacePosition = input.positionWS;
                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
    }
        SubShader
                                    {
                                        Tags
                                        {
                                            "RenderPipeline" = "UniversalPipeline"
                                            "RenderType" = "Transparent"
                                            "UniversalMaterialType" = "Lit"
                                            "Queue" = "Transparent"
                                            "ShaderGraphShader" = "true"
                                            "ShaderGraphTargetId" = "UniversalLitSubTarget"
                                        }
                                        Pass
                                        {
                                            Name "Universal Forward"
                                            Tags
                                            {
                                                "LightMode" = "UniversalForward"
                                            }

                                        // Render State
                                        Cull Back
                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                        ZTest LEqual
                                        ZWrite Off

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
                                        #pragma instancing_options renderinglayer
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // DotsInstancingOptions: <None>
                                        // HybridV1InjectedBuiltinProperties: <None>

                                        // Keywords
                                        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                                        #pragma multi_compile _ LIGHTMAP_ON
                                        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                                        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                                        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                                        #pragma multi_compile_fragment _ _SHADOWS_SOFT
                                        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                        #pragma multi_compile _ SHADOWS_SHADOWMASK
                                        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                                        #pragma multi_compile_fragment _ _LIGHT_LAYERS
                                        #pragma multi_compile_fragment _ DEBUG_DISPLAY
                                        #pragma multi_compile_fragment _ _LIGHT_COOKIES
                                        #pragma multi_compile _ _CLUSTERED_RENDERING
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                        #define VARYINGS_NEED_POSITION_WS
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define VARYINGS_NEED_VIEWDIRECTION_WS
                                        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                        #define VARYINGS_NEED_SHADOW_COORD
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_FORWARD
                                        #define _FOG_FRAGMENT 1
                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                        #define REQUIRE_DEPTH_TEXTURE
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv1 : TEXCOORD1;
                                             float4 uv2 : TEXCOORD2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 positionWS;
                                             float3 normalWS;
                                             float4 tangentWS;
                                             float3 viewDirectionWS;
                                            #if defined(LIGHTMAP_ON)
                                             float2 staticLightmapUV;
                                            #endif
                                            #if defined(DYNAMICLIGHTMAP_ON)
                                             float2 dynamicLightmapUV;
                                            #endif
                                            #if !defined(LIGHTMAP_ON)
                                             float3 sh;
                                            #endif
                                             float4 fogFactorAndVertexLight;
                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                             float4 shadowCoord;
                                            #endif
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
                                             float3 TangentSpaceNormal;
                                             float3 WorldSpaceViewDirection;
                                             float3 WorldSpacePosition;
                                             float4 ScreenPosition;
                                             float3 TimeParameters;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                             float3 WorldSpacePosition;
                                             float3 TimeParameters;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 interp0 : INTERP0;
                                             float3 interp1 : INTERP1;
                                             float4 interp2 : INTERP2;
                                             float3 interp3 : INTERP3;
                                             float2 interp4 : INTERP4;
                                             float2 interp5 : INTERP5;
                                             float3 interp6 : INTERP6;
                                             float4 interp7 : INTERP7;
                                             float4 interp8 : INTERP8;
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

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyz = input.positionWS;
                                            output.interp1.xyz = input.normalWS;
                                            output.interp2.xyzw = input.tangentWS;
                                            output.interp3.xyz = input.viewDirectionWS;
                                            #if defined(LIGHTMAP_ON)
                                            output.interp4.xy = input.staticLightmapUV;
                                            #endif
                                            #if defined(DYNAMICLIGHTMAP_ON)
                                            output.interp5.xy = input.dynamicLightmapUV;
                                            #endif
                                            #if !defined(LIGHTMAP_ON)
                                            output.interp6.xyz = input.sh;
                                            #endif
                                            output.interp7.xyzw = input.fogFactorAndVertexLight;
                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                            output.interp8.xyzw = input.shadowCoord;
                                            #endif
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

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.positionWS = input.interp0.xyz;
                                            output.normalWS = input.interp1.xyz;
                                            output.tangentWS = input.interp2.xyzw;
                                            output.viewDirectionWS = input.interp3.xyz;
                                            #if defined(LIGHTMAP_ON)
                                            output.staticLightmapUV = input.interp4.xy;
                                            #endif
                                            #if defined(DYNAMICLIGHTMAP_ON)
                                            output.dynamicLightmapUV = input.interp5.xy;
                                            #endif
                                            #if !defined(LIGHTMAP_ON)
                                            output.sh = input.interp6.xyz;
                                            #endif
                                            output.fogFactorAndVertexLight = input.interp7.xyzw;
                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                            output.shadowCoord = input.interp8.xyzw;
                                            #endif
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
                                        float4 _Rotate_Property;
                                        float _Noise_Scale;
                                        float _Speed;
                                        float _Cloud_Height;
                                        float2 _In_Min_Max;
                                        float2 _Out_Min_Max;
                                        float4 _Top_Color;
                                        float4 _Bottom_Color;
                                        float2 _Smooth;
                                        float _Power;
                                        float _BaseNoise_Scale;
                                        float _BaseNoise_Speed;
                                        float _BaseNoise_Strength;
                                        float _Emission;
                                        float _Fresnel_Power;
                                        float _Fresnel_Opacity;
                                        float _Density;
                                        CBUFFER_END

                                            // Object and Global properties

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                        // -- Properties used by SceneSelectionPass
                                        #ifdef SCENESELECTIONPASS
                                        int _ObjectId;
                                        int _PassValue;
                                        #endif

                                        // Graph Functions

                                        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                        {
                                            Rotation = radians(Rotation);

                                            float s = sin(Rotation);
                                            float c = cos(Rotation);
                                            float one_minus_c = 1.0 - c;

                                            Axis = normalize(Axis);

                                            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                    };

                                            Out = mul(rot_mat,  In);
                                        }

                                        void Unity_Multiply_float_float(float A, float B, out float Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                        {
                                            Out = UV * Tiling + Offset;
                                        }


                                        float2 Unity_GradientNoise_Dir_float(float2 p)
                                        {
                                            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                            p = p % 289;
                                            // need full precision, otherwise half overflows when p > 1
                                            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                            x = (34 * x + 1) * x % 289;
                                            x = frac(x / 41) * 2 - 1;
                                            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                        }

                                        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                        {
                                            float2 p = UV * Scale;
                                            float2 ip = floor(p);
                                            float2 fp = frac(p);
                                            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                        }

                                        void Unity_Add_float(float A, float B, out float Out)
                                        {
                                            Out = A + B;
                                        }

                                        void Unity_Divide_float(float A, float B, out float Out)
                                        {
                                            Out = A / B;
                                        }

                                        void Unity_Power_float(float A, float B, out float Out)
                                        {
                                            Out = pow(A, B);
                                        }

                                        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                        {
                                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                        }

                                        void Unity_Absolute_float(float In, out float Out)
                                        {
                                            Out = abs(In);
                                        }

                                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                        {
                                            Out = smoothstep(Edge1, Edge2, In);
                                        }

                                        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                        {
                                            Out = A + B;
                                        }

                                        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                        {
                                            Out = lerp(A, B, T);
                                        }

                                        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                                        {
                                            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                                        }

                                        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                        {
                                            Out = A + B;
                                        }

                                        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                        {
                                            if (unity_OrthoParams.w == 1.0)
                                            {
                                                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                            }
                                            else
                                            {
                                                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                            }
                                        }

                                        void Unity_Subtract_float(float A, float B, out float Out)
                                        {
                                            Out = A - B;
                                        }

                                        // Custom interpolators pre vertex
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                            float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                            float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                            float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                            float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                            float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                            float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                            Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                            float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                            float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                            float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                            Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                            float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                            float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                            Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                            float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                            Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                            float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                            Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                            float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                            float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                            Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                            float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                            float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                            float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                            Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                            float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                            Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                            float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                            Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                            float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                            float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                            float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                            float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                            float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                            float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                            Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                            float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                            Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                            float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                            Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                            float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                            Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                            float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                            Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                            float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                            float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                            float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                            Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                            float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                            description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                            description.Normal = IN.ObjectSpaceNormal;
                                            description.Tangent = IN.ObjectSpaceTangent;
                                            return description;
                                        }

                                        // Custom interpolators, pre surface
                                        #ifdef FEATURES_GRAPH_VERTEX
                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                        {
                                        return output;
                                        }
                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                        #endif

                                        // Graph Pixel
                                        struct SurfaceDescription
                                        {
                                            float3 BaseColor;
                                            float3 NormalTS;
                                            float3 Emission;
                                            float Metallic;
                                            float Smoothness;
                                            float Occlusion;
                                            float Alpha;
                                        };

                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                        {
                                            SurfaceDescription surface = (SurfaceDescription)0;
                                            float4 _Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0 = _Bottom_Color;
                                            float4 _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0 = _Top_Color;
                                            float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                            float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                            float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                            float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                            float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                            float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                            Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                            float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                            float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                            float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                            Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                            float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                            float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                            Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                            float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                            Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                            float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                            Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                            float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                            float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                            Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                            float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                            float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                            float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                            Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                            float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                            Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                            float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                            Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                            float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                            float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                            float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                            float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                            float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                            float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                            Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                            float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                            Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                            float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                            Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                            float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                            Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                            float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                            Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                            float4 _Lerp_16f9701748ff4980936cc58aa19de661_Out_3;
                                            Unity_Lerp_float4(_Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0, _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxxx), _Lerp_16f9701748ff4980936cc58aa19de661_Out_3);
                                            float _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0 = _Fresnel_Power;
                                            float _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3;
                                            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3);
                                            float _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2;
                                            Unity_Multiply_float_float(_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3, _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2);
                                            float _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0 = _Fresnel_Opacity;
                                            float _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2;
                                            Unity_Multiply_float_float(_Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2, _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0, _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2);
                                            float4 _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2;
                                            Unity_Add_float4(_Lerp_16f9701748ff4980936cc58aa19de661_Out_3, (_Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2.xxxx), _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2);
                                            float _Property_c362b4b09f5f401e9a18414784876557_Out_0 = _Emission;
                                            float4 _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2;
                                            Unity_Multiply_float4_float4(_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2, (_Property_c362b4b09f5f401e9a18414784876557_Out_0.xxxx), _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2);
                                            float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                            float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                            float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                            float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                            float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                            float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                            float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                            Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                            float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                            Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                            float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                            float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                            Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                            surface.BaseColor = (_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2.xyz);
                                            surface.NormalTS = IN.TangentSpaceNormal;
                                            surface.Emission = (_Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2.xyz);
                                            surface.Metallic = 0;
                                            surface.Smoothness = 0.5;
                                            surface.Occlusion = 1;
                                            surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                            return surface;
                                        }

                                        // --------------------------------------------------
                                        // Build Graph Inputs
                                        #ifdef HAVE_VFX_MODIFICATION
                                        #define VFX_SRP_ATTRIBUTES Attributes
                                        #define VFX_SRP_VARYINGS Varyings
                                        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                        #endif
                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                        {
                                            VertexDescriptionInputs output;
                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                            output.ObjectSpaceNormal = input.normalOS;
                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                            output.ObjectSpacePosition = input.positionOS;
                                            output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                            output.TimeParameters = _TimeParameters.xyz;

                                            return output;
                                        }
                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                        {
                                            SurfaceDescriptionInputs output;
                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                        #ifdef HAVE_VFX_MODIFICATION
                                            // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                        #endif



                                            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                            float3 unnormalizedNormalWS = input.normalWS;
                                            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                                            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
                                            output.WorldSpacePosition = input.positionWS;
                                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                        // --------------------------------------------------
                                        // Visual Effect Vertex Invocations
                                        #ifdef HAVE_VFX_MODIFICATION
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                        #endif

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
                                            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                            // GraphKeywords: <None>

                                            // Defines

                                            #define _NORMALMAP 1
                                            #define _NORMAL_DROPOFF_TS 1
                                            #define ATTRIBUTES_NEED_NORMAL
                                            #define ATTRIBUTES_NEED_TANGENT
                                            #define VARYINGS_NEED_POSITION_WS
                                            #define VARYINGS_NEED_NORMAL_WS
                                            #define FEATURES_GRAPH_VERTEX
                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                            #define SHADERPASS SHADERPASS_SHADOWCASTER
                                            #define REQUIRE_DEPTH_TEXTURE
                                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                            // custom interpolator pre-include
                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                            // Includes
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                            // --------------------------------------------------
                                            // Structs and Packing

                                            // custom interpolators pre packing
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                            struct Attributes
                                            {
                                                 float3 positionOS : POSITION;
                                                 float3 normalOS : NORMAL;
                                                 float4 tangentOS : TANGENT;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                #endif
                                            };
                                            struct Varyings
                                            {
                                                 float4 positionCS : SV_POSITION;
                                                 float3 positionWS;
                                                 float3 normalWS;
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
                                                 float4 ScreenPosition;
                                            };
                                            struct VertexDescriptionInputs
                                            {
                                                 float3 ObjectSpaceNormal;
                                                 float3 ObjectSpaceTangent;
                                                 float3 ObjectSpacePosition;
                                                 float3 WorldSpacePosition;
                                                 float3 TimeParameters;
                                            };
                                            struct PackedVaryings
                                            {
                                                 float4 positionCS : SV_POSITION;
                                                 float3 interp0 : INTERP0;
                                                 float3 interp1 : INTERP1;
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

                                            PackedVaryings PackVaryings(Varyings input)
                                            {
                                                PackedVaryings output;
                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                output.positionCS = input.positionCS;
                                                output.interp0.xyz = input.positionWS;
                                                output.interp1.xyz = input.normalWS;
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

                                            Varyings UnpackVaryings(PackedVaryings input)
                                            {
                                                Varyings output;
                                                output.positionCS = input.positionCS;
                                                output.positionWS = input.interp0.xyz;
                                                output.normalWS = input.interp1.xyz;
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
                                            float4 _Rotate_Property;
                                            float _Noise_Scale;
                                            float _Speed;
                                            float _Cloud_Height;
                                            float2 _In_Min_Max;
                                            float2 _Out_Min_Max;
                                            float4 _Top_Color;
                                            float4 _Bottom_Color;
                                            float2 _Smooth;
                                            float _Power;
                                            float _BaseNoise_Scale;
                                            float _BaseNoise_Speed;
                                            float _BaseNoise_Strength;
                                            float _Emission;
                                            float _Fresnel_Power;
                                            float _Fresnel_Opacity;
                                            float _Density;
                                            CBUFFER_END

                                                // Object and Global properties

                                                // Graph Includes
                                                // GraphIncludes: <None>

                                                // -- Property used by ScenePickingPass
                                                #ifdef SCENEPICKINGPASS
                                                float4 _SelectionID;
                                                #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                            {
                                                Rotation = radians(Rotation);

                                                float s = sin(Rotation);
                                                float c = cos(Rotation);
                                                float one_minus_c = 1.0 - c;

                                                Axis = normalize(Axis);

                                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                        };

                                                Out = mul(rot_mat,  In);
                                            }

                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }


                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                            {
                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                p = p % 289;
                                                // need full precision, otherwise half overflows when p > 1
                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                x = (34 * x + 1) * x % 289;
                                                x = frac(x / 41) * 2 - 1;
                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                            }

                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                            {
                                                float2 p = UV * Scale;
                                                float2 ip = floor(p);
                                                float2 fp = frac(p);
                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                            }

                                            void Unity_Add_float(float A, float B, out float Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Divide_float(float A, float B, out float Out)
                                            {
                                                Out = A / B;
                                            }

                                            void Unity_Power_float(float A, float B, out float Out)
                                            {
                                                Out = pow(A, B);
                                            }

                                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                            {
                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                            }

                                            void Unity_Absolute_float(float In, out float Out)
                                            {
                                                Out = abs(In);
                                            }

                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                            {
                                                Out = smoothstep(Edge1, Edge2, In);
                                            }

                                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                            {
                                                if (unity_OrthoParams.w == 1.0)
                                                {
                                                    Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                                }
                                                else
                                                {
                                                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                }
                                            }

                                            void Unity_Subtract_float(float A, float B, out float Out)
                                            {
                                                Out = A - B;
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                                float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                                float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                                float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                                float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                                Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                                float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                                float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                                Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                                float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                                float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                                float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                                Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                                float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                                float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                                Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                                float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                                Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                                float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                                Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                                float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                                float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                                Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                                float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                                float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                                float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                                Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                                float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                                Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                                float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                                Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                                float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                                float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                                float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                                float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                                float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                                float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                                Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                                float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                                Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                                float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                                Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                                float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                                Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                                float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                                Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                                float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                                Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                                float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                                float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                                Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                                float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                                description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float Alpha;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                                float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                                float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                                float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                                float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                                float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                                float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                                Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                                float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                                Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                                float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                                float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                                surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;
                                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                                output.TimeParameters = _TimeParameters.xyz;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif







                                                output.WorldSpacePosition = input.positionWS;
                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "DepthNormals"
                                                Tags
                                                {
                                                    "LightMode" = "DepthNormals"
                                                }

                                                // Render State
                                                Cull Back
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
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // DotsInstancingOptions: <None>
                                                // HybridV1InjectedBuiltinProperties: <None>

                                                // Keywords
                                                // PassKeywords: <None>
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define VARYINGS_NEED_NORMAL_WS
                                                #define VARYINGS_NEED_TANGENT_WS
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                                #define REQUIRE_DEPTH_TEXTURE
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                     float4 uv1 : TEXCOORD1;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                     float3 normalWS;
                                                     float4 tangentWS;
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
                                                     float3 TangentSpaceNormal;
                                                     float3 WorldSpacePosition;
                                                     float4 ScreenPosition;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                     float3 WorldSpacePosition;
                                                     float3 TimeParameters;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 interp0 : INTERP0;
                                                     float3 interp1 : INTERP1;
                                                     float4 interp2 : INTERP2;
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

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyz = input.positionWS;
                                                    output.interp1.xyz = input.normalWS;
                                                    output.interp2.xyzw = input.tangentWS;
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

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.positionWS = input.interp0.xyz;
                                                    output.normalWS = input.interp1.xyz;
                                                    output.tangentWS = input.interp2.xyzw;
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
                                                float4 _Rotate_Property;
                                                float _Noise_Scale;
                                                float _Speed;
                                                float _Cloud_Height;
                                                float2 _In_Min_Max;
                                                float2 _Out_Min_Max;
                                                float4 _Top_Color;
                                                float4 _Bottom_Color;
                                                float2 _Smooth;
                                                float _Power;
                                                float _BaseNoise_Scale;
                                                float _BaseNoise_Speed;
                                                float _BaseNoise_Strength;
                                                float _Emission;
                                                float _Fresnel_Power;
                                                float _Fresnel_Opacity;
                                                float _Density;
                                                CBUFFER_END

                                                    // Object and Global properties

                                                    // Graph Includes
                                                    // GraphIncludes: <None>

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                // -- Properties used by SceneSelectionPass
                                                #ifdef SCENESELECTIONPASS
                                                int _ObjectId;
                                                int _PassValue;
                                                #endif

                                                // Graph Functions

                                                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                {
                                                    Rotation = radians(Rotation);

                                                    float s = sin(Rotation);
                                                    float c = cos(Rotation);
                                                    float one_minus_c = 1.0 - c;

                                                    Axis = normalize(Axis);

                                                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                            };

                                                    Out = mul(rot_mat,  In);
                                                }

                                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                {
                                                    Out = UV * Tiling + Offset;
                                                }


                                                float2 Unity_GradientNoise_Dir_float(float2 p)
                                                {
                                                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                    p = p % 289;
                                                    // need full precision, otherwise half overflows when p > 1
                                                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                    x = (34 * x + 1) * x % 289;
                                                    x = frac(x / 41) * 2 - 1;
                                                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                }

                                                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                {
                                                    float2 p = UV * Scale;
                                                    float2 ip = floor(p);
                                                    float2 fp = frac(p);
                                                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                }

                                                void Unity_Add_float(float A, float B, out float Out)
                                                {
                                                    Out = A + B;
                                                }

                                                void Unity_Divide_float(float A, float B, out float Out)
                                                {
                                                    Out = A / B;
                                                }

                                                void Unity_Power_float(float A, float B, out float Out)
                                                {
                                                    Out = pow(A, B);
                                                }

                                                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                {
                                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                }

                                                void Unity_Absolute_float(float In, out float Out)
                                                {
                                                    Out = abs(In);
                                                }

                                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                {
                                                    Out = smoothstep(Edge1, Edge2, In);
                                                }

                                                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                {
                                                    Out = A + B;
                                                }

                                                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                                {
                                                    if (unity_OrthoParams.w == 1.0)
                                                    {
                                                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                                    }
                                                    else
                                                    {
                                                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                    }
                                                }

                                                void Unity_Subtract_float(float A, float B, out float Out)
                                                {
                                                    Out = A - B;
                                                }

                                                // Custom interpolators pre vertex
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                                    float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                                    float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                                    float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                                    float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                                    float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                                    float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                                    Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                                    float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                                    float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                                    float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                                    Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                                    float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                                    float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                                    Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                                    float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                                    Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                                    float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                                    Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                                    float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                                    float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                                    Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                                    float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                                    float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                                    float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                                    Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                                    float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                                    Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                                    float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                                    Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                                    float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                                    float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                                    float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                                    float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                                    float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                                    float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                                    Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                                    float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                                    Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                                    float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                                    Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                                    float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                                    Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                                    float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                                    Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                                    float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                                    float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                                    float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                                    Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                                    float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                                    description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                    description.Normal = IN.ObjectSpaceNormal;
                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                    return description;
                                                }

                                                // Custom interpolators, pre surface
                                                #ifdef FEATURES_GRAPH_VERTEX
                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                {
                                                return output;
                                                }
                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                #endif

                                                // Graph Pixel
                                                struct SurfaceDescription
                                                {
                                                    float3 NormalTS;
                                                    float Alpha;
                                                };

                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                {
                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                    float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                                    float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                                    float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                                    float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                                    float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                                    float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                                    float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                                    Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                                    float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                                    Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                                    float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                                    float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                    Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                                    surface.NormalTS = IN.TangentSpaceNormal;
                                                    surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                    return surface;
                                                }

                                                // --------------------------------------------------
                                                // Build Graph Inputs
                                                #ifdef HAVE_VFX_MODIFICATION
                                                #define VFX_SRP_ATTRIBUTES Attributes
                                                #define VFX_SRP_VARYINGS Varyings
                                                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                #endif
                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                {
                                                    VertexDescriptionInputs output;
                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                    output.ObjectSpaceNormal = input.normalOS;
                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                    output.ObjectSpacePosition = input.positionOS;
                                                    output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                                    output.TimeParameters = _TimeParameters.xyz;

                                                    return output;
                                                }
                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                {
                                                    SurfaceDescriptionInputs output;
                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                #ifdef HAVE_VFX_MODIFICATION
                                                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                #endif





                                                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                    output.WorldSpacePosition = input.positionWS;
                                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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

                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                // --------------------------------------------------
                                                // Visual Effect Vertex Invocations
                                                #ifdef HAVE_VFX_MODIFICATION
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                #endif

                                                ENDHLSL
                                                }
                                                Pass
                                                {
                                                    Name "Meta"
                                                    Tags
                                                    {
                                                        "LightMode" = "Meta"
                                                    }

                                                    // Render State
                                                    Cull Off

                                                    // Debug
                                                    // <None>

                                                    // --------------------------------------------------
                                                    // Pass

                                                    HLSLPROGRAM

                                                    // Pragmas
                                                    #pragma target 2.0
                                                    #pragma only_renderers gles gles3 glcore d3d11
                                                    #pragma vertex vert
                                                    #pragma fragment frag

                                                    // DotsInstancingOptions: <None>
                                                    // HybridV1InjectedBuiltinProperties: <None>

                                                    // Keywords
                                                    #pragma shader_feature _ EDITOR_VISUALIZATION
                                                    // GraphKeywords: <None>

                                                    // Defines

                                                    #define _NORMALMAP 1
                                                    #define _NORMAL_DROPOFF_TS 1
                                                    #define ATTRIBUTES_NEED_NORMAL
                                                    #define ATTRIBUTES_NEED_TANGENT
                                                    #define ATTRIBUTES_NEED_TEXCOORD0
                                                    #define ATTRIBUTES_NEED_TEXCOORD1
                                                    #define ATTRIBUTES_NEED_TEXCOORD2
                                                    #define VARYINGS_NEED_POSITION_WS
                                                    #define VARYINGS_NEED_NORMAL_WS
                                                    #define VARYINGS_NEED_TEXCOORD0
                                                    #define VARYINGS_NEED_TEXCOORD1
                                                    #define VARYINGS_NEED_TEXCOORD2
                                                    #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                    #define FEATURES_GRAPH_VERTEX
                                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                    #define SHADERPASS SHADERPASS_META
                                                    #define _FOG_FRAGMENT 1
                                                    #define REQUIRE_DEPTH_TEXTURE
                                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                    // custom interpolator pre-include
                                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                    // Includes
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Structs and Packing

                                                    // custom interpolators pre packing
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                    struct Attributes
                                                    {
                                                         float3 positionOS : POSITION;
                                                         float3 normalOS : NORMAL;
                                                         float4 tangentOS : TANGENT;
                                                         float4 uv0 : TEXCOORD0;
                                                         float4 uv1 : TEXCOORD1;
                                                         float4 uv2 : TEXCOORD2;
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
                                                         float4 texCoord1;
                                                         float4 texCoord2;
                                                         float3 viewDirectionWS;
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
                                                         float3 WorldSpaceViewDirection;
                                                         float3 WorldSpacePosition;
                                                         float4 ScreenPosition;
                                                         float3 TimeParameters;
                                                    };
                                                    struct VertexDescriptionInputs
                                                    {
                                                         float3 ObjectSpaceNormal;
                                                         float3 ObjectSpaceTangent;
                                                         float3 ObjectSpacePosition;
                                                         float3 WorldSpacePosition;
                                                         float3 TimeParameters;
                                                    };
                                                    struct PackedVaryings
                                                    {
                                                         float4 positionCS : SV_POSITION;
                                                         float3 interp0 : INTERP0;
                                                         float3 interp1 : INTERP1;
                                                         float4 interp2 : INTERP2;
                                                         float4 interp3 : INTERP3;
                                                         float4 interp4 : INTERP4;
                                                         float3 interp5 : INTERP5;
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

                                                    PackedVaryings PackVaryings(Varyings input)
                                                    {
                                                        PackedVaryings output;
                                                        ZERO_INITIALIZE(PackedVaryings, output);
                                                        output.positionCS = input.positionCS;
                                                        output.interp0.xyz = input.positionWS;
                                                        output.interp1.xyz = input.normalWS;
                                                        output.interp2.xyzw = input.texCoord0;
                                                        output.interp3.xyzw = input.texCoord1;
                                                        output.interp4.xyzw = input.texCoord2;
                                                        output.interp5.xyz = input.viewDirectionWS;
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

                                                    Varyings UnpackVaryings(PackedVaryings input)
                                                    {
                                                        Varyings output;
                                                        output.positionCS = input.positionCS;
                                                        output.positionWS = input.interp0.xyz;
                                                        output.normalWS = input.interp1.xyz;
                                                        output.texCoord0 = input.interp2.xyzw;
                                                        output.texCoord1 = input.interp3.xyzw;
                                                        output.texCoord2 = input.interp4.xyzw;
                                                        output.viewDirectionWS = input.interp5.xyz;
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
                                                    float4 _Rotate_Property;
                                                    float _Noise_Scale;
                                                    float _Speed;
                                                    float _Cloud_Height;
                                                    float2 _In_Min_Max;
                                                    float2 _Out_Min_Max;
                                                    float4 _Top_Color;
                                                    float4 _Bottom_Color;
                                                    float2 _Smooth;
                                                    float _Power;
                                                    float _BaseNoise_Scale;
                                                    float _BaseNoise_Speed;
                                                    float _BaseNoise_Strength;
                                                    float _Emission;
                                                    float _Fresnel_Power;
                                                    float _Fresnel_Opacity;
                                                    float _Density;
                                                    CBUFFER_END

                                                        // Object and Global properties

                                                        // Graph Includes
                                                        // GraphIncludes: <None>

                                                        // -- Property used by ScenePickingPass
                                                        #ifdef SCENEPICKINGPASS
                                                        float4 _SelectionID;
                                                        #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                    {
                                                        Rotation = radians(Rotation);

                                                        float s = sin(Rotation);
                                                        float c = cos(Rotation);
                                                        float one_minus_c = 1.0 - c;

                                                        Axis = normalize(Axis);

                                                        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                };

                                                        Out = mul(rot_mat,  In);
                                                    }

                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }


                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                    {
                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                        p = p % 289;
                                                        // need full precision, otherwise half overflows when p > 1
                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                        x = (34 * x + 1) * x % 289;
                                                        x = frac(x / 41) * 2 - 1;
                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                    }

                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                    {
                                                        float2 p = UV * Scale;
                                                        float2 ip = floor(p);
                                                        float2 fp = frac(p);
                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                    }

                                                    void Unity_Add_float(float A, float B, out float Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                    {
                                                        Out = A / B;
                                                    }

                                                    void Unity_Power_float(float A, float B, out float Out)
                                                    {
                                                        Out = pow(A, B);
                                                    }

                                                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                    {
                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                    }

                                                    void Unity_Absolute_float(float In, out float Out)
                                                    {
                                                        Out = abs(In);
                                                    }

                                                    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                    {
                                                        Out = smoothstep(Edge1, Edge2, In);
                                                    }

                                                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                    {
                                                        Out = lerp(A, B, T);
                                                    }

                                                    void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                                                    {
                                                        Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                                                    }

                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                                    {
                                                        if (unity_OrthoParams.w == 1.0)
                                                        {
                                                            Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                                        }
                                                        else
                                                        {
                                                            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                        }
                                                    }

                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                    {
                                                        Out = A - B;
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                                        float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                                        float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                                        float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                                        float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                                        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                                        float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                                        float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                                        Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                                        float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                                        float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                                        float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                                        Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                                        float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                                        float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                                        Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                                        float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                                        Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                                        float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                                        Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                                        float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                                        float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                                        Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                                        float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                                        float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                                        float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                                        Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                                        float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                                        Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                                        float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                                        Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                                        float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                                        float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                                        float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                                        float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                                        float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                                        float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                                        Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                                        float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                                        Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                                        float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                                        Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                                        float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                                        Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                                        float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                                        Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                                        float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                                        Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                                        float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                                        float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                                        Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                                        float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                                        description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float3 BaseColor;
                                                        float3 Emission;
                                                        float Alpha;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        float4 _Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0 = _Bottom_Color;
                                                        float4 _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0 = _Top_Color;
                                                        float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                                        float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                                        float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                                        float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                                        float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                                        float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                                        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                                        float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                                        float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                                        Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                                        float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                                        float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                                        float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                                        Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                                        float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                                        float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                                        Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                                        float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                                        Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                                        float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                                        Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                                        float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                                        float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                                        Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                                        float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                                        float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                                        float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                                        Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                                        float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                                        Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                                        float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                                        Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                                        float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                                        float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                                        float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                                        float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                                        Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                                        float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                                        float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                                        Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                                        float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                                        Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                                        float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                                        Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                                        float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                                        Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                                        float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                                        Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                                        float4 _Lerp_16f9701748ff4980936cc58aa19de661_Out_3;
                                                        Unity_Lerp_float4(_Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0, _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxxx), _Lerp_16f9701748ff4980936cc58aa19de661_Out_3);
                                                        float _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0 = _Fresnel_Power;
                                                        float _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3;
                                                        Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3);
                                                        float _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2;
                                                        Unity_Multiply_float_float(_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3, _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2);
                                                        float _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0 = _Fresnel_Opacity;
                                                        float _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2;
                                                        Unity_Multiply_float_float(_Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2, _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0, _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2);
                                                        float4 _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2;
                                                        Unity_Add_float4(_Lerp_16f9701748ff4980936cc58aa19de661_Out_3, (_Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2.xxxx), _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2);
                                                        float _Property_c362b4b09f5f401e9a18414784876557_Out_0 = _Emission;
                                                        float4 _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2;
                                                        Unity_Multiply_float4_float4(_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2, (_Property_c362b4b09f5f401e9a18414784876557_Out_0.xxxx), _Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2);
                                                        float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                                        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                                        float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                                        float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                                        float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                                        float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                                        float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                                        float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                                        Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                                        float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                                        Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                                        float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                                        float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                        Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                                        surface.BaseColor = (_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2.xyz);
                                                        surface.Emission = (_Multiply_6c1e11374f0843f7bdf83ff845591f8e_Out_2.xyz);
                                                        surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;
                                                        output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                                        output.TimeParameters = _TimeParameters.xyz;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif



                                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                        float3 unnormalizedNormalWS = input.normalWS;
                                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                        output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
                                                        output.WorldSpacePosition = input.positionWS;
                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "SceneSelectionPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "SceneSelectionPass"
                                                        }

                                                        // Render State
                                                        Cull Off

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

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define VARYINGS_NEED_POSITION_WS
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENESELECTIONPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                        #define REQUIRE_DEPTH_TEXTURE
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 positionWS;
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
                                                             float4 ScreenPosition;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                             float3 WorldSpacePosition;
                                                             float3 TimeParameters;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 interp0 : INTERP0;
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

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            output.interp0.xyz = input.positionWS;
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

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            output.positionWS = input.interp0.xyz;
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
                                                        float4 _Rotate_Property;
                                                        float _Noise_Scale;
                                                        float _Speed;
                                                        float _Cloud_Height;
                                                        float2 _In_Min_Max;
                                                        float2 _Out_Min_Max;
                                                        float4 _Top_Color;
                                                        float4 _Bottom_Color;
                                                        float2 _Smooth;
                                                        float _Power;
                                                        float _BaseNoise_Scale;
                                                        float _BaseNoise_Speed;
                                                        float _BaseNoise_Strength;
                                                        float _Emission;
                                                        float _Fresnel_Power;
                                                        float _Fresnel_Opacity;
                                                        float _Density;
                                                        CBUFFER_END

                                                            // Object and Global properties

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                        // -- Properties used by SceneSelectionPass
                                                        #ifdef SCENESELECTIONPASS
                                                        int _ObjectId;
                                                        int _PassValue;
                                                        #endif

                                                        // Graph Functions

                                                        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                        {
                                                            Rotation = radians(Rotation);

                                                            float s = sin(Rotation);
                                                            float c = cos(Rotation);
                                                            float one_minus_c = 1.0 - c;

                                                            Axis = normalize(Axis);

                                                            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                    };

                                                            Out = mul(rot_mat,  In);
                                                        }

                                                        void Unity_Multiply_float_float(float A, float B, out float Out)
                                                        {
                                                            Out = A * B;
                                                        }

                                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                        {
                                                            Out = UV * Tiling + Offset;
                                                        }


                                                        float2 Unity_GradientNoise_Dir_float(float2 p)
                                                        {
                                                            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                            p = p % 289;
                                                            // need full precision, otherwise half overflows when p > 1
                                                            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                            x = (34 * x + 1) * x % 289;
                                                            x = frac(x / 41) * 2 - 1;
                                                            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                        }

                                                        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                        {
                                                            float2 p = UV * Scale;
                                                            float2 ip = floor(p);
                                                            float2 fp = frac(p);
                                                            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                        }

                                                        void Unity_Add_float(float A, float B, out float Out)
                                                        {
                                                            Out = A + B;
                                                        }

                                                        void Unity_Divide_float(float A, float B, out float Out)
                                                        {
                                                            Out = A / B;
                                                        }

                                                        void Unity_Power_float(float A, float B, out float Out)
                                                        {
                                                            Out = pow(A, B);
                                                        }

                                                        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                        {
                                                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                        }

                                                        void Unity_Absolute_float(float In, out float Out)
                                                        {
                                                            Out = abs(In);
                                                        }

                                                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                        {
                                                            Out = smoothstep(Edge1, Edge2, In);
                                                        }

                                                        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                        {
                                                            Out = A * B;
                                                        }

                                                        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                        {
                                                            Out = A + B;
                                                        }

                                                        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                                        {
                                                            if (unity_OrthoParams.w == 1.0)
                                                            {
                                                                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                                            }
                                                            else
                                                            {
                                                                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                            }
                                                        }

                                                        void Unity_Subtract_float(float A, float B, out float Out)
                                                        {
                                                            Out = A - B;
                                                        }

                                                        // Custom interpolators pre vertex
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                                            float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                                            float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                                            float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                                            float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                                            float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                                            float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                                            Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                                            float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                                            float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                                            Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                                            float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                                            float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                                            float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                                            Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                                            float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                                            float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                                            Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                                            float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                                            Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                                            float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                                            Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                                            float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                                            float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                                            Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                                            float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                                            float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                                            float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                                            Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                                            float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                                            Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                                            float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                                            Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                                            float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                                            float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                                            float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                                            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                                            float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                                            Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                                            float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                                            float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                                            Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                                            float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                                            Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                                            float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                                            Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                                            float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                                            Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                                            float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                                            Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                                            float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                                            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                                            float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                                            float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                                            Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                                            float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                                            description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                            description.Normal = IN.ObjectSpaceNormal;
                                                            description.Tangent = IN.ObjectSpaceTangent;
                                                            return description;
                                                        }

                                                        // Custom interpolators, pre surface
                                                        #ifdef FEATURES_GRAPH_VERTEX
                                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                        {
                                                        return output;
                                                        }
                                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                        #endif

                                                        // Graph Pixel
                                                        struct SurfaceDescription
                                                        {
                                                            float Alpha;
                                                        };

                                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                        {
                                                            SurfaceDescription surface = (SurfaceDescription)0;
                                                            float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                                            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                                            float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                                            float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                                            float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                                            float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                                            float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                                            float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                                            Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                                            float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                                            Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                                            float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                                            float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                            Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                                            surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                            return surface;
                                                        }

                                                        // --------------------------------------------------
                                                        // Build Graph Inputs
                                                        #ifdef HAVE_VFX_MODIFICATION
                                                        #define VFX_SRP_ATTRIBUTES Attributes
                                                        #define VFX_SRP_VARYINGS Varyings
                                                        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                        #endif
                                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                        {
                                                            VertexDescriptionInputs output;
                                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                            output.ObjectSpaceNormal = input.normalOS;
                                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                            output.ObjectSpacePosition = input.positionOS;
                                                            output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                                            output.TimeParameters = _TimeParameters.xyz;

                                                            return output;
                                                        }
                                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                        {
                                                            SurfaceDescriptionInputs output;
                                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                        #ifdef HAVE_VFX_MODIFICATION
                                                            // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                        #endif







                                                            output.WorldSpacePosition = input.positionWS;
                                                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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

                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Visual Effect Vertex Invocations
                                                        #ifdef HAVE_VFX_MODIFICATION
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                        #endif

                                                        ENDHLSL
                                                        }
                                                        Pass
                                                        {
                                                            Name "ScenePickingPass"
                                                            Tags
                                                            {
                                                                "LightMode" = "Picking"
                                                            }

                                                            // Render State
                                                            Cull Back

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

                                                            #define _NORMALMAP 1
                                                            #define _NORMAL_DROPOFF_TS 1
                                                            #define ATTRIBUTES_NEED_NORMAL
                                                            #define ATTRIBUTES_NEED_TANGENT
                                                            #define VARYINGS_NEED_POSITION_WS
                                                            #define FEATURES_GRAPH_VERTEX
                                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                            #define SHADERPASS SHADERPASS_DEPTHONLY
                                                            #define SCENEPICKINGPASS 1
                                                            #define ALPHA_CLIP_THRESHOLD 1
                                                            #define REQUIRE_DEPTH_TEXTURE
                                                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                            // custom interpolator pre-include
                                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                            // Includes
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Structs and Packing

                                                            // custom interpolators pre packing
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                            struct Attributes
                                                            {
                                                                 float3 positionOS : POSITION;
                                                                 float3 normalOS : NORMAL;
                                                                 float4 tangentOS : TANGENT;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                                #endif
                                                            };
                                                            struct Varyings
                                                            {
                                                                 float4 positionCS : SV_POSITION;
                                                                 float3 positionWS;
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
                                                                 float4 ScreenPosition;
                                                            };
                                                            struct VertexDescriptionInputs
                                                            {
                                                                 float3 ObjectSpaceNormal;
                                                                 float3 ObjectSpaceTangent;
                                                                 float3 ObjectSpacePosition;
                                                                 float3 WorldSpacePosition;
                                                                 float3 TimeParameters;
                                                            };
                                                            struct PackedVaryings
                                                            {
                                                                 float4 positionCS : SV_POSITION;
                                                                 float3 interp0 : INTERP0;
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

                                                            PackedVaryings PackVaryings(Varyings input)
                                                            {
                                                                PackedVaryings output;
                                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                                output.positionCS = input.positionCS;
                                                                output.interp0.xyz = input.positionWS;
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

                                                            Varyings UnpackVaryings(PackedVaryings input)
                                                            {
                                                                Varyings output;
                                                                output.positionCS = input.positionCS;
                                                                output.positionWS = input.interp0.xyz;
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
                                                            float4 _Rotate_Property;
                                                            float _Noise_Scale;
                                                            float _Speed;
                                                            float _Cloud_Height;
                                                            float2 _In_Min_Max;
                                                            float2 _Out_Min_Max;
                                                            float4 _Top_Color;
                                                            float4 _Bottom_Color;
                                                            float2 _Smooth;
                                                            float _Power;
                                                            float _BaseNoise_Scale;
                                                            float _BaseNoise_Speed;
                                                            float _BaseNoise_Strength;
                                                            float _Emission;
                                                            float _Fresnel_Power;
                                                            float _Fresnel_Opacity;
                                                            float _Density;
                                                            CBUFFER_END

                                                                // Object and Global properties

                                                                // Graph Includes
                                                                // GraphIncludes: <None>

                                                                // -- Property used by ScenePickingPass
                                                                #ifdef SCENEPICKINGPASS
                                                                float4 _SelectionID;
                                                                #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions

                                                            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                            {
                                                                Rotation = radians(Rotation);

                                                                float s = sin(Rotation);
                                                                float c = cos(Rotation);
                                                                float one_minus_c = 1.0 - c;

                                                                Axis = normalize(Axis);

                                                                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                        };

                                                                Out = mul(rot_mat,  In);
                                                            }

                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                            {
                                                                Out = UV * Tiling + Offset;
                                                            }


                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                            {
                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                p = p % 289;
                                                                // need full precision, otherwise half overflows when p > 1
                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                x = (34 * x + 1) * x % 289;
                                                                x = frac(x / 41) * 2 - 1;
                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                            }

                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                            {
                                                                float2 p = UV * Scale;
                                                                float2 ip = floor(p);
                                                                float2 fp = frac(p);
                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                            }

                                                            void Unity_Add_float(float A, float B, out float Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                            {
                                                                Out = A / B;
                                                            }

                                                            void Unity_Power_float(float A, float B, out float Out)
                                                            {
                                                                Out = pow(A, B);
                                                            }

                                                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                            {
                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                            }

                                                            void Unity_Absolute_float(float In, out float Out)
                                                            {
                                                                Out = abs(In);
                                                            }

                                                            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                            {
                                                                Out = smoothstep(Edge1, Edge2, In);
                                                            }

                                                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                                            {
                                                                if (unity_OrthoParams.w == 1.0)
                                                                {
                                                                    Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                                                }
                                                                else
                                                                {
                                                                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                }
                                                            }

                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                            {
                                                                Out = A - B;
                                                            }

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                                                float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                                                float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                                                float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                                                float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                                                float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                                                float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                                                Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                                                float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                                                float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                                                Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                                                float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                                                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                                                float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                                                float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                                                Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                                                float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                                                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                                                float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                                                Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                                                float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                                                Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                                                float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                                                Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                                                float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                                                float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                                                Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                                                float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                                                float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                                                float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                                                Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                                                float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                                                Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                                                float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                                                Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                                                float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                                                float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                                                float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                                                float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                                                Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                                                float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                                                float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                                                Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                                                float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                                                Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                                                float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                                                Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                                                float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                                                Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                                                float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                                                Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                                                float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                                                Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                                                float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                                                float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                                                Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                                                float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                                Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                                                description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                                float Alpha;
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                                                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                                                float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                                                float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                                                float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                                                float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                                                float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                                                float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                                                Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                                                float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                                                Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                                                float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                                                float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                                Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                                                surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;
                                                                output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif







                                                                output.WorldSpacePosition = input.positionWS;
                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                // Name: <None>
                                                                Tags
                                                                {
                                                                    "LightMode" = "Universal2D"
                                                                }

                                                                // Render State
                                                                Cull Back
                                                                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                ZTest LEqual
                                                                ZWrite Off

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

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define VARYINGS_NEED_POSITION_WS
                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_2D
                                                                #define REQUIRE_DEPTH_TEXTURE
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 positionWS;
                                                                     float3 normalWS;
                                                                     float3 viewDirectionWS;
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
                                                                     float3 WorldSpaceViewDirection;
                                                                     float3 WorldSpacePosition;
                                                                     float4 ScreenPosition;
                                                                     float3 TimeParameters;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                     float3 WorldSpacePosition;
                                                                     float3 TimeParameters;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 interp0 : INTERP0;
                                                                     float3 interp1 : INTERP1;
                                                                     float3 interp2 : INTERP2;
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

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    output.interp0.xyz = input.positionWS;
                                                                    output.interp1.xyz = input.normalWS;
                                                                    output.interp2.xyz = input.viewDirectionWS;
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

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.positionWS = input.interp0.xyz;
                                                                    output.normalWS = input.interp1.xyz;
                                                                    output.viewDirectionWS = input.interp2.xyz;
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
                                                                float4 _Rotate_Property;
                                                                float _Noise_Scale;
                                                                float _Speed;
                                                                float _Cloud_Height;
                                                                float2 _In_Min_Max;
                                                                float2 _Out_Min_Max;
                                                                float4 _Top_Color;
                                                                float4 _Bottom_Color;
                                                                float2 _Smooth;
                                                                float _Power;
                                                                float _BaseNoise_Scale;
                                                                float _BaseNoise_Speed;
                                                                float _BaseNoise_Strength;
                                                                float _Emission;
                                                                float _Fresnel_Power;
                                                                float _Fresnel_Opacity;
                                                                float _Density;
                                                                CBUFFER_END

                                                                    // Object and Global properties

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                // -- Properties used by SceneSelectionPass
                                                                #ifdef SCENESELECTIONPASS
                                                                int _ObjectId;
                                                                int _PassValue;
                                                                #endif

                                                                // Graph Functions

                                                                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                                                                {
                                                                    Rotation = radians(Rotation);

                                                                    float s = sin(Rotation);
                                                                    float c = cos(Rotation);
                                                                    float one_minus_c = 1.0 - c;

                                                                    Axis = normalize(Axis);

                                                                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                                                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                                                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                                                                            };

                                                                    Out = mul(rot_mat,  In);
                                                                }

                                                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                {
                                                                    Out = A * B;
                                                                }

                                                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                {
                                                                    Out = UV * Tiling + Offset;
                                                                }


                                                                float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                {
                                                                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                    p = p % 289;
                                                                    // need full precision, otherwise half overflows when p > 1
                                                                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                    x = (34 * x + 1) * x % 289;
                                                                    x = frac(x / 41) * 2 - 1;
                                                                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                }

                                                                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                {
                                                                    float2 p = UV * Scale;
                                                                    float2 ip = floor(p);
                                                                    float2 fp = frac(p);
                                                                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                }

                                                                void Unity_Add_float(float A, float B, out float Out)
                                                                {
                                                                    Out = A + B;
                                                                }

                                                                void Unity_Divide_float(float A, float B, out float Out)
                                                                {
                                                                    Out = A / B;
                                                                }

                                                                void Unity_Power_float(float A, float B, out float Out)
                                                                {
                                                                    Out = pow(A, B);
                                                                }

                                                                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                                {
                                                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                }

                                                                void Unity_Absolute_float(float In, out float Out)
                                                                {
                                                                    Out = abs(In);
                                                                }

                                                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                {
                                                                    Out = smoothstep(Edge1, Edge2, In);
                                                                }

                                                                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                                {
                                                                    Out = A * B;
                                                                }

                                                                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                {
                                                                    Out = A + B;
                                                                }

                                                                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                {
                                                                    Out = lerp(A, B, T);
                                                                }

                                                                void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                                                                {
                                                                    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                                                                }

                                                                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                {
                                                                    Out = A + B;
                                                                }

                                                                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                                                                {
                                                                    if (unity_OrthoParams.w == 1.0)
                                                                    {
                                                                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                                                                    }
                                                                    else
                                                                    {
                                                                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                    }
                                                                }

                                                                void Unity_Subtract_float(float A, float B, out float Out)
                                                                {
                                                                    Out = A - B;
                                                                }

                                                                // Custom interpolators pre vertex
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

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
                                                                    float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                                                    float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                                                    float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                                                    float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                                                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                                                    float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                                                    float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                                                    Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                                                    float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                                                    float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                                                    float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                                                    Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                                                    float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                                                    float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                                                    Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                                                    float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                                                    Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                                                    float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                                                    Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                                                    float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                                                    float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                                                    Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                                                    float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                                                    float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                                                    float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                                                    Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                                                    float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                                                    Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                                                    float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                                                    Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                                                    float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                                                    float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                                                    float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                                                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                                                    float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                                                    float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                                                    float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                                                    Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                                                    float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                                                    Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                                                    float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                                                    Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                                                    float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                                                    Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                                                    float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                                                    Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                                                    float3 _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2;
                                                                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxx), _Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2);
                                                                    float _Property_748fa86fd30a4266973470ed9c90ddae_Out_0 = _Cloud_Height;
                                                                    float3 _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2;
                                                                    Unity_Multiply_float3_float3(_Multiply_a6e07f0d6fe547789ca0fe4c42049ee1_Out_2, (_Property_748fa86fd30a4266973470ed9c90ddae_Out_0.xxx), _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2);
                                                                    float3 _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_83ab7f533d3e42989290f00cd464670b_Out_2, _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2);
                                                                    description.Position = _Add_d1d0223a51264cb89358cbfe5dbfeee7_Out_2;
                                                                    description.Normal = IN.ObjectSpaceNormal;
                                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                                    return description;
                                                                }

                                                                // Custom interpolators, pre surface
                                                                #ifdef FEATURES_GRAPH_VERTEX
                                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                {
                                                                return output;
                                                                }
                                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                #endif

                                                                // Graph Pixel
                                                                struct SurfaceDescription
                                                                {
                                                                    float3 BaseColor;
                                                                    float Alpha;
                                                                };

                                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                {
                                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                                    float4 _Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0 = _Bottom_Color;
                                                                    float4 _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0 = _Top_Color;
                                                                    float2 _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0 = _Smooth;
                                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[0];
                                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2 = _Property_c5bfa0edf3514da5b69514fd0d53870b_Out_0[1];
                                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_B_3 = 0;
                                                                    float _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_A_4 = 0;
                                                                    float4 _Property_71401d1c968741ce84ad1c55b762bb03_Out_0 = _Rotate_Property;
                                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_R_1 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[0];
                                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[1];
                                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[2];
                                                                    float _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4 = _Property_71401d1c968741ce84ad1c55b762bb03_Out_0[3];
                                                                    float3 _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0 = float3(_Split_16a7956f858a4f6eaa3da6da5af0373e_R_1, _Split_16a7956f858a4f6eaa3da6da5af0373e_G_2, _Split_16a7956f858a4f6eaa3da6da5af0373e_B_3);
                                                                    float3 _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3;
                                                                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, _Vector3_ad87dc7a11e64dabb4339642606955ed_Out_0, _Split_16a7956f858a4f6eaa3da6da5af0373e_A_4, _RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3);
                                                                    float _Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0 = _Speed;
                                                                    float _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2;
                                                                    Unity_Multiply_float_float(_Property_e2195c1fe49c48ebaecdc70deff7630c_Out_0, IN.TimeParameters.x, _Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2);
                                                                    float2 _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3;
                                                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_35f62e3f078c4c968a89e604df3caff1_Out_2.xx), _TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3);
                                                                    float _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0 = _Noise_Scale;
                                                                    float _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2;
                                                                    Unity_GradientNoise_float(_TilingAndOffset_d69c75dbd00846e6b65c99d9a90555de_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2);
                                                                    float2 _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3;
                                                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3);
                                                                    float _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2;
                                                                    Unity_GradientNoise_float(_TilingAndOffset_324ef71976f44a08939fa0d49f5215d3_Out_3, _Property_52f565d8e8724fc2af1f93eff09b9983_Out_0, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2);
                                                                    float _Add_8746384d0f1d47219a01b29c39a062f2_Out_2;
                                                                    Unity_Add_float(_GradientNoise_a895ccdead904a3f94b5eef399dd77f7_Out_2, _GradientNoise_4761b6013b7c4d65816dba6f7d12b7fd_Out_2, _Add_8746384d0f1d47219a01b29c39a062f2_Out_2);
                                                                    float _Divide_1427232de5604a89b87427ea12c3749d_Out_2;
                                                                    Unity_Divide_float(_Add_8746384d0f1d47219a01b29c39a062f2_Out_2, 2, _Divide_1427232de5604a89b87427ea12c3749d_Out_2);
                                                                    float _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0 = _Power;
                                                                    float _Power_abda22ac52e04e1db38565fca89b0a17_Out_2;
                                                                    Unity_Power_float(_Divide_1427232de5604a89b87427ea12c3749d_Out_2, _Property_ba16cfed9a4149e087ba7981a34ccad0_Out_0, _Power_abda22ac52e04e1db38565fca89b0a17_Out_2);
                                                                    float2 _Property_22109af9288e42859e5e55845973acd7_Out_0 = _In_Min_Max;
                                                                    float2 _Property_5f772d43c30043f79a4da418d2dda486_Out_0 = _Out_Min_Max;
                                                                    float _Remap_9053e4aacb6743458da3c6249db75450_Out_3;
                                                                    Unity_Remap_float(_Power_abda22ac52e04e1db38565fca89b0a17_Out_2, _Property_22109af9288e42859e5e55845973acd7_Out_0, _Property_5f772d43c30043f79a4da418d2dda486_Out_0, _Remap_9053e4aacb6743458da3c6249db75450_Out_3);
                                                                    float _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1;
                                                                    Unity_Absolute_float(_Remap_9053e4aacb6743458da3c6249db75450_Out_3, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1);
                                                                    float _Smoothstep_06663a908bb540829f44189eb272936d_Out_3;
                                                                    Unity_Smoothstep_float(_Split_eb3c4eeb11b74fe38a0cd07abdf8919d_R_1, _Split_eb3c4eeb11b74fe38a0cd07abdf8919d_G_2, _Absolute_8be8aaece5d244a29aba094bdf35ceca_Out_1, _Smoothstep_06663a908bb540829f44189eb272936d_Out_3);
                                                                    float _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0 = _BaseNoise_Strength;
                                                                    float _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0 = _BaseNoise_Speed;
                                                                    float _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2;
                                                                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_fe9b68e9575d4f8d87607f8f91e3b906_Out_0, _Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2);
                                                                    float2 _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3;
                                                                    Unity_TilingAndOffset_float((_RotateAboutAxis_f310849bf4ed425ab052141aa1dfed72_Out_3.xy), float2 (1, 1), (_Multiply_b62fa989ceea4fc89cf989d284f7ee32_Out_2.xx), _TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3);
                                                                    float _Property_903f052fb4c647549603e3734407c34f_Out_0 = _BaseNoise_Scale;
                                                                    float _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2;
                                                                    Unity_GradientNoise_float(_TilingAndOffset_c68a0f09f3f34e0e969a37dbd41c672b_Out_3, _Property_903f052fb4c647549603e3734407c34f_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2);
                                                                    float _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2;
                                                                    Unity_Multiply_float_float(_Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _GradientNoise_54c9f0ddd1df4ee0ad9c7a8a5c1c9e62_Out_2, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2);
                                                                    float _Add_083f76e187d34d479ab406fbb3b98c89_Out_2;
                                                                    Unity_Add_float(_Smoothstep_06663a908bb540829f44189eb272936d_Out_3, _Multiply_4d18a8f234a340d0b866b5212bb0f9bc_Out_2, _Add_083f76e187d34d479ab406fbb3b98c89_Out_2);
                                                                    float _Add_83555ab702004cbdb72557472ceb7786_Out_2;
                                                                    Unity_Add_float(0, _Property_18f6dd86c0704ff19ea25a708ab12473_Out_0, _Add_83555ab702004cbdb72557472ceb7786_Out_2);
                                                                    float _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2;
                                                                    Unity_Divide_float(_Add_083f76e187d34d479ab406fbb3b98c89_Out_2, _Add_83555ab702004cbdb72557472ceb7786_Out_2, _Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2);
                                                                    float4 _Lerp_16f9701748ff4980936cc58aa19de661_Out_3;
                                                                    Unity_Lerp_float4(_Property_d2d44f1dcbad4f06b8cbb08c07015e2a_Out_0, _Property_ce5731c9b64f4fba998c69dbda4a5432_Out_0, (_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2.xxxx), _Lerp_16f9701748ff4980936cc58aa19de661_Out_3);
                                                                    float _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0 = _Fresnel_Power;
                                                                    float _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3;
                                                                    Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_2c3ba70cfe67469aaf3513013f61f8e9_Out_0, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3);
                                                                    float _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2;
                                                                    Unity_Multiply_float_float(_Divide_864107bfe1cc40dfb4510cf9c130ce67_Out_2, _FresnelEffect_f258a8e3db9848a498d143c862bde4fc_Out_3, _Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2);
                                                                    float _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0 = _Fresnel_Opacity;
                                                                    float _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2;
                                                                    Unity_Multiply_float_float(_Multiply_fc458b4c127a4be8a5d89023a187d6df_Out_2, _Property_0d2dee1274ba42ac93b8ba12d9274aa1_Out_0, _Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2);
                                                                    float4 _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2;
                                                                    Unity_Add_float4(_Lerp_16f9701748ff4980936cc58aa19de661_Out_3, (_Multiply_cd88a6e797b84a83bd4dbc1768282643_Out_2.xxxx), _Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2);
                                                                    float _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1;
                                                                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1);
                                                                    float4 _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0 = IN.ScreenPosition;
                                                                    float _Split_452491942d7a49ad80295674220d5140_R_1 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[0];
                                                                    float _Split_452491942d7a49ad80295674220d5140_G_2 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[1];
                                                                    float _Split_452491942d7a49ad80295674220d5140_B_3 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[2];
                                                                    float _Split_452491942d7a49ad80295674220d5140_A_4 = _ScreenPosition_1690a9bf62b748089f31d7a5bdb2f561_Out_0[3];
                                                                    float _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2;
                                                                    Unity_Subtract_float(_Split_452491942d7a49ad80295674220d5140_A_4, 1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2);
                                                                    float _Subtract_cd6ad50230af44bf85193362507f530b_Out_2;
                                                                    Unity_Subtract_float(_SceneDepth_d80697fcfccf44fa96cd96597d289693_Out_1, _Subtract_f214b5aaafa645e6a6bf8f3b5450ac38_Out_2, _Subtract_cd6ad50230af44bf85193362507f530b_Out_2);
                                                                    float _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0 = _Density;
                                                                    float _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                                    Unity_Divide_float(_Subtract_cd6ad50230af44bf85193362507f530b_Out_2, _Property_72ad08f58945443c8c4a7d8984b5e53b_Out_0, _Divide_477e8216f0064774a507b5e500ecdad8_Out_2);
                                                                    surface.BaseColor = (_Add_8de57e9aedaa48ecb0f6a3e7b9108d17_Out_2.xyz);
                                                                    surface.Alpha = _Divide_477e8216f0064774a507b5e500ecdad8_Out_2;
                                                                    return surface;
                                                                }

                                                                // --------------------------------------------------
                                                                // Build Graph Inputs
                                                                #ifdef HAVE_VFX_MODIFICATION
                                                                #define VFX_SRP_ATTRIBUTES Attributes
                                                                #define VFX_SRP_VARYINGS Varyings
                                                                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                #endif
                                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                {
                                                                    VertexDescriptionInputs output;
                                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                    output.ObjectSpaceNormal = input.normalOS;
                                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                    output.ObjectSpacePosition = input.positionOS;
                                                                    output.WorldSpacePosition = TransformObjectToWorld(input.positionOS);
                                                                    output.TimeParameters = _TimeParameters.xyz;

                                                                    return output;
                                                                }
                                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                {
                                                                    SurfaceDescriptionInputs output;
                                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                #ifdef HAVE_VFX_MODIFICATION
                                                                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                #endif



                                                                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                    float3 unnormalizedNormalWS = input.normalWS;
                                                                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                                    output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
                                                                    output.WorldSpacePosition = input.positionWS;
                                                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Visual Effect Vertex Invocations
                                                                #ifdef HAVE_VFX_MODIFICATION
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                #endif

                                                                ENDHLSL
                                                                }
                                    }
                                        CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                    FallBack "Hidden/Shader Graph/FallbackError"
}

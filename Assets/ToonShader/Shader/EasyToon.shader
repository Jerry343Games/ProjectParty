// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EasyToon"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Toggle(_USERIMLIGHT_ON)] _UseRimLight("UseRim Light", Float) = 0
		[Toggle(_USEOUTLINE_ON)] _UseOutline("UseOutline", Float) = 0
		[Toggle(_USESPECULAR_ON)] _UseSpecular("UseSpecular Highlights", Float) = 1
		_SpecColor("Specular Value", Color) = (1,1,1,0)
		_Thicnkess("Thicnkess", Range( 0 , 0.1)) = 0
		_AdaptiveThicnkess("Adaptive Thicnkess", Range( 0 , 1)) = 0
		[KeywordEnum(Normal,Position,UVBaked)] _OutlineType("Outline Type", Float) = 0
		[HDR]_OutlineColor("Outline Color", Color) = (0,0,0,0)
		_Color("Color", Color) = (0.6792453,0.6792453,0.6792453,1)
		_SpecularFaloff("Specular Faloff", Range( 0 , 1)) = 0
		_LightRampOffset("Light Ramp Offset", Range( -1 , 1)) = 0
		_MainTex("Albedo Texture", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_LightRampTexture("Light Ramp Texture", 2D) = "white" {}
		_StepOffset("Step Offset", Range( -0.5 , 0.5)) = 0
		[KeywordEnum(Step,DiffuseRamp,Posterize)] _UseLightRamp("Shading Mode", Float) = 0
		[HideInInspector]_RampDiffuseTextureLoaded("RampDiffuseTextureLoaded", Float) = 1
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimThickness("Rim Thickness", Range( 0 , 3)) = 1
		_RimPower("Rim Power", Range( 1 , 12)) = 12
		_RimSmoothness("Rim Smoothness", Range( 0 , 0.5)) = 0
		[Normal]_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalMapStrength("Normal Map Strength", Float) = 1
		_SpecularPosterizeSteps("Specular Posterize Steps", Range( 0 , 15)) = 15
		[Toggle(_USEENVIRONMENTREFLETION_ON)] _UseEnvironmentRefletion("UseEnvironment Reflections", Float) = 0
		_Strength("Strength", Range( 0 , 1)) = 0
		[NoScaleOffset][SingleLineTexture]_SpecGlossMap("Specular Map", 2D) = "white" {}
		_Glossiness("Smoothness", Range( 0 , 1)) = 0.5
		_Cutoff("Alpha Clip Threshold", Range( 0 , 1)) = 0
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[HDR][NoScaleOffset][SingleLineTexture]_EmissionMap("Emission Map", 2D) = "white" {}
		_UseEmission("UseEmission", Float) = 0
		_IndirectLightStrength("Indirect Light Strength", Range( 0 , 1)) = 1
		_SpecularShadowMask("Specular Shadow Mask", Range( 0 , 1)) = 0
		_AdditionalLightsSmoothnessMultiplier("Additional Lights Specular Size", Range( 0 , 2)) = 1
		_SmoothnessMultiplier("Main Specular Size", Range( 0 , 2)) = 1
		_AdditionalLightsIntesity("Additional Lights Intesity", Range( 0 , 6)) = 1
		[Toggle(_USEADDITIONALLIGHTSDIFFUSE_ON)] _UseAdditionalLightsDiffuse("UseAdditional Lights", Float) = 1
		_AdditionalLightsAmount("Additional Lights Size", Range( 0 , 1)) = 1
		_AdditionalLightsFaloff("Additional Lights Faloff", Range( 0 , 1)) = 1
		_DiffusePosterizeSteps("Posterize Steps", Range( 1 , 10)) = 3
		_DiffusePosterizePower("Posterize Power", Range( 0.5 , 3)) = 1
		_DiffusePosterizeOffset("Posterize Offset", Range( -0.5 , 0.5)) = 0
		_MainLightIntesity("Main Light Intesity", Range( 0 , 6)) = 1
		_OutlineTextureStrength("Texture Strength ", Range( 0 , 1)) = 0
		_ShadowColor("Shadow Color", Color) = (0,0,0,0)
		_RimShadowColor("Rim Shadow Color", Color) = (0,0.05551431,0.9622642,0)
		[KeywordEnum(NoSplit,MultiplyWithDiffuse,UseSecondColor)] _RimSplitColor("Rim Split Color", Float) = 0
		_OcclusionMap("Occlusion Map", 2D) = "white" {}
		[ASEEnd]_OcclusionStrength("Occlusion Strength ", Range( 0 , 1)) = 1

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Cull Back
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			Name "Outline"
			
			
			Blend One Zero
			Cull Front
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#pragma shader_feature_local _USEOUTLINE_ON
			#pragma shader_feature_local _OUTLINETYPE_NORMAL _OUTLINETYPE_POSITION _OUTLINETYPE_UVBAKED
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _EmissionColor;
			half4 _SpecColor;
			half4 _RimColor;
			half4 _RimShadowColor;
			half4 _Color;
			half4 _ShadowColor;
			half4 _OcclusionMap_ST;
			half4 _OutlineColor;
			half _RimThickness;
			half _SpecularPosterizeSteps;
			half _Strength;
			half _SpecularShadowMask;
			half _RimPower;
			half _SmoothnessMultiplier;
			half _MainLightIntesity;
			half _AdditionalLightsIntesity;
			half _SpecularFaloff;
			half _RimSmoothness;
			half _AdditionalLightsSmoothnessMultiplier;
			half _AdditionalLightsFaloff;
			half _IndirectLightStrength;
			half _UseEmission;
			half _AdditionalLightsAmount;
			half _DiffusePosterizeSteps;
			half _DiffusePosterizePower;
			half _DiffusePosterizeOffset;
			half _LightRampOffset;
			half _NormalMapStrength;
			half _StepOffset;
			half _Cutoff;
			half _OcclusionStrength;
			half _OutlineTextureStrength;
			half _Thicnkess;
			half _AdaptiveThicnkess;
			half _Glossiness;
			half _RampDiffuseTextureLoaded;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _OcclusionMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				half lerpResult59 = lerp( 1.0 , distance( _WorldSpaceCameraPos , ase_worldPos ) , _AdaptiveThicnkess);
				#if defined(_OUTLINETYPE_NORMAL)
				half3 staticSwitch57 = v.ase_normal;
				#elif defined(_OUTLINETYPE_POSITION)
				half3 staticSwitch57 = v.vertex.xyz;
				#elif defined(_OUTLINETYPE_UVBAKED)
				half3 staticSwitch57 = half3( v.ase_texcoord3.xy ,  0.0 );
				#else
				half3 staticSwitch57 = v.ase_normal;
				#endif
				#ifdef _USEOUTLINE_ON
				half3 staticSwitch365 = ( lerpResult59 * ( staticSwitch57 * _Thicnkess ) );
				#else
				half3 staticSwitch365 = float3( 0,0,0 );
				#endif
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = staticSwitch365;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				half2 uv_OcclusionMap = IN.ase_texcoord3.xy * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
				half4 tex2DNode362 = tex2D( _MainTex, uv_OcclusionMap );
				half4 lerpResult1448 = lerp( float4( 1,1,1,0 ) , tex2DNode362 , _OutlineTextureStrength);
				
				half lerpResult1655 = lerp( 1.0 , tex2D( _OcclusionMap, uv_OcclusionMap ).r , _OcclusionStrength);
				half4 appendResult1656 = (half4(lerpResult1655 , lerpResult1655 , lerpResult1655 , 1.0));
				half4 MainTexture364 = ( _Color * tex2DNode362 * appendResult1656 );
				half temp_output_673_0 = ( MainTexture364.a * 1.0 );
				#ifdef _USEOUTLINE_ON
				half staticSwitch1349 = temp_output_673_0;
				#else
				half staticSwitch1349 = -2.0;
				#endif
				
				float3 Color = ( _OutlineColor * lerpResult1448 ).rgb;
				float Alpha = staticSwitch1349;
				float AlphaClipThreshold = _Cutoff;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma shader_feature_local _USELIGHTRAMP_STEP _USELIGHTRAMP_DIFFUSERAMP _USELIGHTRAMP_POSTERIZE
			#pragma shader_feature_local _USEADDITIONALLIGHTSDIFFUSE_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma shader_feature_local _USESPECULAR_ON
			#pragma shader_feature_local _USEENVIRONMENTREFLETION_ON
			#pragma shader_feature_local _RIMSPLITCOLOR_NOSPLIT _RIMSPLITCOLOR_MULTIPLYWITHDIFFUSE _RIMSPLITCOLOR_USESECONDCOLOR
			#pragma shader_feature_local _USERIMLIGHT_ON
			#define SHADOWS_SHADOWMASK 
			#define LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 lightmapUVOrVertexSH : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _EmissionColor;
			half4 _SpecColor;
			half4 _RimColor;
			half4 _RimShadowColor;
			half4 _Color;
			half4 _ShadowColor;
			half4 _OcclusionMap_ST;
			half4 _OutlineColor;
			half _RimThickness;
			half _SpecularPosterizeSteps;
			half _Strength;
			half _SpecularShadowMask;
			half _RimPower;
			half _SmoothnessMultiplier;
			half _MainLightIntesity;
			half _AdditionalLightsIntesity;
			half _SpecularFaloff;
			half _RimSmoothness;
			half _AdditionalLightsSmoothnessMultiplier;
			half _AdditionalLightsFaloff;
			half _IndirectLightStrength;
			half _UseEmission;
			half _AdditionalLightsAmount;
			half _DiffusePosterizeSteps;
			half _DiffusePosterizePower;
			half _DiffusePosterizeOffset;
			half _LightRampOffset;
			half _NormalMapStrength;
			half _StepOffset;
			half _Cutoff;
			half _OcclusionStrength;
			half _OutlineTextureStrength;
			half _Thicnkess;
			half _AdaptiveThicnkess;
			half _Glossiness;
			half _RampDiffuseTextureLoaded;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _BumpMap;
			sampler2D _OcclusionMap;
			sampler2D _LightRampTexture;
			sampler2D _MainTex;
			sampler2D _SpecGlossMap;
			sampler2D _EmissionMap;


			half Posterize1331( half In, half Steps )
			{
				return  floor(In / (1 / Steps)) * (1 / Steps);
			}
			
			half3 AdditionalLight( float3 WorldPosition, float3 WorldNormal, half3 LightWrapVector, half SMin, half SMax, half Faloff, half4 shadowmask )
			{
				float3 Color = 0;
				int numLights = GetAdditionalLightsCount();
				for(int i = 0; i<numLights;i++)
				{
					
							#if VERSION_GREATER_EQUAL(10, 1)
							Light light = GetAdditionalLight(i, WorldPosition, shadowmask);
							// see AdditionalLights_float for explanation of this
						#else
							Light light = GetAdditionalLight(i, WorldPosition);
						#endif
					
					float3 DotVector = dot(light.direction,WorldNormal);
					
					half3 AttLightColor = (light.shadowAttenuation * light.distanceAttenuation);
					 float3 colout = max(float3(0.f,0.f,0.f),LightWrapVector + (1-LightWrapVector) * DotVector )*AttLightColor*light.color; 
					float maxColor = max(colout.r,max(colout.g,colout.b));
					float3 outColor = smoothstep(SMin,SMax,maxColor)*light.color;
					 Color += outColor;
					//Color += smoothstep(float3(Faloff,Faloff,Faloff),float3(0.5f,0.5f,0.5f),colout);
				}
				return Color;
			}
			
			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			half3 AdditionalLightsSpecularMy( float3 WorldPosition, float3 WorldNormal, float3 WorldView, float3 SpecColor, float Smoothness, half Steps, half SpecFaloff )
			{
				float3 Color = 0;
				Smoothness = exp2(10 * Smoothness + 1);
				int numLights = GetAdditionalLightsCount();
				for(int i = 0; i<numLights;i++)
				{
					
							#if VERSION_GREATER_EQUAL(10, 1)
							Light light = GetAdditionalLight(i, WorldPosition, half4(1,1,1,1));
							// see AdditionalLights_float for explanation of this
						#else
							Light light = GetAdditionalLight(i, WorldPosition);
						#endif
					
					half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
					Color += LightingSpecular(AttLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness);	
				}
				float IN = max(Color.b,max(Color.r,Color.g));
				float minOut = 0.5 * SpecFaloff - 0.005;
				float faloff = lerp(IN, smoothstep(minOut, 0.5, IN), SpecFaloff);
				if(Steps < 1)
				{
				    return Color *faloff;
				}
				else
				{
				    return  Color *floor(faloff / (1 / Steps)) * (1 / Steps);
				}
			}
			
			half FaloffPosterize( half IN, half SpecFaloff, half Steps )
			{
				float minOut = 0.5 * SpecFaloff - 0.005;
				float faloff = lerp(IN, smoothstep(minOut, 0.5, IN), SpecFaloff);
				if(Steps < 1)
				{
				    return faloff;
				}
				else
				{
				    return  floor(faloff / (1 / Steps)) * (1 / Steps);
				}
			}
			
			
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				half3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				half ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				half4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				o.texcoord1 = v.texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				half temp_output_371_0 = ( _StepOffset + 0.5 );
				half2 uv_OcclusionMap = IN.ase_texcoord3.xy * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
				half3 lerpResult1536 = lerp( half3(0,0,1) , UnpackNormalScale( tex2D( _BumpMap, uv_OcclusionMap ), 1.0f ) , _NormalMapStrength);
				half3 ase_worldTangent = IN.ase_texcoord4.xyz;
				half3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				half3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				half3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				half3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal1537 = lerpResult1536;
				half3 worldNormal1537 = normalize( float3(dot(tanToWorld0,tanNormal1537), dot(tanToWorld1,tanNormal1537), dot(tanToWorld2,tanNormal1537)) );
				float3 BNCurrentNormal1538 = worldNormal1537;
				half dotResult234 = dot( BNCurrentNormal1538 , _MainLightPosition.xyz );
				float BNNDotL233 = dotResult234;
				half3 temp_cast_0 = (BNNDotL233).xxx;
				half localLightAttenuation1412 = ( 0.0 );
				half3 WorldPos1412 = WorldPosition;
				half DistanceAtten1412 = 0;
				half ShadowAtten1412 = 0;
				{
				    #if SHADOWS_SCREEN
				        half4 clipPos = TransformWorldToHClip(WorldPos1412);
				        half4 shadowCoord = ComputeScreenPos(clipPos);
				    #else
				        half4 shadowCoord = TransformWorldToShadowCoord(WorldPos1412);
				    #endif
				    Light mainLight = GetMainLight(shadowCoord);
				    DistanceAtten1412 = mainLight.distanceAttenuation;
				    ShadowAtten1412 = mainLight.shadowAttenuation;
				}
				float3 BNAttenuationColor244 = ( _MainLightColor.rgb * DistanceAtten1412 );
				half3 break3_g166 = ( max( temp_cast_0 , float3(0,0,0) ) * BNAttenuationColor244 );
				half temp_output_1188_0 = max( max( break3_g166.x , break3_g166.y ) , break3_g166.z );
				half smoothstepResult444 = smoothstep( ( temp_output_371_0 - 0.009 ) , temp_output_371_0 , temp_output_1188_0);
				half4 lerpResult1619 = lerp( _ShadowColor , _MainLightColor , saturate( smoothstepResult444 ));
				half ShadowAtten1415 = ShadowAtten1412;
				half4 lerpResult1626 = lerp( _ShadowColor , lerpResult1619 , ShadowAtten1415);
				half2 appendResult356 = (half2(( _LightRampOffset + temp_output_1188_0 ) , 0.0));
				half2 temp_cast_1 = (0.02).xx;
				half2 temp_cast_2 = (0.98).xx;
				half2 clampResult358 = clamp( appendResult356 , temp_cast_1 , temp_cast_2 );
				half4 lerpResult1617 = lerp( ( tex2D( _LightRampTexture, half2( 0.02,0 ) ) * _MainLightColor ) , ( tex2D( _LightRampTexture, clampResult358 ) * _MainLightColor ) , ShadowAtten1415);
				half In1331 = pow( saturate( ( temp_output_1188_0 + ( _DiffusePosterizeOffset * -1.0 ) ) ) , _DiffusePosterizePower );
				half Steps1331 = round( _DiffusePosterizeSteps );
				half localPosterize1331 = Posterize1331( In1331 , Steps1331 );
				half4 lerpResult1629 = lerp( _ShadowColor , _MainLightColor , localPosterize1331);
				half4 lerpResult1628 = lerp( _ShadowColor , lerpResult1629 , ShadowAtten1415);
				#if defined(_USELIGHTRAMP_STEP)
				half4 staticSwitch372 = lerpResult1626;
				#elif defined(_USELIGHTRAMP_DIFFUSERAMP)
				half4 staticSwitch372 = lerpResult1617;
				#elif defined(_USELIGHTRAMP_POSTERIZE)
				half4 staticSwitch372 = lerpResult1628;
				#else
				half4 staticSwitch372 = lerpResult1626;
				#endif
				half3 WorldPosition1181 = WorldPosition;
				half3 WorldNormal1181 = BNCurrentNormal1538;
				half3 temp_cast_3 = (0.0).xxx;
				half3 LightWrapVector1181 = temp_cast_3;
				half temp_output_1203_0 = ( 1.0 - ( (2.0 + (_AdditionalLightsAmount - 0.0) * (2.9 - 2.0) / (1.0 - 0.0)) + -2.0 ) );
				half SMin1181 = ( ( temp_output_1203_0 * _AdditionalLightsFaloff ) - 0.005 );
				half SMax1181 = temp_output_1203_0;
				half Faloff1181 = 0.0;
				half4 shadowmask1181 = float4( 1,1,1,1 );
				half3 localAdditionalLight1181 = AdditionalLight( WorldPosition1181 , WorldNormal1181 , LightWrapVector1181 , SMin1181 , SMax1181 , Faloff1181 , shadowmask1181 );
				#ifdef _USEADDITIONALLIGHTSDIFFUSE_ON
				half3 staticSwitch1143 = localAdditionalLight1181;
				#else
				half3 staticSwitch1143 = float3( 0,0,0 );
				#endif
				half3 AdditionalLightsDiffuse1144 = staticSwitch1143;
				half4 BNDiffuse391 = ( staticSwitch372 + half4( AdditionalLightsDiffuse1144 , 0.0 ) );
				half4 tex2DNode362 = tex2D( _MainTex, uv_OcclusionMap );
				half lerpResult1655 = lerp( 1.0 , tex2D( _OcclusionMap, uv_OcclusionMap ).r , _OcclusionStrength);
				half4 appendResult1656 = (half4(lerpResult1655 , lerpResult1655 , lerpResult1655 , 1.0));
				half4 MainTexture364 = ( _Color * tex2DNode362 * appendResult1656 );
				half3 bakedGI276 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, BNCurrentNormal1538);
				Light ase_mainLight = GetMainLight( ShadowCoords );
				MixRealtimeAndBakedGI(ase_mainLight, BNCurrentNormal1538, bakedGI276, half4(0,0,0,0));
				half IndirectLightStrength1221 = _IndirectLightStrength;
				half3 lerpResult692 = lerp( float3( 0,0,0 ) , bakedGI276 , IndirectLightStrength1221);
				half4 IndirectDiffuseLight1269 = ( MainTexture364 * half4( lerpResult692 , 0.0 ) );
				float4 BNFinalDiffuse239 = ( ( BNDiffuse391 * MainTexture364 ) + IndirectDiffuseLight1269 );
				half3 WorldPosition1573 = WorldPosition;
				half3 WorldNormal1573 = BNCurrentNormal1538;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				half3 WorldView1573 = ase_worldViewDir;
				half3 SpecColor1573 = half3(1,1,1);
				half Smoothness638 = ( tex2D( _SpecGlossMap, uv_OcclusionMap ).r * _Glossiness );
				half Smoothness1573 = ( Smoothness638 * ( 2.0 - _AdditionalLightsSmoothnessMultiplier ) );
				half temp_output_588_0 = round( _SpecularPosterizeSteps );
				half Steps1573 = temp_output_588_0;
				half SpecFaloff1573 = _SpecularFaloff;
				half3 localAdditionalLightsSpecularMy1573 = AdditionalLightsSpecularMy( WorldPosition1573 , WorldNormal1573 , WorldView1573 , SpecColor1573 , Smoothness1573 , Steps1573 , SpecFaloff1573 );
				half3 normalizeResult222 = normalize( _MainLightPosition.xyz );
				half3 normalizeResult238 = normalize( ( normalizeResult222 + ase_worldViewDir ) );
				float3 BNHalfDirection265 = normalizeResult238;
				half dotResult252 = dot( BNHalfDirection265 , BNCurrentNormal1538 );
				half IN1578 = ( pow( max( dotResult252 , 0.0 ) , ( exp2( ( ( Smoothness638 * 10.0 * ( 2.0 - _SmoothnessMultiplier ) ) + -2.0 ) ) * 2.0 ) ) * ( _SmoothnessMultiplier == 0.0 ? 0.0 : 1.0 ) );
				half SpecFaloff1578 = _SpecularFaloff;
				half Steps1578 = temp_output_588_0;
				half localFaloffPosterize1578 = FaloffPosterize( IN1578 , SpecFaloff1578 , Steps1578 );
				half4 SpecularColor1388 = _SpecColor;
				#ifdef _USESPECULAR_ON
				half4 staticSwitch627 = ( half4( ( ( localAdditionalLightsSpecularMy1573 * _AdditionalLightsIntesity * ( _AdditionalLightsSmoothnessMultiplier == 0.0 ? 0.0 : 1.0 ) ) + ( _MainLightColor.rgb * _MainLightIntesity * localFaloffPosterize1578 ) ) , 0.0 ) * Smoothness638 * SpecularColor1388 );
				#else
				half4 staticSwitch627 = float4( 0,0,0,0 );
				#endif
				float4 BNspecularFinalColor243 = staticSwitch627;
				half grayscale1797 = dot(BNDiffuse391.rgb, float3(0.299,0.587,0.114));
				half lerpResult695 = lerp( 1.0 , grayscale1797 , _SpecularShadowMask);
				half3 reflectVector618 = reflect( -ase_worldViewDir, BNCurrentNormal1538 );
				float3 indirectSpecular618 = GlossyEnvironmentReflection( reflectVector618, 1.0 - Smoothness638, 0.75 );
				#ifdef _USEENVIRONMENTREFLETION_ON
				half3 staticSwitch621 = ( indirectSpecular618 * _Strength * Smoothness638 );
				#else
				half3 staticSwitch621 = float3( 0,0,0 );
				#endif
				half3 IndirectSpecular1364 = staticSwitch621;
				half4 BNBlinnPhongLightning274 = ( BNFinalDiffuse239 + ( BNspecularFinalColor243 * lerpResult695 ) + half4( IndirectSpecular1364 , 0.0 ) );
				half4 BNDiffuseNoAdditionalLights1554 = staticSwitch372;
				half grayscale1648 = Luminance(BNDiffuseNoAdditionalLights1554.rgb);
				half4 lerpResult1650 = lerp( _RimShadowColor , _RimColor , grayscale1648);
				#if defined(_RIMSPLITCOLOR_NOSPLIT)
				half4 staticSwitch1646 = _RimColor;
				#elif defined(_RIMSPLITCOLOR_MULTIPLYWITHDIFFUSE)
				half4 staticSwitch1646 = ( _RimColor * BNDiffuseNoAdditionalLights1554 );
				#elif defined(_RIMSPLITCOLOR_USESECONDCOLOR)
				half4 staticSwitch1646 = lerpResult1650;
				#else
				half4 staticSwitch1646 = _RimColor;
				#endif
				half4 RimColor1642 = staticSwitch1646;
				half fresnelNdotV454 = dot( normalize( BNCurrentNormal1538 ), ase_worldViewDir );
				half fresnelNode454 = ( 0.0 + _RimThickness * pow( max( 1.0 - fresnelNdotV454 , 0.0001 ), _RimPower ) );
				half smoothstepResult462 = smoothstep( ( ( 1.0 - _RimSmoothness ) - 0.5 ) , 0.5 , fresnelNode454);
				half FresnelValue738 = smoothstepResult462;
				#ifdef _USERIMLIGHT_ON
				half staticSwitch464 = FresnelValue738;
				#else
				half staticSwitch464 = 0.0;
				#endif
				half RimLight460 = staticSwitch464;
				half4 lerpResult1635 = lerp( BNBlinnPhongLightning274 , RimColor1642 , RimLight460);
				half4 Emission680 = ( _UseEmission == 1.0 ? ( tex2D( _EmissionMap, uv_OcclusionMap ) * _EmissionColor ) : float4( 0,0,0,0 ) );
				
				half temp_output_673_0 = ( MainTexture364.a * 1.0 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( lerpResult1635 + Emission680 ).rgb;
				float Alpha = temp_output_673_0;
				float AlphaClipThreshold = _Cutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM
			
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag
#if ASE_SRP_VERSION >= 110000
			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
#endif
			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define SHADOWS_SHADOWMASK 
			#define LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _EmissionColor;
			half4 _SpecColor;
			half4 _RimColor;
			half4 _RimShadowColor;
			half4 _Color;
			half4 _ShadowColor;
			half4 _OcclusionMap_ST;
			half4 _OutlineColor;
			half _RimThickness;
			half _SpecularPosterizeSteps;
			half _Strength;
			half _SpecularShadowMask;
			half _RimPower;
			half _SmoothnessMultiplier;
			half _MainLightIntesity;
			half _AdditionalLightsIntesity;
			half _SpecularFaloff;
			half _RimSmoothness;
			half _AdditionalLightsSmoothnessMultiplier;
			half _AdditionalLightsFaloff;
			half _IndirectLightStrength;
			half _UseEmission;
			half _AdditionalLightsAmount;
			half _DiffusePosterizeSteps;
			half _DiffusePosterizePower;
			half _DiffusePosterizeOffset;
			half _LightRampOffset;
			half _NormalMapStrength;
			half _StepOffset;
			half _Cutoff;
			half _OcclusionStrength;
			half _OutlineTextureStrength;
			half _Thicnkess;
			half _AdaptiveThicnkess;
			half _Glossiness;
			half _RampDiffuseTextureLoaded;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _OcclusionMap;


			
			float3 _LightDirection;
#if ASE_SRP_VERSION >= 110000 
			float3 _LightPosition;
#endif
			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );
#if ASE_SRP_VERSION >= 110000 
			#if _CASTING_PUNCTUAL_LIGHT_SHADOW
				float3 lightDirectionWS = normalize(_LightPosition - positionWS);
			#else
				float3 lightDirectionWS = _LightDirection;
			#endif
				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
			#if UNITY_REVERSED_Z
				clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#else
				clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#endif
#else
				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );
				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				half2 uv_OcclusionMap = IN.ase_texcoord2.xy * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
				half4 tex2DNode362 = tex2D( _MainTex, uv_OcclusionMap );
				half lerpResult1655 = lerp( 1.0 , tex2D( _OcclusionMap, uv_OcclusionMap ).r , _OcclusionStrength);
				half4 appendResult1656 = (half4(lerpResult1655 , lerpResult1655 , lerpResult1655 , 1.0));
				half4 MainTexture364 = ( _Color * tex2DNode362 * appendResult1656 );
				half temp_output_673_0 = ( MainTexture364.a * 1.0 );
				
				float Alpha = temp_output_673_0;
				float AlphaClipThreshold = _Cutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define SHADOWS_SHADOWMASK 
			#define LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _EmissionColor;
			half4 _SpecColor;
			half4 _RimColor;
			half4 _RimShadowColor;
			half4 _Color;
			half4 _ShadowColor;
			half4 _OcclusionMap_ST;
			half4 _OutlineColor;
			half _RimThickness;
			half _SpecularPosterizeSteps;
			half _Strength;
			half _SpecularShadowMask;
			half _RimPower;
			half _SmoothnessMultiplier;
			half _MainLightIntesity;
			half _AdditionalLightsIntesity;
			half _SpecularFaloff;
			half _RimSmoothness;
			half _AdditionalLightsSmoothnessMultiplier;
			half _AdditionalLightsFaloff;
			half _IndirectLightStrength;
			half _UseEmission;
			half _AdditionalLightsAmount;
			half _DiffusePosterizeSteps;
			half _DiffusePosterizePower;
			half _DiffusePosterizeOffset;
			half _LightRampOffset;
			half _NormalMapStrength;
			half _StepOffset;
			half _Cutoff;
			half _OcclusionStrength;
			half _OutlineTextureStrength;
			half _Thicnkess;
			half _AdaptiveThicnkess;
			half _Glossiness;
			half _RampDiffuseTextureLoaded;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _OcclusionMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				half2 uv_OcclusionMap = IN.ase_texcoord2.xy * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
				half4 tex2DNode362 = tex2D( _MainTex, uv_OcclusionMap );
				half lerpResult1655 = lerp( 1.0 , tex2D( _OcclusionMap, uv_OcclusionMap ).r , _OcclusionStrength);
				half4 appendResult1656 = (half4(lerpResult1655 , lerpResult1655 , lerpResult1655 , 1.0));
				half4 MainTexture364 = ( _Color * tex2DNode362 * appendResult1656 );
				half temp_output_673_0 = ( MainTexture364.a * 1.0 );
				
				float Alpha = temp_output_673_0;
				float AlphaClipThreshold = _Cutoff;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	
	CustomEditor "EasyToonEditor"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
838;73;1056;655;6566.92;-591.5627;1.512067;False;False
Node;AmplifyShaderEditor.CommentaryNode;678;1058.121,1503.775;Inherit;False;1482.025;1686.722;Comment;27;636;659;686;679;685;658;680;638;682;677;364;204;362;1388;1376;1536;1537;1538;1539;1540;1541;1651;1652;1653;1655;1656;1669;Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1669;1124.039,1766.173;Inherit;False;0;1651;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1652;1503.492,2306.291;Inherit;False;Property;_OcclusionStrength;Occlusion Strength ;48;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1651;1432.063,2063.587;Inherit;True;Property;_OcclusionMap;Occlusion Map;47;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1655;1780.563,2131.611;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1656;1932.025,2227.229;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;362;1404.155,1877.507;Inherit;True;Property;_MainTex;Albedo Texture;11;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;204;1971.248,1808.104;Inherit;False;Property;_Color;Color;8;0;Create;True;0;0;0;False;0;False;0.6792453,0.6792453,0.6792453,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1653;2040.811,2106.22;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;2184.66,1995.724;Inherit;False;MainTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;277;-8712.34,-525.5221;Inherit;False;6331.035;6906.721;;9;217;386;390;213;215;1208;216;219;1829;BlinnPhong;0.2631274,0.6002151,0.6886792,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;670;46.10808,1250.098;Inherit;False;364;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1208;-8188.008,2298.021;Inherit;False;1877.47;918.8329;;13;1181;1202;1144;1203;1154;1182;1143;1241;1243;1245;1247;1562;1840;Additional Lights Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;671;280.2685,1150.97;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;215;-8227.284,3635.811;Inherit;False;3808.721;1802.809;;48;1577;805;1574;1576;1573;627;220;1397;1403;618;256;619;1093;651;1098;1094;1103;1102;623;1404;621;660;207;243;1099;650;252;1400;1097;1100;254;653;652;406;401;1096;583;649;644;588;661;1364;246;665;804;1104;1578;1579;Main Specular ;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;217;-5811.318,98.81934;Inherit;False;977.2441;332.3028;;6;265;238;237;236;226;222;Half Dir;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;219;-8640.2,-404.9457;Inherit;False;1797.078;446.0921;;6;1415;1412;244;1414;227;247;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;387;1643.036,755.7413;Inherit;False;338;166;;1;373;Editor Properties;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;390;-4258.111,704.8892;Inherit;False;1678.375;818.0153;;13;229;263;1269;692;642;392;1221;691;276;581;239;1363;1466;Final Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;216;-6310.873,-429.0269;Inherit;False;698.8475;398.5884;;4;1542;269;233;234;NDotL;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;386;-8714.788,795.2674;Inherit;False;4310.062;1258.77;;55;1451;372;361;1360;1331;1416;1157;1504;391;1554;1276;370;1355;1087;1188;262;1356;1502;264;965;260;1501;240;356;1505;223;358;1329;1508;1211;360;371;1362;359;1359;1500;1274;444;1357;1358;1330;445;1617;1618;1619;1622;1623;1625;1626;1628;1629;1680;1683;1684;1841;Main Light Diffuse Mode;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;213;-4675.104,-420.4454;Inherit;False;1762.018;982.026;;10;274;696;694;270;695;259;693;271;1366;1797;Diffuse + Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;465;423.3723,-1099.152;Inherit;False;3204.799;1529.321;;20;1644;1647;456;1645;1646;1642;739;457;537;463;454;467;738;464;462;460;458;466;1648;1650;Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1829;-8621.713,2170.759;Inherit;False;285;161;do not delete;1;1828;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;64;-1880.329,-546.7816;Inherit;False;1478.969;931.5795;;12;50;57;52;54;53;55;51;56;60;62;58;59;Outline;1,1,1,1;0;0
Node;AmplifyShaderEditor.Compare;1104;-7680.824,4381.492;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;282;-438.3608,945.2823;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;1646;3250.362,-717.5472;Inherit;False;Property;_RimSplitColor;Rim Split Color;46;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;NoSplit;MultiplyWithDiffuse;UseSecondColor;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;636;1382.471,1568.447;Inherit;True;Property;_SpecGlossMap;Specular Map;25;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;238;-5230.689,185.8815;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;650;-7413.339,5109.979;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;265;-5070.689,185.8815;Float;False;BNHalfDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;458;465.8676,-974.0062;Inherit;False;Property;_RimThickness;Rim Thickness;17;0;Create;True;0;0;0;False;0;False;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;581;-4000.692,1309.903;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1619;-5512.82,1153.598;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;360;-7214.942,911.5303;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1536;1761.389,2825.948;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1243;-7901.144,3098.145;Inherit;False;Property;_AdditionalLightsFaloff;Additional Lights Faloff;38;0;Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1376;2060.616,1574.841;Inherit;False;Property;_SpecColor;Specular Value;3;0;Create;False;0;0;0;True;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1274;-7096.629,1012.689;Inherit;False;Constant;_Float3;Float 3;101;0;Create;True;0;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;252;-7648.309,4843.384;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1103;-7826.284,4247.077;Inherit;False;2;0;FLOAT;2;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;365;341.8629,510.9032;Inherit;False;Property;_UseOutline;UseOutline;1;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;401;-7217.791,4919.301;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1414;-8570.379,-326.1027;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;254;-7895.649,4818.049;Inherit;False;265;BNHalfDirection;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;246;-7498.901,4880.049;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1645;2840.679,-393.1641;Inherit;False;Property;_RimShadowColor;Rim Shadow Color;45;0;Create;False;0;0;0;False;0;False;0,0.05551431,0.9622642,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;243;-5017.183,3809.587;Float;False;BNspecularFinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;674;441.585,1038.581;Inherit;False;Property;_Cutoff;Alpha Clip Threshold;27;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-7287.485,4481.617;Inherit;False;Property;_SpecularFaloff;Specular Faloff;9;0;Create;True;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1358;-6910.61,1515.219;Inherit;False;Property;_DiffusePosterizeOffset;Posterize Offset;41;0;Create;False;0;0;0;True;0;False;0;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1574;-7877.564,3745.817;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;1415;-7941.565,-117.7121;Inherit;False;ShadowAtten;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1359;-6532.81,1215.119;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1362;-6617.578,1499.284;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;233;-5864.712,-350.3873;Float;False;BNNDotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;660;-8005.023,5010.653;Inherit;False;638;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1349;424.3337,676.1953;Inherit;False;Property;_UseOutline;UseOutline;1;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;695;-3958.377,7.337563;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;371;-7062.73,1565.988;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;652;-7264.339,5114.979;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;276;-3764.335,1268.758;Inherit;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;623;-6089.939,5049.021;Inherit;False;Property;_Strength;Strength;24;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;466;820.7245,-839.5659;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1188;-7435.184,1116.345;Inherit;False;MaxFromVector3;-1;;166;92f2539b674dd3042b132cfbdf18809e;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1505;-8173.14,1720.243;Inherit;False;244;BNAttenuationColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;638;1855.223,1676.036;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;661;-5611.068,4894.948;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1364;-5092.619,4955.397;Inherit;False;IndirectSpecular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectSpecularLight;618;-5941.455,4859.122;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;0.75;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;804;-8058.192,4148.725;Inherit;False;638;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1540;1479.323,2996.637;Inherit;False;Constant;_Vector0;Vector 0;44;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;1628;-5297.678,1225.747;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;1355;-6389.81,1206.019;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;356;-7079.368,897.3414;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;370;-7245.275,1723.849;Inherit;False;Property;_StepOffset;Step Offset;13;0;Create;False;0;0;0;True;0;False;0;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;-1129.327,1009.439;Inherit;False;460;RimLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;467;1004.604,-900.3163;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;361;-6671.905,934.7034;Inherit;True;Property;_LightRampTexture;Light Ramp Texture;12;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;1;;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;1562;-8031.964,2896.065;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;4;FLOAT;2.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1093;-8154.446,4332.71;Inherit;False;Property;_AdditionalLightsSmoothnessMultiplier;Additional Lights Specular Size;33;0;Create;False;0;0;0;True;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassSwitchNode;42;122.0946,834.946;Inherit;False;0;0;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1357;-6701.81,1200.818;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1245;-7507.291,2967.906;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;269;-6073.979,-207.2886;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;1157;-4866.73,1335.895;Inherit;False;1144;AdditionalLightsDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;454;757.5737,-1049.152;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1541;1421.466,2768.47;Inherit;True;Property;_BumpMap;Normal Map;20;1;[Normal];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;1181;-7437.597,2437.959;Inherit;False;float3 Color = 0@$$int numLights = GetAdditionalLightsCount()@$for(int i = 0@ i<numLights@i++)${$	$			#if VERSION_GREATER_EQUAL(10, 1)$			Light light = GetAdditionalLight(i, WorldPosition, shadowmask)@$			// see AdditionalLights_float for explanation of this$		#else$			Light light = GetAdditionalLight(i, WorldPosition)@$		#endif$$	$	float3 DotVector = dot(light.direction,WorldNormal)@$	$$	half3 AttLightColor = (light.shadowAttenuation * light.distanceAttenuation)@$	 float3 colout = max(float3(0.f,0.f,0.f),LightWrapVector + (1-LightWrapVector) * DotVector )*AttLightColor*light.color@ $	float maxColor = max(colout.r,max(colout.g,colout.b))@$	float3 outColor = smoothstep(SMin,SMax,maxColor)*light.color@$	 Color += outColor@$	//Color += smoothstep(float3(Faloff,Faloff,Faloff),float3(0.5f,0.5f,0.5f),colout)@$}$$return Color@;3;Create;7;True;WorldPosition;FLOAT3;0,0,0;In;;Float;False;True;WorldNormal;FLOAT3;0,0,0;In;;Float;False;True;LightWrapVector;FLOAT3;0,0,0;In;;Inherit;False;True;SMin;FLOAT;0;In;;Inherit;False;True;SMax;FLOAT;0;In;;Inherit;False;True;Faloff;FLOAT;0;In;;Inherit;False;True;shadowmask;FLOAT4;1,1,1,1;In;;Inherit;False;AdditionalLight;False;False;0;;False;7;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT4;1,1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1635;-822.1129,860.0081;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1684;-7575.029,1450.475;Inherit;False;MaxFromVector3;-1;;173;92f2539b674dd3042b132cfbdf18809e;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1416;-5811.629,1344.007;Inherit;False;1415;ShadowAtten;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1449;-597.9544,675.8444;Inherit;False;Property;_OutlineTextureStrength;Texture Strength ;43;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;-3975.169,-292.4447;Inherit;False;239;BNFinalDiffuse;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;222;-5534.689,146.8815;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;223;-8288.604,1062.242;Inherit;False;233;BNNDotL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1099;-7290.118,5245.943;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1203;-7706.201,2766.889;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1397;-5568.067,4428.058;Inherit;False;638;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1643;-1114.389,903.2255;Inherit;False;1642;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;682;1351.523,2385.05;Inherit;True;Property;_EmissionMap;Emission Map;29;3;[HDR];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;372;-4979.424,998.819;Inherit;False;Property;_UseLightRamp;Shading Mode;14;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;Step;DiffuseRamp;Posterize;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1403;-5572.458,4532.488;Inherit;False;1388;SpecularColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;693;-4402.304,-54.1281;Inherit;False;391;BNDiffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1841;-5549.3,866.7593;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;530;-1141.869,719.5949;Inherit;False;274;BNBlinnPhongLightning;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;659;1476.81,1783.215;Inherit;False;Property;_Glossiness;Smoothness;26;0;Create;False;0;0;0;True;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1683;-7312.262,1457.329;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1247;-7808.318,2893.219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;237;-5358.689,185.8815;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;247;-7623.115,-365.4415;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;239;-2802.317,769.5178;Float;True;BNFinalDiffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;270;-4165.508,-150.3121;Inherit;False;243;BNspecularFinalColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1360;-6125.02,1244.424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;1330;-6382.303,1497.039;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;462;1232.969,-1000.956;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;229;-3574.793,815.2498;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCGrayscale;1797;-4153.83,-58.39511;Inherit;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;256;-7909.895,4907.049;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1329;-6869.518,1637.568;Inherit;False;Property;_DiffusePosterizeSteps;Posterize Steps;39;0;Create;False;0;0;0;True;0;False;3;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1629;-5545.506,1353.28;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1451;-5700.567,1031.205;Inherit;False;Property;_ShadowColor;Shadow Color;44;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1211;-7850.36,1482.069;Inherit;False;1144;AdditionalLightsDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1680;-5913.26,1010.336;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;444;-6817.886,1357.984;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.495;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1508;-8045.536,1809.592;Inherit;False;1415;ShadowAtten;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1100;-6998.229,4927.666;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1502;-8426.737,1589.252;Inherit;False;233;BNNDotL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;-7138.799,-347.3582;Float;False;BNAttenuationColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;679;1461,2580.218;Inherit;False;Property;_EmissionColor;Emission Color;28;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;1577;-7670.493,3670.727;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;651;-7960.333,5141.979;Float;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;234;-6008.713,-366.3873;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;665;-7371.13,4969.236;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1202;-8066.06,2766.57;Inherit;False;Property;_AdditionalLightsAmount;Additional Lights Size;37;0;Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;1702.515,1656.614;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;1648;2883.622,-509.4114;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1466;-3047.77,1230.248;Inherit;False;IndirectHatching;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;226;-5790.688,169.8815;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;58;-841.3283,219.3617;Inherit;False;Property;_Thicnkess;Thicnkess;4;0;Create;True;0;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;696;-4517.71,204.9207;Inherit;False;Property;_SpecularShadowMask;Specular Shadow Mask;32;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1647;2982.141,-773.8771;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1500;-7856.688,1603.479;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;-7768.49,1046.19;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;52;-1850.069,191.2531;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;391;-4592.066,972.1625;Inherit;False;BNDiffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;406;-6525.84,4341.426;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.Compare;685;2006.266,2608.482;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1448;-252.7794,586.307;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-552.3168,-51.57129;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;583;-7335.241,4691.376;Inherit;False;Property;_SpecularPosterizeSteps;Specular Posterize Steps;22;0;Create;True;0;0;0;True;0;False;15;0;0;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1221;-3451.219,1360.915;Inherit;False;IndirectLightStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;691;-3773.227,1400.115;Inherit;False;Property;_IndirectLightStrength;Indirect Light Strength;31;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1622;-5863.845,822.6514;Inherit;True;Property;_LightRampTexture;Light Ramp Texture;12;2;[NoScaleOffset];[SingleLineTexture];Fetch;True;0;0;0;False;1;;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;57;-1367.279,63.58631;Inherit;False;Property;_OutlineType;Outline Type;6;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;Normal;Position;UVBaked;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1828;-8584.713,2231.759;Inherit;False;SRP Additional Light;-1;;172;6c86746ad131a0a408ca599df5f40861;7,6,0,9,0,23,0,26,0,27,0,24,0,25,0;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;0.5;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;373;1693.036,805.7413;Inherit;False;Property;_RampDiffuseTextureLoaded;RampDiffuseTextureLoaded;15;1;[HideInInspector];Create;True;0;0;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;680;2194.921,2612.172;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1840;-7687.038,2476.176;Inherit;False;Constant;_Float5;Float 5;69;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1388;2304.728,1627.696;Inherit;False;SpecularColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;642;-4138.578,1020.884;Inherit;False;364;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1366;-3538.575,-113.5741;Inherit;False;1364;IndirectSpecular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;460;2121.997,-931.0809;Inherit;False;RimLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;649;-7547.332,5220.979;Float;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;259;-3353.517,-351.2742;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-593.3286,72.36163;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;1143;-7157.366,2366.717;Inherit;False;Property;_UseAdditionalLightsDiffuse;UseAdditional Lights;36;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1096;-8022.605,5304.383;Inherit;False;Property;_SmoothnessMultiplier;Main Specular Size;34;0;Create;False;0;0;0;True;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;55;-929.3464,-380.4816;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;54;-1444.329,249.3617;Inherit;False;3;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;59;-713.4068,-214.2483;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1276;-7092.629,1090.689;Inherit;False;Constant;_Float4;Float 4;101;0;Create;True;0;0;0;False;0;False;0.98;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1087;-4633.485,1184.714;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1400;-6367.526,4558.088;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;1412;-8332.21,-310.8027;Inherit;False;$    #if SHADOWS_SCREEN$        half4 clipPos = TransformWorldToHClip(WorldPos)@$        half4 shadowCoord = ComputeScreenPos(clipPos)@$    #else$        half4 shadowCoord = TransformWorldToShadowCoord(WorldPos)@$    #endif$$    Light mainLight = GetMainLight(shadowCoord)@$    DistanceAtten = mainLight.distanceAttenuation@$    ShadowAtten = mainLight.shadowAttenuation@$;7;Create;3;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;DistanceAtten;FLOAT;0;Out;;Inherit;False;True;ShadowAtten;FLOAT;0;Out;;Inherit;False;Light Attenuation;True;False;0;;False;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1097;-6363.097,3985.778;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1356;-6555.81,1409.019;Inherit;False;Property;_DiffusePosterizePower;Posterize Power;40;0;Create;False;0;0;0;True;0;False;1;0.5;0.5;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1098;-6693.153,4020.493;Inherit;False;Property;_AdditionalLightsIntesity;Additional Lights Intesity;35;0;Create;False;0;0;0;True;0;False;1;0;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;627;-5040.281,4026.474;Inherit;False;Property;_UseSpecular;UseSpecular Highlights;2;0;Create;False;0;0;0;True;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1539;1768.883,3052.132;Inherit;False;Property;_NormalMapStrength;Normal Map Strength;21;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1094;-7646.415,4181.712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1241;-7348.737,2726.091;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;619;-6182.985,4835.125;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;53;-1660.237,206.434;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;51;-1108.915,-350.8623;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;673;420.2685,1256.97;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;358;-6906.585,966.5153;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.02,0.02;False;2;FLOAT2;0.98,0.98;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;1576;-7699.739,3809.799;Inherit;False;Constant;_Vector6;Vector 6;125;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;1542;-6257.038,-382.9371;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1013.993,-179.219;Inherit;False;Property;_AdaptiveThicnkess;Adaptive Thicnkess;5;0;Create;False;0;0;0;False;0;False;0;0.32;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1538;2114.056,2805.07;Float;False;BNCurrentNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;445;-7002.459,1448.423;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.009;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1421;-33.53701,737.0069;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1617;-5375.458,893.8284;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1579;-6158.399,4053.709;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;-3140.385,-357.7659;Inherit;False;BNBlinnPhongLightning;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;694;-3814.204,-108.875;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;50;-1180.349,-497.7589;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;537;510.0921,-1058.331;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1350;268.6716,661.877;Inherit;False;Constant;_Float6;Float 6;111;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1554;-4676.51,851.5873;Inherit;False;BNDiffuseNoAdditionalLights;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;263;-3059.157,798.1735;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;1504;-8396.227,1702.525;Float;False;Constant;_Vector2;Vector 2;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1102;-7736.342,5243.698;Inherit;False;2;0;FLOAT;2;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;653;-7723.332,5087.979;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;236;-5736.223,268.1741;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;1331;-6158.115,1367.33;Inherit;False;return  floor(In / (1 / Steps)) * (1 / Steps)@;1;Create;2;True;In;FLOAT;0;In;;Inherit;False;True;Steps;FLOAT;0;In;;Inherit;False;Posterize;True;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1650;3146.622,-579.4114;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1625;-5765.402,1346.932;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1501;-8218.911,1604.912;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;1537;1916.055,2801.07;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;456;2734.758,-872.3867;Inherit;False;Property;_RimColor;Rim Color;16;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1404;-6737.913,4481.702;Inherit;False;Property;_MainLightIntesity;Main Light Intesity;42;0;Create;False;0;0;0;False;0;False;1;0;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;457;458.4457,-880.3952;Inherit;False;Property;_RimPower;Rim Power;18;0;Create;True;0;0;0;False;0;False;12;1;1;12;0;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;588;-7000.311,4651.526;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;686;1827.266,2502.482;Inherit;False;Property;_UseEmission;UseEmission;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1144;-6842.029,2368.752;Inherit;False;AdditionalLightsDiffuse;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;621;-5460.198,4893.861;Inherit;False;Property;_UseEnvironmentRefletion;UseEnvironment Reflections;23;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-7521.66,861.0554;Inherit;False;Property;_LightRampOffset;Light Ramp Offset;10;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1363;-3200.625,1032.195;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;264;-8078.69,1188.689;Float;False;Constant;_Vector3;Vector 3;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightColorNode;1618;-6177.877,1073.607;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;240;-7871.515,1182.917;Inherit;False;244;BNAttenuationColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;44;-272.0464,388.2114;Inherit;False;Property;_OutlineColor;Outline Color;7;1;[HDR];Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;392;-3964.421,784.6321;Inherit;False;391;BNDiffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;805;-7912.013,3671.725;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;965;-7234.521,1335.426;Inherit;False;CompleteDiffuseLight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;677;1771.378,2591.815;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;262;-7955.69,1024.69;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-5309.791,4408.579;Inherit;False;3;3;0;FLOAT3;1,1,1;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;1578;-6617.355,4640.566;Inherit;False;float minOut = 0.5 * SpecFaloff - 0.005@$float faloff = lerp(IN, smoothstep(minOut, 0.5, IN), SpecFaloff)@$if(Steps < 1)${$    return faloff@$}$else${$    return  floor(faloff / (1 / Steps)) * (1 / Steps)@$};1;Create;3;True;IN;FLOAT;0;In;;Inherit;False;True;SpecFaloff;FLOAT;0;In;;Inherit;False;True;Steps;FLOAT;0;In;;Inherit;False;FaloffPosterize;False;False;0;;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;692;-3272.457,1181.337;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;463;474.3687,-786.8387;Inherit;False;Property;_RimSmoothness;Rim Smoothness;19;0;Create;True;0;0;0;False;0;False;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1269;-2978.034,1065.561;Inherit;False;IndirectDiffuseLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;738;1410.798,-984.0667;Inherit;False;FresnelValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;681;-642.0081,1027.625;Inherit;False;680;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1642;3442.544,-824.1395;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;644;-6449.8,4949.976;Inherit;False;638;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1573;-6998.024,3902.458;Inherit;False;float3 Color = 0@$$Smoothness = exp2(10 * Smoothness + 1)@$int numLights = GetAdditionalLightsCount()@$for(int i = 0@ i<numLights@i++)${$	$			#if VERSION_GREATER_EQUAL(10, 1)$			Light light = GetAdditionalLight(i, WorldPosition, half4(1,1,1,1))@$			// see AdditionalLights_float for explanation of this$		#else$			Light light = GetAdditionalLight(i, WorldPosition)@$		#endif$	$	half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation)@$	Color += LightingSpecular(AttLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness)@	$}$$float IN = max(Color.b,max(Color.r,Color.g))@$$float minOut = 0.5 * SpecFaloff - 0.005@$float faloff = lerp(IN, smoothstep(minOut, 0.5, IN), SpecFaloff)@$if(Steps < 1)${$    return Color *faloff@$}$else${$    return  Color *floor(faloff / (1 / Steps)) * (1 / Steps)@$}$;3;Create;7;True;WorldPosition;FLOAT3;0,0,0;In;;Float;False;True;WorldNormal;FLOAT3;0,0,0;In;;Float;False;True;WorldView;FLOAT3;0,0,0;In;;Float;False;True;SpecColor;FLOAT3;0,0,0;In;;Float;False;True;Smoothness;FLOAT;0.5;In;;Float;False;True;Steps;FLOAT;0;In;;Inherit;False;True;SpecFaloff;FLOAT;0;In;;Inherit;False;AdditionalLightsSpecularMy;False;False;0;;False;7;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.5;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1182;-7973.279,2382.003;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;739;1602.727,-887.0901;Inherit;False;738;FresnelValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1154;-7747.325,2352.084;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;-7359.01,-314.2965;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StickyNoteNode;1830;-212.1996,1143.355;Inherit;False;233;107;Passes note;;1,1,1,1;Outline goes to pass 0 and main color - pass1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;1644;2679.005,-656.2682;Inherit;False;1554;BNDiffuseNoAdditionalLights;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;1623;-6113.893,853.9744;Inherit;False;Constant;_Vector7;Vector 7;127;0;Create;True;0;0;0;False;0;False;0.02,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;1626;-5251.492,1022.015;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;464;1860.825,-948.3539;Inherit;False;Property;_UseRimLight;UseRim Light;0;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;37;767.6155,655.3234;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;Outline;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;False;3;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;38;810.7261,969.3201;Half;False;True;-1;2;EasyToonEditor;0;3;EasyToon;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;609;False;False;False;False;False;False;False;False;True;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;False;3;False;-1;255;False;-1;255;False;-1;6;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;3;Include;;False;;Native;Define;SHADOWS_SHADOWMASK ;False;;Custom;Define;LIGHTMAP_SHADOW_MIXING;False;;Custom;Hidden/InternalErrorShader;0;0;Standard;22;Surface;0;637907986160208080;  Blend;0;0;Two Sided;1;637939936961855668;Cast Shadows;1;637902205630114247;  Use Shadow Threshold;0;637907986233619545;Receive Shadows;1;0;GPU Instancing;1;637907985755765500;LOD CrossFade;1;637907985705130755;Built-in Fog;1;637944461292224148;DOTS Instancing;1;637929599127041209;Meta Pass;0;637907985862699637;Extra Pre Pass;1;637895286114259463;Tessellation;0;637907986108290338;  Phong;0;637907986103939104;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;True;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;40;-6,232;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;41;-6,232;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;39;-6,232;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;1651;1;1669;0
WireConnection;1655;1;1651;1
WireConnection;1655;2;1652;0
WireConnection;1656;0;1655;0
WireConnection;1656;1;1655;0
WireConnection;1656;2;1655;0
WireConnection;362;1;1669;0
WireConnection;1653;0;204;0
WireConnection;1653;1;362;0
WireConnection;1653;2;1656;0
WireConnection;364;0;1653;0
WireConnection;671;0;670;0
WireConnection;1104;0;1093;0
WireConnection;282;0;1635;0
WireConnection;282;1;681;0
WireConnection;1646;1;456;0
WireConnection;1646;0;1647;0
WireConnection;1646;2;1650;0
WireConnection;636;1;1669;0
WireConnection;238;0;237;0
WireConnection;650;0;653;0
WireConnection;650;1;649;0
WireConnection;265;0;238;0
WireConnection;1619;0;1451;0
WireConnection;1619;1;1618;0
WireConnection;1619;2;1625;0
WireConnection;360;0;359;0
WireConnection;360;1;1188;0
WireConnection;1536;0;1540;0
WireConnection;1536;1;1541;0
WireConnection;1536;2;1539;0
WireConnection;252;0;254;0
WireConnection;252;1;256;0
WireConnection;1103;1;1093;0
WireConnection;365;0;62;0
WireConnection;401;0;246;0
WireConnection;401;1;665;0
WireConnection;246;0;252;0
WireConnection;243;0;627;0
WireConnection;1415;0;1412;4
WireConnection;1359;0;1357;0
WireConnection;1362;0;1358;0
WireConnection;233;0;234;0
WireConnection;1349;1;1350;0
WireConnection;1349;0;673;0
WireConnection;695;1;1797;0
WireConnection;695;2;696;0
WireConnection;371;0;370;0
WireConnection;652;0;650;0
WireConnection;276;0;581;0
WireConnection;466;0;463;0
WireConnection;1188;1;260;0
WireConnection;638;0;658;0
WireConnection;661;0;618;0
WireConnection;661;1;623;0
WireConnection;661;2;644;0
WireConnection;1364;0;621;0
WireConnection;618;0;619;0
WireConnection;618;1;644;0
WireConnection;1628;0;1451;0
WireConnection;1628;1;1629;0
WireConnection;1628;2;1416;0
WireConnection;1355;0;1359;0
WireConnection;1355;1;1356;0
WireConnection;356;0;360;0
WireConnection;467;0;466;0
WireConnection;361;1;358;0
WireConnection;1562;0;1202;0
WireConnection;42;0;1421;0
WireConnection;42;1;282;0
WireConnection;1357;0;1188;0
WireConnection;1357;1;1362;0
WireConnection;1245;0;1203;0
WireConnection;1245;1;1243;0
WireConnection;454;0;537;0
WireConnection;454;2;458;0
WireConnection;454;3;457;0
WireConnection;1541;1;1669;0
WireConnection;1181;0;1182;0
WireConnection;1181;1;1154;0
WireConnection;1181;2;1840;0
WireConnection;1181;3;1241;0
WireConnection;1181;4;1203;0
WireConnection;1635;0;530;0
WireConnection;1635;1;1643;0
WireConnection;1635;2;461;0
WireConnection;1684;1;1211;0
WireConnection;222;0;226;1
WireConnection;1099;0;1096;0
WireConnection;1203;0;1247;0
WireConnection;682;1;1669;0
WireConnection;372;1;1626;0
WireConnection;372;0;1617;0
WireConnection;372;2;1628;0
WireConnection;1841;0;1622;0
WireConnection;1841;1;1618;0
WireConnection;1683;0;1684;0
WireConnection;1683;1;1500;0
WireConnection;1247;0;1562;0
WireConnection;237;0;222;0
WireConnection;237;1;236;0
WireConnection;239;0;263;0
WireConnection;1360;0;444;0
WireConnection;1330;0;1329;0
WireConnection;462;0;454;0
WireConnection;462;1;467;0
WireConnection;229;0;392;0
WireConnection;229;1;642;0
WireConnection;1797;0;693;0
WireConnection;1629;0;1451;0
WireConnection;1629;1;1618;0
WireConnection;1629;2;1331;0
WireConnection;1680;0;361;0
WireConnection;1680;1;1618;0
WireConnection;444;0;1188;0
WireConnection;444;1;445;0
WireConnection;444;2;371;0
WireConnection;1100;0;401;0
WireConnection;1100;1;1099;0
WireConnection;244;0;227;0
WireConnection;234;0;1542;0
WireConnection;234;1;269;0
WireConnection;665;0;652;0
WireConnection;658;0;636;1
WireConnection;658;1;659;0
WireConnection;1648;0;1644;0
WireConnection;1466;0;692;0
WireConnection;1647;0;456;0
WireConnection;1647;1;1644;0
WireConnection;1500;0;1501;0
WireConnection;1500;1;1505;0
WireConnection;1500;2;1508;0
WireConnection;260;0;262;0
WireConnection;260;1;240;0
WireConnection;391;0;1087;0
WireConnection;685;0;686;0
WireConnection;685;2;677;0
WireConnection;1448;1;362;0
WireConnection;1448;2;1449;0
WireConnection;62;0;59;0
WireConnection;62;1;60;0
WireConnection;1221;0;691;0
WireConnection;1622;1;1623;0
WireConnection;57;1;52;0
WireConnection;57;0;53;0
WireConnection;57;2;54;0
WireConnection;680;0;685;0
WireConnection;1388;0;1376;0
WireConnection;460;0;464;0
WireConnection;259;0;271;0
WireConnection;259;1;694;0
WireConnection;259;2;1366;0
WireConnection;60;0;57;0
WireConnection;60;1;58;0
WireConnection;1143;0;1181;0
WireConnection;55;0;50;0
WireConnection;55;1;51;0
WireConnection;59;1;55;0
WireConnection;59;2;56;0
WireConnection;1087;0;372;0
WireConnection;1087;1;1157;0
WireConnection;1400;0;406;1
WireConnection;1400;1;1404;0
WireConnection;1400;2;1578;0
WireConnection;1412;1;1414;0
WireConnection;1097;0;1573;0
WireConnection;1097;1;1098;0
WireConnection;1097;2;1104;0
WireConnection;627;0;220;0
WireConnection;1094;0;804;0
WireConnection;1094;1;1103;0
WireConnection;1241;0;1245;0
WireConnection;673;0;671;3
WireConnection;358;0;356;0
WireConnection;358;1;1274;0
WireConnection;358;2;1276;0
WireConnection;1538;0;1537;0
WireConnection;445;0;371;0
WireConnection;1421;0;44;0
WireConnection;1421;1;1448;0
WireConnection;1617;0;1841;0
WireConnection;1617;1;1680;0
WireConnection;1617;2;1416;0
WireConnection;1579;0;1097;0
WireConnection;1579;1;1400;0
WireConnection;274;0;259;0
WireConnection;694;0;270;0
WireConnection;694;1;695;0
WireConnection;1554;0;372;0
WireConnection;263;0;229;0
WireConnection;263;1;1269;0
WireConnection;1102;1;1096;0
WireConnection;653;0;660;0
WireConnection;653;1;651;0
WireConnection;653;2;1102;0
WireConnection;1331;0;1355;0
WireConnection;1331;1;1330;0
WireConnection;1650;0;1645;0
WireConnection;1650;1;456;0
WireConnection;1650;2;1648;0
WireConnection;1625;0;1360;0
WireConnection;1501;0;1502;0
WireConnection;1501;1;1504;0
WireConnection;1537;0;1536;0
WireConnection;588;0;583;0
WireConnection;1144;0;1143;0
WireConnection;621;0;661;0
WireConnection;1363;0;642;0
WireConnection;1363;1;692;0
WireConnection;965;0;1683;0
WireConnection;677;0;682;0
WireConnection;677;1;679;0
WireConnection;262;0;223;0
WireConnection;262;1;264;0
WireConnection;220;0;1579;0
WireConnection;220;1;1397;0
WireConnection;220;2;1403;0
WireConnection;1578;0;1100;0
WireConnection;1578;1;207;0
WireConnection;1578;2;588;0
WireConnection;692;1;276;0
WireConnection;692;2;1221;0
WireConnection;1269;0;1363;0
WireConnection;738;0;462;0
WireConnection;1642;0;1646;0
WireConnection;1573;0;1577;0
WireConnection;1573;1;805;0
WireConnection;1573;2;1574;0
WireConnection;1573;3;1576;0
WireConnection;1573;4;1094;0
WireConnection;1573;5;588;0
WireConnection;1573;6;207;0
WireConnection;227;0;247;1
WireConnection;227;1;1412;3
WireConnection;1626;0;1451;0
WireConnection;1626;1;1619;0
WireConnection;1626;2;1416;0
WireConnection;464;0;739;0
WireConnection;37;0;42;0
WireConnection;37;1;1349;0
WireConnection;37;2;674;0
WireConnection;37;3;365;0
WireConnection;38;2;42;0
WireConnection;38;3;673;0
WireConnection;38;4;674;0
ASEEND*/
//CHKSM=8CCE39711CCA7B8681149C3B273B6942F9382FC0
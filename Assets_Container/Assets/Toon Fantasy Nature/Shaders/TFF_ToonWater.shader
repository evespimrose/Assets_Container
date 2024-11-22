Shader "Toon/TFF_ToonWater"
{
	Properties
	{
		_ShallowColor("Shallow Color", Color) = (0,0.6117647,1,1)
		_DeepColor("Deep Color", Color) = (0,0.3333333,0.8509804,1)
		_ShallowColorDepth("Shallow Color Depth", Range( 0 , 15)) = 2.75
		_Opacity("Opacity", Range( 0 , 1)) = 0.5
		_OpacityDepth("Opacity Depth", Range( 0 , 20)) = 6.5
		_FoamColor("Foam Color", Color) = (0.8705882,0.8705882,0.8705882,1)
		_FoamHardness("Foam Hardness", Range( 0 , 1)) = 0.33
		_FoamDistance("Foam Distance", Range( 0 , 1)) = 0.05
		_FoamOpacity("Foam Opacity", Range( 0 , 1)) = 0.65
		_FoamScale("Foam Scale", Range( 0 , 1)) = 0.2
		_FoamSpeed("Foam Speed", Range( 0 , 1)) = 0.125
		_FresnelColor("Fresnel Color", Color) = (0.8313726,0.8313726,0.8313726,1)
		_FresnelIntensity("Fresnel Intensity", Range( 0 , 1)) = 0.4
		[Toggle(_WAVES_ON)] _Waves("Waves", Float) = 1
		_WaveAmplitude("Wave Amplitude", Range( 0 , 1)) = 0.5
		_WaveIntensity("Wave Intensity", Range( 0 , 1)) = 0.15
		_WaveSpeed("Wave Speed", Range( 0 , 1)) = 1
		_ReflectionsOpacity("Reflections Opacity", Range( 0 , 1)) = 0.65
		_ReflectionsScale("Reflections Scale", Range( 1 , 40)) = 4.8
		_ReflectionsScrollSpeed("Reflections Scroll Speed", Range( -1 , 1)) = 0.05
		_ReflectionsCutoff("Reflections Cutoff", Range( 0 , 1)) = 0.35
		_ReflectionsCutoffScale("Reflections Cutoff Scale", Range( 1 , 40)) = 3
		_ReflectionsCutoffScrollSpeed("Reflections Cutoff Scroll Speed", Range( -1 , 1)) = -0.025
		[Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.5
		#pragma shader_feature _WAVES_ON
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha addshadow fullforwardshadows nolightmap  nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _WaveSpeed;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _WaveAmplitude;
		uniform float _WaveIntensity;
		uniform sampler2D _NoiseTexture;
		uniform float _ReflectionsScrollSpeed;
		uniform float _ReflectionsScale;
		uniform float _ReflectionsOpacity;
		uniform float4 _ShallowColor;
		uniform float4 _DeepColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _ShallowColorDepth;
		uniform float4 _FresnelColor;
		uniform float _FresnelIntensity;
		uniform float4 _FoamColor;
		uniform float _FoamSpeed;
		uniform float _FoamScale;
		uniform float _FoamDistance;
		uniform float _FoamHardness;
		uniform float _FoamOpacity;
		uniform float _ReflectionsCutoffScrollSpeed;
		uniform float _ReflectionsCutoffScale;
		uniform float _ReflectionsCutoff;
		uniform float _Opacity;
		uniform float _OpacityDepth;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float2 uv_NormalMap = v.texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			#ifdef _WAVES_ON
				float3 staticSwitch321 = ( ase_vertexNormal * ( sin( ( ( _Time.y * _WaveSpeed ) - ( UnpackNormal( tex2Dlod( _NormalMap, float4( uv_NormalMap, 0, 0.0) ) ).b * ( _WaveAmplitude * 30.0 ) ) ) ) * (0.0 + (_WaveIntensity - 0.0) * (0.15 - 0.0) / (1.0 - 0.0)) ) );
			#else
				float3 staticSwitch321 = float3( 0,0,0 );
			#endif
			v.vertex.xyz += staticSwitch321;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth163 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth163 = abs( ( screenDepth163 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( tex2D( _NoiseTexture, ( ( (0.0 + (_FoamSpeed - 0.0) * (2.5 - 0.0) / (1.0 - 0.0)) * _Time.y ) + ( i.uv_texcoord * (30.0 + (_FoamScale - 0.0) * (1.0 - 30.0) / (1.0 - 0.0)) ) ) ).r * (0.0 + (_FoamDistance - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) );
			float clampResult208 = clamp( distanceDepth163 , 0.0 , 1.0 );
			float clampResult160 = clamp( pow( clampResult208 , (1.0 + (_FoamHardness - 0.0) * (10.0 - 1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
			float temp_output_156_0 = ( ( 1.0 - clampResult160 ) * _FoamOpacity );
			float screenDepth191 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth191 = abs( ( screenDepth191 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( (0.0 + (_FoamDistance - 0.0) * (15.0 - 0.0) / (1.0 - 0.0)) ) );
			float clampResult207 = clamp( distanceDepth191 , 0.0 , 1.0 );
			float FoamScale330 = _FoamScale;
			float temp_output_185_0 = ( ( 1.0 - clampResult207 ) * ( tex2D( _NoiseTexture, ( ( _Time.y * _FoamSpeed ) + ( i.uv_texcoord * (15.0 + (FoamScale330 - 0.0) * (1.0 - 15.0) / (1.0 - 0.0)) ) ) ).r * (0.0 + (_FoamOpacity - 0.0) * (0.85 - 0.0) / (1.0 - 0.0)) ) );
			float screenDepth294 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth294 = abs( ( screenDepth294 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _OpacityDepth ) );
			float clampResult295 = clamp( distanceDepth294 , 0.0 , 1.0 );
			float clampResult299 = clamp( ( ( temp_output_156_0 + temp_output_185_0 ) + _Opacity + clampResult295 ) , 0.0 , 1.0 );
			float3 ase_worldPos = i.worldPos;
			float3 normalizeResult232 = normalize( ( _WorldSpaceCameraPos - ase_worldPos ) );
			float2 temp_cast_8 = (_ReflectionsCutoffScrollSpeed).xx;
			float2 panner342 = ( 1.0 * _Time.y * temp_cast_8 + ( i.uv_texcoord * (2.0 + (_ReflectionsCutoffScale - 0.0) * (10.0 - 2.0) / (10.0 - 0.0)) ));
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult108 = dot( reflect( -normalizeResult232 , (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, panner342 ) ) )) ) , ase_worldlightDir );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 temp_cast_9 = (_ReflectionsScrollSpeed).xx;
			float2 panner40 = ( 1.0 * _Time.y * temp_cast_9 + ( i.uv_texcoord * _ReflectionsScale ));
			float temp_output_37_0 = ( UnpackNormal( tex2D( _NormalMap, panner40 ) ).g * (0.0 + (_ReflectionsOpacity - 0.0) * (8.0 - 0.0) / (1.0 - 0.0)) );
			float3 clampResult120 = clamp( ( ( pow( dotResult108 , exp( (0.0 + (_ReflectionsCutoff - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) * ase_lightColor.rgb ) * temp_output_37_0 ) , float3( 0,0,0 ) , float3( 1,1,1 ) );
			float3 lerpResult90 = lerp( ( clampResult120 * float3( i.uv_texcoord ,  0.0 ) ) , ( ase_lightColor.rgb * ase_lightAtten ) , ( 1.0 - ase_lightAtten ));
			c.rgb = lerpResult90;
			c.a = clampResult299;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 appendResult31 = (float2(( ase_screenPosNorm.x + 0.01 ) , ( ase_screenPosNorm.y + 0.01 )));
			float2 temp_cast_1 = (_ReflectionsScrollSpeed).xx;
			float2 panner40 = ( 1.0 * _Time.y * temp_cast_1 + ( i.uv_texcoord * _ReflectionsScale ));
			float temp_output_37_0 = ( UnpackNormal( tex2D( _NormalMap, panner40 ) ).g * (0.0 + (_ReflectionsOpacity - 0.0) * (8.0 - 0.0) / (1.0 - 0.0)) );
			float Turbulence291 = temp_output_37_0;
			float4 lerpResult24 = lerp( ase_screenPosNorm , float4( appendResult31, 0.0 , 0.0 ) , Turbulence291);
			float screenDepth146 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth146 = abs( ( screenDepth146 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _ShallowColorDepth ) );
			float clampResult211 = clamp( distanceDepth146 , 0.0 , 1.0 );
			float4 lerpResult142 = lerp( _ShallowColor , _DeepColor , clampResult211);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV136 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode136 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV136, (0.0 + (_FresnelIntensity - 1.0) * (10.0 - 0.0) / (0.0 - 1.0)) ) );
			float clampResult209 = clamp( fresnelNode136 , 0.0 , 1.0 );
			float4 lerpResult133 = lerp( lerpResult142 , _FresnelColor , clampResult209);
			float4 blendOpSrc300 = ( 0.0 * tex2D( _NoiseTexture, lerpResult24.xy ) );
			float4 blendOpDest300 = lerpResult133;
			float screenDepth163 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth163 = abs( ( screenDepth163 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( tex2D( _NoiseTexture, ( ( (0.0 + (_FoamSpeed - 0.0) * (2.5 - 0.0) / (1.0 - 0.0)) * _Time.y ) + ( i.uv_texcoord * (30.0 + (_FoamScale - 0.0) * (1.0 - 30.0) / (1.0 - 0.0)) ) ) ).r * (0.0 + (_FoamDistance - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) );
			float clampResult208 = clamp( distanceDepth163 , 0.0 , 1.0 );
			float clampResult160 = clamp( pow( clampResult208 , (1.0 + (_FoamHardness - 0.0) * (10.0 - 1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
			float temp_output_156_0 = ( ( 1.0 - clampResult160 ) * _FoamOpacity );
			float screenDepth191 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth191 = abs( ( screenDepth191 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( (0.0 + (_FoamDistance - 0.0) * (15.0 - 0.0) / (1.0 - 0.0)) ) );
			float clampResult207 = clamp( distanceDepth191 , 0.0 , 1.0 );
			float FoamScale330 = _FoamScale;
			float temp_output_185_0 = ( ( 1.0 - clampResult207 ) * ( tex2D( _NoiseTexture, ( ( _Time.y * _FoamSpeed ) + ( i.uv_texcoord * (15.0 + (FoamScale330 - 0.0) * (1.0 - 15.0) / (1.0 - 0.0)) ) ) ).r * (0.0 + (_FoamOpacity - 0.0) * (0.85 - 0.0) / (1.0 - 0.0)) ) );
			float3 temp_cast_3 = (1.0).xxx;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 lerpResult7 = lerp( temp_cast_3 , ase_lightColor.rgb , 0.75);
			float3 normalizeResult232 = normalize( ( _WorldSpaceCameraPos - ase_worldPos ) );
			float2 temp_cast_5 = (_ReflectionsCutoffScrollSpeed).xx;
			float2 panner342 = ( 1.0 * _Time.y * temp_cast_5 + ( i.uv_texcoord * (2.0 + (_ReflectionsCutoffScale - 0.0) * (10.0 - 2.0) / (10.0 - 0.0)) ));
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult108 = dot( reflect( -normalizeResult232 , (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, panner342 ) ) )) ) , ase_worldlightDir );
			float3 clampResult120 = clamp( ( ( pow( dotResult108 , exp( (0.0 + (_ReflectionsCutoff - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) ) * ase_lightColor.rgb ) * temp_output_37_0 ) , float3( 0,0,0 ) , float3( 1,1,1 ) );
			o.Emission = ( ( ( ( blendOpSrc300 + blendOpDest300 ) + ( _FoamColor * temp_output_156_0 ) + ( _FoamColor * temp_output_185_0 ) ) * float4( lerpResult7 , 0.0 ) ) + float4( clampResult120 , 0.0 ) ).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
}
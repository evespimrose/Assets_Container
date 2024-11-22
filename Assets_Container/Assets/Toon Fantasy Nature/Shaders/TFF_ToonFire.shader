Shader "Toon/TFF_ToonFire"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BurnSpeed("Burn Speed", Range( 0 , 1)) = -0.75
		_ColorBlend("Color Blend", Range( 0 , 1)) = 0.65
		_TopColor("Top Color", Color) = (1,0,0.2424197,0)
		_BaseColor("Base Color", Color) = (1,0.808957,0,0)
		_InnerColor("Inner Color", Color) = (0,0.5678592,1,0)
		_OpacityCutoff("Opacity Cutoff", Range( 0 , 1)) = 0.1
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		_MaskTexture("Mask Texture", 2D) = "white" {}
		_Shading("Shading", Range( 0 , 1)) = 0
		_Brightness("Brightness", Range( 0 , 5)) = 1.49
		_DepthFade("Depth Fade", Range( 0 , 10)) = 0
		_Offset("Offset", Range( 0 , 1)) = 0.125
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.5
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows nolightmap  nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float _Offset;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFade;
		uniform float4 _BaseColor;
		uniform float _ColorBlend;
		uniform float4 _TopColor;
		uniform sampler2D _NoiseTexture;
		uniform float _BurnSpeed;
		uniform sampler2D _MaskTexture;
		uniform float4 _MaskTexture_ST;
		uniform float4 _InnerColor;
		uniform float _Shading;
		uniform float _Brightness;
		uniform float _OpacityCutoff;
		uniform float _Cutoff = 0.5;


		inline float4 ASESafeNormalize(float4 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			//Calculate new billboard vertex position and normal;
			float3 upCamVec = normalize ( UNITY_MATRIX_V._m10_m11_m12 );
			float3 forwardCamVec = -normalize ( UNITY_MATRIX_V._m20_m21_m22 );
			float3 rightCamVec = normalize( UNITY_MATRIX_V._m00_m01_m02 );
			float4x4 rotationCamMatrix = float4x4( rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1 );
			v.normal = normalize( mul( float4( v.normal , 0 ), rotationCamMatrix )).xyz;
			v.tangent.xyz = normalize( mul( float4( v.tangent.xyz , 0 ), rotationCamMatrix )).xyz;
			//This unfortunately must be made to take non-uniform scaling into account;
			//Transform to world coords, apply rotation and transform back to local;
			v.vertex = mul( v.vertex , unity_ObjectToWorld );
			v.vertex = mul( v.vertex , rotationCamMatrix );
			v.vertex = mul( v.vertex , unity_WorldToObject );
			float4 transform420 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 normalizeResult422 = ASESafeNormalize( ( float4( _WorldSpaceCameraPos , 0.0 ) - transform420 ) );
			float3 ase_vertex3Pos = v.vertex.xyz;
			v.vertex.xyz += ( ( _Offset * normalizeResult422 ) + float4( ( 0.1 * ( 0 + ase_vertex3Pos ) ) , 0.0 ) ).xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth408 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth408 = saturate( abs( ( screenDepth408 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFade ) ) );
			float smoothstepResult381 = smoothstep( 0.0 , _ColorBlend , i.uv_texcoord.y);
			float temp_output_425_0 = (0.0 + (_BurnSpeed - 0.0) * (-2.0 - 0.0) / (1.0 - 0.0));
			float2 appendResult357 = (float2(0.0 , temp_output_425_0));
			float2 uv_TexCoord350 = i.uv_texcoord + float2( 2.6,0 );
			float2 panner359 = ( 1.0 * _Time.y * appendResult357 + ( 1.0 * uv_TexCoord350 ));
			float2 appendResult358 = (float2(0.0 , ( temp_output_425_0 * 2 )));
			float2 panner360 = ( 1.0 * _Time.y * appendResult358 + ( uv_TexCoord350 * 0.5 ));
			float2 uv_MaskTexture = i.uv_texcoord * _MaskTexture_ST.xy + _MaskTexture_ST.zw;
			float4 tex2DNode373 = tex2D( _MaskTexture, uv_MaskTexture );
			o.Emission = ( saturate( distanceDepth408 ) * ( ( ( ( ( _BaseColor * ( 1.0 - smoothstepResult381 ) ) + ( smoothstepResult381 * _TopColor ) ) * ( 1.0 - ( ( ( tex2D( _NoiseTexture, panner359 ).r * tex2D( _NoiseTexture, panner360 ).r ) + tex2DNode373.r ) * tex2DNode373.r ) ) ) + ( _InnerColor * ( ( ( tex2D( _NoiseTexture, panner359 ).r * tex2D( _NoiseTexture, panner360 ).r ) + tex2DNode373.r ) * tex2DNode373.r ) ) ) * saturate( ( ( 1.0 - _Shading ) + ( ( ( tex2D( _NoiseTexture, panner359 ).r * tex2D( _NoiseTexture, panner360 ).r ) + tex2DNode373.r ) * tex2DNode373.r ) ) ) * _Brightness ) ).rgb;
			o.Alpha = 1;
			clip( step( (0.02 + (_OpacityCutoff - 0.0) * (1.0 - 0.02) / (1.0 - 0.0)) , ( ( ( tex2D( _NoiseTexture, panner359 ).r * tex2D( _NoiseTexture, panner360 ).r ) + tex2DNode373.r ) * tex2DNode373.r ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
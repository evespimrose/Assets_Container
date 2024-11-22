// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Polytope Studio/ PT_Medieval Buildings Glass Shader PBR"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (0.004227493,0.8962264,0.8136094,1)
		[Gamma]_Transparency("Transparency", Range( 0 , 1)) = 0.85
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ "RefractionGrab1" }
		CGPROGRAM
		#pragma target 3.5
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#pragma surface surf Standard keepalpha finalcolor:RefractionF noshadow exclude_path:deferred 
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
		};

		uniform float4 _Color;
		uniform float _Transparency;
		uniform sampler2D RefractionGrab1;

		inline float4 Refraction( Input i, SurfaceOutputStandard o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) );
			float2 cameraRefraction = float2( refractionOffset.x, refractionOffset.y );
			float4 redAlpha = tex2D( RefractionGrab1, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( RefractionGrab1, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( RefractionGrab1, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandard o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			color.rgb = color.rgb + Refraction( i, o, 1.0, _Transparency ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			o.Albedo = _Color.rgb;
			o.Metallic = 0.0;
			o.Smoothness = 1.0;
			float smoothstepResult832 = smoothstep( 0.0 , 1.0 , _Transparency);
			o.Alpha = smoothstepResult832;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
	}
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;428;-3373.004,1442.333;Float;False;True;-1;3;;0;0;Standard;Polytope Studio/ PT_Medieval Buildings Glass Shader PBR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;True;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.1;True;False;0;True;Transparent;;Transparent;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;2;5;False;;10;False;;0;False;;0;False;;1;False;13.63;1,0,0,0;VertexScale;False;False;Cylindrical;False;True;Relative;0;;1;-1;3;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0;True;_Transparency;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SmoothstepOpNode;832;-4131.246,1804.473;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;836;-3750.356,1653.055;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;833;-4503.05,1766.66;Float;False;Property;_Transparency;Transparency;2;2;[Gamma];[Header];Create;False;0;0;0;False;0;False;0.85;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;835;-3837.795,1322.305;Float;False;Property;_Color;Color;0;2;[HDR];[Header];Create;True;0;0;0;False;0;False;0.004227493,0.8962264,0.8136094,1;0.000303527,0.783538,0.6239606,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;831;-4116.295,1503.016;Inherit;False;Constant;_METALLIC; METALLIC;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;834;-4138.837,1626.747;Inherit;False;Constant;_Smoothness;Smoothness;3;1;[Header];Create;True;0;0;0;False;0;False;1;0.3;0;1;0;1;FLOAT;0
WireConnection;428;0;835;0
WireConnection;428;3;831;0
WireConnection;428;4;834;0
WireConnection;428;8;836;0
WireConnection;428;9;832;0
WireConnection;832;0;833;0
ASEEND*/
//CHKSM=35E28400C7CF39DB5FB36C47DF08E6F094B07AF0
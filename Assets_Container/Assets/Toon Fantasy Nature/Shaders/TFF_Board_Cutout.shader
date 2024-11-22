Shader "Toon/TFF_Board_Cutout"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_ColorOverlay("Color Overlay", Color) = (0,0,0,0)
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TreeTransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows nolightmap  nodirlightmap 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _ColorOverlay;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Emission = _ColorOverlay.rgb;
			o.Alpha = 1;
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			clip( tex2D( _TextureSample0, uv_TextureSample0 ).a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
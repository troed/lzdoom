
layout(location=0) in vec2 TexCoord;
layout(location=0) out vec4 FragColor;

layout(binding=0) uniform sampler2D InputTexture;
layout(binding=1) uniform sampler2D DitherTexture;

vec4 ApplyGamma(vec4 c)
{
	vec3 valgray;
	if (GrayFormula == 0)
		valgray = vec3(c.r + c.g + c.b) * (1 - Saturation) / 3 + c.rgb * Saturation;
	else
		valgray = mix(vec3(dot(c.rgb, vec3(0.3,0.56,0.14))), c.rgb, Saturation);
	vec3 val = valgray * Contrast - (Contrast - 1.0) * 0.5;
	val += Brightness * 0.5;
	val = pow(max(val, vec3(0.0)), vec3(InvGamma));
	return vec4(val, c.a);
}

vec4 Dither(vec4 c)
{
	if (ColorScale == 0.0)
		return c;
	vec2 texSize = vec2(textureSize(DitherTexture, 0));
	float threshold = texture(DitherTexture, gl_FragCoord.xy / texSize).r;
	return vec4(floor(c.rgb * ColorScale + threshold) / ColorScale, c.a);
}

vec4 sRGBtoLinear(vec4 c)
{
	return vec4(mix(c.rgb / 12.92, pow((c.rgb + 0.055) / 1.055, vec3(2.4)), step(c.rgb, vec3(0.04045))), c.a);
}

vec4 ApplyHdrMode(vec4 c)
{
	if (HdrMode == 0)
		return c;
	else
		return sRGBtoLinear(c);
}

void main()
{
	FragColor = Dither(ApplyHdrMode(ApplyGamma(texture(InputTexture, UVOffset + TexCoord * UVScale))));
}

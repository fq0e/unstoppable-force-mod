import flixel.system.FlxAssets.FlxShader;

class GlitchEffect1 extends FlxShader
{
	@:glFragmentSource("
    //SHADERTOY PORT FIX
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    #define iChannel0 bitmap
    #define iChannel1 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    uniform float glitchAmount = 0.0;

    //SHADERTOY PORT FIX (thanks bbpanzu)

vec4 posterize(vec4 color, float numColors)
{
    return floor(color * numColors - 0.5) / numColors;
}

vec2 quantize(vec2 v, float steps)
{
    return floor(v * steps) / steps;
}

float dist(vec2 a, vec2 b)
{
    return sqrt(pow(b.x - a.x, 2.0) + pow(b.y - a.y, 2.0));
}

void mainImage()
{   
	vec2 uv = fragCoord.xy / iResolution.xy;
    float amount = pow(glitchAmount, 2.0);
    vec2 pixel = 1.0 / iResolution.xy;    
    vec4 color = texture(iChannel0, uv);

    float t = mod(mod(iTime, amount * 100.0 * (amount - 0.5)) * 109.0, 1.0);
    vec4 postColor = posterize(color, 16.0);
    vec4 a = posterize(texture(iChannel0, quantize(uv, 64.0 * t) + pixel * (postColor.rb - vec2(.5)) * 100.0), 5.0).rbga;
    vec4 b = posterize(texture(iChannel0, quantize(uv, 32.0 - t) + pixel * (postColor.rg - vec2(.5)) * 1000.0), 4.0).gbra;
    vec4 c = posterize(texture(iChannel0, quantize(uv, 16.0 + t) + pixel * (postColor.rg - vec2(.5)) * 20.0), 16.0).bgra;
    fragColor = mix(
        			texture(iChannel0, 
                              uv + amount * (quantize((a * t - b + c - (t + t / 2.0) / 10.0).rg, 16.0) - vec2(.5)) * pixel * 100.0),
                    (a + b + c) / 3.0,
                    (0.5 - (dot(color, postColor) - 1.5)) * amount);
}
    ")
	public function new()
	{
		super();
        iTime.value = [0.0];
        glitchAmount.value = [0.0];
	}

	public function update(elapsed: Float)
	{
		iTime.value[0] += elapsed;
        glitchAmount.value[0] += elapsed;
	}
}


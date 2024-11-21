shader_type canvas_item;

//uniform sampler2D noiseTexture;
uniform vec3 baseColorRGB = vec3(0.2, 0.1, 0.4);
uniform float speed = 0.15;

mat2 makem2(in float theta)
{
	float c = cos(theta);
	float s = sin(theta);
	vec2 part1 = vec2(c, -s);
	vec2 part2 = vec2(s, c);
	return mat2(part1, part2);
}

//float noise(in vec2 x)
//{
	//return texture(noiseTexture, x * 0.01).x;
//}

vec2 random(vec2 uv){
	uv = vec2( dot(uv, vec2(127.1,311.7) ), dot(uv, vec2(269.5,183.3) ) );
	return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
	vec2 uv_index = floor(uv);
	vec2 uv_fract = fract(uv);

	vec2 blur = smoothstep(0.0, 1.0, uv_fract);

	return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
				dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
				mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
				dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

float fbm(in vec2 p)
{
	float z = 2.0;
	float rz = 0.0;
	vec2 bp = p;
	for (float i = 1.0; i < 6.0; i++)
	{
		rz += abs((noise(p) - 0.5) * 2.0) / z;
		z = z * 2.0;
		p = p * 2.0;
	}
	return rz;
}

float dualfbm(in vec2 p)
{
	//get two rotated fbm calls and displace the domain
	vec2 p2 = p * 0.7;
	vec2 basis = vec2(fbm(p2 - (TIME * speed) * 1.6), fbm(p2 + (TIME * speed) * 1.7));
	basis = (basis - 0.5) * 0.2;
	p += basis;
	
	//coloring
	return fbm(p * makem2((TIME * speed) * 0.2));
}

float circ(vec2 p) 
{
	float tau = 6.2831853;
	float r = length(p);
	r = 0.5 * log(r);
	return abs(mod(r * 4.0, tau) - 3.14) * 3.0 + 0.2;
}

void fragment()
{
	//setup system
	vec2 p = UV.xy / (1.0 / TEXTURE_PIXEL_SIZE).xy - 0.5;
	p.x *= (1.0 / TEXTURE_PIXEL_SIZE).x / (1.0 / TEXTURE_PIXEL_SIZE).y;
	p *= 4.0;
	
	float rz = dualfbm(p);
	
	//rings
	p /= exp(mod((TIME * speed) * 10.0, 3.14159));
	rz *= pow(abs((0.1 - circ(p))), 0.9);
	
	//final color
	vec3 col = baseColorRGB / rz;
	col = pow(abs(col), vec3(0.99));
	COLOR = vec4(col, 1.0);
}
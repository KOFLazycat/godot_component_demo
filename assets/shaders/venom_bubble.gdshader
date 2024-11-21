shader_type canvas_item;

uniform float progress1:hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float progress2:hint_range(0.0, 1.0, 0.01) = 0.0;

//------------------------------------------------------------
uniform sampler2D noise;
uniform float progress4: hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge_color: source_color;

// 粒子寿命
varying float lifetime;
void vertex(){
	lifetime = INSTANCE_CUSTOM.y - 0.5;
}

void fragment(){
	// 做遮罩
	vec2 uv = UV;
	uv.x = uv.x-0.5;
	uv.y = uv.y+0.4;
	float a = length(uv);
	a = 1.0-smoothstep(0.52,0.5,a*progress1);
	//COLOR = vec4(a,a,a,1.0);

	vec2 uv2 = UV;
	uv2.x = uv2.x-0.5;
	uv2.y = uv2.y-0.5;
	float b = length(uv2*2.0);
	float c = smoothstep(0.52,0.5,b*progress2);

	float d = clamp(c-a,0.0,1.0);
	//COLOR = vec4(d,d,d,d);

	float e = smoothstep(0.52,0.4,b*progress2);
	float f = clamp(e-a,0.0,1.0);
	f = clamp(d-f,0.0,1.0);
	float g = clamp(d-f,0.0,1.0);
	//COLOR = vec4(f);

	vec4 a_color = vec4(g,g,g,g) * COLOR;
	vec4 b_color = vec4(f,f,f,f) * edge_color;
	COLOR = a_color + b_color;

	// 溶解
	vec4 noise_color = texture(noise,UV);

	float noise_mask = step(0.0,noise_color.r+UV.g - lifetime*2.);
	vec3 noise_mask_edge = vec3(noise_mask - step(0.0,noise_color.r+UV.g - (lifetime * 2.0 + 0.07)));

	COLOR.a = clamp(COLOR.a * noise_mask,0.0,1.0);
	COLOR.rgb = clamp(COLOR.rgb - noise_mask_edge,0.0,1.0) + noise_mask_edge * edge_color.rgb;

}
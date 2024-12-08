shader_type canvas_item;

uniform float speed = 1.0;
uniform float p:hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() {
	vec2 uv = vec2(UV.y, UV.x);
	vec2 moving_uv = vec2(uv.x, UV.y - (TIME * speed));
	moving_uv = fract(moving_uv);
	
	vec4 in_tex = texture(TEXTURE, moving_uv);
	float mask_color = 1.0 - (UV.x + p);
	
	COLOR = vec4(COLOR.r, COLOR.g, COLOR.b, clamp(in_tex.a * mask_color, 0.0, 1.0));
}

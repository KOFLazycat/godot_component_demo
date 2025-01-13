shader_type canvas_item;

uniform float yoffset = 0.5;
uniform float animation_speed = 0.5;
uniform vec4 flame_color: source_color = vec4(1.0);
uniform sampler2D noise_texture: hint_default_black, repeat_enable;

void fragment() {
	vec2 uv = vec2(UV.x, UV.y + TIME * animation_speed);
	vec4 noise_color = texture(noise_texture, uv);
	vec4 final_color = noise_color;
	final_color.rgb += vec3(UV.y - yoffset);
	final_color.rgb = step(final_color.rgb, vec3(0.5));
	final_color.rgb = vec3(1.0) - final_color.rgb;
	final_color.a = final_color.r;
	final_color.rgb = flame_color.rgb;
	COLOR = final_color;
}


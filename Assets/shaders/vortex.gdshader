shader_type canvas_item;

uniform float intensity : hint_range(0, 20);
uniform float mask : hint_range(0.0, 1.0, 0.01);
uniform float offset : hint_range(0.0, 2.0, 0.01);

float distFromCen( vec2 p) {
	return distance(p, vec2(0.5));
}

//rotates by angle radians
vec2 rotate(vec2 p, float angle){
	return vec2(cos(angle) * p.x - sin(angle)*p.y, sin(angle) * p.x + cos(angle) * p.y);
}

void fragment( ) {
	float distMod = distFromCen(UV);
	float angle = intensity * distMod;
	vec2 newp = rotate(UV - vec2(0.5), angle) + vec2(0.5);
	float a = abs((newp.x - 0.5) * 2.0);
	newp.x = fract(a + offset * TIME);
		
	COLOR = texture(TEXTURE, newp);
	float mask_tex = step(distMod, mask);
	COLOR.a = COLOR.a * mask_tex;
}
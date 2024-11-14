shader_type canvas_item;

vec3 palette(float t) {
	vec3 a = vec3(0.5, 0.5, 0.5);
	vec3 b = vec3(0.5, 0.5, 0.5);
	vec3 c = vec3(1.0, 1.0, 1.0);
	vec3 d = vec3(0.263, 0.416, 0.557);
	return a + b * cos(6.28318*(c*t+d));
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	vec2 uv0 = uv;
	vec3 finalColor = vec3(0.0);
	
	for (float i = 0.0; i < 4.0; i++) {
		vec3 col = palette(length(uv0) + i*.4 + TIME*.4);
		
		uv = fract(uv * 1.5) - 0.5;
		
		float d = length(uv) * exp(-length(uv0));
		d = sin(d*8. + TIME)/8.;
		d = abs(d);
		d = pow(0.01 / d, 1.2);
		
		finalColor += col * d;
	}
	
	COLOR = vec4(finalColor, 1.0);
}

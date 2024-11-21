shader_type canvas_item;

// Outline color.
uniform vec4 color: source_color = vec4(1.0);
// Outline thickness.
uniform float thickness: hint_range(0.0, 100.0) = 1.0;
// Used to compensate for alpha values.
uniform float tolerance: hint_range(0.0, 0.999) = 0.0;
// If on will draw at diagonals. Off is mainly for pixel art but you do you.
uniform bool diagonals = true;
// If diagonals are checked will check for half pixels so it rounds the outline a bit more.
uniform bool rounded = true;

// Compensate UV for outline.
void vertex() {
	VERTEX = vec2(VERTEX.x * (1.0 + TEXTURE_PIXEL_SIZE.x * thickness * 2.0), VERTEX.y * (1.0 + TEXTURE_PIXEL_SIZE.y * thickness * 2.0));
}

// Checks a fragment for the edge of an uv.
bool border(vec2 uv) {
	vec2 uvBorder = abs(uv - vec2(0.5));
	return max(step(0.5, uvBorder.x), step(0.5, uvBorder.y)) > 0.0;
}

// Gets alpha of given fragment if not near the edge.
float get_alpha(sampler2D tex, vec2 uv){
	float res = 0.0;
	if (!border(uv)) {
		res = texture(tex, uv).a;
	}
	return res;
}

// Checks for neighboring pixels.
float in_range(vec2 size, sampler2D tex, vec2 uv) {
	float res = 0.0;
	for (float i = -1.0; i < 2.0; i += 2.0) {
		res += get_alpha(tex, uv + vec2(i * size.x, 0.0));
		res += get_alpha(tex, uv + vec2(0.0, i * size.y));
		if (diagonals) {
			for (float j = -1.0; j < 2.0; j += 2.0) {
				res += get_alpha(tex, uv + vec2(i * size.x, j * size.y));
				if (rounded) {
					res += get_alpha(tex, uv + vec2(i * size.x, j * size.y * 0.5));
				}
			}
		}
	}
	return res;
}

void fragment() {
	if (thickness > 0.0) {
		// Correct image size to for outline in frame.
		vec2 uv = UV;
		uv -= vec2(0.5);
		float edge = TEXTURE_PIXEL_SIZE.x * thickness * 2.0;
		uv = uv + uv * edge;
		uv += vec2(0.5);
		
		// Apply outline.
		vec4 newColor = texture(TEXTURE, uv);
		if (newColor.a == 0.0 || border(uv)) {
			float outline = in_range(TEXTURE_PIXEL_SIZE * thickness, TEXTURE, uv);
			vec4 finalColor = step(1.0 - tolerance, outline) * color;
			newColor = finalColor;
		}
		COLOR = newColor;
	}
}
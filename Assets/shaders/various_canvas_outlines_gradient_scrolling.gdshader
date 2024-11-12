shader_type canvas_item;

// The texture to scroll with.
uniform sampler2D scrollingTexture: hint_default_white;
// The scroll texture scale.
uniform vec2 textureScale = vec2(1.0);
// Angle to scroll towards. In degrees. Starts at the right.
uniform float angle: hint_range(0.0, 360.0) = 45.0;
// Speed to scroll at.
uniform float textureSpeed: hint_range(-10.0, 10.0) = 0.1;
// Strength of the texture over the color.
uniform float textureStrength: hint_range(0.0, 1.0) = 0.5;
// Outline thickness.
uniform float thickness: hint_range(0.0, 100.0) = 1.0;
// Used to compensate for alpha values.
uniform float tolerance: hint_range(0.0, 0.999) = 0.0;
// The outline color. GradientTexture1D is recommended.
uniform sampler2D color: source_color;
// The resolution for the gradient. Higher numbers will result in smoother but more expensive passes.
uniform int gradientResolution: hint_range(1, 30) = 10;
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
bool in_range(vec2 size, sampler2D tex, vec2 uv) {
	for (float i = -1.0; i < 2.0; i += 2.0) {
		if (get_alpha(tex, uv + vec2(i * size.x, 0.0)) > 0.0) {return true;};
		if (get_alpha(tex, uv + vec2(0.0, i * size.y)) > 0.0) {return true;};
		if (diagonals) {
			for (float j = -1.0; j < 2.0; j += 2.0) {
				if (get_alpha(tex, uv + vec2(i * size.x, j * size.y)) > 0.0) {return true;};
				if (rounded) {
					if (get_alpha(tex, uv + vec2(i * size.x, j * size.y * 0.5)) > 0.0) {return true;};
				}
			}
		}
	}
	return false;
}

// Get's closes pixel.
float get_distance(vec2 maxDistance, sampler2D tex, vec2 uv) {
	for (int i = 1; i < gradientResolution; i++) {
		vec2 actualDistance = float(i) / float (gradientResolution) * maxDistance;
		if (in_range(actualDistance, tex, uv)) {
			return float(i) / float (gradientResolution);
		}
	}
}

void fragment() {
	if (thickness > 0.0) {
		// Correct image size to for outline in frame.
		vec2 uv = UV;
		uv -= vec2(0.5);
		vec2 edge = TEXTURE_PIXEL_SIZE * thickness * 2.0;
		uv = uv + uv * edge;
		uv += vec2(0.5);
		
		// Apply outline.
		vec4 newColor = texture(TEXTURE, uv);
		if (newColor.a <= tolerance || border(uv)) {
			// Correct angle to start at right and convert to radians.
			float radiansAngle = radians(angle + 180.0);
			// Make a vector out of the angle.
			vec2 vector = vec2(cos(radiansAngle), sin(radiansAngle));
			vec4 textureColor = texture(scrollingTexture, fract(UV / textureScale + vector * textureSpeed * TIME));
			vec4 actualColor = texture(color, vec2(get_distance(edge / 2.0 + 0.01, TEXTURE, uv)));
			vec4 finalColor = step(1.0 - tolerance, in_range(edge / 2.0, TEXTURE, uv) ? 1.0: 0.0) * mix(actualColor, textureColor, textureStrength);
			newColor = finalColor;
		}
		COLOR = newColor;
	}
}
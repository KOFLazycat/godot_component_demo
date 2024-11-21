shader_type canvas_item;

/** The center point of the effect. */
uniform vec2 center = vec2(0.5);

/** The number of stripes. */
uniform int stripes = 24;

/** The rotation speed. Set to 0 for a static effect. */
uniform float speed: hint_range(0.0, 5.0, 0.1) = 0.2;

/** Rotation direction: 1 for clockwise and -1 for counter-clockwise. */
uniform int direction: hint_range(-1, 1, 2) = 1;

/** The modifier to apply to the pixels when inside a stripe. The final color will be multiplied by this value. */
uniform vec3 color_modifier = vec3(0.9);


void fragment() {
	// Fix aspect ratio issue.
	vec2 uv_deriv = fwidthFine(UV);
	float aspect_ratio = uv_deriv.y / uv_deriv.x;
	vec2 corrected_uv = UV * vec2(aspect_ratio, 1.0);
	vec2 corrected_center = center * vec2(aspect_ratio, 1.0);

	// Get the angle between the center of the effect and the UV.
	vec2 dir = corrected_center - corrected_uv;
	float angle = atan(dir.y, dir.x) - (TIME * speed * float(direction));
	// Check if the angle is in a stripe or not.
	if (mod(floor(angle / (TAU / float(stripes))), 2) == 0.0) {
		// If yes, apply the modifier to the pixel.
		COLOR.rgb *= color_modifier;
	}
}

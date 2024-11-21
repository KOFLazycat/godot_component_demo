shader_type canvas_item;

/*
 * Arc effect shader by Giles McArdell 2024
 *
 * For creating electric arc and similar effects.
 *
 * based on lumenfruits shader here : https://godotshaders.com/shader/2d-lightning-electric-arc-plasma/
 */

group_uniforms line;
/** The line to draw, usually you want a thin light centre fading quickly to transparent */
uniform sampler2D line_gradient;
/** Width of the line texture */
uniform float width:     hint_range (0.0,1.0);
/** Fix the line start point to the centre */
uniform bool fix_start =  false;
/** Fix the line end point to the centre*/
uniform bool fix_end =    false;
/** Switch the effect across the x or y axis */
uniform bool inverted  =  false;
group_uniforms;
group_uniforms noise;
/** A noise texture to provide the variation in the line */
uniform sampler2D noise_texture;
/** The rate at which the shader moves its sampling position over the noise texture*/
uniform float speed:     hint_range (0.0,5.0);
/** How much the noise moves the line from the centre */
uniform float variation: hint_range (0.0,1.0);
/** Scale (width) of the effect */
uniform float scale:     hint_range(0.0, 100.0);
/** number of times the noise repeats ( < 1.0 stretches the effect, > 1.0 compresses the effect) */
uniform float repeats:   hint_range(0.0, 50.0);

void fragment(){
	vec2 in_uv = UV;
	if (inverted) {in_uv = vec2(UV.y, UV.x);} // Reverse the axes if inverted
	in_uv.y = ((in_uv.y - .5) / scale + .5); // scale the y axis

	// Get the noise value for this point at this time
	float repeat_x = mod(in_uv.x * repeats, 1.); // Alter the x sample position for for the number of repeats
	// now grab the a float value from the noise texture at a time adjusted location
	vec2 noise_uv = vec2(mod(repeat_x+(TIME/4.)*speed,1.0), mod(in_uv.y-(TIME)*speed,1.0));
	float noise_sample = texture(noise_texture, noise_uv).r;

	// Set a varied offset for where to grab from the line gradient texture
	float new_variation = variation;
	// as UV.x gets near the ends use UV.x for variation if it is less than "variation" (IE variation reduces as it approaches the end)
	if (fix_start) {new_variation = (min(new_variation, in_uv.x));}
	if (fix_end) {new_variation = (min(new_variation, 1.0-in_uv.x));}
	float gradient_offset = noise_sample*new_variation - new_variation / 2.;

	// Grab the colour from the line gradient texture offset by a varied amount
	COLOR = texture(line_gradient, vec2((in_uv.y-0.5 )/width + 0.5 + gradient_offset/width, in_uv.x));
}
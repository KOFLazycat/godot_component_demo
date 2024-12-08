shader_type canvas_item;

uniform float outer_radius :hint_range(0., 1.) = 1.0;
uniform float inner_radius :hint_range(0., 1.) = 0.75;
uniform float turn :hint_range(0., 1.) = 0.0;
uniform float blur :hint_range(0., 1., .0001) = 0.005;
uniform float fill_ratio :hint_range(0., 1.) = 0.75;

float remap(float i_min, float i_max, float o_min, float o_max, float val) {
	float t = (val - i_min) / (i_max - i_min);
	return o_min + (o_max - o_min) * t;
}

vec2 rotate_uv(vec2 uv, vec2 pivot, float rotation) {
    float cosa = cos(rotation);
    float sina = sin(rotation);
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x
    ) + pivot;
}

float circle(vec2 uv, float value)
{
	float d = length(uv);
	float t = smoothstep(
		inner_radius + blur,
		inner_radius - blur,
		d
	) - smoothstep(
		outer_radius + blur,
		outer_radius - blur,
		d
	);

	return t;
}

float mask(vec2 uv, float value)
{
	float r = atan(uv.x, uv.y);
	r = remap(-PI, PI, 0.0, 1.0, r);
	r = step(r, value * 0.5);

	uv.x = uv.x + 1.0;
	uv.x = uv.x * -1.0;
	uv.x += 1.0;
	float l = atan(uv.x, uv.y);
	l = remap(-PI, PI, 0.0, 1.0, l);
	l = step(l, value * 0.5);

	return r + l ;
}

void fragment() {
	vec2 uv = (UV * 2.0) - 1.0;
	vec2 origin = vec2(0.0, 0.0);
	uv = rotate_uv(uv, origin, turn * TAU);
	float t = mask(uv, fill_ratio);
	float c = circle(uv, 0.5);
	COLOR = vec4(t * c);
}
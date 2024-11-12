shader_type canvas_item;

uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;

uniform float screen_resolution = 1;

mat2 rot_dist(float s, float d)
{
    float angularspeed = s * pow(d, 8.0);
    float cas = cos(angularspeed);
    float sas = sin(angularspeed);
    return mat2(vec2(cas, -sas), vec2(sas, cas));
}

void fragment()
{


    vec3 ring_color = vec3(0.976, 0.447, 0.023);

    vec2 uv = FRAGCOORD.xy/(1.0 / SCREEN_PIXEL_SIZE);
    float ratio = (1.0 / SCREEN_PIXEL_SIZE).y/(1.0 / SCREEN_PIXEL_SIZE).x;
    uv.y *= ratio;

    vec2 center = ((1.0 / SCREEN_PIXEL_SIZE).xy * .5f) / (1.0 / SCREEN_PIXEL_SIZE).xy;
    //center = iMouse.xy / iResolution.xy;
    center.y *= ratio;

    float _dist = distance(uv, center);
    float _s = .15;
    float _a = .005;
    vec2 uvp = uv + min(texture(iChannel2, _s * vec2(uv.x + TIME * .1, uv.y + TIME * -.3)).r,
                        texture(iChannel2, _s * vec2(uv.x + TIME * -.3, uv.y + TIME * .2)).r) * _a * pow(1. - _dist, 5.);

    float dist = distance(uvp, center);
    float idist = 1.0 - dist;
    vec2 dir = normalize(uv - center);

    // Mask
    float m = step(.06, dist);
    m *= smoothstep(.065, .08, dist);
    m = (1.0 - dist * 1.6) * 2. * m;
	float mask = m;

    // Phases
    float speed = -0.06;
    float phase1 = fract(TIME * speed + .5);
    float phase2 = fract(TIME * speed);

    float pidist = pow(idist, 2.3);
    vec2 uv1 = (dir * pidist * .2) + phase1 * dir;
    vec2 uv2 = (dir * pidist * .2) + phase2 * dir;

    // Samplings
    float lerp = abs((.5 - phase1) / .5);
    float sampling1 = texture(iChannel0, uv1 * rot_dist(2.4, idist)).r;
    float sampling2 = texture(iChannel0, uv2 * rot_dist(2.4, idist)).r;

    float sampling3 = texture(iChannel0, uv1 * 2. * rot_dist(2.6, idist)).g;
    float sampling4 = texture(iChannel0, uv2 * 2. * rot_dist(2.6, idist)).g;

    float sampling5 = texture(iChannel1, uv1 * rot_dist(4.6, idist) * .4).r;
    float sampling6 = texture(iChannel1, uv2 * rot_dist(4.6, idist) * .6).r;

    float stars = (1. - smoothstep(0.22, 0.34, mix(sampling3, sampling4, lerp))) * 0.4;

    vec3 sp = mix(sampling1, sampling2, lerp) * vec3(1.);
    sp *= 0.2;
   	sp += stars * vec3(0.13, 0.31, 0.46);
    sp += smoothstep(0.26, 0.14, mix(sampling5, sampling6, lerp)) * vec3(0.7) * pow(idist, 8.) * ring_color;

    vec3 finalSamp = sp;
    vec3 col = ring_color * pow(1.0 - dist, 7.);
    float ring = pow(smoothstep(.32, .08, dist * 1.5) * 3.5, 2.8) + 1.;



    COLOR = vec4(finalSamp * mask + 1.2 * ring * mask * finalSamp * col, 1.);
}
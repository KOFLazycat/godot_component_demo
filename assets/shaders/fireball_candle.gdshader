// FIREBALL SHADER

shader_type canvas_item;

uniform vec3 fire_color: source_color = vec3(1.0, 0.33, 0.068);
uniform float fire_power_factor = 2.0;
uniform float fire_intensity = 3.0;
uniform float fire_start = 1.0;
uniform float ball_size = 1.0;

uniform float roughness = 0.675;
uniform int detail = 6;
uniform float scale = 4.0;
uniform float lacunarity = 2.0;

vec2 random2(vec2 st, float seed) {
    st = vec2(dot(st, vec2(127.1, 311.7)),
              dot(st, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(st) * 43758.5453123 * seed * 0.753421);
}

// Remap value
float map(float value, float from_min, float from_max, float to_min, float to_max) {
    value = (value - from_min) / (from_max - from_min);
    value = to_min + value * (to_max - to_min);
    return value;
}

// Blender's mixRGB node, linear light mode
vec3 linear_light(in vec3 a, in vec3 b, in float factor) {
    return a + factor * (2.0 * b - 1.0);
}

float noise(vec2 st, float seed) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(dot(random2(i + vec2(0.0, 0.0), seed), f - vec2(0.0, 0.0)),
                   dot(random2(i + vec2(1.0, 0.0), seed), f - vec2(1.0, 0.0)), u.x),
               mix(dot(random2(i + vec2(0.0, 1.0), seed), f - vec2(0.0, 1.0)),
                   dot(random2(i + vec2(1.0, 1.0), seed), f - vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(in float seed, in vec2 st, in float _scale, in int octaves, in float _roughness, in float _lacunarity) {
    float amplitude = 0.5;
    float frequency = 0.0;
    float value = 0.0;
    st *= _scale;
    for (int i = 1; i < octaves; i++) {
        value += amplitude * noise(st, seed);
        st *= _lacunarity;
        amplitude *= _roughness;
    }
    return value * 0.5 + 0.5;
}

vec3 neon(float val, vec3 color) {
    float ramp = clamp(val, 0.0, 1.0);
    vec3 outp = vec3(0.0);
    ramp = ramp * ramp;
    outp += pow(color, vec3(4.0)) * ramp;
    ramp = ramp * ramp;
    outp += color * ramp;
    ramp = ramp * ramp;
    outp += vec3(1.0) * ramp;
    return outp;
}

void fragment() {
    vec2 uv = UV;
    float uv_x = uv.x;
    uv = (uv * 2.0 - 1.0);
    vec2 uv_flame = uv + vec2(TIME * 2.0, 0.0);

    float noise_1d = fbm(24.0, uv_flame, scale, detail, roughness, lacunarity);
    vec3 noise_3d = vec3(fbm(24.0, uv_flame, scale, detail, roughness, lacunarity),
                         fbm(12.0, uv_flame, scale, detail, roughness, lacunarity),
                         fbm(33.0, uv_flame, scale, detail, roughness, lacunarity));

    float light_factor = clamp(map(uv_x, 0.13, 0.87, 1.0, 0.06), 0.06, 1.0);

    vec3 light = linear_light(vec3(uv * vec2(1.0, 1.0), 0.0), noise_3d, light_factor);
    light = abs(light) - vec3(0.75, 0.0, 0.0);
    light = max(light, vec3(0.0));
    float light_length = length(light) / ball_size;
    float fireball_grad = clamp(map(uv_x, -0.24, 0.82, 0.0, 0.27), 0.0, 0.27);
    light_length -= fireball_grad;
    light_length = smoothstep(0.0, -0.09, light_length);

    noise_1d *= uv_x * fire_start;
    noise_1d *= pow(uv_x, fire_power_factor);

    vec3 color = mix(vec3(0.0), fire_color * noise_1d * 4.0, light_length);

    float alpha = mix(0.0, noise_1d * fire_intensity, light_length);

    COLOR = vec4(neon(alpha * UV.x + 0.2, color), 1.0);
    COLOR.a = alpha;
}
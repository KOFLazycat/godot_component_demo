shader_type canvas_item;

// 星星的顏色 
uniform vec4 color: source_color = vec4(1.0,1.0,1.0,1.0);
// 初始透明度(但不”初始”)
uniform float alpha: hint_range(-2.0,2.0) = -.5;
// 光的”分散”程度
uniform float shney_disperse: hint_range(0.01,10.0) = 1.;
// 閃爍速度
uniform float shney_speed: hint_range(0.0,1000.0) = .5;
// 扭曲速度與程度
uniform float twist_speed: hint_range(-2.0,2.0) = 1.;
// 旋轉速度(負數為反方向旋轉)
uniform float rota_speed: hint_range(-10.0,10.0) = 1.;
// 瘦(星星) 到 胖(圓圓)的係數
uniform float curve_ci: hint_range(0.0,2.0) = .3;

void fragment() {

	vec2 uv = (UV - 0.5)*2.0;

	vec2 a = vec2(cos(TIME*rota_speed),-sin(TIME*rota_speed));
	vec2 b = vec2(sin(TIME*rota_speed),cos(TIME*rota_speed)*twist_speed);

	uv = vec2(uv.x*a.x + uv.y*a.y, uv.x*b.x + uv.y*b.y);

    float sig2 = sin(mod(TIME*shney_speed,PI))*(1.);
    float L = (1./(2.*PI*sig2))*exp(-((pow(uv.x,2.)+pow(uv.y,2.))/(2.*sig2*shney_disperse))) + alpha;

	if (uv.x > 0.0 && uv.y > 0.0) {

		if (uv.y <= pow(-(pow(uv.x,curve_ci) - 1.0),1.0/curve_ci)) {

			COLOR = color;
			COLOR.a = L;
		} else {

			COLOR.a = 0.0;
		}
	} else if (uv.x > 0.0 && uv.y < 0.0) {

		if (uv.y >= -pow(-(pow(uv.x,curve_ci) - 1.0),1.0/curve_ci) ) {

			COLOR = color;
			COLOR.a = L;
		} else {

			COLOR.a = 0.0;
		}
	} else if (uv.x < 0.0 && uv.y > 0.0) {

		if (uv.y <= pow(-(pow(-uv.x,curve_ci) - 1.0),1.0/curve_ci) ) {

			COLOR = color;
			COLOR.a = L;
		} else {

			COLOR.a = 0.0;
		}
	} else if (uv.x < 0.0 && uv.y < 0.0) {

		if (uv.y >= -pow(-(pow(-uv.x,curve_ci) - 1.0),1.0/curve_ci) ) {

			COLOR = color;
			COLOR.a = L;
		} else {

			COLOR.a = 0.0;
		}
	}
}

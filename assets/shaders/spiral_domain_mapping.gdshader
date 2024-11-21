shader_type canvas_item;

float mod1(inout float p, float size) {
  float halfsize = size*0.5;
  float c = floor((p + halfsize)/size);
  p = mod(p + halfsize, size) - halfsize;
  return c;
}

float spiralLength(float b, float a) {
  return 0.5*b*(a*sqrt(1.0+a*a)+log(a+sqrt(1.0+a*a)));
}

void spiralMod(inout vec2 p, float a) {
  vec2 op     = p;
  float b     = a/TAU;
  float  rr   = length(op);
  float  aa   = atan(op.y, op.x);
  rr         -= aa*b;
  float nn    = mod1(rr, a);
  float sa    = aa + TAU*nn;
  float sl    = spiralLength(b, sa);
  p           = vec2(sl, rr);
}

float sRGB1(float t) { return mix(1.055*pow(t, 1./2.4) - 0.055, 12.92*t, step(t, 0.0031308)); }

vec3 sRGB(in vec3 c) { return vec3 (sRGB1(c.x), sRGB1(c.y), sRGB1(c.z)); }

float hash(float co) {
  return fract(sin(co*12.9898) * 13758.5453);
}

vec2 toPolar(vec2 p) {
  return vec2(length(p), atan(p.y, p.x));
}

float circle(vec2 p, float r) {
  return length(p) - r;
}

// https://iquilezles.org/articles/distfunctions2d
float vesica(vec2 p, float r, float d) {
  p = abs(p);
  float b = sqrt(r*r-d*d);
  return ((p.y-b)*d>p.x*b) ? length(p-vec2(0.0,b))
                           : length(p-vec2(-d,0.0))-r;
}

// https://iquilezles.org/articles/smin
float pmin(float a, float b, float k) {
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

float pmax(float a, float b, float k) {
  return -pmin(-a, -b, k);
}

float eye(vec2 p, float h) {
  float a  = mix(0.0, 0.85, smoothstep(0.995, 1.0, cos(TAU*(TIME+h)/5.0)));
  const float b = 4.0;
  float rr = mix(1.6, b, a);
  float dd = mix(1.12, b, a);
  
  vec2 p0 = p;
  p0 = p0.yx;
  float d0 =  vesica(p0, rr, dd);
  float d5 = d0;

  vec2 p1 = p;
  p1.y -= 0.28;
  float d1 = circle(p1, 0.622);
  d1 = max(d1,d0);

  vec2 p2 = p;
  p2 -= vec2(-0.155, 0.35);
  float d2 = circle(p2, 0.065);

  vec2 p3 = p;
  p3.y -= 0.28;
  p3 = toPolar(p3);
  float n3 = mod1(p3.x, 0.05);
  float d3 = abs(p3.x)-0.0125*(1.0-length(p1));

  vec2 p4 = p;
  p4.y -= 0.28;
  float d4 = circle(p4, 0.285);

  d3 = max(d3,-d4);

  d1 = pmax(d1,-d2, 0.0125);
  d1 = max(d1,-d3);

  float t0 = abs(0.9*p.x);
  t0 *= t0;
  t0 *= t0;
  t0 *= t0;
  t0 = clamp(t0, 0.0, 1.0);
  d0 = abs(d0)-mix(0.0125, -0.0025, t0);


  float d = d0;
  d = pmin(d, d1, 0.0125);
  return d;
}

void fragment() {
  vec2 q = FRAGCOORD.xy/(1.0 / SCREEN_PIXEL_SIZE).xy;
  vec2 p = -1. + 2. * q;
  p.x *= (1.0 / SCREEN_PIXEL_SIZE).x/(1.0 / SCREEN_PIXEL_SIZE).y;
  
  float aa = 2.0/(1.0 / SCREEN_PIXEL_SIZE).y;
  vec3 col = vec3(1.0);

  float a = 0.25;
  
  vec2 sp = p;
  spiralMod(sp, a);
  sp.x += -TIME*0.2;
  vec2 msp = sp;
  float nsp = mod1(msp.x, a);
  
  float z = a*0.4;
  
  float dd = length(msp)-z;
  
  float h = hash(nsp+123.4);
  
  float de = eye(msp/z,h)*z;
  de -= 0.25*aa;
  
  col = mix(vec3(1.0-abs(2.0*sp.y/a)), vec3(0.0), smoothstep(aa, -aa, de));
  col *= smoothstep(0.0, 0.4, length(p));
  
  col = sRGB(col);
  COLOR = vec4(col, 1.0);
}
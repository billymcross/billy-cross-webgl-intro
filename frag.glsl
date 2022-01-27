precision mediump float;
#pragma glslify: noise = require(glsl-noise/periodic/3d)

uniform float time;
uniform vec2 resolution;
uniform sampler2D texture;
uniform vec2 mouse;
uniform float freq;
uniform float amp;
uniform float noise_mult;

float random (vec2 st) {
  return fract(sin(dot(st.xy, vec2(15.6234636, 70.3453425))) * 432113.12354125);
}

float plot(vec2 st, float func){
  return  smoothstep( func-0.06, func, st.y) - smoothstep( func, func+0.06, st.y);
}

float noise (vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);

  float a = random(i);
  float b = random(i + vec2(1.0, 0.0));
  float c = random(i + vec2(0.0, 1.0));
  float d = random(i + vec2(1.0, 1.0));

  //Make u, which is our smooth interpolation function
  vec2 u = f * f * (3.0 - 2.0 * f);

  //Mix the 4 corners
  return mix(a, b, u.x) +
  (c - a) * u.y * (1.0 - u.x) +
  (d - b) * u.x * u.y;
}

#define OCTAVES 8
float fbm (vec2 st) {
  //Initialize values
  float value = 0.0;
  float amplitude = 1.0;

  //Loop
  for (int i = 0; i < OCTAVES; i++) {
    value += amplitude * noise(st + time);
    st *= noise_mult;
    amplitude *= .5;
  }
  return value;
}

void main() {
  vec2 st = gl_FragCoord.xy/resolution.xy;
  vec2 mouse_st = mouse.xy/resolution.xy;

  vec3 color = texture2D( texture, vec2( st.x * fbm(st - mouse.x/resolution.x),
                                        (1.0 - st.y) * fbm(st - mouse.y/resolution.y))).xyz;
  color *= mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), mouse_st.y);
  color += plot(st, 1.0 - mouse_st.y) * mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), st.y);
  color += plot(st, mouse_st.y) * mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), st.y);

  float base_frequency = 1.;
  float base_amp = 1.;
  float sin_func = sin(gl_FragCoord.x * base_frequency * freq / 20. * mouse_st.x + time * 17.897) * base_amp * amp / 4. * (1. - mouse_st.y) + .5;
  sin_func += sin(gl_FragCoord.x * base_frequency * freq / 23.654 * mouse_st.x + time * 22.56) * base_amp * amp/ 4. * (1. - mouse_st.y);
  sin_func += sin(gl_FragCoord.x * base_frequency / 7. * mouse_st.x + time) / 4. * (1.0 - mouse_st.y);
  color += plot(st, sin_func) * mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), st.y);

  gl_FragColor = vec4( color, 1. );
}

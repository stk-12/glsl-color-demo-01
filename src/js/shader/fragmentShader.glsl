varying vec2 vUv;
varying vec3 vPosition;
uniform float uTime;
uniform float uTimeSpeed;
uniform sampler2D uTex;
uniform vec2 uResolution;
uniform vec2 uTexResolution;
uniform vec2 uNoiseLoudness;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uColor4;


// #pragma glslify: snoise = require(glsl-noise/simplex/2d);
#pragma glslify: snoise = require(glsl-noise/simplex/3d);


void main() {
  vec2 uv = vUv;

  vec2 ratio = vec2(
    min((uResolution.x / uResolution.y) / (uTexResolution.x / uTexResolution.y), 1.0),
    min((uResolution.y / uResolution.x) / (uTexResolution.y / uTexResolution.x), 1.0)
  );
  uv = vec2(
    vUv.x * ratio.x + (1.0 - ratio.x) * 0.5,
    vUv.y * ratio.y + (1.0 - ratio.y) * 0.5
  );
  // vec3 color = texture2D(uTex, uv).rgb;
  vec3 texColor = texture2D(uTex, uv).rgb;

  // vec3 RED = vec3(0.831, 0.247, 0.552);
  // vec3 BLUE = vec3(0.007, 0.313, 0.772);

  float time = sin(uTime * 10.0) * 0.5 + 0.5;
  // vec3 color = mix(RED, BLUE, time);
  // // vec3 color = mix(RED, BLUE, 0.5);
  // gl_FragColor = vec4(color, 1.0);



  vec3 BLACK = vec3(0.1, 0.1, 0.1);
  vec3 GREEN = vec3(0.086, 0.627, 0.522);
  vec3 GREEN1 = vec3(0.0588, 0.6667, 0.5451);
  vec3 GREEN2 = vec3(0.0157, 0.3333, 0.2706);
  vec3 YELLOW = vec3(0.957, 0.816, 0.247);
  vec3 RED = vec3(0.831, 0.247, 0.552);
  // vec3 RED = vec3(0.831, 0.247, 0.552);
  vec3 BLUE = vec3(0.007, 0.313, 0.772);

  vec3 COLOR1 = uColor1;
  vec3 COLOR2 = uColor2;
  vec3 COLOR3 = uColor3;
  vec3 COLOR4 = uColor4;

  // Simplex 2D Noise
  // noiseにuvを適用、数値をかけ合わせるとノイズが細かくなる
  // float noise = snoise(uv * 3.0);
  // float noise = snoise(uv * 3.0 - uTime * 5.0);
  // float noise = snoise(vec2(uv.x * 3.0 - uTime * 5.0, uv.y * 3.0 - uTime * 2.0));
  // float noise = snoise(uv * 3.0 - sin(uTime * 5.0));
  // float noise = snoise(vec2(uv.x * 2.0 - sin(uv.y + uTime / 3.0), uv.y * 2.0));
  // float noise = snoise(vec2(uv.x * 3.0 - sin(uv.y + uTime / 2.0), uv.y * 3.0 + sin(uv.x + uTime / 2.0)));

  // Simplex 3D Noise
  // float noise = snoise(vec3(uv, 1.0));
  // float noise = snoise(vec3(vUv * uNoiseLoudness, uTime * uTimeSpeed));
  // float noise = snoise(vec3(uv * 2.0, uTime * 0.5));
  // float noise = snoise(vec3(uv.x, uv.y, uTime * 0.5));
  // float noise = snoise(vec3(uv.x * 2.0, uv.y * 2.0, uTime * 0.2));
  // float noise = snoise(vec3(uv.x * 2.0 + sin(uv.y + uTime), uv.y * 2.0, uTime * 0.5));
  // float noise = snoise(vec3(uv.x * 2.0 - uTime * 0.2, uv.y * 2.0 - uTime * 0.2, uTime * 0.5));
  // float noise = snoise(vec3(uv.x * 20.0 - uTime * 0.2, uv.y * 20.0 - uTime * 0.2, uTime * 0.5));
  // float noise = snoise(vec3(uv.x * 414.0 - uTime * 0.2, uv.y * 414.0 - uTime * 0.2, uTime * 8.8));
  // float noise = snoise(vec3(uv.x * 4.0 - uTime * 0.2, uv.y * 4.0 - uTime * 0.2, uTime * 0.8));
  // 縦縞ノイズ
  // float noise = snoise(vec3(vUv.x * uNoiseLoudness, vUv.x * uNoiseLoudness, uTime * uTimeSpeed));
  // 横縞ノイズ
  // float noise = snoise(vec3(vUv.y * uNoiseLoudness, vUv.y * uNoiseLoudness, uTime * uTimeSpeed));
  // sin,cosでuv全体に回転を加える
  // float noise = snoise(vec3(vUv.x + cos(uTime * 0.1) * uNoiseLoudness, vUv.y + sin(uTime * 0.2) * uNoiseLoudness, uTime * uTimeSpeed));
  float noise = snoise(vec3(vUv.x * uNoiseLoudness.x + cos(uTime * 0.5), vUv.y * uNoiseLoudness.y + sin(uTime * 0.5), uTime * uTimeSpeed));


  // vec3 color = mix(GREEN, GREEN1, noise);
  // vec3 color = mix(GREEN, YELLOW, noise);
  // vec3 color = mix(texColor, GREEN, noise);
  // vec3 color = mix(mix(GREEN, YELLOW, uv.x), mix(BLUE, RED, uv.x), uv.y);
  // vec3 color = mix(mix(GREEN, YELLOW, noise), mix(BLUE, RED, noise), vUv.y);
  vec3 color = mix(mix(COLOR1, COLOR2, noise), mix(COLOR4, COLOR3, noise), vUv.y + sin(uTime * 0.5));
  // vec3 color = mix(mix(GREEN, YELLOW, noise), mix(BLUE, RED, noise), noise * 0.5);
  gl_FragColor = vec4(color, 1.0);
}
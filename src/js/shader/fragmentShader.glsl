varying vec2 vUv;
varying vec3 vPosition;
uniform float uTime;
uniform float uTimeSpeed;
uniform sampler2D uTex;
uniform vec2 uResolution;
uniform vec2 uTexResolution;
uniform float uNoiseLoudness;

// Simplex 2D noise
//
// vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

// float snoise(vec2 v){
//   const vec4 C = vec4(0.211324865405187, 0.366025403784439,
//            -0.577350269189626, 0.024390243902439);
//   vec2 i  = floor(v + dot(v, C.yy) );
//   vec2 x0 = v -   i + dot(i, C.xx);
//   vec2 i1;
//   i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
//   vec4 x12 = x0.xyxy + C.xxzz;
//   x12.xy -= i1;
//   i = mod(i, 289.0);
//   vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
//   + i.x + vec3(0.0, i1.x, 1.0 ));
//   vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
//     dot(x12.zw,x12.zw)), 0.0);
//   m = m*m ;
//   m = m*m ;
//   vec3 x = 2.0 * fract(p * C.www) - 1.0;
//   vec3 h = abs(x) - 0.5;
//   vec3 ox = floor(x + 0.5);
//   vec3 a0 = x - ox;
//   m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
//   vec3 g;
//   g.x  = a0.x  * x0.x  + h.x  * x0.y;
//   g.yz = a0.yz * x12.xz + h.yz * x12.yw;
//   return 130.0 * dot(m, g);
// }

//	Simplex 3D Noise 
//	by Ian McEwan, Ashima Arts
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(vec3 v){ 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C 
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = mod(i, 289.0 ); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}

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
  float noise = snoise(vec3(vUv * uNoiseLoudness, uTime * uTimeSpeed));
  // float noise = snoise(vec3(uv * 2.0, uTime * 0.5));
  // float noise = snoise(vec3(uv.x, uv.y, uTime * 0.5));
  // float noise = snoise(vec3(uv.x * 2.0, uv.y * 2.0, uTime * 0.2));
  // float noise = snoise(vec3(uv.x * 2.0 + sin(uv.y + uTime), uv.y * 2.0, uTime * 0.5));
  // float noise = snoise(vec3(uv.x * 2.0 - uTime * 0.2, uv.y * 2.0 - uTime * 0.2, uTime * 0.5));
  // float noise = snoise(vec3(uv.x * 20.0 - uTime * 0.2, uv.y * 20.0 - uTime * 0.2, uTime * 0.5));
  // float noise = snoise(vec3(uv.x * 414.0 - uTime * 0.2, uv.y * 414.0 - uTime * 0.2, uTime * 8.8));
  // float noise = snoise(vec3(uv.x * 4.0 - uTime * 0.2, uv.y * 4.0 - uTime * 0.2, uTime * 0.8));


  // vec3 color = mix(GREEN, GREEN1, noise);
  // vec3 color = mix(GREEN, YELLOW, noise);
  // vec3 color = mix(texColor, GREEN, noise);
  // vec3 color = mix(mix(GREEN, YELLOW, uv.x), mix(BLUE, RED, uv.x), uv.y);
  vec3 color = mix(mix(GREEN, YELLOW, noise), mix(BLUE, RED, noise), vUv.y);
  // vec3 color = mix(mix(GREEN, YELLOW, noise), mix(BLUE, RED, noise), noise * 0.5);
  gl_FragColor = vec4(color, 1.0);
}
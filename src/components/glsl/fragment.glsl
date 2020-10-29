varying vec2 vCoordinates;
varying vec3 vPos;
uniform sampler2D t1;
uniform sampler2D t2;
uniform float uMix;
// varying vec2 vUv;

void main() {
  vec2 myUV = vec2(vCoordinates.x, vCoordinates.y);
  vec4 image1 = texture2D(t1, myUV);
  vec4 image2 = texture2D(t2, myUV);
  // gl_FragColor = vec4(vUv.x, vUv.y, 0.0, 1.0);
  // gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  vec4 color = mix(image1, image2, smoothstep(0.0, 1.0, uMix));

  float d = distance(vec3(vPos.x, vPos.y, 0.0), vec3(vPos));

  color.a -= d / 512.0 * 2.2;
  // color.a += map(0, 1, 0, distance(vec3(0.0, 0.0, 0.0), vCoordinates));

  gl_FragColor = vec4(color);
}

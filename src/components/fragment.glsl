varying vec2 vCoordinates;
uniform sampler2D t1;
// varying vec2 vUv;

void main() {
  vec2 myUV = vec2(vCoordinates.x, vCoordinates.y);
  vec4 image = texture2D(t1, myUV);
  // gl_FragColor = vec4(vUv.x, vUv.y, 0.0, 1.0);
  // gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  gl_FragColor = image;
}

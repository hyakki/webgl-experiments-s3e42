varying vec2 vUv;
varying vec2 vCoordinates;
uniform float time;
uniform float progress;
attribute vec3 aCoordinates;

void main() {
  vUv = uv;  
  vCoordinates = aCoordinates.xy;
  vec3 pos = position;

  pos.z = pos.z + (sin(pos.x + (time / 1000.0)) * progress) + (sin(pos.y + (time / 1000.0)) * progress) ;

  vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);

  gl_PointSize = 3.0 - (1.0 / - mvPosition.z);
  gl_Position = projectionMatrix * mvPosition;
}

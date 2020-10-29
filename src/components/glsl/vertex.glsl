varying vec2 vUv;
varying vec2 vCoordinates;
varying vec3 vPos;
uniform float time;
uniform float uProgress;
attribute vec3 aCoordinates;

void main() {
  vUv = uv;  
  vCoordinates = aCoordinates.xy;
  vec3 pos = position;

  pos.z = pos.z + (sin(pos.x + (time / 1000.0)) * uProgress) + (sin(pos.y + (time / 1000.0)) * uProgress) ;

  vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);

  gl_PointSize = 2.0 - (1.0 / - mvPosition.z);
  gl_Position = projectionMatrix * mvPosition;

  vPos = pos;
}

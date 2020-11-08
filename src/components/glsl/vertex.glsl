#pragma glslify: snoise4 = require(glsl-noise/simplex/4d)

varying vec2 vUv;
varying vec2 vCoordinates;
varying vec3 vPos;
uniform float time;
uniform float uProgress;
attribute vec3 aCoordinates;

void main() {
  vUv = uv;  
  vCoordinates = aCoordinates.xy + snoise4(vec4(
    aCoordinates.x - 1.0,
    aCoordinates.y + 1.0,
    uProgress / 1000.0,
    uProgress / 1000.0
  )) * uProgress / 100.0;

  vec3 pos = position;

  // pos.x = pos.x + ((sin(pos.y + (time / 10000.0))) * uProgress) ;
  pos.z = pos.z + ((sin(pos.x + (time / 100.0)) + 1.0) * uProgress) + ((sin(pos.y + (time / 100.0)) + 1.0) * uProgress) ;

  vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);

  gl_PointSize = 3.0 - (1.0 / - mvPosition.z);
  gl_Position = projectionMatrix * mvPosition;

  vPos = pos;
}

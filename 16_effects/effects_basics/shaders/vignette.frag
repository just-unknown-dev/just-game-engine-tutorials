#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uResolution;
  vec4 color = texture(uTexture, uv);
  float edge = 0.75 + 0.05 * sin(uTime);
  float d = distance(uv, vec2(0.5));
  float shade = 1.0 - smoothstep(0.35, edge, d);
  fragColor = vec4(color.rgb * shade, color.a);
}

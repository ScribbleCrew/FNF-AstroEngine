#pragma header

// yeahh i love dis :3c

uniform float iTime;
uniform vec3 circleColor = vec3(1.0);
uniform vec3 backgroundColor = vec3(0.0);
uniform float frequency = 1.0;
uniform float speed = 0.25;
uniform float size = 0.7;
uniform float alpha = .001;
uniform bool visible = true;
uniform bool heatWarp = true;

uniform float warpStrength = 0.04;
uniform float warpFreq = 12.0;
uniform float warpSpeed = 2.0;

const float PI = 3.14159265359;
float tex(vec2 pos) {
    float angle = PI / 3.0 + iTime * 0.1;
    float s = sin(angle), c = cos(angle);
    vec2 p = mat2(c, -s, s, c) * pos;

    float r = length(p);
    return min(pow(r, 0.11), pow(1.0 - r, 0.2));
}
void main() {
    vec2 position = openfl_TextureCoordv * 2.0 - 1.0;
    position.y *= openfl_TextureSize.y / openfl_TextureSize.x;
    position /= size;

    if (heatWarp) {
        float warpTime = iTime * warpSpeed;
        float wx = sin(position.y * warpFreq + warpTime);
        float wy = cos(position.x * warpFreq + warpTime);
        position += vec2(wx, wy) * warpStrength;
    }

    vec4 baseColor = vec4(backgroundColor, alpha);

    vec2 distor = position;
    float denom = max(0.05, sqrt(5.0) - length(distor));
    distor /= denom;

    float off = mod(iTime * speed, 1.0);
    float len = length(distor);
    if (len > 0.0) {
        distor = normalize(distor) * mod(len - off, 1.0);
    }

    //vec4 col = mix(vec4(circleColor, alpha), baseColor, tex(distor));
    //gl_FragColor = visible ? col : baseColor;

    vec3 colRGB = mix(circleColor, backgroundColor, tex(distor));
    gl_FragColor = visible ? vec4(colRGB, alpha) : vec4(backgroundColor, 0.0);
}

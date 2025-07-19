#pragma header

#define PULSE_SIZE 0.7 // Change this value to make the pulse bigger or smaller
#define HEAT_WARP 1    // Set to 1 to enable heat warp, 0 to disable

uniform float time;
uniform vec3 circleColor;
uniform vec3 backgroundColor;
uniform float frequency;
uniform float speed;

uniform float alpha;

uniform bool visible;
uniform bool heatWarp;

#define ecircleColor vec3(0.1176, 0.0, 0.6314)

const float PI = 3.14159265;

float tex(vec2 pos){
    float upper = length(vec2(cos(PI/3.), sin(PI/3.)) * length(pos) - pos);
    return min(pow(upper, .11), pow(1.0 - length(pos), .2));
}

void main() {
    vec2 position = openfl_TextureCoordv * 2.0 - 1.0;
    position.y *= openfl_TextureSize.y / openfl_TextureSize.x;
    position /= PULSE_SIZE;

    #if HEAT_WARP
    // Heat warp effect: wobble the coordinates
    float warpStrength = 0.04;
    float warpFreq = 12.0;
    float warpSpeed = 2.0;
    position.x += sin(position.y * warpFreq + time * warpSpeed) * warpStrength;
    position.y += cos(position.x * warpFreq + time * warpSpeed) * warpStrength;
    #endif

    vec4 baseColor = vec4(backgroundColor, 1.0);

    vec2 circleDistor = position;
    float denom = max(0.05, sqrt(5.0) - length(circleDistor));
    circleDistor /= denom;

    float modab = 1.0;
    float off = mod(time * speed, 1.0) * modab;
    float len = length(circleDistor);
    if (len > 0.0) circleDistor = normalize(circleDistor) * mod(len - off, modab);

    float ang = atan(circleDistor.y, circleDistor.x);
    ang = mod(ang, PI / frequency);
    circleDistor = vec2(cos(ang), sin(ang)) * length(circleDistor);

    vec4 col = mix(vec4(ecircleColor, 1.0), baseColor, tex(circleDistor));

    gl_FragColor = visible ? col: baseColor;
}
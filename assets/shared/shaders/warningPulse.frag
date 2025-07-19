// bunch of artifacts in the shader, i'll fix them later

#pragma header

uniform float time;
uniform vec3 circleColor;
uniform vec3 backgroundColor;
uniform float frequency;
uniform float speed;
uniform bool showLines;

const float PI = 3.14159265;

float tex(vec2 pos){
    float upper = length(vec2(cos(PI/3.), sin(PI/3.))*length(pos)-pos);
    return min(pow(upper, .11), pow(1.-length(pos), .2));
}

void main() {
    // Centered position, aspect-corrected
    vec2 position = openfl_TextureCoordv * 2.0 - 1.0;
    position.y *= openfl_TextureSize.y / openfl_TextureSize.x;

    vec4 baseColor = vec4(backgroundColor, 1.0);

    vec2 circleDistor = position;
    float denom = max(0.05, sqrt(5.0) - length(circleDistor));
    circleDistor /= denom;

    float modab = 1.0;
    float off = mod(time * speed, 1.0) * modab;
    float len = length(circleDistor);
    if (len > 0.0) circleDistor = normalize(circleDistor) * mod(len - off, modab);

    // Use atan for angle, which avoids seams
    float ang = atan(circleDistor.y, circleDistor.x);
    ang = mod(ang, PI / frequency);
    circleDistor = vec2(cos(ang), sin(ang)) * length(circleDistor);

    vec4 col = mix(vec4(circleColor, 1.0), baseColor, tex(circleDistor));

    gl_FragColor = col;
}
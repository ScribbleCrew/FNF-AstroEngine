#pragma header

// yeahh i love dis :3c

uniform float iTime;
uniform vec3 circleColor=vec3(1.,1.,1.);
uniform vec3 backgroundColor=vec3(0.,0.,0.);
uniform float frequency=1;
uniform float speed=.25;
uniform float size=.7;
uniform float alpha=.5;
uniform bool visible=true;
uniform bool heatWarp=true;

uniform float warpStrength = .04;
uniform float warpFreq = 12.;
uniform float warpSpeed = 2.;

const float PI=3.14159265;

// float tex(vec2 pos){// line bug here!!!
//     float upper=length(vec2(cos(PI/3.),sin(PI/3.))*length(pos)-pos);
//     return min(pow(upper,.11),pow(1.-length(pos),.2));
// }

float tex(vec2 pos){ // !!! Weird line artifact here !!!
    float angle = PI / 3.0 + iTime * 0.1; 
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 p = rot * pos;
    float upper = length(vec2(cos(angle), sin(angle)) * length(p) - p);
    return min(pow(upper, .11), pow(1.0 - length(p), .2));
}

void main(){
    vec2 position=openfl_TextureCoordv*2.-1.;
    position.y*=openfl_TextureSize.y/openfl_TextureSize.x;
    position/=size;
    
    // heat warping
    if(heatWarp){
        position.x+=sin(position.y*warpFreq+iTime*warpSpeed)*warpStrength;
        position.y+=cos(position.x*warpFreq+iTime*warpSpeed)*warpStrength;
    }
    
    vec4 baseColor=vec4(backgroundColor,alpha);
    
    vec2 circleDistor=position;
    float denom=max(.05,sqrt(5.)-length(circleDistor));
    circleDistor/=denom;
    
    float modab=1.;
    float off=mod(iTime*speed,1.)*modab;
    float len=length(circleDistor);
    if(len>0.)circleDistor=normalize(circleDistor)*mod(len-off,modab);
    
    vec4 col=mix(vec4(circleColor,alpha),baseColor,tex(circleDistor));
    
    gl_FragColor=(visible?col:baseColor);
}
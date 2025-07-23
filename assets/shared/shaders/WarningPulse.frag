#pragma header

// yeahh i love dis :3c

uniform float iTime;
uniform vec3 circleColor=vec3(1.);
uniform vec3 backgroundColor=vec3(0.);
uniform float frequency=1.;
uniform float speed=.25;
uniform float size=.7;
uniform float alpha=.001;
uniform bool visible=true;
uniform bool heatWarp=true;

uniform float warpStrength=.04;
uniform float warpFreq=12.;
uniform float warpSpeed=2.;

// 
//uniform vec2 customResolution=vec2(1280.,720.);
//uniform bool useCustomPixels=false;// use the sprites pixel so 1280x720 instead of a custom given value like `vec2(1280.,720.)`

const float PI=3.14159265359;

float tex(vec2 pos){
    float angle=PI/3.+iTime*.1;
    float s=sin(angle),c=cos(angle);
    vec2 p=mat2(c,-s,s,c)*pos;
    
    float r=length(p);
    return min(pow(r,.11),pow(1.-r,.2));
}
void main(){
    if(!visible||alpha<.0001)discard;
    
    vec2 position;
       
  //  if(!useCustomPixels){
        position=openfl_TextureCoordv*2.-1.;
        position.y*=openfl_TextureSize.y/openfl_TextureSize.x;
  //  }else{
   //     position=gl_FragCoord.xy/customResolution*2.-1.;// cam zoom doesn't effect :(
   //     position.y*=customResolution.y/customResolution.x;
   // }
    
    position/=size;
    
    if(heatWarp){
        float warpTime=iTime*warpSpeed;
        float wx=sin(position.y*warpFreq+warpTime);
        float wy=cos(position.x*warpFreq+warpTime);
        position+=vec2(wx,wy)*warpStrength;
    }
    
    vec4 baseColor=vec4(backgroundColor,alpha);
    
    vec2 distor=position;
    float denom=max(.05,sqrt(5.)-length(distor));
    distor/=denom;
    
    float off=mod(iTime*speed,1.);
    float len=length(distor);
    if(len>0.){
        distor=normalize(distor)*mod(len-off,1.);
    }
    
    //vec4 col = mix(vec4(circleColor, alpha), baseColor, tex(distor));
    //gl_FragColor = visible ? col : baseColor;
    
    vec3 colRGB=mix(circleColor,backgroundColor,tex(distor));
    gl_FragColor=visible?vec4(colRGB,alpha):vec4(backgroundColor,0.);
    
}

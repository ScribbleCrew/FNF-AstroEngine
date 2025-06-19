#pragma header

void main(){
    float len=length(openfl_TextureCoordv-vec2(.5,.5));
    float r=.5-(1./openfl_TextureSize.x);
    vec4 c=flixel_texture2D(bitmap,openfl_TextureCoordv);
    vec4 color=mix(vec4(0.,0.,0.,.5),c,c.a);
    gl_FragColor=color*clamp(1.-((len-r)*openfl_TextureSize.x),0.,1.);
}
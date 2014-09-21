//
// Simple passthrough vertex shader
//

attribute vec3 in_Position;     //(x,y,z) xyz position of first frame
attribute vec2 in_TextureCoord; //(u,v) uv coordinate
attribute vec3 in_Normal;       // (x,y,z)  normal of first frame
attribute vec4 in_Colour;       // (r,g,b,a) color

attribute vec3 in_Colour2;      //(x,y,z) position of second frame
attribute vec3 in_Colour3;      //(x,y,z) normal of second frame




varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_interpol;

//light
uniform vec3 uAmbientColor;
uniform vec3 uLightingDirection;
uniform vec3 uDirectionalColor;


varying vec3 vLightWeighting;




void main()
{        

    vec4 object_space_pos = vec4( mix(in_Position.x,in_Colour2.x,u_interpol), mix(in_Position.y,in_Colour2.y,u_interpol), mix(in_Position.z,in_Colour2.z,u_interpol), 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;

    //Light
    
     //vec3 transformedNormal = getNormalMatrix() * in_Normal;
     vec3 transformedNormal = normalize(vec3( mix(in_Normal.x,in_Colour3.x,u_interpol), mix(in_Normal.y,in_Colour3.y,u_interpol), mix(in_Normal.z,in_Colour3.z,u_interpol)));
    float directionalLightWeighting = max(dot(transformedNormal, uLightingDirection), 0.0);
    vLightWeighting = uAmbientColor + (uDirectionalColor * directionalLightWeighting);
    
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec3 vLightWeighting;

void main()
{
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
    
vec4 lightColor = vec4(vLightWeighting.xyz,1.0);
vec4 finalColor = v_vColour*lightColor;
        gl_FragColor = finalColor;
}
/*
void main()
{

vec4 lightColor = vec4(vLightWeighting.xyz,1.0);
vec4 finalColor = v_vColour*lightColor * texture2D( gm_BaseTexture, v_vTexcoord) ;
        gl_FragColor = finalColor;
}
*/

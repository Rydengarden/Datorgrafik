#version 410

uniform int use_normal_mapping;
uniform vec3 diffuse_colour;
uniform vec3 specular_colour;
uniform vec3 ambient_colour;
uniform float shininess_value;

uniform sampler2D diffuse_texture;
uniform sampler2D specular_texture;
uniform sampler2D normal_map;

uniform mat4 vertex_model_to_world;
uniform mat4 normal_model_to_world;
uniform mat4 vertex_world_to_clip;

in VS_OUT{
    vec3 fn;
    vec3 fv;
    vec3 fl;
    vec3 texcoord;
    vec3 t;
    vec3 b;
    vec3 normal;
}fs_in;

out vec4 fColor;

void main()
{
    vec3 t = normalize(fs_in.t);
    vec3 b = normalize(fs_in.b);
    vec3 normal = normalize(fs_in.normal);
    mat3 TBN = mat3(fs_in.t,fs_in.b,fs_in.normal);
    vec3 N=normalize(fs_in.fn);
    if(use_normal_mapping==1){
         N=normalize((normal_model_to_world*vec4(TBN*(texture(normal_map,fs_in.texcoord.xy)*2.-1.).xyz,0)).xyz);
    }
    
    vec3 L= normalize(fs_in.fl);
    vec3 V= normalize(fs_in.fv);
    vec3 R= normalize(reflect(-L,N));
    vec3 diffuse= diffuse_colour*max(dot(N,L),0.)*texture(diffuse_texture,fs_in.texcoord.xy).xyz;
    vec3 specular= specular_colour * pow(max(dot(R,V),0.0f),shininess_value);
    
    fColor.xyz=ambient_colour+diffuse+specular;
    fColor.w=1.;
    
}

#version 410

layout(location=0)in vec3 vertex;
layout(location=1)in vec3 normal;
layout(location=2)in vec3 textcoord;
layout(location=3)in vec3 t;
layout(location=4)in vec3 b;

uniform vec3 light_position;
uniform vec3 camera_position;
uniform mat4 vertex_model_to_world;
uniform mat4 normal_model_to_world;
uniform mat4 vertex_world_to_clip;

out VS_OUT{
    vec3 fn;
    vec3 fv;
    vec3 fl;
    vec3 texcoord;
    vec3 t;
    vec3 b;
    vec3 normal;
}vs_out;

void main()
{
    vec3 worldPos=vec3(vertex_model_to_world*vec4(vertex,1.)).xyz;
    vs_out.texcoord=textcoord;
    vs_out.fn=normalize((normal_model_to_world*vec4(normal,0)).xyz);
    vs_out.fv=normalize(camera_position-worldPos);
    vs_out.fl=normalize(light_position-worldPos);
    vs_out.t = normalize(t);
    vs_out.b = normalize(b);
    vs_out.normal = normalize(normal);
    
    gl_Position=vertex_world_to_clip*vertex_model_to_world*vec4(vertex,1.);
}
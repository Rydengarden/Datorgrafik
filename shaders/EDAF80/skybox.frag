#version 410

out vec4 FragColor;

in vec3 texCoords;

uniform samplerCube skybox;

void main()
{
    FragColor=texture(skybox,normalize(texCoords));
}

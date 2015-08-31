#version 430 core

uniform mat4 modelViewMatrix;

// "in"s
layout (location = 0) in vec2 position;
// "out"s
out vec2 backgroundpos;

void main(void)
{
    gl_Position = modelViewMatrix * vec4(position, 0.0, 1.0);
    backgroundpos = position;
}

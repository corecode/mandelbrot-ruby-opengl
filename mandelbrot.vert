#version 140
#extension GL_ARB_explicit_attrib_location : require

layout( location = 0 ) in vec4 vPosition;

void main()
{
  gl_Position = vPosition;
}
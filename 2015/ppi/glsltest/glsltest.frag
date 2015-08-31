#version 430 core

uniform sampler2D tex;
uniform float light;

in vec2 backgroundpos;

out vec4 color;

void main(void)
{
    vec2 pos = backgroundpos.xy;

    float distance = 0.0;
    distance = sqrt( pos.x * pos.x + pos.y * pos.y );

    float theta = 0.0;
    float pi = 3.1415926;

    // to implement atan2()
    if(pos.x > 0)
    {
        theta = atan( pos.y/pos.x );
    }
    if(pos.y >= 0 && pos.x < 0)
    {
        theta = atan( pos.y/pos.x ) + pi;
    }
    if(pos.y < 0 && pos.x < 0)
    {
        theta = atan( pos.y/pos.x ) - pi;
    }
    if(pos.x == 0 && pos.y > 0)
    {
        theta = pi/2;
    }
    if(pos.x == 0 && pos.y < 0)
    {
        theta = -pi/2;
    }
    if(pos.x == 0 && pos.y == 0)
    {
        theta = 0;
    }

    // specify lightoffset for latter use
    float lightoffset = theta/2/pi+0.5;

    // set zero degree up
    theta = theta - pi/2;

    // get texture coordinates
    vec2 coord = vec2(0,0);

    if(distance >= 1)
    {
    }else{
        coord = vec2(theta/2/pi, distance/1);
    }

    // implement afterglow
    float temp = lightoffset - light;
    float alpha;
    if(temp < 0)
    {
        alpha = temp + 1;
    }else
    {
        alpha = temp;
    }

    color =  texture(tex, coord) * vec4(alpha, 0, 0, 1);
}

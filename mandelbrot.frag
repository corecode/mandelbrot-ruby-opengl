#version 140

uniform vec2 windowsize;
uniform vec2 center;
uniform float scale;
out vec4 fColor;

// from https://github.com/hughsk/glsl-hsv2rgb/blob/master/index.glsl

vec3 hsv2rgb(vec3 c) {
        vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
        vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
        return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
        vec2 z;
        vec2 zn;
        vec2 c;
        int iters;

        c.x = (gl_FragCoord.x / windowsize.x - 0.5) * scale + center.x;
        c.y = (gl_FragCoord.y / windowsize.y - 0.5) * scale + center.y;

        z.x = 0;
        z.y = 0;

        iters = 100;

        for (int i = 0; i < 100; ++i) {
                zn.x = z.x * z.x - z.y * z.y;
                zn.y = z.x * z.y + z.y * z.x;
                z = zn + c;

                if (sqrt(pow(z.x, 2) + pow(z.y, 2)) > 16) {
                        iters = i;
                        break;
                }
        }

        vec3 oc;
        if (iters == 100)
                oc = vec3(0.0, 0.0, 0.0);
        else
                oc = vec3(iters/100.0, 1.0, 1.0);
        fColor = vec4(hsv2rgb(oc), 1.0);
}

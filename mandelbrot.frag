#version 140

uniform vec2 windowsize;
uniform vec2 center;
uniform vec2 size;
out vec4 fColor;

void main()
{
        vec2 z;
        vec2 zn;
        vec2 c;
        int iters;

        c.x = (gl_FragCoord.x / windowsize.x - 0.5) * size.x + center.x;
        c.y = (gl_FragCoord.y / windowsize.y - 0.5) * size.y + center.y;

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

        if (iters == 100)
                fColor = vec4(0.0, 0.0, 0.0, 1.0);
        else
                fColor = vec4( 0.0, (100-iters)/100.0, iters/100.0, 1.0 );
}

#version 140

out vec4 fColor;

void main()
{
        vec2 z;
        vec2 zn;
        vec2 c;
        int iters;

        c.x = gl_FragCoord.x / 200 - 2;
        c.y = gl_FragCoord.y / 200 - 2;

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
        fColor = vec4( 0.0, (100-iters)/100.0, iters/100.0, 1.0 );
}

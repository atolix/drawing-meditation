#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, .0));
    float c = hash(i + vec2(.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
    float sum = .0;
    float amp = .5;
    mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
    for (int i = 0; i < 5; i++) {
        sum += amp * noise(p);
        p = m * p + .07;
        amp *= .5;
    }
    return sum;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;
    vec2 uv = st * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

    float t = u_time * .2;

    vec2 q = vec2(
        fbm(uv * .6 + vec2(.0, t)),
        fbm(uv * .6 + vec2(5.2, -t))
    );
    vec2 r = vec2(
        fbm(uv * 1.2 + 4.0 * q + vec2(1.7, 9.2) + t),
        fbm(uv * 1.2 + 4.0 * q + vec2(8.3, 2.8) - t)
    );

    float d = fbm(uv * 6.0 + 2.5 * r - t * .5);

    float vign = smoothstep(1.2, .3, length(uv));
    float heightFog = smoothstep(-.6, .6, uv.y);

    float fog = mix(d, d * d, .35);
    fog = mix(fog, 1.0 - fog, .15 * q.x);
    fog *= .85 * vign * (.7 + .3 * heightFog);

    vec3 colA = vec3(.2431, .5725, .9451);
    vec3 colB = vec3(.9804, .5725, 1.0);
    vec3 color = mix(colA, colB, fog);

    float light = .55 + .7 * smoothstep(-.2, .6, uv.y + .15 * fbm(uv + t));
    color *= light;

    gl_FragColor = vec4(color, 1.0);
}


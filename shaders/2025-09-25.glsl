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
        p = m * p + .09;
        amp *= .5;
    }
    return sum;
}

float turbulence(vec2 p) {
    float t = .0;
    float amp = 1.0;
    for (int i = 0; i < 5; i++) {
        t += abs(noise(p)) * amp;
        p *= 2.0;
        amp *= .6;
    }
    return t;
}

vec2 rotate(vec2 p, float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c) * p;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;
    vec2 uv = st * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

    float t = u_time * .10;

    vec2 p = rotate(uv, 2.0);

    vec2 q = vec2(
        fbm(p * 1.2 + vec2(.0, t)),
        fbm(p * 1.2 + vec2(5.2, -t))
    );
    vec2 r = vec2(
        fbm(p * 2.0 + 3.0 * q + vec2(1.7, 7.2) + t),
        fbm(p * 2.0 + 3.0 * q + vec2(8.3, 2.8) - t)
    );

    float scale = 1.0 + fract(t) * 4.0;
    float turbPower = 4.0;
    float s = sin(p.x * scale + turbPower * (turbulence(p * 1.6 + 1.5 * r) + .15 * r.x));

    float veins = abs(s);
    veins = pow(1.0 - veins, 2.5);

    float baseVar = fbm(p * 1.8 + .5 * q) * .06;
    vec3 base = vec3(.95, .96, .97) + baseVar * vec3(.8, .9, 1.0);

    float mineral = smoothstep(-.2, .8, fbm(p * 3.0 + 2.0 * r));
    vec3 veinCool = vec3(0.4275, 0.5176, 0.8902);
    vec3 veinWarm = vec3(.451, .5059, .4039);
    vec3 veinCol = mix(veinCool, veinWarm, .35 + .35 * mineral);

    vec3 color = base;
    color = mix(color, veinCol, clamp(veins * .9 + floor(sin(t)), .0, 1.0));

    float light = .95 + .12 * smoothstep(-.6, .8, uv.y + .2 * fbm(uv + t));
    float rawVign = smoothstep(1.50, .15, length(uv));
    float vign = mix(1.0, rawVign, .25);
    color *= light * vign;

    gl_FragColor = vec4(color, 1.0);
}

#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p){
    float n = sin(dot(p, vec2(81.0, 289.0)));
    return fract(vec2(777773.0, 32768.0) * n);
}

float voronoi(vec2 p){
    vec2 g = floor(p);
    vec2 f = fract(p);
    float d = 1.0;
    for(int j=-1;j<=1;j++){
        for(int i=-1;i<=1;i++){
            vec2 o = vec2(i,j);
            vec2 r = o + hash2(g + o) - f;
            d = min(d, dot(r,r));
        }
    }
    return sqrt(d);
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;
    vec2 uv = st * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

    float r = length(uv);
    float rings = .5 + .5 * sin(5.5 * r - u_time * 3.0);

    vec3 baseA = vec3(0.9686, 0.6314, 0.9412);
    vec3 baseB = vec3(0.5647, 0.7961, 0.9608);
    vec3 color = mix(baseA, baseB, rings);

    float v = voronoi(st * 7.0 + vec2(u_time * .1));
    v = smoothstep(0.0, 1.5, v);

    float add = sin(u_time * .3) + .5;
    color *= mix(.8, 1.0 + add, v);

    gl_FragColor = vec4(color, 1.0);
}

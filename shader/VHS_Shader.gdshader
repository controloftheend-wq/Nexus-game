shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float shake : hint_range(0.0, 1.0) = 0.03;      // antes 0.1
uniform float rgb_offset : hint_range(0.0, 0.01) = 0.0015; // antes 0.003
uniform float scanline_strength : hint_range(0.0, 0.1) = 0.015; // antes 0.04
uniform float shake_strength : hint_range(0.0, 0.02) = 0.004; // antes 0.01

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // VHS shake MUY suave
    if (rand(vec2(TIME, 0.0)) < shake) {
        uv.x += rand(vec2(TIME, uv.y)) * shake_strength;
    }

    // Separación RGB más ligera
    float r = texture(SCREEN_TEXTURE, uv + vec2(rgb_offset, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - vec2(rgb_offset, 0.0)).b;
    
    // Scanlines suaves
    float scanline = sin(uv.y * 400.0) * scanline_strength;

    COLOR = vec4(r - scanline, g - scanline, b - scanline, 1.0);
}
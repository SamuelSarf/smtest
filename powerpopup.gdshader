shader_type canvas_item;

uniform float split : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float half_height = split * 0.5;
    vec2 uv = UV;

    if (UV.y < 0.5) {
        float top_edge = 0.5 - half_height;
        if (UV.y < top_edge) discard;
        float t = (UV.y - top_edge) / half_height;
        uv.y = t * 0.5;
    } else {
        float bottom_edge = 0.5 + half_height;
        if (UV.y > bottom_edge) discard;
        float t = (UV.y - 0.5) / half_height;
        uv.y = 0.5 + t * 0.5;
    }

    COLOR = texture(TEXTURE, uv) * COLOR;
}
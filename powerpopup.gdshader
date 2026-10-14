shader_type canvas_item;

// 0 = collapsed at center
// 1 = fully assembled
uniform float split : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    float half_height = split * 0.5;
    vec2 uv = UV;

    if (UV.y < 0.5) {
        // Top half of screen. Visible band is [0.5 - half_height, 0.5].
        // Map that band to texture [0.0, 0.5].
        float top_edge = 0.5 - half_height;
        if (UV.y < top_edge) discard;
        float t = (UV.y - top_edge) / half_height; // 0 at top edge, 1 at center
        uv.y = t * 0.5;
    } else {
        // Bottom half. Visible band is [0.5, 0.5 + half_height].
        // Map that band to texture [0.5, 1.0].
        float bottom_edge = 0.5 + half_height;
        if (UV.y > bottom_edge) discard;
        float t = (UV.y - 0.5) / half_height; // 0 at center, 1 at bottom edge
        uv.y = 0.5 + t * 0.5;
    }

    COLOR = texture(TEXTURE, uv) * COLOR;
}
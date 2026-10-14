shader_type canvas_item;

uniform vec2 screen_size = vec2(1920.0, 1080.0);
uniform vec2 origin = vec2(0.5, 0.5);
uniform float pixel_size = 16.0;

uniform float phase_meet = 0.0;
uniform float phase_widen = 0.0;
uniform float phase_morph = 0.0;      // 0 = rect, 1 = ellipse
uniform float phase_expand = 0.0;     // 0 = 1/5 width, 1 = full width
uniform float phase_brighten = 0.0;
uniform float phase_collapse_v = 0.0;
uniform float phase_collapse_h = 0.0;

uniform vec4 base_color : source_color = vec4(0.86, 0.97, 1, 0.5);
uniform vec4 bright_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Ellipse must reach corners: multiply half-extents by sqrt(2) to inscribe the rect
const float CORNER_FACTOR = 1.4143;

// Higher eccentricity: ellipse gets extra width relative to height
const float ECCENTRICITY = 1.6;

void fragment() {
    vec2 snapped_uv = floor(UV * screen_size / pixel_size) * pixel_size / screen_size;
    vec2 uv = (snapped_uv - origin) * screen_size;

    // --- Width: independent of morph ---
    float line_half  = max(pixel_size * 0.5, 1.0);
    float fifth_half = screen_size.x * 0.5 / 5.0;
    float full_half  = screen_size.x * 0.5;

    // Base width: line -> 1/5 -> full
    float base_half_w = mix(line_half, fifth_half, phase_widen);
    base_half_w = mix(base_half_w, full_half, phase_expand);

    // --- Height: full screen, then vertical collapse ---
    float base_half_h = screen_size.y * 0.5;
    base_half_h *= max(1.0 - phase_collapse_v, 0.0);

    // --- Horizontal collapse (last phase only) ---
    float h_collapse = max(1.0 - phase_collapse_h, 0.0);

    // --- Shape half-extents (rect / ellipse share these, but ellipse needs scaling) ---
    // For rect: use base extents directly
    // For ellipse: scale by CORNER_FACTOR (to cover corners) and ECCENTRICITY on X
    vec2 rect_he = vec2(base_half_w * h_collapse, base_half_h);
    vec2 ellipse_he = vec2(base_half_w * h_collapse * CORNER_FACTOR * ECCENTRICITY,
                           base_half_h * CORNER_FACTOR);

    vec2 he = mix(rect_he, ellipse_he, phase_morph);
    he = max(he, vec2(0.001));

    // --- Distance fields ---
    vec2 d = abs(uv) - he;
    float rect_dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float ellipse_dist = (length(uv / he) - 1.0) * min(he.x, he.y);

    float dist = mix(rect_dist, ellipse_dist, phase_morph);
    float shape_mask = step(dist, 0.0);

    // --- Incoming top/bottom lines ---
    float line_x_ok = step(abs(uv.x), line_half);
    float top_edge_y    =  screen_size.y * 0.5;
    float bottom_edge_y = -screen_size.y * 0.5;
    float inner_gap = (screen_size.y * 0.5) * (1.0 - phase_meet);

    float in_top    = step(uv.y, top_edge_y) * step(inner_gap, uv.y);
    float in_bottom = step(bottom_edge_y, uv.y) * step(uv.y, -inner_gap);
    float lines_mask = line_x_ok * max(in_top, in_bottom);

    float mask = mix(lines_mask, shape_mask, phase_meet);

    // --- Color ---
    float end_fade = max(phase_collapse_v, phase_collapse_h);
    float bright = phase_brighten * (1.0 - end_fade);

    vec4 col = mix(base_color, bright_color, bright);
    col.a = mix(base_color.a, 1.0, bright);
    col.a *= mask;

    COLOR = col;
}
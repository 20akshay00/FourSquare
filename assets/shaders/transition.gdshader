shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float angle : hint_range(0.0, 360.0) = 15.0;
uniform bool reverse = false;

void fragment() {
    vec2 uv = UV;
    
    float rad = radians(angle);
    vec2 dir = vec2(cos(rad), sin(rad));
    
    if (reverse) dir *= -1.0;

    float sweep = dot(uv, dir);
    
    float min_val = min(0.0, min(dir.x, min(dir.y, dir.x + dir.y)));
    float max_val = max(0.0, max(dir.x, max(dir.y, dir.x + dir.y)));
    
    float threshold = mix(min_val, max_val, progress);

    if (sweep < threshold) {
        COLOR = COLOR;
    } else {
        COLOR.a = 0.0;
    }
}
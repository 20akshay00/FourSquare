shader_type canvas_item;

uniform vec4 bg_color : source_color = vec4(0.08, 0.05, 0.1, 1.0);     // Deep Midnight
uniform vec4 stripe_color : source_color = vec4(0.12, 0.1, 0.18, 1.0); // Muted Dark Pastel
uniform float speed : hint_range(0.0, 1.0) = 0.05;
uniform float angle : hint_range(0.0, 360.0) = 45.0; // Matches your sweep angle
uniform float band_density : hint_range(1.0, 100.0) = 15.0;
uniform float wave_stretch : hint_range(0.1, 5.0) = 2.0;
uniform float wave_speed : hint_range(0.0, 2.0) = 0.5;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.4;

void fragment() {
    vec2 uv = UV;

    float rad = radians(angle);
    vec2 dir = vec2(cos(rad), sin(rad));

    vec2 perp_dir = vec2(-dir.y, dir.x);
    float pos = dot(uv, dir) * band_density;
    
    pos -= TIME * speed * 10.0;
    
    float wave = sin(dot(uv, perp_dir) * wave_stretch + TIME * wave_speed) * 0.5;
    pos += wave;
    
    float band = smoothstep(0.3, 0.6, sin(pos));
    
    vec4 final_color = mix(bg_color, stripe_color, band);
    
    float dist = distance(uv, vec2(0.5));
    float vignette = 1.0 - smoothstep(0.4, 1.2, dist * vignette_intensity);
    
    COLOR = final_color * vignette;
}
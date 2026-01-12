shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform vec4 mix_color : source_color = vec4(1.0, 1.0, 1.0, 0.2);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
    COLOR = mix(color, mix_color, mix_color.a);
}
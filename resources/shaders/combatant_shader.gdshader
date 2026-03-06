shader_type canvas_item;

uniform vec4 solid_color : source_color = vec4(1.0);
uniform float white_out_index : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
	texture_color.rgb = mix(texture_color.rgb, solid_color.rgb, white_out_index);
    COLOR = texture_color;
}

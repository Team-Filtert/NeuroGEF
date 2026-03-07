shader_type canvas_item;

uniform vec4 solid_color : source_color = vec4(1.0);
uniform float white_out_index : hint_range(0.0, 1.0) = 0.0;
uniform bool toggle_off = false;

void fragment() {
	if (!toggle_off) {
	    vec4 texture_color = texture(TEXTURE, UV);
		texture_color.rgb = mix(texture_color.rgb, solid_color.rgb, white_out_index);
	    COLOR = texture_color;
	}
}

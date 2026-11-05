shader_type canvas_item;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(tex.rgb + vec3(0.1) - tex.rgb * 0.01, tex.a);
}

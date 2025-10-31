shader_type canvas_item;

uniform bool active = true;
uniform float brightness : hint_range(0.0, 1.0, 0.1) = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (active) {
		COLOR = vec4(vec3((color.r + color.g + color.b) / 3.0 * brightness), color.a);
	} else COLOR = color;
}

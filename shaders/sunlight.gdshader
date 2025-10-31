shader_type canvas_item;
render_mode blend_add;

uniform vec2 light_center; // position of the sun (0 - 1)
uniform vec4 light_color : source_color;
uniform float radius : hint_range(0.1, 2.0) = 1.0;
uniform float intensity : hint_range(0.0, 2.0) = 1.0; // brightness multiplier

void fragment() {
	vec2 uv = UV;
	vec2 light_pos = light_center;

	// distance from the light center
	float dist = length(uv - light_pos) / radius;

	// radial gradient (inverted for glow effect)
	float glow = smoothstep(1.0, 0.0, dist);

	COLOR = light_color * glow * intensity;
}
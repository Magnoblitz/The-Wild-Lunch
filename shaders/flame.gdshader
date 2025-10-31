shader_type canvas_item;

void fragment() {
	vec2 uv = UV * 2. - 1.;

	float dist = length(uv);
	float pulse = 0.5 + 0.5 * sin(TIME * 2.0);

	float intensity = exp(-dist * 2.0) + pulse * 0.2;

	vec3 color = mix(vec3(1.0, 0.2, 0.0), vec3(1.0, 0.8, 0.0), intensity);

	COLOR = vec4(color * intensity, smoothstep(1, 0, dist));
}
shader_type canvas_item;

uniform vec3 color1 : source_color = vec3(0.2, 0.5, 1.0);
uniform vec3 color2 : source_color = vec3(1.0, 0.5, 0.2);
uniform float angle : hint_range(0.0, 360.0) = 45.0;
uniform float speed : hint_range(-2.0, 2.0) = 0.5;

void fragment() {
	float offset = TIME * speed;
	vec2 direction = vec2(cos(angle * PI / 180.0), sin(angle * PI / 180.0));
	float gradient = 0.5 + 0.5 * sin(6.28318 * (dot(UV * SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y, direction) + offset));

	vec3 color = mix(color1, color2, gradient);


	vec2 uv = UV;

	float x = uv.x;
	float y = uv.y;
	float e0 = x;
	float e1 = 1.0 - x;
	float e2 = y;
	float e3 = 1.0 - y;

	float scl = 1.0;
	if (e0 <= e1 && e0 <= e2 && e0 <= e3 && e0 < 0.1) scl = 1.2; // left edge
	if (e1 <= e0 && e1 <= e2 && e1 <= e3 && e1 < 0.1) scl = 0.5; // right edge
	if (e2 <= e1 && e2 <= e0 && e2 <= e3 && e2 < 0.1) scl = 1.5; // bottom edge
	if (e3 <= e1 && e3 <= e2 && e3 <= e0 && e3 < 0.1) scl = 0.7; // top edge

	COLOR = vec4(color * scl, 1.0);
}
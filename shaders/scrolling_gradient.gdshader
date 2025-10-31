shader_type canvas_item;

uniform vec3 color1 : source_color = vec3(0.2, 0.5, 1.0);
uniform vec3 color2 : source_color = vec3(1.0, 0.5, 0.2);
uniform float angle : hint_range(0.0, 360.0) = 45.0;
uniform float speed : hint_range(-2.0, 2.0) = 0.5;

void fragment() {
	vec2 uv = UV;
	uv.x *= SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;

	float offset = TIME * speed;
	vec2 direction = vec2(cos(angle * PI / 180.0), sin(angle * PI / 180.0));
	float gradient = 0.5 + 0.5 * sin(6.28318 * (dot(uv, direction) + offset));

	COLOR = vec4(mix(color1, color2, gradient), 1.0);
}

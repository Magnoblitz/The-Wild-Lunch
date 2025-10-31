shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float blur_radius : hint_range(0.0, 10.0);
uniform vec4 tint_color : source_color = vec4(1.0);

void fragment() {
	vec2 tex_size = vec2(textureSize(screen_texture, 0));
	vec2 uv = SCREEN_UV;
	
	vec4 color = vec4(0.0);
	float total = 0.0;
	
	int kernel_size = 5;
	
	for (int x = -kernel_size; x <= kernel_size; x++) {
		for (int y = -kernel_size; y <= kernel_size; y++) {
			vec2 offset = vec2(float(x), float(y)) * blur_radius / tex_size;
			color += texture(screen_texture, uv + offset);
			total += 1.0;
		}
	}
	
	COLOR = color / total * tint_color;
}
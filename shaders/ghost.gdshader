shader_type canvas_item;

uniform float speed = 3.0;
uniform float frequency = 4.0;
uniform float wavelength = .01;

uniform vec4 modulate : source_color = vec4(1,1,1,1);

void fragment() {
	float offset = TIME * speed;
	
	vec2 uv = UV;
	uv.x += sin(uv.y * frequency + offset) * wavelength;
	
	COLOR = texture(TEXTURE, uv) * modulate;
}

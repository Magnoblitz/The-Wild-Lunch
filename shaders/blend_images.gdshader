shader_type canvas_item;

uniform sampler2D current_texture;
uniform sampler2D new_texture;
uniform float time : hint_range(0, 2);

void fragment() {
	vec2 uv = UV;

	vec4 img1 = texture(current_texture, uv);
	vec4 img2 = texture(new_texture, uv);

	float lum1 = dot(img1.rgb, vec3(0.299, 0.587, 0.114));
	float lum2 = dot(img2.rgb, vec3(0.299, 0.587, 0.114));

	float blend = smoothstep(0.0, 1.0, time * (1.0 - abs(lum1 - lum2)));

	if (time >= 1.5) {
		float opacityBlend = smoothstep(0.0, 1.0, (time - 1.5) * 2.0);
		blend = mix(blend, 1.0, opacityBlend);
	}

	COLOR = mix(img1, img2, blend);
}

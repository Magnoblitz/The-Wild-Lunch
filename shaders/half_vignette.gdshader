shader_type canvas_item;

uniform float alpha = 1.0;
uniform float inner_radius = 0.0;
uniform float outer_radius = 1.0;

void fragment() {
	float x = abs(UV.r - 0.5) * 2.0;
	float y = (1.0 - UV.g) * 2.0; // shift to affect only the top half
	
	// ensure the vignette fades out smoothly at the middle
	y = max(y, 0.0); // prevent negative ys
	
	float distance = sqrt(x * x + y * y);
	float q = 1.0 - (1.0 - distance / outer_radius) / (1.0 - inner_radius);
	
	// fade out near the middle instead of a hard cut
	float fade_factor = smoothstep(0.0, 1.0, y);
	q *= fade_factor;
	
	COLOR = vec4(0, 0, 0, q * alpha);
}

shader_type canvas_item;

/* ================= SETTINGS ================= */

uniform float glitch_chance : hint_range(0.0, 1.0) = 0.2;
uniform float glitch_speed = 7.0;
uniform float slice_density = 14.0;
uniform float slice_strength = 0.38;
uniform float shake_strength = 0.02;
uniform float chroma_offset = 0.016;
uniform float noise_strength = 0.2;
uniform float color_flash_strength = 0.4;
uniform float scanline_strength = 0.18;
uniform float local_warp_strength = 0.14;
uniform float flip_chance : hint_range(0.0,1.0) = 0.15;

/* ================= RANDOM ================= */

float rand(float x){ 
	return fract(sin(x * 143758.5453) * 43758.5453); 
}

float rand2(vec2 p){ 
	return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); 
}

/* ================= FRAGMENT ================= */

void fragment() {
	vec2 uv = UV;

	float t = floor(TIME * glitch_speed);
	float glitch = step(1.0 - glitch_chance, rand(t));

	/* ----- SLICES ----- */
	float slice_id = floor(uv.y * slice_density);
	float slice_rand = rand(slice_id + t);
	float slice_mask = step(0.5, slice_rand) * glitch;

	// Flip horizontal SIN usar if
	float flip = step(rand(slice_id * 13.7 + t), flip_chance);
	uv.x = mix(uv.x, 1.0 - uv.x, flip * glitch);

	// Desplazamiento horizontal
	uv.x += (slice_rand - 0.5) * slice_strength * slice_mask;

	/* ----- MICRO JITTER ----- */
	float jitter = step(0.85, rand(TIME * 12.0)) * glitch;
	uv.x += (rand(TIME * 3.0) - 0.5) * 0.08 * jitter;

	/* ----- LOCAL WARP ----- */
	float warp_zone = step(0.65, rand2(vec2(slice_id, t)));
	vec2 warp = (vec2(rand2(uv + TIME), rand2(uv - TIME)) - 0.5)
		* local_warp_strength * warp_zone * glitch;
	uv += warp;

	/* ----- GLOBAL SHAKE ----- */
	uv += vec2(
		rand(TIME * 1.3) - 0.5,
		rand(TIME * 1.7) - 0.5
	) * shake_strength * glitch;

	// Evitar que el UV salga de rango (CRÍTICO en Godot 4)
	uv = clamp(uv, vec2(0.001), vec2(0.999));

	/* ----- COLOR SPLIT ----- */
	vec4 base = texture(TEXTURE, uv);
	float r = texture(TEXTURE, uv + vec2(chroma_offset * glitch, 0.0)).r;
	float b = texture(TEXTURE, uv - vec2(chroma_offset * glitch, 0.0)).b;
	vec3 color = vec3(r, base.g, b);

	/* ----- DIGITAL NOISE ----- */
	color += (rand2(uv * TIME * 1.5) - 0.5) * noise_strength * glitch;

	/* ----- SCANLINE ----- */
	float scan = step(0.9, rand(uv.y * 100.0 + TIME * 10.0));
	color *= 1.0 - scan * scanline_strength * glitch;

	/* ----- COLOR FLASH ----- */
	vec3 flash_color = vec3(
		step(0.5, rand(TIME + 0.9)),
		step(0.5, rand(TIME + 3.1)),
		step(0.5, rand(TIME + 6.9))
	);
	color = mix(color, flash_color, rand(TIME * 4.0) * color_flash_strength * glitch);

	COLOR = vec4(color, base.a);
}
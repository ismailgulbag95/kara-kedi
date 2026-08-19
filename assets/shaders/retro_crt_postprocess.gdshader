shader_type canvas_item;

// Retro CRT, Vinyet ve Dinamik Kromatik Aberasyon Shader'ı
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.35;
uniform float vignette_radius : hint_range(0.1, 1.5) = 0.85;

uniform float scanline_count : hint_range(50.0, 600.0) = 320.0;
uniform float scanline_intensity : hint_range(0.0, 0.5) = 0.06;

uniform float chromatic_aberration : hint_range(0.0, 0.05) = 0.0;
uniform vec4 rage_tint : source_color = vec4(0.1, 1.0, 0.4, 0.0); // Öfke modunda yeşil ton
uniform float rage_intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// 1. Kromatik Aberasyon (RGB Split)
	vec2 offset = vec2(chromatic_aberration, 0.0);
	float r = texture(SCREEN_TEXTURE, uv + offset).r;
	float g = texture(SCREEN_TEXTURE, uv).g;
	float b = texture(SCREEN_TEXTURE, uv - offset).b;
	vec3 color = vec3(r, g, b);
	
	// 2. Scanline Efekti (Piksel Tarama Çizgileri)
	if (scanline_intensity > 0.001) {
		float scanline = sin(uv.y * scanline_count * 3.14159);
		color -= scanline_intensity * (0.5 + 0.5 * scanline);
	}
	
	// 3. Vinyet (Kenar Karartması)
	float dist_from_center = distance(uv, vec2(0.5, 0.5));
	float vignette = smoothstep(vignette_radius, vignette_radius - 0.45, dist_from_center);
	color *= mix(1.0 - vignette_intensity, 1.0, vignette);
	
	// 4. Kediotu Öfkesi (Emerald Night-Vision Tint)
	if (rage_intensity > 0.001) {
		vec3 green_vision = vec3(color.g * 0.4, color.g * 1.35, color.g * 0.5);
		color = mix(color, green_vision, rage_intensity * 0.45);
	}
	
	COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}

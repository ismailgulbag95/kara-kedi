shader_type canvas_item;

// Hue-Shifting Palette & Master Shading Shader
uniform vec4 shadow_tint : source_color = vec4(0.11, 0.08, 0.20, 1.0); // Derin gece moru / indigo
uniform vec4 highlight_tint : source_color = vec4(0.98, 0.85, 0.35, 1.0); // Sıcak altın / kehribar
uniform float grading_strength : hint_range(0.0, 1.0) = 0.22;

// Hit Flash
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (col.a < 0.02) {
		discard;
	}
	
	// Luminance-based Hue Shifting (Gölgeyi soğuk mora, ışığı sıcak kehribara kaydırma)
	float lum = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	vec3 tint_ramp = mix(shadow_tint.rgb, highlight_tint.rgb, smoothstep(0.0, 1.0, lum));
	vec3 graded_rgb = mix(col.rgb, col.rgb * (tint_ramp * 1.5), grading_strength);
	
	// Hit Flash Beyaz/Kırmızı Parlama
	vec3 final_rgb = mix(graded_rgb, flash_color.rgb, flash_modifier);
	
	COLOR = vec4(final_rgb, col.a);
}

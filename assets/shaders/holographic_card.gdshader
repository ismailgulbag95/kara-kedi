shader_type canvas_item;

// Holografik Kart Parıltı Shader'ı (Balatro-Tarzı Epik & Efsanevi Işıltı)
uniform float shine_speed : hint_range(0.1, 5.0) = 1.2;
uniform float shine_width : hint_range(0.01, 1.0) = 0.22;
uniform float shine_angle : hint_range(-3.14, 3.14) = 0.785; // 45 derece
uniform vec4 shine_color : source_color = vec4(1.0, 0.92, 0.65, 0.85);
uniform float intensity : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	
	// Kartın transparan bölgelerini yoksay
	if (base_color.a < 0.05) {
		COLOR = base_color;
	} else {
		// Açılı kayan parıltı koordinatı
		vec2 rotated_uv = vec2(
			UV.x * cos(shine_angle) - UV.y * sin(shine_angle),
			UV.x * sin(shine_angle) + UV.y * cos(shine_angle)
		);
		
		float current_time = TIME * shine_speed;
		float pos = mod(current_time, 2.5) - 0.75;
		float dist = abs(rotated_uv.x - pos);
		
		if (dist < shine_width) {
			float factor = (1.0 - (dist / shine_width)) * intensity;
			// Gökkuşağı / Altın Holografik Ton
			vec3 holo_tint = mix(shine_color.rgb, vec3(1.0, 1.0, 1.0), factor * 0.5);
			base_color.rgb = mix(base_color.rgb, holo_tint, factor * 0.6);
			base_color.rgb += holo_tint * factor * 0.4;
		}
		
		COLOR = base_color;
	}
}

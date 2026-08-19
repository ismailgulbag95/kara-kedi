shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.02, 0.02, 0.05, 0.4);
uniform float inner_radius : hint_range(0.0, 1.0) = 0.5;
uniform float outer_radius : hint_range(0.0, 2.0) = 1.1;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float vignette = smoothstep(inner_radius, outer_radius, dist);
	COLOR = vec4(vignette_color.rgb, vignette * vignette_color.a);
}

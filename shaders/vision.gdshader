shader_type canvas_item;
// Perda de visão: "Ao morrer, o jogador vê a tela escurecer pelas bordas.
// Depois de muitas mortes (referência: 8), quase só o próprio personagem fica visível."
// loss = 0 → visão perfeita · loss = 1 → só um círculo pequeno em volta do herói.

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec2 center = vec2(0.5, 0.5);
uniform float loss : hint_range(0.0, 1.0) = 0.0;
uniform float aspect = 1.7777;

void fragment() {
	vec2 delta = (SCREEN_UV - center) * vec2(aspect, 1.0);
	float dist = length(delta);
	float radius = mix(1.15, 0.17, loss);
	float softness = mix(0.55, 0.12, loss);
	float darkness = smoothstep(radius - softness, radius, dist);
	vec3 scene = texture(screen_texture, SCREEN_UV).rgb;
	float gray = dot(scene, vec3(0.299, 0.587, 0.114));
	// O mundo perde a cor antes de sumir.
	float desaturate = clamp(loss * 1.2, 0.0, 0.85) * smoothstep(radius * 0.3, radius, dist);
	vec3 color = mix(scene, vec3(gray) * vec3(0.95, 0.97, 1.05), desaturate);
	color = mix(color, vec3(0.015, 0.012, 0.02), darkness);
	COLOR = vec4(color, 1.0);
}

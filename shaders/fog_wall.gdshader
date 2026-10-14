shader_type canvas_item;
// Névoa branca da arena do chefe (ruído animado, sem textura).

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	// Coordenadas do mundo deixam a névoa contínua entre células vizinhas.
	vec2 p = (FRAGCOORD.xy / 6.0);
	float n = noise(p * 0.35 + vec2(TIME * 0.6, -TIME * 0.9)) * 0.6
			+ noise(p * 0.8 - vec2(TIME * 0.3, TIME * 1.4)) * 0.4;
	// smoothstep exige borda0 < borda1 (invertido é "indefinido" no GLSL e
	// alguns celulares desenham lixo): para descer no fim, usamos 1 - smoothstep.
	float edge = smoothstep(0.0, 0.3, UV.y) * (1.0 - smoothstep(0.65, 1.0, UV.y));
	float alpha = (0.3 + n * 0.6) * edge;
	COLOR = vec4(0.93, 0.95, 1.0, alpha * COLOR.a);
}

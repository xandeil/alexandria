shader_type canvas_item;
// Efeitos de sprite do Alexandria:
//  1) "flash": pisca de branco (ou outra cor) ao levar golpe.
//  2) Troca de paleta: as cores-chave do cabelo e dos olhos do herói clareiam
//     com as mortes ("olhos e cabelos ficavam brancos" — Bíblia do Jogo).
// As cores-chave são as MESMAS de tools/art/palette.py (HAIR, HAIR_LIGHT, EYE).

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float swap_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 key_hair = vec4(0.2314, 0.1686, 0.1412, 1.0);
uniform vec4 key_hair_light = vec4(0.3569, 0.2627, 0.2039, 1.0);
uniform vec4 key_eye = vec4(0.8314, 0.6392, 0.2353, 1.0);
uniform vec4 white_hair = vec4(0.84, 0.83, 0.80, 1.0);
uniform vec4 white_hair_light = vec4(0.95, 0.94, 0.92, 1.0);
uniform vec4 white_eye = vec4(0.97, 0.98, 1.0, 1.0);

const float TOLERANCE = 0.03;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (swap_amount > 0.0) {
		if (distance(c.rgb, key_hair.rgb) < TOLERANCE) {
			c.rgb = mix(c.rgb, white_hair.rgb, swap_amount);
		} else if (distance(c.rgb, key_hair_light.rgb) < TOLERANCE) {
			c.rgb = mix(c.rgb, white_hair_light.rgb, swap_amount);
		} else if (distance(c.rgb, key_eye.rgb) < TOLERANCE) {
			c.rgb = mix(c.rgb, white_eye.rgb, swap_amount);
		}
	}
	c.rgb = mix(c.rgb, flash_color.rgb, flash);
	COLOR = c * COLOR;
}

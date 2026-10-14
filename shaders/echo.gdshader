shader_type canvas_item;
render_mode unshaded;
// Ecos das crianças, da Governanta e dos chefes do sonho de Nyssa: silhuetas
// brancas que brilham no escuro.
// "No fim, restaram apenas ecos… e uma mesa vazia."
// unshaded = não escurece com a luz da área (CanvasModulate).
//
// ATENÇÃO (Godot 4): dentro de fragment(), COLOR já chega como
// textura × modulate. Ler texture(TEXTURE, UV) de novo e multiplicar por
// COLOR aplicaria a textura DUAS vezes — e a cor original "voltava",
// desfazendo o branco (foi o bug das versões 0.5 a 0.8).

uniform float whiteness : hint_range(0.0, 1.0) = 0.78;
uniform vec4 echo_color = vec4(0.93, 0.97, 1.0, 1.0);

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, echo_color.rgb, whiteness);
}

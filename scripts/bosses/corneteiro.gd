class_name Corneteiro
extends SargentoSemPelotao
## O Corneteiro — mini-chefe opcional da Cidade, no alto da Torre (v0.35, Etapa 6).
## O mesmo oficial de antes, com uma corneta: o toque é um ANEL (ScreamRing)
## que se espalha — dash através dele ou saia do alcance. E chama três.
##
## Vencido, a Cidade fica sem toque de recolher: os soldados que você derrubar
## depois disso NÃO voltam no descanso (Game.slain_forever).

const WAKE_LINE := "Recolher! ...Recolher!"
const DEFEAT_LINE := "Recolher... Ninguém nunca recolheu."
const HORN_LINES := ["Toque de recolher!", "Recolher! Todos!", "Às posições!"]
const RING_DAMAGE := 16.0
const RING_SPEED := 140.0
const RING_REACH := 110.0


func _on_wake() -> void:
	speech.emit(WAKE_LINE)
	Sfx.play(&"telegraph", -6.0)
	_set_mode(Mode.DECIDE)
	_decision = 0.6


## O apito do Sargento, trocado pela corneta (a fala é dele, não do Sargento).
func _start_whistle() -> void:
	_whistles_done += 1
	_combo.clear()
	_runner.cancel()
	_set_mode(Mode.WHISTLE)
	body_sprite.play(&"apito")
	Sfx.play(&"whistle", -2.0)
	Fx.float_text(global_position + Vector2(-10, -30), "TUUUU!", Color(1.0, 0.85, 0.5), 8)
	speech.emit(HORN_LINES[(_whistles_done - 1) % HORN_LINES.size()])


func _call_reinforcements() -> void:
	ScreamRing.launch(get_parent(), global_position, self, RING_DAMAGE, RING_SPEED, RING_REACH)
	Fx.shake(1.5, 0.2)
	super._call_reinforcements()


func _on_died() -> void:
	Game.set_flag("corneteiro_morto")
	_dismiss_platoon()
	_defeat(DEFEAT_LINE)

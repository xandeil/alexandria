class_name IceBlock
extends Node2D
## O herói preso num bloco de gelo (a Curadora de Vitrines, o Cassian).
##
## Bíblia: "prende o jogador em blocos de gelo; quebrar o bloco exige toques
## rápidos". É o MESMO agarrão das Raízes (`player.grab`): toques no Ataque
## para sair, o HUD já mostra "Solte-se!". O bloco é só "quem agarrou" — um
## nó parado no lugar. Ele também derrete sozinho depois de um tempo.

const TEXTURE := preload("res://assets/fx/bloco_de_gelo.png")

## Derrete sozinho depois disto (ninguém fica preso para sempre).
var max_time := 3.5
var _time := 0.0
var _player: Player


## Prende o herói onde ele está. Devolve null se não deu (dash, já preso...).
static func trap(player: Player, taps: int, seconds: float = 3.5) -> IceBlock:
	var block := IceBlock.new()
	block.max_time = seconds
	player.get_parent().add_child(block)
	block.global_position = player.global_position
	if not player.grab(block, taps, Vector2.ZERO):
		block.queue_free()
		return null
	block._player = player
	return block


func _ready() -> void:
	add_to_group(&"ice_blocks")
	z_index = 1
	var sprite := Sprite2D.new()
	sprite.texture = TEXTURE
	sprite.offset = Vector2(0, -12)
	sprite.modulate.a = 0.85
	add_child(sprite)
	Sfx.play(&"freeze", -4.0)


func holds_player() -> bool:
	return is_instance_valid(_player) and _player.is_grabbed_by(self)


func _physics_process(delta: float) -> void:
	_time += delta
	if is_instance_valid(_player) and _player.is_grabbed_by(self) and _time >= max_time:
		_player.release_grab(false)  # derreteu
	if not holds_player():
		shatter()


func shatter() -> void:
	if is_queued_for_deletion():
		return
	Sfx.play(&"shatter", -2.0, 0.1)
	Fx.sparks(global_position + Vector2(0, -10), Vector2.UP, Color(0.8, 0.94, 1.0), 14, 120.0)
	queue_free()

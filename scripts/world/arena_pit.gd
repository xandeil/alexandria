class_name ArenaPit
extends Node2D
## Buraco aberto pelo martelo do Aldir. Pelo rombo aparece o CÉU embaixo da ilha.
##
##   CRACKING (aviso, ~0,8 s): o chão racha em brasa — ainda dá para pisar.
##   OPEN: quem ANDA para dentro cai (perde vida e volta para a borda).
##         O dash passa por cima: durante o dash você está "no ar"
##         (igual ao Hyper Light Drifter, uma das referências da Bíblia).
##   FILLED: entupido de entulho — chão seguro de novo.
##
## O buraco não sabe nada do herói: ele só responde "esse ponto está dentro
## de mim?" (contains_point). Quem decide cair é o Player — responsabilidade única.

signal opened(pit: ArenaPit)

enum State { CRACKING, OPEN, FILLED }

const CRACKS := preload("res://assets/fx/pit_cracks.png")
const HOLE := preload("res://assets/fx/pit_hole.png")
const RUBBLE := preload("res://assets/fx/pit_rubble.png")
## Tamanho de referência das texturas (elipse do buraco desenhado).
const ART_RADIUS := Vector2(18, 11)

## Meia-largura e meia-altura da elipse (vista 3/4: mais largo que alto).
@export var radius := Vector2(19, 12)
@export var warning_time := 0.8

## Aparência (padrão: o asfalto da Cidade, com o céu lá embaixo). O Prólogo usa
## o piso de metal do laboratório e um escuro sem fundo.
var crack_texture: Texture2D = CRACKS
var hole_texture: Texture2D = HOLE

var state := State.CRACKING
var _time := 0.0
var _sprite: Sprite2D


static func create(at: Vector2, size: Vector2 = Vector2(19, 12), warning: float = 0.8) -> ArenaPit:
	var pit := ArenaPit.new()
	pit.position = at
	pit.radius = size
	pit.warning_time = warning
	return pit


func _ready() -> void:
	z_index = -9  # no chão: abaixo de personagens e objetos
	add_to_group(&"pits")
	_sprite = Sprite2D.new()
	_sprite.texture = crack_texture
	_sprite.scale = radius / ART_RADIUS
	_sprite.material = Fx.unshaded  # a brasa da rachadura brilha no escuro
	add_child(_sprite)
	Sfx.play(&"crumble", -10.0)


func _process(delta: float) -> void:
	_time += delta
	if state == State.CRACKING:
		_sprite.modulate.a = 0.55 + 0.45 * absf(sin(_time * 14.0))
		if _time >= warning_time:
			_open()


func _open() -> void:
	state = State.OPEN
	_sprite.texture = hole_texture
	_sprite.material = null
	_sprite.modulate = Color.WHITE
	Sfx.play(&"crumble", -2.0)
	Fx.dust(global_position, 14)
	Fx.shake(3.0, 0.2)
	# Uma cobertura em cima do buraco despenca junto.
	for node in get_tree().get_nodes_in_group(&"covers"):
		var cover := node as DestructibleCover
		if cover and contains_point(cover.global_position, 4.0):
			cover.smash()
	opened.emit(self)


## Entope o buraco com entulho (o chão volta a ser seguro).
func fill() -> void:
	if state == State.FILLED:
		return
	state = State.FILLED
	_sprite.texture = RUBBLE
	_sprite.material = null
	_sprite.modulate = Color.WHITE
	Fx.dust(global_position, 10)
	Sfx.play(&"crumble", -12.0)


## O chão "volta" (o Pesadelo de Nyssa: o sonho devolve o que tirou).
## Diferente de fill(): não deixa entulho — o buraco some e o nó sai da cena.
func close(fade_time: float = 0.5) -> void:
	if state == State.FILLED:
		return
	state = State.FILLED
	remove_from_group(&"pits")
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate:a", 0.0, fade_time)
	tween.tween_callback(queue_free)


func is_open() -> bool:
	return state == State.OPEN


func is_active() -> bool:
	return state != State.FILLED


## O ponto está dentro da elipse? margin > 0 aumenta a área ("perto da borda"
## também conta); margin < 0 diminui (dá uma folga antes de cair).
func contains_point(point: Vector2, margin: float = 0.0) -> bool:
	if state != State.OPEN:
		return false
	var d := point - global_position
	var rx := maxf(radius.x + margin, 1.0)
	var ry := maxf(radius.y + margin, 1.0)
	return (d.x * d.x) / (rx * rx) + (d.y * d.y) / (ry * ry) <= 1.0

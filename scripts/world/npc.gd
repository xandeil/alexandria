class_name NPC
extends StaticBody2D
## Personagem do Teatro (Fada, Vendedor, Ferreiro, Orbe...) ou objeto com falas.
## As falas ficam em data/dialogos.json — texto separado do código, para você
## escrever a história sem mexer em script.

signal talked(npc: NPC)

@export var dialogue_id := ""
@export var display_name := ""
## Anda de um lado para o outro (o Orbe Branco "indo de um lado a outro" sob o palco).
@export var wander_distance := 0.0
@export var wander_speed := 10.0
## Flutua (Fada, Orbe).
@export var hover := false

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var interactable: Interactable = $Interactable

var _home := Vector2.ZERO
var _dir := 1.0
var _time := 0.0


func _ready() -> void:
	_home = position
	interactable.interacted.connect(_on_interacted)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(&"idle"):
		sprite.play(&"idle")


func _process(delta: float) -> void:
	_time += delta
	if hover:
		sprite.position.y = sin(_time * 2.4) * 2.0 - 4.0
	if wander_distance > 0.0:
		position.x += _dir * wander_speed * delta
		if absf(position.x - _home.x) >= wander_distance:
			_dir *= -1.0
			position.x = _home.x + signf(position.x - _home.x) * wander_distance


func _on_interacted(_player: Player) -> void:
	talked.emit(self)

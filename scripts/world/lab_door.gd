@tool
class_name LabDoor
extends StaticBody2D
## Porta de saída do Complexo das Cápsulas (ocupa 2 células na parede).
## Abre sozinha quando o herói chega perto — a não ser que esteja TRANCADA:
## "Ela se levanta gritando, a porta tranca e vira mini-chefe."
##
## @tool: aparece no editor ao abrir a cena (como as coberturas do Aldir).

signal opened

const TEXTURE := preload("res://assets/props/lab_door.png")
const LIGHT_TEXTURE := preload("res://assets/fx/light.png")
const GREEN := Color(0.4, 0.95, 0.55)
const RED := Color(1.0, 0.3, 0.25)

@export var open_distance := 30.0

var locked := false
var is_open := false

var _sprite: Sprite2D
var _shape: CollisionShape2D
var _light: PointLight2D


func _ready() -> void:
	collision_layer = 1  # "mundo": bloqueia tudo enquanto fechada
	collision_mask = 0
	_sprite = Sprite2D.new()
	_sprite.texture = TEXTURE
	_sprite.hframes = 3
	_sprite.offset = Vector2(0, -12)
	add_child(_sprite)
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32, 12)
	_shape.shape = rect
	_shape.position = Vector2(0, -6)
	add_child(_shape)
	if Engine.is_editor_hint():
		return
	_light = PointLight2D.new()
	_light.texture = LIGHT_TEXTURE
	_light.texture_scale = 0.3
	_light.energy = 0.8
	_light.position = Vector2(12, -22)
	add_child(_light)
	_refresh()


func set_locked(value: bool) -> void:
	locked = value
	if locked and is_open:
		_close()
	_refresh()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var near := player != null and player.global_position.distance_to(global_position) <= open_distance
	if near and not locked and not is_open:
		_open()
	elif not near and is_open:
		_close()


func _open() -> void:
	is_open = true
	Sfx.play(&"door_slide", -4.0)
	_shape.set_deferred("disabled", true)
	_refresh()
	opened.emit()


func _close() -> void:
	is_open = false
	Sfx.play(&"door_slide", -10.0)
	_shape.set_deferred("disabled", false)
	_refresh()


func _refresh() -> void:
	_sprite.frame = 2 if is_open else (1 if locked else 0)
	if _light:
		_light.color = RED if locked else GREEN

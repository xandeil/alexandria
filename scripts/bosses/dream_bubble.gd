class_name DreamBubble
extends Node2D
## Bolha de sono da Nyssa: flutua DEVAGAR atrás do herói. Encostou = sono
## (e um arranhão). Um golpe estoura. O dash passa por dentro.
## "Ela quase não ataca": a bolha é lenta de propósito — é pressão, não perigo.

const TEXTURE := preload("res://assets/fx/dream_bubble.png")

var speed := 40.0
var lifetime := 7.0
var drowsiness := 30.0
var damage := 4.0
var source: Node2D

var _time := 0.0
var _sprite: Sprite2D
var _popped := false


static func spawn(parent: Node, at: Vector2, owner_node: Node2D) -> DreamBubble:
	var bubble := DreamBubble.new()
	bubble.source = owner_node
	parent.add_child(bubble)
	bubble.global_position = at
	return bubble


func _ready() -> void:
	add_to_group("dream_bubbles")
	z_index = 6
	_sprite = Sprite2D.new()
	_sprite.texture = TEXTURE
	_sprite.material = Fx.unshaded
	_sprite.position = Vector2(0, -12)
	add_child(_sprite)


func _physics_process(delta: float) -> void:
	if _popped:
		return
	_time += delta
	_sprite.position.y = -12.0 + sin(_time * 3.0) * 2.0
	if _time >= lifetime:
		pop(false)
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead():
		return
	var to_player := player.global_position - global_position
	global_position += to_player.limit_length(speed * delta)
	# Um golpe do herói estoura a bolha.
	if player.hitbox.active and player.hitbox.global_position.distance_to(global_position + Vector2(0, -8)) < 18.0:
		pop(false)
		return
	if to_player.length() < 9.0 and not player.hurtbox.invulnerable:
		player.add_drowsiness(drowsiness)
		var info := HitInfo.create(damage, global_position, player.global_position)
		info.attack_name = "Bolha de sono"
		info.source = source
		info.unblockable = true  # sonho não se segura com escudo
		player.hurtbox.receive_hit(info)
		pop(true)


func pop(touched: bool) -> void:
	if _popped:
		return
	_popped = true
	Fx.splash(global_position + Vector2(0, -12), Color(0.8, 0.72, 1.0), 6 if touched else 4)
	Sfx.play(&"chime", -12.0, 0.2)
	var tween := create_tween()
	tween.tween_property(_sprite, "scale", Vector2(1.6, 1.6), 0.12)
	tween.parallel().tween_property(_sprite, "modulate:a", 0.0, 0.12)
	tween.tween_callback(queue_free)

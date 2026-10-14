class_name MemoryMote
extends Sprite2D
## Fiapo de memória: sai do inimigo derrotado e voa até o herói.
## É a representação visual de "Memórias são moeda, XP e lore".

signal arrived

var target: Node2D
var velocity := Vector2.ZERO
var homing := 520.0
var _age := 0.0


func _ready() -> void:
	texture = preload("res://assets/fx/mote.png")
	z_index = 12
	material = Fx.unshaded
	velocity = Vector2.from_angle(randf() * TAU) * randf_range(40.0, 90.0)


func _process(delta: float) -> void:
	_age += delta
	if not is_instance_valid(target):
		modulate.a -= delta * 2.0
		if modulate.a <= 0.0:
			queue_free()
		return
	var goal := target.global_position + Vector2(0, -8)
	var to_goal := goal - global_position
	# Primeiro se espalha, depois é "puxado" com força crescente.
	var pull := homing * clampf(_age * 2.0, 0.0, 1.0)
	velocity += to_goal.normalized() * pull * delta
	velocity = velocity.limit_length(260.0)
	global_position += velocity * delta
	if to_goal.length() < 6.0 or _age > 2.5:
		arrived.emit()
		queue_free()

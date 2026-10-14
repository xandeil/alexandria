class_name GameCamera
extends Camera2D
## Câmera que segue o herói com suavidade e treme nos impactos.
## Em luta de chefe ela enquadra os dois (herói + chefe), como nos Souls.

@export var follow_speed := 7.0
## Quanto a câmera "puxa" na direção do chefe (0 = só o herói).
@export_range(0.0, 0.5) var focus_weight := 0.32

var target: Node2D
var focus: Node2D

var _shake_strength := 0.0
var _shake_left := 0.0
var _shake_duration := 0.0


func _ready() -> void:
	if not Engine.is_editor_hint():
		Fx.camera = self


func _process(delta: float) -> void:
	if is_instance_valid(target):
		var goal := _goal()
		global_position = global_position.lerp(goal, 1.0 - exp(-follow_speed * delta))
	_update_shake(delta)


func snap_to_target() -> void:
	if is_instance_valid(target):
		global_position = _goal()
		reset_smoothing()


func shake(strength: float, duration: float) -> void:
	if strength >= _shake_strength * (_shake_left / maxf(_shake_duration, 0.001)):
		_shake_strength = strength
		_shake_duration = duration
		_shake_left = duration


func _goal() -> Vector2:
	var goal := target.global_position + Vector2(0, -10)
	if is_instance_valid(focus):
		goal = goal.lerp(focus.global_position, focus_weight)
	return goal


func _update_shake(delta: float) -> void:
	if _shake_left <= 0.0:
		offset = Vector2.ZERO
		return
	_shake_left -= delta
	var power := _shake_strength * (_shake_left / _shake_duration)
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * power

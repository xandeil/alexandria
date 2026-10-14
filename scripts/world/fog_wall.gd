class_name FogWall
extends StaticBody2D
## Névoa branca que fecha a arena do chefe (a "fog wall" dos Souls).
## Enquanto a luta não começa ela é atravessável; quando o herói entra, vira sólida.

@onready var mist: ColorRect = $Mist
@onready var shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	mist.modulate.a = 0.0
	visible = false
	set_solid(false)


func appear() -> void:
	visible = true
	var tween := create_tween()
	tween.tween_property(mist, "modulate:a", 1.0, 0.6)


func set_solid(solid: bool) -> void:
	shape.set_deferred("disabled", not solid)


func vanish() -> void:
	set_solid(false)
	var tween := create_tween()
	tween.tween_property(mist, "modulate:a", 0.0, 1.2)
	tween.tween_callback(hide)

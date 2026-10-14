class_name TrainingDummy
extends StaticBody2D
## Boneco de treino do Ferreiro: nunca morre e mostra o dano de cada golpe.
## Ferramenta de AJUSTE: use para sentir os números do AttackData no celular.

@onready var sprite: Sprite2D = $Sprite
@onready var hurtbox: Hurtbox = $Hurtbox

var _wobble := 0.0
var _wobble_dir := 1.0


func _ready() -> void:
	add_to_group("enemies")
	hurtbox.owner_body = self
	hurtbox.hit_received.connect(_on_hit)


func is_targetable() -> bool:
	return true


func _on_hit(info: HitInfo) -> void:
	_wobble = 0.35 if info.is_heavy else 0.22
	_wobble_dir = signf(info.direction.x) if absf(info.direction.x) > 0.1 else 1.0
	Fx.damage_number(global_position, info.damage, Color(1.0, 0.85, 0.5) if info.is_heavy else Color(1, 0.97, 0.9))
	Fx.sparks(global_position + Vector2(0, -12), info.direction, Color(0.95, 0.85, 0.55), 7)
	Fx.flash(sprite, 0.08)
	Sfx.play(&"hit_heavy" if info.is_heavy else &"hit", -3.0)


func _process(delta: float) -> void:
	_wobble = move_toward(_wobble, 0.0, delta * 0.9)
	sprite.rotation = sin(Time.get_ticks_msec() * 0.03) * _wobble * _wobble_dir

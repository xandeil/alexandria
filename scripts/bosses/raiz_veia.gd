class_name RaizVeia
extends Enemy
## Raiz-Veia — nasce do chão na fase 2 de Mabel e fica ligada a ela.
## Bíblia: "Cortar as raízes ligadas a ela interrompe a cura."
##
## Não anda e não ataca: enquanto viva, bombeia humanidade até Mabel (a linha
## vermelha pulsando) e dela saem os lacaios. É um alvo, não um inimigo.

## Quem esta raiz alimenta (a linha é desenhada por ela, não por mim).
var feeds: Node2D
var _clock := 0.0


func _ready() -> void:
	super._ready()
	_clock = randf() * TAU
	Fx.dust(global_position, 10)
	visual.scale = Vector2(1.0, 0.1)
	create_tween().tween_property(visual, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _physics_process(delta: float) -> void:
	_clock += delta
	velocity = Vector2.ZERO
	if dead:
		return
	regen_poise(delta)
	# Pulsa como veia: o bulbo "bate".
	var beat := maxf(sin(_clock * 4.0), 0.0)
	body_sprite.self_modulate = Color(1, 1, 1).lerp(Color(1.5, 0.8, 0.8), beat)


func _can_be_staggered() -> bool:
	return false


func _play_death() -> void:
	Sfx.play(&"root_burst", -2.0, 0.1)
	Fx.splash(global_position + Vector2(0, -14), Color(0.62, 0.1, 0.16), 14)
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.3, 0.1), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)

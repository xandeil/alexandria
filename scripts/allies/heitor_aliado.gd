class_name HeitorAliado
extends Ally
## Heitor, o marido de Helena (v0.45, Etapa 8). Substitui o antigo Guarda Sem
## Posto. Alegre, armadura redonda, vive preso em lugares (poço, estátua, gelo).
## Salvo três vezes (heitor_gelo), ele entra com você na luta contra a Helena —
## ela não sabe que é ele. Ele também não.

const FRAMES := preload("res://assets/sprites/heitor_aliado_frames.tres")
const HELMET := preload("res://assets/props/elmo_heitor.png")
## O que fica onde ele caiu (o mesmo do people do Teatro, com heitor_morto).
const MEMORIAL := {"dialogue": "heitor_memorial", "name": "Elmo e garrafa",
	"texture": "res://assets/props/heitor_memorial.png", "prompt": "Examinar"}


func _setup() -> void:
	ally_id = "heitor"
	display_name = "Espada do Heitor"
	frames = FRAMES
	can_enter_arenas = true  # a única arena em que ele entra é a da Helena
	max_health = 190.0
	strike_damage = 15.0
	move_speed = 74.0


func _on_fall() -> String:
	return "Heitor caiu de joelhos. Ele volta para o lago do Domínio."


## v0.46 (Etapa 8): o golpe roteirizado da Helena no fim da fase 2. Ele cai,
## o elmo voa longe, e fica ali: elmo + a garrafa de Licor quebrada. O anel
## dele rola até você (é ele que ela vê na fase 3).
func struck_by_helena(from_direction: Vector2) -> void:
	fallen = true
	_hurtbox.set_deferred("monitorable", false)
	velocity = Vector2.ZERO
	_sprite.flip_h = from_direction.x > 0.0  # de frente para ela
	_sprite.play(&"caido")
	Fx.flash(_sprite, 0.2)
	Game.set_flag("heitor_morto")
	Game.add_item("anel_do_guarda")
	# O elmo sai voando num arco curto e quica.
	var helmet := Sprite2D.new()
	helmet.texture = HELMET
	helmet.top_level = true
	helmet.global_position = global_position + Vector2(0, -20)
	helmet.z_index = 5
	add_child(helmet)
	var land := global_position + from_direction.normalized() * 22.0 + Vector2(0, -3)
	var arc := helmet.create_tween()
	arc.tween_property(helmet, "global_position", (helmet.global_position + land) * 0.5 + Vector2(0, -18), 0.25).set_ease(Tween.EASE_OUT)
	arc.tween_property(helmet, "global_position", land, 0.25).set_ease(Tween.EASE_IN)
	arc.parallel().tween_property(helmet, "rotation", 2.6, 0.5)
	arc.tween_callback(func(): Sfx.play(&"clang", -2.0))
	var level := Level.find(self)
	if level and level.hud:
		level.hud.toast("Um anel rolou até os seus pés.")
	# Depois do grito, ele some; no lugar, o memorial (Examinar).
	var tween := create_tween()
	tween.tween_interval(4.5)
	tween.tween_property(self, "modulate:a", 0.0, 1.2)
	tween.tween_callback(func():
		var where := global_position
		var lvl := Level.find(self)
		if lvl:
			lvl._place_object(MEMORIAL, where)
		queue_free())

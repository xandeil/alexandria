class_name Tito
extends Crianca
## O Tito, filho do Galeno (v0.47, Etapa 9). Fica no canto do dormitório,
## atrás de uma caminha, desenhando a giz. Não brinca de pega-pega e não ri.
##
## Um olho ainda castanho: morreu menos vezes que as outras crianças — por isso
## AINDA PODE MORRER DE VERDADE. Mesma vida das outras; um golpe sem querer
## conta como criança ferida, igual. A diferença: zerou a vida, as outras
## levantam menores; ele fica caído, respirando pouco (tito_caido). O herói
## recebe a Espada de Madeira Pequena.
##
## Reverter: voltar ao laboratório e usar um Frasco de Sanidade nele
## (tito_revivido). Prazo: o último fragmento do Galeno — depois, tito_morto.

const FRAMES := preload("res://assets/sprites/tito_frames.tres")
## O que fica no lugar dele, caído (Examinar).
const FALLEN_SPOT := {"dialogue": "tito_no_chao", "name": "Criança caída", "prompt": "Examinar"}

var _spot: NPC


func _ready() -> void:
	super._ready()
	body_sprite.sprite_frames = FRAMES
	body_sprite.play(&"idle")
	down_time = INF  # ele não levanta


## Ele não corre atrás de ninguém: fica desenhando no canto.
func _ai_play(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	facing = Vector2.UP  # de costas, virado para a parede (o desenho)


func laugh() -> void:
	pass


## Apanhou: conta como criança ferida (igual às outras), mas ele não revida.
func _on_damaged(_amount: float, info: HitInfo, _blocked: bool) -> void:
	if is_instance_valid(info.source) and info.source.is_in_group("player"):
		Game.register_child_hurt()


func _on_died() -> void:
	super._on_died()
	if not Game.has_flag("tito_caido"):
		Game.set_flag("tito_caido")
		if Game.add_item("espada_madeira_pequena") > 0:
			var level := Level.find(self)
			if level and level.hud:
				level.hud.toast(Items.get_item("espada_madeira_pequena").description)
	_add_spot()


## Carregado já caído (voltou ao laboratório depois): no chão, sem barra, sem golpe.
func lie_down() -> void:
	stats.set_health(0.0)
	down = true
	hitbox.deactivate()
	hurtbox.invulnerable = true
	remove_from_group("enemies")
	_set_ai(AI.DOWN)
	visual.rotation = deg_to_rad(88.0)
	visual.modulate = Color(0.7, 0.72, 0.76)
	_add_spot.call_deferred()


func _get_up() -> void:
	pass  # os outros sempre levantam; ele não


func _add_spot() -> void:
	if is_instance_valid(_spot):
		return
	var level := Level.find(self)
	if level == null:
		return
	_spot = level._make_npc(FALLEN_SPOT["dialogue"], FALLEN_SPOT["name"], "", 1, global_position, FALLEN_SPOT["prompt"])
	_spot.get_node("CollisionShape2D").disabled = true
	_spot.add_to_group(&"npcs")
	if not _spot.talked.is_connected(level._on_npc_talked):
		_spot.talked.connect(level._on_npc_talked)


## O Frasco de Sanidade (Level, ação "reviver_tito"): ele some daqui; no lugar,
## o Tito revivido (o olho castanho ficou branco).
func remove_for_revival() -> void:
	if is_instance_valid(_spot):
		_spot.queue_free()
	queue_free()

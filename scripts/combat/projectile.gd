class_name Projectile
extends Node2D
## Projétil em linha reta (o tiro do Atirador de Telhado; amanhã, as bolas de
## fogo da Rachel ou o gelo do Cassian).
##
## Não usa física de corpo: a cada passo ele lança um RAIO do ponto anterior
## até o próximo contra a camada "mundo". Assim um tiro rápido não "atravessa"
## uma parede fina entre dois quadros (o famoso "tunneling").
## Paredes, barricadas e coberturas seguram o tiro. O dash (i-frames) passa
## por dentro dele.

const BULLET := preload("res://assets/fx/bala.png")
const EMBER := preload("res://assets/fx/bola_de_fogo.png")
const SHARD := preload("res://assets/fx/estilhaco_gelo.png")
const BOOK := preload("res://assets/fx/livro_voando.png")
## Elementos: o MESMO tiro, com textura e efeito diferentes. Um StringName em
## vez de vários booleanos (fire, frost, ...): uma opção só, sem combinações
## impossíveis ("fogo E gelo ao mesmo tempo").
const PLAIN := &""
const FIRE := &"fogo"  # bola de fogo (dragonoides): onde bate, fogo no chão
const FROST := &"gelo"  # estilhaço de gelo (Domínio Congelado): quem leva fica lento
const TOME := &"livro"  # livro congelado arremessado (o Golem do Arquivo): só pesa
## Quanto tempo o estilhaço de gelo deixa o herói lento.
const FROST_CHILL := 1.6

var direction := Vector2.RIGHT
var speed := 150.0
var damage := 16.0
var knockback := 120.0
var max_distance := 320.0
## Raio em que o tiro acerta o herói.
var hit_radius := 7.0
var source: Node2D
var element := PLAIN
## Fogo amigo (v0.30.7, ideia de um testador): o tiro dos ATIRADORES também
## acerta outros inimigos no caminho. Vira estratégia: ponha um inimigo entre
## você e o atirador. Chefes não usam (o tiro deles é só para o herói).
var friendly_fire := false

var _traveled := 0.0
var _done := false
var _sprite: Sprite2D


static func launch(parent: Node, from: Vector2, dir: Vector2, owner_node: Node2D, shot_damage: float,
		shot_speed: float, distance: float, shot_element: StringName = PLAIN) -> Projectile:
	var shot := Projectile.new()
	shot.element = shot_element
	shot.direction = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	shot.source = owner_node
	shot.damage = shot_damage
	shot.speed = shot_speed
	shot.max_distance = distance
	parent.add_child(shot)
	shot.global_position = from
	return shot


func _ready() -> void:
	add_to_group("projectiles")  # o escudo do herói se vira para balas chegando
	z_index = 6
	_sprite = Sprite2D.new()
	match element:
		FIRE:
			_sprite.texture = EMBER
		FROST:
			_sprite.texture = SHARD
			_sprite.rotation = direction.angle()
		TOME:
			_sprite.texture = BOOK
		_:
			_sprite.texture = BULLET
	_sprite.material = Fx.unshaded  # brasa e gelo: brilham no escuro
	_sprite.position = Vector2(0, -8)  # na altura do peito, não no chão
	add_child(_sprite)


## Bala já parada (acertou algo) não é ameaça.
func is_targetable() -> bool:
	return not _done


func _physics_process(delta: float) -> void:
	if _done:
		return
	var from := global_position
	var step := direction * speed * delta
	var query := PhysicsRayQueryParameters2D.create(from, from + step, 1)
	if is_instance_valid(source) and source is CollisionObject2D:
		query.exclude = [(source as CollisionObject2D).get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit["position"]
		_impact(true)
		return
	global_position = from + step
	_traveled += step.length()
	if element == TOME:
		_sprite.rotation += delta * 12.0  # livro girando no ar
	_try_hit_player()
	if not _done and friendly_fire:
		_try_hit_enemies()
	if _traveled >= max_distance:
		_impact(false)


func _try_hit_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead():
		return
	if player.global_position.distance_to(global_position) > hit_radius:
		return
	var info := HitInfo.create(damage, global_position - direction * 6.0, player.global_position)
	info.knockback = knockback
	info.source = source
	info.attack_name = {FIRE: "Bola de fogo", FROST: "Estilhaço de gelo", TOME: "Livro congelado"}.get(element, "Tiro")
	if player.hurtbox.receive_hit(info):  # i-frames do dash: o tiro passa direto
		if element == FROST:
			player.apply_chill(FROST_CHILL)
		_impact(true)


func _try_hit_enemies() -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy == source or enemy.dead or enemy is Boss:
			continue
		if enemy.global_position.distance_to(global_position) > hit_radius + 3.0:
			continue
		var info := HitInfo.create(damage, global_position - direction * 6.0, enemy.global_position)
		info.knockback = knockback
		info.source = source
		info.attack_name = "Tiro"
		if enemy.hurtbox.receive_hit(info):
			_impact(true)
			return


func _impact(spark: bool) -> void:
	_done = true
	if spark:
		var color := Color(0.75, 0.92, 1.0) if element == FROST else Color(1.0, 0.75, 0.4)
		Fx.sparks(global_position + Vector2(0, -8), -direction, color, 6)
	if element == FIRE:
		# Quem atirou pode ter morrido com a bola ainda no ar: não passe um nó liberado.
		var owner_node := source if is_instance_valid(source) else null
		FirePatch.spawn(get_parent(), global_position, 10.0, 1.6, 8.0, owner_node)
	queue_free()


func is_done() -> bool:
	return _done

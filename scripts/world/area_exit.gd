class_name AreaExit
extends Area2D
## Passagem para outra área (porta do Teatro, rua da Cidade...).
## Só "arma" depois que o herói sai de cima dela — senão quem acabou de chegar
## por esta porta seria mandado de volta no mesmo instante.

@export_file("*.tscn") var target_scene := ""
@export var target_spawn := ""

var _armed := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # jogador
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(func(body: Node2D): if body is Player: _armed = true)
	# connect() em vez de "await": se a cena for trocada antes, a conexão morre
	# junto com este nó e nada tenta rodar num objeto que já não existe.
	get_tree().create_timer(0.6, false).timeout.connect(_arm_if_clear)


func _arm_if_clear() -> void:
	if not _has_player_inside():
		_armed = true


func _has_player_inside() -> bool:
	for body in get_overlapping_bodies():
		if body is Player:
			return true
	return false


func _on_body_entered(body: Node2D) -> void:
	if not _armed or not body is Player or target_scene.is_empty():
		return
	var player := body as Player
	if player.is_dead():
		return
	_armed = false
	player.lock_input(true)
	Sfx.play(&"door")
	Game.carry(player.stats.health, player.health_flasks)  # vida e frascos atravessam a porta com você
	Game.travel(target_scene, target_spawn)

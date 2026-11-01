class_name ZoneTrigger
extends Area2D
## GATILHO DE ZONA (v0.31, Etapa 1): pisou aqui, TODOS os inimigos da zona vêm
## atrás de você. O fio de alarme da Cidade, a sineta das mesas postas das Raízes.
##
## A zona é um retângulo do mapa (Level.zones, com um "id"). Os inimigos que
## nascem dentro dele ganham a marca "zona" = id. O gatilho só chama os da sua
## zona — o resto do mapa nem fica sabendo.
##
## Dispara uma vez por visita (a fase recarregou, o alarme rearma).

signal triggered(zone_id: String)

var zone_id := ""
var sound := &"bell"
var _fired := false


static func spawn(parent: Node, id: String, at: Vector2) -> ZoneTrigger:
	var trigger := ZoneTrigger.new()
	trigger.zone_id = id
	trigger.position = at
	parent.add_child(trigger)
	return trigger


func _ready() -> void:
	add_to_group("zone_triggers")
	collision_layer = 0
	collision_mask = 2  # camada do jogador
	monitoring = true
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(14, 14)
	shape.shape = box
	add_child(shape)
	body_entered.connect(_on_body_entered)
	z_index = -5
	queue_redraw()


## O fio no chão: dá para VER (quem presta atenção passa por cima com o dash
## ou contorna). Depois de tocar, o fio fica frouxo.
func _draw() -> void:
	var color := Color(0.75, 0.72, 0.6, 0.9) if not _fired else Color(0.45, 0.42, 0.38, 0.6)
	draw_line(Vector2(-7, 1), Vector2(7, 1 if not _fired else 4), color, 1.0)
	draw_rect(Rect2(-8, -1, 2, 4), Color(0.4, 0.35, 0.3))
	draw_rect(Rect2(6, -1, 2, 4), Color(0.4, 0.35, 0.3))


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		fire(body as Player)


## Chama a zona (público: testes e eventos de roteiro também usam).
func fire(player: Player = null) -> int:
	if _fired:
		return 0
	_fired = true
	queue_redraw()
	Sfx.play(sound, -4.0)
	var called := ZoneTrigger.alert_zone(get_tree(), zone_id)
	triggered.emit(zone_id)
	if player:
		player.make_noise(400.0)  # quem só ouve (Sonâmbulos) também acorda
	return called


## Acorda todos os inimigos marcados com esta zona. Devolve quantos.
static func alert_zone(tree: SceneTree, id: String, seconds: float = 8.0) -> int:
	var called := 0
	for node in tree.get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy and not enemy.dead and str(enemy.get_meta(&"zona", "")) == id:
			enemy.alert(seconds)
			called += 1
	return called

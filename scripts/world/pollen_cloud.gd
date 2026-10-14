class_name PollenCloud
extends Node2D
## Nuvem de pólen: "o sono de Nyssa espalhado pelo chão".
## Quem fica DENTRO enche a Barra de Sonolência. O dash atravessa sem encher
## (o herói prende a respiração) — mesma regra do grito da Governanta: a saída
## é sempre ler o aviso e agir, nunca ficar parado.

const TEXTURE := preload("res://assets/fx/pollen_cloud.png")

## Sonolência por segundo dentro da nuvem (a barra desce ~9/s sozinha).
var drowsiness_per_second := 40.0
var radius := 34.0
var duration := 3.5
## Deriva lenta (o ar do bosque quase não se mexe).
var drift := Vector2.ZERO

var _time := 0.0
var _sprites: Array[Sprite2D] = []


static func spawn(parent: Node, at: Vector2, cloud_radius: float = 34.0, seconds: float = 3.5) -> PollenCloud:
	var cloud := PollenCloud.new()
	cloud.radius = cloud_radius
	cloud.duration = seconds
	cloud.position = at
	parent.add_child(cloud)
	return cloud


func _ready() -> void:
	add_to_group("pollen_clouds")
	z_index = 5
	# Três "bolos" girando devagar: parece fumaça, custa quase nada.
	for i in 3:
		var sprite := Sprite2D.new()
		sprite.texture = TEXTURE
		sprite.material = Fx.unshaded
		sprite.position = Vector2.from_angle(i * TAU / 3.0) * radius * 0.3 + Vector2(0, -6)
		sprite.scale = Vector2.ONE * (radius / 16.0) * (0.8 + 0.15 * i)
		sprite.modulate.a = 0.0
		add_child(sprite)
		_sprites.append(sprite)


## 0 → 1 no começo, 1 no meio, 1 → 0 no último segundo.
func strength() -> float:
	return clampf(minf(_time / 0.3, (duration - _time) / 1.0), 0.0, 1.0)


func contains(point: Vector2) -> bool:
	return point.distance_to(global_position) <= radius


func _physics_process(delta: float) -> void:
	_time += delta
	if _time >= duration:
		queue_free()
		return
	position += drift * delta
	var s := strength()
	for i in _sprites.size():
		_sprites[i].rotation += delta * (0.3 + i * 0.15) * (1 if i % 2 == 0 else -1)
		_sprites[i].modulate.a = s * 0.85
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead() or player.state == Player.State.DASH:
		return
	if contains(player.global_position):
		player.add_drowsiness(drowsiness_per_second * s * delta)

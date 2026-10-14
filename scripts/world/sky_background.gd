extends Node2D
## Céu sob a ilha flutuante: gradiente + nuvens passando devagar POR BAIXO.
## Bíblia: "Lá fora a verdade aparece sem palavras: o jogador está no topo de
## uma ilha flutuante, com o céu passando por baixo."

const CLOUDS := [
	preload("res://assets/fx/cloud_1.png"),
	preload("res://assets/fx/cloud_2.png"),
	preload("res://assets/fx/cloud_3.png"),
]

var area_size := Vector2(800, 600)

var _clouds: Array[Sprite2D] = []
var _speeds: Array[float] = []


func _ready() -> void:
	z_index = -50
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.38, 0.46, 0.59))
	gradient.set_color(1, Color(0.69, 0.73, 0.81))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	texture.width = 8
	texture.height = 64
	var sky := Sprite2D.new()
	sky.texture = texture
	sky.centered = false
	var margin := Vector2(400, 300)
	sky.position = -margin
	sky.scale = (area_size + margin * 2.0) / Vector2(8, 64)
	add_child(sky)
	for i in 26:
		var cloud := Sprite2D.new()
		cloud.texture = CLOUDS[i % CLOUDS.size()]
		cloud.position = Vector2(randf_range(-200, area_size.x + 200), randf_range(-100, area_size.y + 200))
		var depth := randf_range(0.6, 1.0)
		cloud.modulate = Color(1, 1, 1, 0.55 + 0.4 * depth)
		cloud.scale = Vector2.ONE * (0.8 + depth)
		add_child(cloud)
		_clouds.append(cloud)
		_speeds.append(randf_range(5.0, 14.0) * depth)


func _process(delta: float) -> void:
	for i in _clouds.size():
		var cloud := _clouds[i]
		cloud.position.x += _speeds[i] * delta
		if cloud.position.x > area_size.x + 260.0:
			cloud.position.x = -260.0

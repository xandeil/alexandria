class_name SlumberPollen
extends Node2D
## Nuvem de pólen do Arco do Sono Eterno (não confundir com a PollenCloud do
## Bosque, que dá SONO no herói — esta deixa os INIMIGOS lentos): quem está dentro anda e ataca na
## metade da velocidade (Preguiça). Sair da nuvem, ou ela sumir, devolve o normal
## — o efeito é renovado em pedacinhos (REFRESH) enquanto o inimigo fica dentro.

const TICK := 0.2
const REFRESH := 0.5  ## lentidão que sobra depois de sair da nuvem

var radius := 34.0
var duration := 4.0
var _time := 0.0
var _tick := 0.0
var _motes: Array[Vector3] = []


static func spawn(parent: Node, at: Vector2, cloud_radius: float, seconds: float) -> SlumberPollen:
	var cloud := SlumberPollen.new()
	cloud.radius = cloud_radius
	cloud.duration = seconds
	cloud.position = at
	parent.add_child(cloud)
	return cloud


func _ready() -> void:
	add_to_group("slumber_pollen")
	z_index = 4
	material = Fx.unshaded
	for i in 26:
		_motes.append(Vector3(randf_range(-1, 1), randf_range(-1, 1), randf() * TAU))
	Sfx.play(&"puff", -6.0)


func _physics_process(delta: float) -> void:
	_time += delta
	queue_redraw()
	if _time >= duration:
		queue_free()
		return
	_tick -= delta
	if _tick > 0.0:
		return
	_tick = TICK
	for enemy in WeaponSkill.enemies_in(get_tree(), global_position, radius):
		EnemyStatus.of(enemy).apply_slow(REFRESH)


func _draw() -> void:
	var fade := clampf((duration - _time) / 0.8, 0.0, 1.0) * clampf(_time / 0.3, 0.0, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.88, 0.45, 0.14 * fade))
	draw_circle(Vector2.ZERO, radius * 0.6, Color(1.0, 0.92, 0.6, 0.12 * fade))
	draw_set_transform(Vector2.ZERO)
	for m in _motes:
		var a := m.z + _time * 0.8
		var p := Vector2(m.x + sin(a) * 0.15, m.y + cos(a * 1.3) * 0.15) * radius * Vector2(1.0, 0.6)
		draw_circle(p + Vector2(0, -6), 1.2, Color(1.0, 0.95, 0.55, 0.7 * fade))

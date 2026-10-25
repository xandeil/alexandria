class_name GravityVortex
extends Node2D
## Vórtice da Âncora da Gravidade: o machado fincado puxa os inimigos em volta
## para o centro e, no fim, tudo que ficou perto leva um golpe.
##
## O puxão usa move_and_collide (e não "teleporte" de posição): o inimigo é
## arrastado mas RESPEITA paredes — ninguém atravessa cenário por causa dele.
## Chefes e gigantes não saem do lugar (WeaponSkill.is_heavyweight): só levam o dano.

const PULL_SPEED := 90.0  ## px/s na borda; mais forte perto do centro
const BURST_RADIUS := 30.0

var radius := 72.0
var duration := 2.2
var burst_damage := 30.0
var source: Player
var _time := 0.0


static func spawn(parent: Node, at: Vector2, vortex_radius: float, seconds: float, damage: float,
		owner_node: Player) -> GravityVortex:
	var vortex := GravityVortex.new()
	vortex.radius = vortex_radius
	vortex.duration = seconds
	vortex.burst_damage = damage
	vortex.source = owner_node
	vortex.position = at
	parent.add_child(vortex)
	return vortex


func _ready() -> void:
	add_to_group("vortices")
	z_index = 3  # por cima do chão e das sombras
	material = Fx.unshaded


func _physics_process(delta: float) -> void:
	_time += delta
	queue_redraw()
	for enemy in WeaponSkill.enemies_in(get_tree(), global_position, radius):
		if WeaponSkill.is_heavyweight(enemy):
			continue
		var to_center := global_position - enemy.global_position
		var distance := to_center.length()
		if distance < 4.0:
			continue
		var strength := PULL_SPEED * (0.5 + 0.5 * (1.0 - distance / radius))
		enemy.move_and_collide(to_center / distance * strength * delta)
	if _time >= duration:
		_burst()


func _burst() -> void:
	set_physics_process(false)
	if is_instance_valid(source):
		for enemy in WeaponSkill.enemies_in(get_tree(), global_position, BURST_RADIUS):
			WeaponSkill.strike(enemy, source, burst_damage, 40.0, "Âncora", true, false, 160.0)
	Fx.shake(3.0, 0.15)
	WeaponFx.ring(get_parent(), global_position, BURST_RADIUS + 6.0, Color(0.95, 0.85, 0.5))
	queue_free()


func _draw() -> void:
	var t := _time * 5.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	for k in 3:
		var r := fposmod(radius - t * 18.0 - k * radius / 3.0, radius)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(0.95, 0.85, 0.5, 0.6 * r / radius), 2.0)
	for k in 6:  # braços da espiral
		var a := t + k * TAU / 6.0
		draw_line(Vector2.from_angle(a) * radius * 0.25, Vector2.from_angle(a + 0.6) * radius * 0.7,
			Color(1.0, 0.88, 0.45, 0.45), 1.5)
	draw_set_transform(Vector2.ZERO)

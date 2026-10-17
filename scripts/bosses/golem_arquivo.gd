class_name GolemArquivo
extends MiniBoss
## O Golem do Arquivo — 2º mini-chefe do Domínio Congelado.
## Bíblia: "feito de estantes congeladas; ao morrer libera um livro de lore
## sobre o Projeto Alexandria."
##
## Enorme e lento. Tudo nele é aviso grande:
##   • PILÃO: ergue os braços (círculo) e esmaga; o chão em volta vira gelo.
##   • VARREDURA: o braço-estante em leque largo.
##   • LIVROS: arremessa um leque de livros congelados (o escudo segura).
## Vencido, deixa o livro do Arquivo no chão (o nível o coloca: "memorial").

enum Mode { DECIDE, SLAM, SWEEP, BOOKS }

@export var sweep: AttackData
@export var slam_windup := 1.1
@export var slam_radius := 38.0
@export var slam_damage := 32.0
@export var book_count := 5
@export var book_damage := 14.0
@export var book_speed := 130.0
@export var books_windup := 0.8

@onready var telegraph: TelegraphDrawer = $Telegraph

var mode := Mode.DECIDE
var _mode_time := 0.0
var _actions := 0
var _aim := Vector2.RIGHT


func _on_wake() -> void:
	speech.emit("(Páginas congeladas estalam. As estantes se levantam.)")
	Sfx.play(&"quake", -6.0)
	_go_decide(1.0)


func _on_reset() -> void:
	telegraph.clear()
	_go_decide(0.0)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _go_decide(delay: float) -> void:
	_set_mode(Mode.DECIDE)
	_mode_time = -delay


func _fight(delta: float) -> void:
	_mode_time += delta
	match mode:
		Mode.DECIDE:
			var to_target := target.global_position - global_position
			facing = to_target.normalized()
			if _mode_time < 0.0:
				velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
				return
			_actions += 1
			var distance := to_target.length()
			if distance > 90.0 or _actions % 4 == 0:
				_aim = facing
				_set_mode(Mode.BOOKS)
				Sfx.play(&"telegraph", -6.0)
			elif distance < 34.0 and _actions % 2 == 0:
				_set_mode(Mode.SWEEP)
				start_attack(sweep, facing)
			elif distance < 60.0:
				_set_mode(Mode.SLAM)
				Sfx.play(&"telegraph", -4.0)
			else:
				velocity = velocity.move_toward(facing * move_speed, acceleration * delta)
				_mode_time = -0.3
		Mode.SLAM:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time >= slam_windup and _mode_time - delta < slam_windup:
				slam()
			if _mode_time >= slam_windup + 0.8:
				_go_decide(0.4)
		Mode.SWEEP:
			velocity = _runner.step(delta, velocity)
		Mode.BOOKS:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
			if _mode_time < books_windup * 0.7:
				_aim = (target.global_position - global_position).normalized()
				facing = _aim
			if _mode_time >= books_windup:
				throw_books()
				_go_decide(1.0)


func slam() -> void:
	Sfx.play(&"slam", 0.0)
	Sfx.play(&"freeze", -6.0)
	Fx.shake(5.0, 0.35)
	Fx.dust(global_position, 14)
	if target and target.global_position.distance_to(global_position) <= slam_radius:
		var info := HitInfo.create(slam_damage, global_position, target.global_position)
		info.knockback = 220.0
		info.poise_damage = 45.0
		info.is_heavy = true
		info.attack_name = "Pilão de estantes"
		info.source = self
		target.hurtbox.receive_hit(info)
	# O chão em volta congela um instante (escorrega: cuidado ao fugir).
	var area := Rect2(global_position - Vector2(slam_radius, slam_radius * 0.7), Vector2(slam_radius, slam_radius * 0.7) * 2.0)
	FrostZone.spawn(get_parent(), area, 0.05, 3.0, 0, self)


func throw_books() -> void:
	for i in book_count:
		var spread := deg_to_rad(14.0) * (i - (book_count - 1) * 0.5)
		Projectile.launch(get_parent(), global_position + Vector2(0, -26) + _aim * 14.0, _aim.rotated(spread), self,
			book_damage, book_speed, 260.0, Projectile.TOME)
	Sfx.play(&"swing_heavy", -4.0)


func _on_attack_finished() -> void:
	if mode == Mode.SWEEP:
		_go_decide(0.8)


func _can_be_staggered() -> bool:
	return false  # uma estante não cambaleia: o jogador tem de ler os avisos


func _on_died() -> void:
	telegraph.clear()
	_defeat()


func _after_move(_delta: float) -> void:
	if absf(facing.x) > 0.15:
		body_sprite.flip_h = facing.x < 0.0
	telegraph.circle_visible = mode == Mode.SLAM and _mode_time < slam_windup
	if telegraph.circle_visible:
		telegraph.circle_center = global_position
		telegraph.circle_radius = slam_radius
		telegraph.circle_progress = _mode_time / slam_windup
	telegraph.line_visible = mode == Mode.BOOKS
	if mode == Mode.BOOKS:
		telegraph.line_origin = global_position + Vector2(0, -20)
		telegraph.line_direction = _aim
		telegraph.line_length = 120.0
		telegraph.line_locked = _mode_time >= books_windup * 0.7
		telegraph.extra_line_directions.assign([_aim.rotated(deg_to_rad(-28.0)), _aim.rotated(deg_to_rad(28.0))])
	else:
		telegraph.extra_line_directions.clear()
	var anim := &"idle"
	match mode:
		Mode.SLAM:
			anim = &"ergue" if _mode_time < slam_windup else &"esmaga"
		Mode.SWEEP:
			anim = &"varre"
		Mode.BOOKS:
			anim = &"ergue"
	if mode == Mode.DECIDE and velocity.length() > 5.0:
		anim = &"walk"
	if body_sprite.animation != anim:
		body_sprite.play(anim)

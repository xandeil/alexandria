class_name TorretaFaisca
extends Enemy
## Torreta de Faísca — Forjas Ocas.
## Bíblia: "Fixa; atira raio pelas placas do chão. A engenharia do projeto."
##
## Ela não acerta você: acerta o CHÃO. Mira, carrega (zumbido e brilho) e
## manda o raio pelas placas de metal entre ela e você — e pelas placas em
## volta de onde você está. As placas acendem antes (amarelo): saia delas.
## Perto dela não há perigo nenhum: chegue e desmonte.

enum AI { IDLE, CHARGE, COOLDOWN }

@export var sight_range := 150.0
@export var charge_time := 0.6
@export var fire_every := 3.2
## Comprimento da trilha de raio (px) e raio em volta do herói.
@export var line_length := 150.0
@export var splash_radius := 22.0
@export var plate_warning := 0.9
@export var shock_damage := 18.0

var ai := AI.IDLE
var _ai_time := 0.0
var _aim := Vector2.RIGHT


func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if dead:
		return
	_ai_time += delta
	regen_poise(delta)
	target = find_target()
	match ai:
		AI.IDLE, AI.COOLDOWN:
			var ready := ai == AI.IDLE or _ai_time >= fire_every
			if ready and target and global_position.distance_to(target.global_position) <= sight_range and can_see(target.global_position):
				_set_ai(AI.CHARGE)
				_aim = (target.global_position - global_position).normalized()
				Sfx.play(&"hum", -8.0, 0.1)
		AI.CHARGE:
			if target and _ai_time < charge_time * 0.6:
				_aim = (target.global_position - global_position).normalized()
			if _ai_time >= charge_time:
				fire()
				_set_ai(AI.COOLDOWN)
	_update_pose()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


## Acende as placas: a trilha até o herói + as placas em volta dele.
func fire() -> PlateCharge:
	var cells := plate_targets()
	if cells.is_empty():
		return null
	Sfx.play(&"zap", -10.0, 0.2)
	return PlateCharge.spawn(get_parent(), cells, plate_warning, shock_damage, self)


func plate_targets() -> Array[Vector2i]:
	var from := global_position
	var to := from + _aim * line_length
	var level := Level.find(self)
	var cells: Array[Vector2i] = []
	if level:
		cells = level.plates_on_line(from, to)
		if target:
			for cell in level.plates_near(target.global_position, splash_radius):
				if not cells.has(cell):
					cells.append(cell)
	else:
		# Sem fase (teste): a trilha inteira conta como placa.
		var steps := int(line_length / 8.0)
		for i in steps + 1:
			var cell := Level.cell_at(from.lerp(to, float(i) / steps))
			if not cells.has(cell):
				cells.append(cell)
	return cells


func _update_pose() -> void:
	var anim := &"carrega" if ai == AI.CHARGE else &"idle"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	if absf(_aim.x) > 0.1:
		body_sprite.flip_h = _aim.x < 0.0
	if ai == AI.CHARGE:
		visual.position.x = sin(_ai_time * 70.0) * 0.6
	else:
		visual.position.x = 0.0

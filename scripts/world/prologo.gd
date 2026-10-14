@tool
class_name Prologo
extends Level
## O Prólogo: o Complexo das Cápsulas. A primeira escolha moral — SEM AVISO.
##
## Herda tudo da Level (mapa em texto, herói, HUD, Câmara, arena de chefe) e
## só acrescenta as regras deste lugar (herança no lugar certo: o Prólogo É
## uma fase, com três peças a mais):
##   N  a Governanta, sentada na cabeceira da mesa comprida;
##   E  a porta de saída (2 células) — tranca se ela lutar;
##   !  o chão que some depois da porta (a queda até o Teatro).
##
## A decisão "ela luta?" mora AQUI, não na Governanta: quando o herói entra no
## refeitório, a fase olha Game.criancas_feridas.
##   0  → ela só levanta os olhos (observa) e a porta abre. Sem diálogo.
##   1+ → BossArena.arm(): ela se ergue gritando, a névoa fecha, a porta tranca.
## Vencida, a lembrança dela toma a tela (ecos em volta da mesa vazia).

const GOVERNESS_SCENE := preload("res://scenes/bosses/governanta.tscn")
const LAB_CRACKS := preload("res://assets/fx/lab_cracks.png")
const LAB_HOLE := preload("res://assets/fx/lab_hole.png")
const CHILD_SHEETS := [
	preload("res://assets/sprites/crianca_a.png"),
	preload("res://assets/sprites/crianca_b.png"),
	preload("res://assets/sprites/adolescente.png"),
]
const GOVERNESS_SHEET := preload("res://assets/sprites/governanta_body.png")
## Os ecos da lembrança: brancos, translúcidos, brilhando no escuro (shaders/echo.gdshader).
const ECHO_MATERIAL := preload("res://shaders/echo_material.tres")
const ECHO_COLOR := Color(1.0, 1.0, 1.0, 0.7)
## Tamanho do sprite da mesa comprida (assets/props/long_table.png).
const TABLE_SIZE := Vector2(40, 92)

var governess: Governanta
var exit_door: LabDoor

var _table_feet := Vector2.ZERO
var _fall_cells: Array[Vector2] = []
var _fall_area: Area2D
var _falling := false
var _room := Rect2()
var _echoes: Array[Sprite2D] = []
var _governess_echo: Sprite2D


func _clear() -> void:
	super._clear()
	governess = null
	exit_door = null
	_table_feet = Vector2.ZERO
	_fall_cells.clear()


func _build_entity(x: int, y: int, c: String) -> void:
	match c:
		"N":
			var node := GOVERNESS_SCENE.instantiate()
			node.position = _cell_feet(x, y) + Vector2(8, 0)  # alinhada à mesa (2 células)
			entities.add_child(node)
			if not Engine.is_editor_hint():
				governess = node as Governanta
				_boss = governess
		"E":
			exit_door = LabDoor.new()
			exit_door.position = _cell_feet(x, y) + Vector2(8, 0)
			entities.add_child(exit_door)
		"!":
			_fall_cells.append(_cell_center(x, y))
		"m":
			_table_feet = _cell_feet(x, y) + Vector2(8, 0)
			super._build_entity(x, y, c)
		_:
			super._build_entity(x, y, c)


## A Governanta não arma a arena ao abrir a fase: quem decide é a escolha moral.
func _auto_arm_boss() -> bool:
	return false


func _start_runtime() -> void:
	super._start_runtime()
	if boss_arena:
		_room = boss_arena.arena_rect
		boss_arena.sealed.connect(func(_boss_node: Boss): _lock_exit(true))
	_make_fall_trigger()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or not is_instance_valid(player) or boss_arena == null:
		return
	if boss_arena.state != BossArena.State.IDLE or player.is_dead() or _falling:
		return
	# "Ela já sabe o que o jogador fez."
	if Game.criancas_feridas > 0 and _room.grow(-10.0).has_point(player.global_position):
		_wake_governess()


func _wake_governess() -> void:
	_lock_exit(true)
	Sfx.stop_ambience(0.3)
	boss_arena.arm()


func _lock_exit(locked: bool) -> void:
	if is_instance_valid(exit_door):
		exit_door.set_locked(locked)


# --- Vitória: a lembrança dela ------------------------------------------------------

func _celebrate_victory(_subtitle: String) -> void:
	await _play_governess_memory()
	_lock_exit(false)


## "Ao ser derrotada, sua lembrança se partia em fragmentos: crianças brincando,
## o tempo passando sem aviso, a descoberta de que a morte havia sido retirada
## daquele lugar... No fim, restaram apenas ecos… e uma mesa vazia."
func _play_governess_memory() -> void:
	begin_cutscene()
	var base_color := canvas_modulate.color
	var tint := create_tween()
	tint.tween_property(canvas_modulate, "color", Color(0.95, 0.93, 0.88), 1.0)
	_spawn_memory_echoes()
	var narration := Narration.new()
	narration.hold_time = 3.0
	add_child(narration)
	narration.line_started.connect(_on_memory_line)
	await narration.play(DialogueData.get_entry("memoria_governanta").get("falas", []), Narration.Style.SUBTITLE)
	narration.queue_free()
	_clear_memory_echoes()
	var back := create_tween()
	back.tween_property(canvas_modulate, "color", base_color, 1.0)
	await back.finished
	if not player.is_dead():
		end_cutscene()


func _table_top_left() -> Vector2:
	return _table_feet - Vector2(TABLE_SIZE.x * 0.5, TABLE_SIZE.y)


## Ecos sentados nas cadeirinhas (3 de cada lado) e ela de pé na cabeceira.
func _spawn_memory_echoes() -> void:
	_clear_memory_echoes()
	if _table_feet == Vector2.ZERO:
		return
	var origin := _table_top_left()
	var index := 0
	for row in 3:
		for side in [-1, 1]:
			var at := origin + Vector2(20 + side * 17, 27 + row * 22)
			_echoes.append(_make_echo(CHILD_SHEETS[index % CHILD_SHEETS.size()], Vector2(24, 24), at, side < 0))
			index += 1
	_governess_echo = _make_echo(GOVERNESS_SHEET, Vector2(32, 40), origin + Vector2(20, 13), true)
	_governess_echo.flip_h = false


func _make_echo(sheet: Texture2D, frame: Vector2, at: Vector2, face_right: bool) -> Sprite2D:
	var sprite := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(Vector2.ZERO, frame)
	sprite.texture = atlas
	sprite.offset = Vector2(0, -frame.y * 0.5)
	sprite.flip_h = not face_right
	sprite.material = ECHO_MATERIAL
	sprite.modulate = Color(ECHO_COLOR, 0.0)
	sprite.z_index = 2
	entities.add_child(sprite)
	sprite.global_position = at
	return sprite


func _clear_memory_echoes() -> void:
	for echo in _echoes:
		if is_instance_valid(echo):
			echo.queue_free()
	_echoes.clear()
	if is_instance_valid(_governess_echo):
		_governess_echo.queue_free()
	_governess_echo = null


## Cada frase da lembrança move os ecos (a cena acompanha o texto).
func _on_memory_line(index: int) -> void:
	match index:
		0:  # Crianças brincando.
			Sfx.play(&"echo", -6.0)
			for i in _echoes.size():
				var echo := _echoes[i]
				var appear := echo.create_tween()
				appear.tween_interval(i * 0.12)
				appear.tween_property(echo, "modulate:a", ECHO_COLOR.a, 0.6)
				var y := echo.position.y
				var hop := echo.create_tween().set_loops(5)
				hop.tween_interval(randf_range(0.15, 0.5))
				hop.tween_property(echo, "position:y", y - 3.0, 0.12)
				hop.tween_property(echo, "position:y", y, 0.14)
			if _governess_echo:
				_governess_echo.create_tween().tween_property(_governess_echo, "modulate:a", ECHO_COLOR.a, 0.8)
		1:  # O tempo passando sem aviso.
			var flicker := create_tween()
			for i in 3:
				flicker.tween_property(canvas_modulate, "color", Color(0.6, 0.62, 0.62), 0.25)
				flicker.tween_property(canvas_modulate, "color", Color(0.95, 0.93, 0.88), 0.35)
		2:  # A descoberta de que a morte havia sido retirada daquele lugar.
			for i in [0, 3]:
				if i < _echoes.size():
					var echo := _echoes[i]
					var fall := echo.create_tween()
					fall.tween_property(echo, "rotation", deg_to_rad(85.0), 0.25)
					fall.tween_interval(0.8)
					fall.tween_property(echo, "rotation", 0.0, 0.3)
					fall.parallel().tween_property(echo, "scale", Vector2.ONE * 0.85, 0.3)
		3:  # Uma eternidade mal concedida. Um cuidado que virou prisão.
			for echo in _echoes:
				echo.create_tween().tween_property(echo, "scale", Vector2.ONE * 0.75, 1.2)
			if _governess_echo:
				_governess_echo.create_tween().tween_property(_governess_echo, "rotation", 0.12, 1.2)
		4:  # No fim, restaram apenas ecos…
			for i in _echoes.size():
				var echo := _echoes[i]
				var fade := echo.create_tween()
				fade.tween_interval(i * 0.3)
				fade.tween_property(echo, "modulate:a", 0.0, 0.5)
		5:  # …e uma mesa vazia.
			if _governess_echo:
				_governess_echo.create_tween().tween_property(_governess_echo, "modulate:a", 0.0, 1.4)
		6:  # O grito dela não era de raiva. Era de falha.
			Sfx.play(&"echo", -12.0)


# --- A queda ----------------------------------------------------------------------------

func _make_fall_trigger() -> void:
	if _fall_cells.is_empty():
		return
	_fall_area = Area2D.new()
	_fall_area.name = "FallTrigger"
	_fall_area.collision_layer = 0
	_fall_area.collision_mask = 2  # jogador
	for center in _fall_cells:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(TILE, TILE)
		shape.shape = rect
		shape.position = center
		_fall_area.add_child(shape)
	add_child(_fall_area)
	_fall_area.body_entered.connect(_on_fall_area_entered)


func _on_fall_area_entered(body: Node2D) -> void:
	if body is Player:
		start_fall()


## "Passando pela porta, o chão some. O jogador cai num buraco e acorda no Teatro."
func start_fall() -> void:
	if _falling or not is_instance_valid(player) or player.is_dead():
		return
	_falling = true
	begin_cutscene()
	var pit := ArenaPit.create(player.global_position + Vector2(0, -3), Vector2(24, 15), 0.45)
	pit.crack_texture = LAB_CRACKS
	pit.hole_texture = LAB_HOLE
	entities.add_child(pit)
	Fx.shake(3.0, 0.5)
	Fx.vibrate(80)
	await _wait(0.5)
	Sfx.play(&"fall")
	player.plunge(pit.global_position + Vector2(0, 2), 0.9)
	await _wait(1.0)
	Sfx.stop_ambience(1.0)
	var narration := Narration.new()
	add_child(narration)
	await narration.play(DialogueData.get_entry("queda").get("falas", []), Narration.Style.SCREEN)
	Game.finish_prologue()


func is_falling() -> bool:
	return _falling

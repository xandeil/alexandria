extends Node
## Autoload "Fx": efeitos de impacto (game feel) e partículas.
##
##   • hitstop: congela o jogo por alguns milissegundos quando um golpe conecta.
##     É o truque nº 1 para dar PESO ao combate.
##   • shake: tremor de câmera proporcional ao impacto.
##   • vibrate: vibração do celular (tátil). Desligável no menu de pausa.
##   • partículas e meias-luas de golpe criadas por código.

const SPARK := preload("res://assets/fx/spark.png")
const DUST := preload("res://assets/fx/dust.png")
const MOTE := preload("res://assets/fx/mote.png")
const NUMBER_FONT := preload("res://assets/fonts/Tiny5-Regular.woff2")

## Testes automáticos desligam hitstop/vibração para medir tempo com precisão.
var enabled := true
var camera: GameCamera

## Efeitos de tempo ativos: [escala, fim em ms]. Vale o MAIS LENTO enquanto
## durar; quando ele acaba, o próximo assume (hitstop curto + câmera lenta
## longa = congela um instante e depois desacelera, não "congela tudo").
var _time_effects: Array = []
## Efeitos "sem sombra": não escurecem com o CanvasModulate da área (brilham no escuro).
var unshaded := CanvasItemMaterial.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED


func _process(_delta: float) -> void:
	if not _time_effects.is_empty():
		_apply_time_scale()


# --- Tempo -----------------------------------------------------------------------

func hitstop(duration: float, scale: float = 0.05) -> void:
	slow_motion(scale, duration)


func slow_motion(scale: float, duration: float) -> void:
	if not enabled or duration <= 0.0:
		return
	_time_effects.append([scale, Time.get_ticks_msec() + int(duration * 1000.0)])
	_apply_time_scale()


## Troca de cena: nada de câmera lenta "vazando" para a próxima área.
func clear_time_effects() -> void:
	_time_effects.clear()
	Engine.time_scale = 1.0


func _apply_time_scale() -> void:
	var now := Time.get_ticks_msec()
	var scale := 1.0
	for i in range(_time_effects.size() - 1, -1, -1):
		var effect: Array = _time_effects[i]
		if now >= int(effect[1]):
			_time_effects.remove_at(i)
		else:
			scale = minf(scale, float(effect[0]))
	Engine.time_scale = scale


# --- Câmera e vibração --------------------------------------------------------------

func shake(strength: float, duration: float = 0.15) -> void:
	if enabled and is_instance_valid(camera):
		camera.shake(strength, duration)


func vibrate(milliseconds: int) -> void:
	if enabled and Game.vibration_enabled and OS.has_feature("mobile"):
		Input.vibrate_handheld(milliseconds)


## Pisca um sprite de branco (usa o parâmetro "flash" do shader sprite_fx).
func flash(item: CanvasItem, duration: float = 0.12, color: Color = Color.WHITE) -> void:
	if not is_instance_valid(item):
		return
	var material := item.material as ShaderMaterial
	if material == null:
		var tween := item.create_tween()
		item.modulate = Color(3, 3, 3)
		tween.tween_property(item, "modulate", Color.WHITE, duration)
		return
	material.set_shader_parameter("flash_color", color)
	material.set_shader_parameter("flash", 1.0)
	var t := item.create_tween()
	t.tween_method(func(v: float): material.set_shader_parameter("flash", v), 1.0, 0.0, duration)


# --- Efeitos visuais -----------------------------------------------------------------

func spawn_slash(at: Vector2, angle: float, attack: AttackData, reverse: bool) -> void:
	var slash := SlashFX.new()
	slash.radius = attack.slash_radius
	slash.arc = deg_to_rad(maxf(attack.slash_arc_degrees, 1.0))
	slash.thrust = attack.slash_arc_degrees <= 10.0
	slash.thickness = 7.0 if attack.is_heavy else 5.0
	slash.color = attack.slash_color
	slash.reverse = reverse
	slash.duration = 0.18 if attack.is_heavy else 0.14
	slash.rotation = angle
	slash.z_index = 8
	slash.material = unshaded
	_add_to_world(slash, at)


func sparks(at: Vector2, direction: Vector2, color: Color = Color(1, 0.92, 0.7), amount: int = 8, speed: float = 110.0) -> void:
	var p := _particles(amount, 0.28, SPARK)
	p.direction = direction if direction != Vector2.ZERO else Vector2.UP
	p.spread = 55.0
	p.initial_velocity_min = speed * 0.5
	p.initial_velocity_max = speed
	p.damping_min = 180.0
	p.damping_max = 260.0
	p.color_ramp = _fade_ramp(color)
	p.z_index = 9
	_emit(p, at)


func dust(at: Vector2, amount: int = 6) -> void:
	var p := _particles(amount, 0.45, DUST)
	p.direction = Vector2.UP
	p.spread = 90.0
	p.initial_velocity_min = 8.0
	p.initial_velocity_max = 26.0
	p.gravity = Vector2(0, -12)
	p.scale_amount_min = 0.8
	p.scale_amount_max = 1.6
	p.color_ramp = _fade_ramp(Color(0.75, 0.72, 0.66, 0.7))
	p.z_index = -1
	_emit(p, at)


func splash(at: Vector2, color: Color, amount: int = 14) -> void:
	var p := _particles(amount, 0.6, SPARK)
	p.direction = Vector2.UP
	p.spread = 70.0
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 70.0
	p.gravity = Vector2(0, 160)
	p.color_ramp = _fade_ramp(color)
	p.z_index = 9
	_emit(p, at)


func afterimage(sprite: AnimatedSprite2D, tint: Color = Color(0.6, 0.8, 1.0, 0.55)) -> void:
	if not is_instance_valid(sprite) or sprite.sprite_frames == null:
		return
	var ghost := Sprite2D.new()
	ghost.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	ghost.flip_h = sprite.flip_h
	ghost.offset = sprite.offset
	ghost.modulate = tint
	ghost.z_index = -1
	ghost.scale = sprite.global_scale
	_add_to_world(ghost, sprite.global_position)
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.22)
	tween.tween_callback(ghost.queue_free)


func damage_number(at: Vector2, value: float, color: Color = Color(1, 0.95, 0.85)) -> void:
	float_text(at + Vector2(randf_range(-6, 2), -26), str(int(round(value))), color)


## Texto que sobe e some (número de dano, o "hi hi" das crianças).
func float_text(at: Vector2, text: String, color: Color = Color(1, 0.95, 0.85), size: int = 8) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", NUMBER_FONT)
	label.material = unshaded
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.06))
	label.add_theme_constant_override("outline_size", 3)
	label.z_index = 20
	_add_to_world(label, at)
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 12.0, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.25)
	tween.chain().tween_callback(label.queue_free)


## Fiapos de memória voando até o herói. Toca o "pling" quando o primeiro chega.
func memory_motes(from: Vector2, target: Node2D, count: int) -> void:
	var played := false
	for i in count:
		var mote := MemoryMote.new()
		mote.target = target
		_add_to_world(mote, from + Vector2(randf_range(-4, 4), randf_range(-10, 0)))
		if not played:
			played = true
			mote.arrived.connect(func(): Sfx.play(&"memory", -4.0))


# --- Utilidades ---------------------------------------------------------------------------

func _particles(amount: int, lifetime: float, texture: Texture2D) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = maxi(amount, 1)
	p.lifetime = lifetime
	p.explosiveness = 1.0
	p.texture = texture
	return p


func _emit(p: CPUParticles2D, at: Vector2) -> void:
	p.material = unshaded
	_add_to_world(p, at)
	p.emitting = true
	get_tree().create_timer(p.lifetime + 0.3, false).timeout.connect(p.queue_free)


func _fade_ramp(color: Color) -> Gradient:
	var g := Gradient.new()
	g.set_color(0, color)
	g.set_color(1, Color(color, 0.0))
	return g


func _add_to_world(node: CanvasItem, at: Vector2) -> void:
	var root := get_tree().current_scene
	if root == null:
		node.queue_free()
		return
	root.add_child(node)
	if node is Node2D:
		(node as Node2D).global_position = at
	elif node is Control:
		(node as Control).global_position = at

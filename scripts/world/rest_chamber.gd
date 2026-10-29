class_name RestChamber
extends StaticBody2D
## Câmara do jogador — a cápsula diante do palco. Ponto de descanso e salvamento.
## Bíblia: "Aos poucos o jogador percebe que é o quarto dele."
##
## Descansar: vida, estamina e Frascos de Vida de volta, os inimigos voltam a
## existir (eles "morrem e estagnam") e o jogo salva. A visão NÃO volta —
## só o Frasco de Sanidade devolve o que as mortes tiraram.
##
## v0.28 — ENTRAR e SAIR animados, com o SEU personagem:
##   a cápsula agora é feita de PEÇAS: o corpo (com o colchão), o "dorminhoco"
##   (o seu sprite, deitado) e a tampa de vidro por cima. Como cada peça se
##   mexe sozinha, a cena funciona para qualquer uma das 90 aparências — um
##   vídeo pronto mostraria sempre a mesma pessoa.
##   play_enter(): vai até a frente, a tampa sobe chiando, sobe e deita,
##                 a tampa fecha e o vidro embaça.
##   play_exit():  a luz pisca, vapor, a tampa abre, senta, pula para fora e
##                 se espreguiça; a tampa fecha vazia.
## Quem decide QUANDO tocar é a fase (descanso, despertar, viagem, morte).

signal rest_requested(chamber: RestChamber)

## A tampa aberta: sobe um pouco (como na cápsula vazia do Prólogo).
const LID_OPEN := Vector2(0, -8)
## Onde o herói fica deitado (centro do colchão) e de pé, na frente.
const LYING := Vector2(-1, -11)
const STANDING_FRONT := Vector2(0, 11)
## Vidro embaçado com alguém dormindo: mais claro e esverdeado.
const FOG := Color(1.25, 1.5, 1.35)

@export var spawn_id := "camara"

@onready var interactable: Interactable = $Interactable
@onready var glow: PointLight2D = $Glow
@onready var lid: Sprite2D = $Lid
@onready var sleeper: AnimatedSprite2D = $Sleeper

var _time := 0.0
## Brilho extra por cima da respiração da luz (a luz que pisca ao acordar).
var _boost := 0.0


func _ready() -> void:
	interactable.interacted.connect(func(_player: Player): rest_requested.emit(self))
	sleeper.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _process(delta: float) -> void:
	_time += delta
	glow.energy = 0.55 + sin(_time * 1.6) * 0.12 + _boost


func set_available(available: bool) -> void:
	interactable.enabled = available
	glow.color = Color(0.4, 0.86, 0.53) if available else Color(0.7, 0.2, 0.2)


## Onde o herói fica de pé, de frente para a cápsula (o ponto "camara").
func front_point() -> Vector2:
	return global_position + Vector2(0, 22)


func is_occupied() -> bool:
	return sleeper.visible


# --- Entrar -------------------------------------------------------------------------------

func play_enter(player: Player) -> void:
	var was_enabled := interactable.enabled
	interactable.enabled = false
	# 1. Vai até a frente da cápsula, de costas para a câmera.
	player.facing = Vector2.UP
	var distance := player.global_position.distance_to(front_point())
	if distance > 2.0:
		var walk := create_tween()
		walk.tween_property(player, "global_position", front_point(), clampf(distance / 70.0, 0.15, 0.6))
		await walk.finished
	# 2. A tampa sobe.
	await _open_lid()
	# 3. Sobe na borda e deita (o sprite de verdade some; quem anima é o "dorminhoco").
	_dress_sleeper()
	sleeper.position = STANDING_FRONT
	sleeper.rotation = 0.0
	sleeper.scale = Vector2.ONE
	sleeper.visible = true
	player.visual.visible = false
	var climb := create_tween()
	climb.tween_property(sleeper, "position", Vector2(0, -3), 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	climb.tween_property(sleeper, "position", LYING, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	climb.parallel().tween_property(sleeper, "rotation", -PI * 0.5, 0.34)
	climb.parallel().tween_property(sleeper, "scale", Vector2(0.8, 0.8), 0.34)
	await climb.finished
	Fx.dust(global_position + Vector2(0, -8), 4)
	await _wait(0.15)
	# 4. A tampa fecha e o vidro embaça.
	await _close_lid(true)
	await _wait(0.35)
	interactable.enabled = was_enabled


# --- Sair ---------------------------------------------------------------------------------

## Deixa a cápsula fechada, com o herói dormindo lá dentro (antes de play_exit).
func show_sleeping() -> void:
	_dress_sleeper()
	sleeper.visible = true
	sleeper.position = LYING
	sleeper.rotation = -PI * 0.5
	sleeper.scale = Vector2(0.8, 0.8)
	lid.position = Vector2.ZERO
	lid.modulate = FOG


func play_exit(player: Player) -> void:
	if not sleeper.visible:
		show_sleeping()
	player.visual.visible = false
	var was_enabled := interactable.enabled
	interactable.enabled = false
	# 1. A luz pisca duas vezes (alguém está acordando).
	var flicker := create_tween()
	for i in 2:
		flicker.tween_property(self, "_boost", 1.1, 0.1)
		flicker.tween_property(self, "_boost", 0.0, 0.12)
	await flicker.finished
	# 2. Vapor e a tampa abre.
	Fx.splash(global_position + Vector2(0, -12), Color(0.85, 1.0, 0.95), 10)
	await _open_lid()
	# 3. Senta...
	var sit := create_tween()
	sit.tween_property(sleeper, "rotation", -0.2, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	sit.parallel().tween_property(sleeper, "position", Vector2(-2, -15), 0.32)
	sit.parallel().tween_property(sleeper, "scale", Vector2(0.9, 0.9), 0.32)
	await sit.finished
	await _wait(0.12)
	# ...e pula para fora.
	var hop := create_tween()
	hop.tween_property(sleeper, "position", Vector2(0, -6), 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	hop.parallel().tween_property(sleeper, "rotation", 0.0, 0.16)
	hop.tween_property(sleeper, "position", STANDING_FRONT, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	hop.parallel().tween_property(sleeper, "scale", Vector2.ONE, 0.22)
	await hop.finished
	# 4. O sprite de verdade volta, no mesmo lugar, e "se espreguiça".
	sleeper.visible = false
	player.global_position = front_point()
	player.reset_physics_interpolation()  # aparece já no lugar (sem "arrastar")
	player.facing = Vector2.DOWN
	player.visual.visible = true
	player.visual.scale = Vector2(1.15, 0.85)
	var stretch := create_tween()
	stretch.tween_property(player.visual, "scale", Vector2(0.92, 1.1), 0.12)
	stretch.tween_property(player.visual, "scale", Vector2.ONE, 0.16)
	Fx.dust(front_point(), 5)
	await _close_lid(false)
	interactable.enabled = was_enabled


# --- Peças --------------------------------------------------------------------------------

func _dress_sleeper() -> void:
	sleeper.sprite_frames = Appearance.sprite_frames(Game.appearance)
	sleeper.play(&"idle")


func _open_lid() -> void:
	Sfx.play(&"capsule_open", -4.0)
	Fx.dust(global_position + Vector2(0, -10), 8)
	var tween := create_tween()
	tween.tween_property(lid, "position", LID_OPEN, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(lid, "modulate", Color.WHITE, 0.32)
	await tween.finished


func _close_lid(fog: bool) -> void:
	var tween := create_tween()
	tween.tween_property(lid, "position", Vector2.ZERO, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	Sfx.play(&"door", -10.0)
	if fog:
		var mist := create_tween()
		mist.tween_property(lid, "modulate", FOG, 0.5)
		mist.parallel().tween_property(self, "_boost", 0.5, 0.25)
		mist.tween_property(self, "_boost", 0.0, 0.4)
		await mist.finished


## Espera que morre junto com a cápsula (troca de cena no meio não quebra nada).
func _wait(seconds: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(seconds)
	await timer.timeout
	timer.queue_free()

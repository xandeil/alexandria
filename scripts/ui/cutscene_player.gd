class_name CutscenePlayer
extends Control
## Toca um VÍDEO em tela cheia (cutscene) e avisa quando acabou.
##
##   var cena := CutscenePlayer.create("res://assets/cutscenes/abertura.ogv")
##   add_child(cena)
##   await cena.finished
##
## Um toque na tela, um clique, ✕ / ○ no controle ou Enter / Esc pulam.
## O vídeo precisa estar em Ogg Theora (.ogv): é o formato que o Godot toca
## sozinho, em todas as plataformas (Android, PC e navegador).
##
## TROCAR O VÍDEO DEPOIS: é só substituir o arquivo .ogv (mesmo nome). O
## código não sabe nada do conteúdo — duração, cenas, som, tudo vem do arquivo.

signal finished

## Pular só depois deste tempo: o mesmo toque que abriu a cena não a fecha.
const SKIP_GRACE := 0.35
## A dica "pular" aparece depois de um instante (no começo, a tela é do vídeo).
const HINT_DELAY := 1.2

var video_path := ""
var video: VideoStreamPlayer
var _hint: Label
var _time := 0.0
var _done := false


static func create(path: String) -> CutscenePlayer:
	var cutscene := CutscenePlayer.new()
	cutscene.video_path = path
	return cutscene


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(black)
	# 16:9 sem esticar (em telas mais largas sobram faixas pretas dos lados).
	var frame := AspectRatioContainer.new()
	frame.ratio = 16.0 / 9.0
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(frame)
	video = VideoStreamPlayer.new()
	video.expand = true
	video.bus = Settings.AMBIENCE_BUS  # o volume de "Ambiente" nas Opções vale aqui
	video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(video)
	_hint = UIStyle.label(PadStyle.text("{cross} pular") if Settings.controller_mode else "Toque para pular", 8, UIStyle.TEXT_DIM)
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hint.offset_left = -110
	_hint.offset_right = -8
	_hint.offset_top = -18
	_hint.offset_bottom = -6
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.modulate.a = 0.0
	add_child(_hint)
	var stream := load(video_path) as VideoStream if ResourceLoader.exists(video_path) else null
	if stream == null:
		push_warning("CutscenePlayer: vídeo não encontrado (%s) — pulando" % video_path)
		_finish.call_deferred()
		return
	video.stream = stream
	video.finished.connect(_finish)
	Sfx.stop_ambience(0.4)  # a música do título não toca por cima do vídeo
	video.play()


func _process(delta: float) -> void:
	_time += delta
	if _time >= HINT_DELAY and _hint.modulate.a < 0.8:
		_hint.modulate.a = minf(_hint.modulate.a + delta * 2.0, 0.8)


## _input (e não _unhandled_input): a cutscene está por cima de tudo, nenhum
## menu embaixo deve receber o ✕ que pula o vídeo.
func _input(event: InputEvent) -> void:
	if _done or not _is_skip(event):
		return
	get_viewport().set_input_as_handled()
	if _time >= SKIP_GRACE:
		skip()


func _is_skip(event: InputEvent) -> bool:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		return event.pressed
	for action in [&"ui_accept", &"ui_cancel", &"attack", &"pause"]:
		if event.is_action_pressed(action):
			return true
	return false


func skip() -> void:
	Sfx.play(&"ui_click", -6.0)
	_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	if is_instance_valid(video):
		video.stop()
	finished.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_visible_in_tree():
		skip()  # o "voltar" do Android também pula

extends Control
## O final (Bíblia: "O jogo não diz qual é o certo; só mostra as consequências.").
##
## Tela preta, frases que aparecem e somem uma de cada vez, o "FIM" e os
## créditos. Qual final: `Game.flags["final"]` ("proteger" ou "destruir").
## Tocar na tela adianta a frase (ninguém fica preso numa cena longa no celular).

const LINES := {
	"proteger": [
		"Você se ajoelhou onde ele estava.",
		"A luz atravessou o seu peito como atravessava o dele. Era quente. Era pesada.",
		"Lá embaixo, o Teatro continuou aceso. As ilhas continuaram no céu.",
		"Ninguém caiu. Ninguém seguiu.",
		"A ilha não cai.",
		"Algumas coisas sobrevivem, mas nunca vivem.",
	],
	"destruir": [
		"Você rompeu o elo.",
		"Ela abriu os olhos pela primeira vez. Não pareceu assustada. Pareceu cansada.",
		"As correntes das Âncoras cantaram uma nota longa. Depois, nenhuma.",
		"A ilha começou a cair.",
		"O impacto não é mostrado. A resposta não é dada.",
		"Libertar algo pode ser o mesmo que destruí-lo.",
	],
}
const CLOSING := "Quanto tempo algo pode ser protegido antes de deixar de ser salvo?"
const CREDITS := [
	"ALEXANDRIA — A Ilha Que Não Cai",
	"Uma história de Alexandre",
	"Feito em Godot 4 · arte e sons gerados por código",
	"Fontes: Cinzel, Pixelify Sans, Tiny5 (SIL Open Font License)",
	"Obrigado por jogar.",
]
const FADE := 1.0

var kind := "proteger"
var _label: Label
var _skip := false
var _done := false
## Depois dos créditos (v0.27): "Iniciar nova jornada" e "Explorar o mundo atual".
var choices: VBoxContainer
var new_journey_button: Button
var explore_button: Button
var creation: CharacterCreation


func _ready() -> void:
	# A escolha acontece num diálogo (que pausa o mundo). O final é uma cena nova:
	# nada aqui deve ficar congelado por uma pausa que sobrou.
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	kind = str(Game.flags.get("final", "proteger"))
	if not LINES.has(kind):
		kind = "proteger"
	_build()
	Sfx.play_ambience(&"amb_core", -14.0)
	Sfx.play(&"bell", -6.0)
	_run()


func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if not get_parent() is Control:
		size = get_viewport_rect().size  # sem um Control pai, as âncoras não têm a que se prender
	mouse_filter = Control.MOUSE_FILTER_STOP
	var black := ColorRect.new()
	# Proteger termina na luz; destruir, no escuro.
	black.color = Color(0.1, 0.09, 0.08) if kind == "proteger" else Color(0.01, 0.01, 0.02)
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black)
	_label = UIStyle.label("", 12, UIStyle.TEXT)
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.offset_left = 40
	_label.offset_right = -40
	_label.modulate.a = 0.0
	add_child(_label)


func _gui_input(event: InputEvent) -> void:
	var pressed: bool = (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed)
	if pressed and not _done:
		_skip = true


func _unhandled_input(event: InputEvent) -> void:
	if _done:
		return  # agora quem manda são os dois botões
	if event.is_action_pressed(&"attack") or event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept"):
		_skip = true


func _run() -> void:
	await _wait(1.2)
	for line in LINES[kind]:
		await _show(line, UIStyle.TEXT, 12, UIStyle.FONT)
	await _show(CLOSING, UIStyle.GOLD, 12, UIStyle.FONT)
	await _show("FIM", UIStyle.GOLD, 28, UIStyle.TITLE_FONT)
	for line in CREDITS:
		await _show(line, UIStyle.TEXT_DIM, 10, UIStyle.FONT, 1.6)
	_show_choices()
	_done = true


## As duas saídas do fim (o NG+ da Alexandria).
func _show_choices() -> void:
	_label.visible = false  # o último crédito (pulado no meio do fade) não fica por baixo dos botões
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	choices = VBoxContainer.new()
	choices.set_anchors_preset(Control.PRESET_CENTER)
	choices.offset_left = -130
	choices.offset_right = 130
	choices.offset_top = -40
	choices.offset_bottom = 40
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	choices.add_theme_constant_override("separation", 10)
	choices.modulate.a = 0.0
	add_child(choices)
	new_journey_button = DSMenuButton.make("Iniciar nova jornada", 13)
	new_journey_button.pressed.connect(open_new_journey)
	choices.add_child(new_journey_button)
	var hint := UIStyle.label("Outro experimento, num mundo mais duro. Só o nível passa adiante.", 8, UIStyle.TEXT_DIM)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_constant_override("outline_size", 0)  # fundo já é escuro: o contorno só sujava as letras
	choices.add_child(hint)
	explore_button = DSMenuButton.make("Explorar o mundo atual", 13)
	explore_button.pressed.connect(explore)
	choices.add_child(explore_button)
	create_tween().tween_property(choices, "modulate:a", 1.0, FADE)
	new_journey_button.grab_focus()


## Direto para a criação do novo experimento (sem "criar personagem" no botão).
func open_new_journey() -> void:
	Sfx.play(&"ui_open")
	choices.visible = false
	creation = CharacterCreation.new()
	creation.journey_cycle = Game.cycle + 1
	add_child(creation)
	creation.confirmed.connect(func(choice: Dictionary): Game.start_new_journey(choice))
	creation.cancelled.connect(_close_creation)


func _close_creation() -> void:
	creation.queue_free()
	creation = null
	choices.visible = true
	new_journey_button.grab_focus()


func explore() -> void:
	Sfx.play(&"ui_click")
	Game.explore_after_ending()


## Uma frase: aparece, fica (tempo pelo tamanho do texto) e some.
func _show(text: String, color: Color, size: int, font: Font, hold: float = -1.0) -> void:
	_label.text = text
	_label.add_theme_font_override("font", font)
	_label.add_theme_font_size_override("font_size", size)
	_label.add_theme_color_override("font_color", color)
	if hold < 0.0:
		hold = clampf(1.4 + text.length() * 0.045, 2.0, 5.0)
	_skip = false
	var tween := create_tween()
	tween.tween_property(_label, "modulate:a", 1.0, FADE)
	await _wait(FADE + hold)
	_skip = false
	tween = create_tween()
	tween.tween_property(_label, "modulate:a", 0.0, FADE * 0.6)
	await tween.finished


## Espera que o toque na tela encurta.
func _wait(seconds: float) -> void:
	var left := seconds
	while left > 0.0 and not _skip:
		await get_tree().process_frame
		left -= get_process_delta_time()

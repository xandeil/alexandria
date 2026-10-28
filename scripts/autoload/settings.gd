extends Node
## Opções do APARELHO (volume, vibração, tamanho dos botões, dicas).
##
## Ficam num arquivo próprio (user://opcoes.cfg), separado do save do jogo:
## começar um jogo novo não deve zerar o volume que você escolheu, e quem
## divide o celular divide também o gosto de som. (Responsabilidade única:
## o save guarda a SUA história; isto aqui guarda o aparelho.)

signal changed

const PATH := "user://opcoes.cfg"
const SFX_BUS := &"Efeitos"
const AMBIENCE_BUS := &"Ambiente"
## Tamanho dos botões de toque: nome mostrado → escala.
const BUTTON_SIZES := {"Pequenos": 0.85, "Médios": 1.0, "Grandes": 1.2}

var sfx_volume := 0.9
var ambience_volume := 0.8
var vibration := true
var button_size := "Médios"
var hints := true
## Modo controle: some os botões de toque e aparecem, discretos, os botões do
## controle (do jeito do controle ligado: PlayStation, Xbox, Nintendo...).
var controller_mode := false
## No modo controle: mostrar a legenda dos botões? false = modo
## LIMPO (nada de botão na tela; a tela fica só com o jogo).
var pad_legend := true
## Desenho dos botões do controle: "auto" (descobre pelo nome do controle) ou
## uma família forçada ("playstation", "xbox", "nintendo", "generico").
var pad_style := "auto"
const PAD_STYLES: Array[String] = ["auto", "playstation", "xbox", "nintendo", "generico"]
## Testes e o passeio de fotos não gravam opções no aparelho.
var persistence_enabled := true

var _loaded_from_file := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_buses()
	load_settings()
	apply()


## Cria os barramentos de áudio por código (o projeto fica 100% em texto).
func _ensure_buses() -> void:
	for bus in [SFX_BUS, AMBIENCE_BUS]:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			var index := AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus)
			AudioServer.set_bus_send(index, &"Master")


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	_loaded_from_file = true
	sfx_volume = clampf(float(config.get_value("audio", "efeitos", sfx_volume)), 0.0, 1.0)
	ambience_volume = clampf(float(config.get_value("audio", "ambiente", ambience_volume)), 0.0, 1.0)
	vibration = bool(config.get_value("toque", "vibracao", vibration))
	var size := str(config.get_value("toque", "botoes", button_size))
	button_size = size if BUTTON_SIZES.has(size) else "Médios"
	hints = bool(config.get_value("jogo", "dicas", hints))
	controller_mode = bool(config.get_value("toque", "modo_controle", controller_mode))
	pad_legend = bool(config.get_value("toque", "legenda_controle", pad_legend))
	var style := str(config.get_value("toque", "estilo_botoes", pad_style))
	pad_style = style if PAD_STYLES.has(style) else "auto"


func save_settings() -> void:
	if not persistence_enabled:
		return
	var config := ConfigFile.new()
	config.set_value("audio", "efeitos", sfx_volume)
	config.set_value("audio", "ambiente", ambience_volume)
	config.set_value("toque", "vibracao", vibration)
	config.set_value("toque", "botoes", button_size)
	config.set_value("jogo", "dicas", hints)
	config.set_value("toque", "modo_controle", controller_mode)
	config.set_value("toque", "legenda_controle", pad_legend)
	config.set_value("toque", "estilo_botoes", pad_style)
	config.save(PATH)
	_loaded_from_file = true


## Saves antigos guardavam a vibração no save do jogo: vale só se o aparelho
## ainda não tem um arquivo de opções (migração de uma vez).
func import_legacy_vibration(value: bool) -> void:
	if not _loaded_from_file:
		vibration = value


func apply() -> void:
	_set_bus_volume(SFX_BUS, sfx_volume)
	_set_bus_volume(AMBIENCE_BUS, ambience_volume)
	changed.emit()


func _set_bus_volume(bus: StringName, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index == -1:
		return
	AudioServer.set_bus_mute(index, linear <= 0.001)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.001)))


## Aparelho de toque? (celular pelo APK OU celular pelo navegador). No
## navegador o Godot não liga o "mobile": ele avisa com "web_android"/"web_ios".
static func is_touch_device() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")


func button_scale() -> float:
	return BUTTON_SIZES.get(button_size, 1.0)


# --- Mudanças (o menu chama estas; cada uma aplica e grava) ---------------------------

func step_sfx(delta: float) -> void:
	sfx_volume = snappedf(clampf(sfx_volume + delta, 0.0, 1.0), 0.1)
	_commit()


func step_ambience(delta: float) -> void:
	ambience_volume = snappedf(clampf(ambience_volume + delta, 0.0, 1.0), 0.1)
	_commit()


func toggle_vibration() -> void:
	vibration = not vibration
	_commit()


func toggle_controller_mode() -> void:
	controller_mode = not controller_mode
	_commit()


## Os 3 jeitos de jogar, em ciclo: Toque → Controle (com legenda) → Limpo → Toque.
## Limpo = controle SEM legenda: a tela mostra só o jogo (e a barra de vida).
func cycle_controls() -> void:
	match controls_mode():
		"toque":
			controller_mode = true
			pad_legend = true
		"controle":
			controller_mode = true
			pad_legend = false
		_:
			controller_mode = false
			pad_legend = true
	_commit()


func controls_mode() -> String:
	if not controller_mode:
		return "toque"
	return "controle" if pad_legend else "limpo"


## Automático → PlayStation → Xbox → Nintendo → Genérico → Automático.
func cycle_pad_style() -> void:
	pad_style = PAD_STYLES[(PAD_STYLES.find(pad_style) + 1) % PAD_STYLES.size()]
	_commit()


func toggle_hints() -> void:
	hints = not hints
	_commit()


func cycle_button_size() -> void:
	var names := BUTTON_SIZES.keys()
	button_size = names[(names.find(button_size) + 1) % names.size()]
	_commit()


func _commit() -> void:
	apply()
	save_settings()

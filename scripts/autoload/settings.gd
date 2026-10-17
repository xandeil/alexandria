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


func save_settings() -> void:
	if not persistence_enabled:
		return
	var config := ConfigFile.new()
	config.set_value("audio", "efeitos", sfx_volume)
	config.set_value("audio", "ambiente", ambience_volume)
	config.set_value("toque", "vibracao", vibration)
	config.set_value("toque", "botoes", button_size)
	config.set_value("jogo", "dicas", hints)
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

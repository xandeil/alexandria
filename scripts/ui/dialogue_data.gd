class_name DialogueData
## Lê data/dialogos.json uma vez e entrega as falas por id.
## Texto fica FORA do código: você escreve a história sem tocar em script.

const PATH := "res://data/dialogos.json"

static var _entries: Dictionary = {}


static func get_entry(id: String) -> Dictionary:
	if _entries.is_empty():
		_load()
	var entry: Variant = _entries.get(id, {})
	return entry if entry is Dictionary else {}


static func _load() -> void:
	if not FileAccess.file_exists(PATH):
		push_error("Arquivo de falas não encontrado: %s" % PATH)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary:
		_entries = parsed
	else:
		push_error("data/dialogos.json inválido (confira vírgulas e aspas).")

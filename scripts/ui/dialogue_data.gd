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


## Qual fala usar de verdade (v0.31). Uma entrada pode trazer as suas variantes:
##   "ferreiro": {"falas": [...], "variantes": [
##       {"quando": "chefe:durgan", "usar": "ferreiro_irmao"}, ...]}
## A primeira cuja condição valer (Game.requirement_met) ganha. Sem nenhuma, a própria.
static func variant(id: String) -> String:
	var entry := get_entry(id)
	for rule: Variant in entry.get("variantes", []):
		if rule is Dictionary and Game.requirement_met(str((rule as Dictionary).get("quando", ""))):
			var target := str((rule as Dictionary).get("usar", id))
			return target if target == id else variant(target)
	return id


## Troca os marcadores do texto: "{nome}" vira o nome do herói.
static func fill(text: String) -> String:
	return text.replace("{nome}", Game.spoken_name())


static func _load() -> void:
	if not FileAccess.file_exists(PATH):
		push_error("Arquivo de falas não encontrado: %s" % PATH)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary:
		_entries = parsed
	else:
		push_error("data/dialogos.json inválido (confira vírgulas e aspas).")

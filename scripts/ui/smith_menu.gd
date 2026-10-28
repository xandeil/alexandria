class_name SmithMenu
extends SoulsMenu
## A Forja do Ferreiro Anão, no mesmo estilo do inventário (SoulsMenu):
##   REFORÇAR — memórias + Sucata Temperada → +1 em TODAS as armas;
##   FORJAR   — a Lembrança de um Pecado vira a arma dele (a Lembrança NÃO é
##              gasta: ela abre o Núcleo). A espada inicial e as já forjadas
##              ganham CÓPIA, para usar uma em cada mão.
##
## Como a loja, o menu não sabe regra nenhuma: custos, tetos e motivos vêm do
## Game (next_upgrade_cost, upgrade_block_reason, forge_block_reason...).

const ICON_MEMORY := preload("res://assets/ui/icon_memory.png")
const ICON_SUCATA := preload("res://assets/items/sucata_temperada.png")

## O que o Ferreiro diz quando não dá para reforçar.
const REASONS := {
	"cap": "\"Daqui pra frente, só com as mãos de quem martelava comigo. Não lembro dele.\"",
	"max": "\"Não há mais o que tirar desse aço.\"",
	"memories": "Faltam memórias.",
	"sucata": "Falta Sucata Temperada (inimigos e o Vendedor).",
}
## ...e quando não dá para forjar.
const FORGE_REASONS := {
	"owned": "\"Você já tem duas. Mão tem só duas também.\"",
	"lembranca": "\"Sem a Lembrança dele, isso é só ferro. Traga a alma, eu dou a forma.\"",
	"basica": "\"Arma comum eu não invento: traga uma, que eu faço a outra.\"",
	"memories": "Faltam memórias.",
	"sucata": "Falta Sucata Temperada.",
}


func _init() -> void:
	accent = Color(0.95, 0.55, 0.2)
	keeper_name = "Ferreiro Anão"
	keeper_line = "\"Segura firme. Vai doer menos em você do que nele.\""
	portrait_texture = preload("res://assets/sprites/npc_ferreiro.png")


func _tabs() -> Array[String]:
	return ["Reforçar", "Forjar"]


func _entries(tab_index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if tab_index == 0:
		for id in Game.owned_weapons():
			if id == Game.FISTS:
				continue  # punho não se reforça no fogo
			result.append({"id": id, "icon": Items.get_item(id).icon, "corner": "+%d" % Game.weapon_level})
	else:
		for id in Game.smith_weapons():
			var known := Game.forge_block_reason(id) != "lembranca" or Game.owns_weapon(id)
			var count := Game.weapon_count(id)
			result.append({"id": id, "icon": Items.get_item(id).icon, "dim": not known,
				"corner": "x%d" % count if count > 0 else ""})
	return result


func _show_detail(id: String) -> void:
	var weapon := Items.get_weapon(id)
	if _tab == 0:
		_show_upgrade(weapon)
	else:
		_show_forge(weapon)


func _show_upgrade(weapon: WeaponData) -> void:
	var level := Game.weapon_level
	detail_icon.texture = weapon.icon
	detail_name.text = "%s +%d" % [weapon.display_name, level]
	detail_kind.text = "Reforço: vale para TODAS as suas armas"
	var power := Game.weapon_power(weapon)
	detail_stats.text = "Ataque  %d / %d\n%s" % [power.x, power.y, _pips(level)]
	detail_text.text = ""
	var reason := Game.upgrade_block_reason()
	var cost := Game.next_upgrade_cost()
	if not cost.is_empty() and reason != "cap":
		var after := int(round(Game.WEAPON_DAMAGE_PER_LEVEL * (level + 1) * 100.0))
		detail_text.text = "Dano +%d%%  →  +%d%%" % [int(round((Game.weapon_damage_multiplier() - 1.0) * 100.0)), after]
		add_cost_line(ICON_MEMORY, "%d memórias (tem %d)" % [int(cost["memories"]), Game.memories], Game.memories >= int(cost["memories"]))
		var sucata := int(cost["sucata_temperada"])
		add_cost_line(ICON_SUCATA, "%d Sucata Temperada (tem %d)" % [sucata, Game.item_count("sucata_temperada")],
			Game.has_item("sucata_temperada", sucata))
	detail_status.text = REASONS.get(reason, PadStyle.text("{cross} para reforçar.") if Settings.controller_mode else "Confirme para reforçar.")


## "◆◆◆◇◇": o nível do reforço em pedrinhas (até onde ele sabe ir hoje).
func _pips(level: int) -> String:
	var text := ""
	for i in Game.WEAPON_UPGRADES.size():
		text += "◆" if i < level else "◇"
	return text


func _show_forge(weapon: WeaponData) -> void:
	var reason := Game.forge_block_reason(weapon.id)
	var copy := Game.owns_weapon(weapon.id)
	var known := reason != "lembranca" or copy  # sem a Lembrança, a arma é um mistério
	detail_icon.texture = weapon.icon
	detail_name.text = (weapon.display_name + (" (cópia)" if copy else "")) if known else "???"
	detail_kind.text = weapon.weapon_class if known else "Uma forma que o aço ainda não conhece"
	detail_stats.text = "Você tem: %d de 2\n(uma para cada mão)" % Game.weapon_count(weapon.id)
	if known:
		add_scaling_table(weapon)
		detail_text.text = "%s — %s" % [weapon.skill_name, weapon.skill_text] if not weapon.skill_name.is_empty() else weapon.description
	else:
		detail_text.text = ""
	if not weapon.memory_item.is_empty():
		var memory := Items.get_item(weapon.memory_item)
		add_cost_line(memory.icon, "%s (não é gasta)" % memory.display_name, Game.has_item(weapon.memory_item))
	add_cost_line(ICON_MEMORY, "%d memórias" % weapon.forge_memories, Game.memories >= weapon.forge_memories)
	if weapon.forge_sucata > 0:
		add_cost_line(ICON_SUCATA, "%d Sucata Temperada" % weapon.forge_sucata, Game.has_item("sucata_temperada", weapon.forge_sucata))
	var action := PadStyle.text("{cross} para forjar") if Settings.controller_mode else "Confirme para forjar"
	detail_status.text = FORGE_REASONS.get(reason, "%s%s." % [action, " a cópia" if copy else ""])


func _activate(id: String) -> void:
	if _tab == 0:
		upgrade()
	else:
		forge(id)


## Reforça (+1 em todas as armas). Devolve se deu certo.
func upgrade() -> bool:
	var keep := selected()
	if not Game.try_upgrade_weapon():
		Sfx.play(&"ui_click")
		return false
	Sfx.play(&"forge")
	_line.text = "\"Ouviu? O aço respondeu.\""
	_selected = ""
	refresh()
	flash_slot(keep)
	return true


func forge(id: String) -> bool:
	if not Game.try_forge_weapon(id):
		Sfx.play(&"ui_click")
		return false
	Sfx.play(&"forge")
	Fx.vibrate(40)
	_line.text = "\"A Lembrança fica com você. Eu só copio a raiva dela no aço.\""
	_selected = ""
	refresh()
	flash_slot(id)
	return true


func _hint_items() -> Array:
	return [["cross", "Enter", "Reforçar" if _tab == 0 else "Forjar"], ["circle", "Esc", "Sair"], ["L1/R1", "Q/E", "Reforçar/Forjar"]]

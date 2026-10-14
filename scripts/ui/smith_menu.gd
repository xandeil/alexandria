class_name SmithMenu
extends CanvasLayer
## A forja do Ferreiro Anão: memórias + Sucata Temperada → espada mais forte.
##
## O menu NÃO sabe as regras (custos, teto de nível): pergunta tudo ao Game
## (next_upgrade_cost, upgrade_block_reason). UI que só mostra e repassa
## cliques é fácil de trocar por arte final sem quebrar o balanceamento.

signal _closed

## O que o Ferreiro diz quando não dá para melhorar (motivo vem do Game).
const REASONS := {
	"cap": "\"Daqui pra frente, só com as mãos de quem martelava comigo. Não lembro dele.\"",
	"max": "\"Não há mais o que tirar desse aço.\"",
	"memories": "Faltam memórias.",
	"sucata": "Falta Sucata Temperada (inimigos da Cidade e o Vendedor).",
}

var _player: Player
var _weapon_label: Label
var _damage_label: Label
var _cost_label: Label
var _reason_label: Label
var _upgrade_button: Button
var _close_button: Button
var _icon: TextureRect


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UIStyle.panel_style())
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -140
	panel.offset_right = 140
	panel.offset_top = -82
	panel.offset_bottom = 82
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var title := UIStyle.label("A Forja", 12, UIStyle.GOLD, UIStyle.TITLE_FONT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_icon = TextureRect.new()
	_icon.texture = Items.get_item("espada").icon
	_icon.custom_minimum_size = Vector2(24, 24)
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	row.add_child(_icon)
	_weapon_label = UIStyle.label("", 11, UIStyle.TEXT, UIStyle.FONT_BOLD)
	row.add_child(_weapon_label)
	box.add_child(row)
	_damage_label = UIStyle.label("", 9, UIStyle.TEXT, UIStyle.FONT_NUMBERS)
	_damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_damage_label)
	_cost_label = UIStyle.label("", 9, UIStyle.TEXT_DIM, UIStyle.FONT_NUMBERS)
	_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_cost_label)
	_reason_label = UIStyle.label("", 8, UIStyle.TEXT_DIM)
	_reason_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reason_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reason_label.custom_minimum_size = Vector2(250, 0)
	box.add_child(_reason_label)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 8)
	_upgrade_button = UIStyle.button("Melhorar", 10)
	_upgrade_button.custom_minimum_size = Vector2(90, 20)
	_upgrade_button.pressed.connect(_upgrade)
	buttons.add_child(_upgrade_button)
	_close_button = UIStyle.button("Sair", 10)
	_close_button.custom_minimum_size = Vector2(60, 20)
	_close_button.pressed.connect(func():
		Sfx.play(&"ui_click")
		_closed.emit())
	buttons.add_child(_close_button)
	box.add_child(buttons)
	visible = false


func run(player: Player) -> void:
	_player = player
	_refresh()
	visible = true
	UIStyle.focus_first([_upgrade_button], _close_button)
	Sfx.play(&"ui_open")
	await _closed
	visible = false


func _upgrade() -> void:
	if not Game.try_upgrade_weapon():
		Sfx.play(&"ui_click")
		_refresh()
		return
	Sfx.play(&"forge")
	# A bigorna "responde": o ícone pisca dourado.
	var tween := create_tween()
	_icon.modulate = Color(2.0, 1.6, 0.8)
	tween.tween_property(_icon, "modulate", Color.WHITE, 0.4)
	_refresh()
	if _upgrade_button.disabled:
		_close_button.grab_focus()


func _refresh() -> void:
	var level := Game.weapon_level
	_weapon_label.text = "%s +%d" % [Items.display_name("espada"), level]
	var now := int(round((Game.weapon_damage_multiplier() - 1.0) * 100.0))
	var reason := Game.upgrade_block_reason()
	var cost := Game.next_upgrade_cost()
	if cost.is_empty() or reason == "cap":
		_damage_label.text = "Dano +%d%%" % now
		_cost_label.text = ""
	else:
		var after := int(round(Game.WEAPON_DAMAGE_PER_LEVEL * (level + 1) * 100.0))
		_damage_label.text = "Dano +%d%%  ->  +%d%%" % [now, after]
		_cost_label.text = "Custo: %d memórias (tem %d)  ·  %d sucata (tem %d)" % [
			int(cost["memories"]), Game.memories,
			int(cost["sucata_temperada"]), Game.item_count("sucata_temperada")]
	_reason_label.text = REASONS.get(reason, "\"Segura firme. Vai doer menos em você do que nele.\"")
	_upgrade_button.disabled = reason != ""

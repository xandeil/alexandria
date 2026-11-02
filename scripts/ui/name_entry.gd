class_name NameEntry
extends Control
## TELA DE DIGITAR O NOME (v0.41, Etapa 5). O herói acorda sem nome: ele só
## ganha um quando a Governanta pergunta. O nome é OBRIGATÓRIO aqui.
##
## Funciona dos três jeitos:
##   • teclado físico: digite direto no campo;
##   • celular: tocar no campo abre o teclado virtual do aparelho;
##   • controle: a grade de letras embaixo (↑↓←→ e ✕), com "Apagar" e "Pronto".
##
## Uso:  var nome: String = await hud.name_entry.run("QUAL É O SEU NOME?")
## O texto da pergunta é ESCRITO (não é dublado): a fala dublada fica no
## diálogo antes. Nenhum personagem diz o nome em voz alta.

signal submitted(text: String)

const MAX_LENGTH := 14
const LETTERS := [
	"A", "B", "C", "D", "E", "F", "G", "H", "I",
	"J", "K", "L", "M", "N", "O", "P", "Q", "R",
	"S", "T", "U", "V", "W", "X", "Y", "Z", "Ç",
	"Á", "É", "Í", "Ó", "Ú", "Ã", "Õ", "Â", "Ê",
]

var field: LineEdit
var _prompt: Label
var _done: Button
var _grid: GridContainer
var _lower := false
var _shift: Button


func _ready() -> void:
	add_to_group(&"pad_menu")
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build()


func _build() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -170
	box.offset_right = 170
	box.offset_top = -110
	box.offset_bottom = 110
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	_prompt = UIStyle.label("", 14, Color(0.92, 0.9, 0.86), UIStyle.TITLE_FONT)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_prompt)
	field = LineEdit.new()
	field.max_length = MAX_LENGTH
	field.alignment = HORIZONTAL_ALIGNMENT_CENTER
	field.placeholder_text = "???"
	field.virtual_keyboard_enabled = true
	field.add_theme_font_override("font", UIStyle.FONT)
	field.add_theme_font_size_override("font_size", 14)
	field.text_changed.connect(func(_t: String): _refresh())
	field.text_submitted.connect(func(_t: String): confirm())
	box.add_child(field)
	_grid = GridContainer.new()
	_grid.columns = 9
	_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_grid.add_theme_constant_override("h_separation", 2)
	_grid.add_theme_constant_override("v_separation", 2)
	box.add_child(_grid)
	for letter: String in LETTERS:
		var key := UIStyle.button(letter, 10)
		key.custom_minimum_size = Vector2(34, 18)
		key.pressed.connect(func(): type_letter(key.text))
		_grid.add_child(key)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	box.add_child(row)
	_shift = UIStyle.button("abc", 10)
	_shift.pressed.connect(toggle_case)
	row.add_child(_shift)
	var space := UIStyle.button("Espaço", 10)
	space.pressed.connect(func(): type_letter(" "))
	row.add_child(space)
	var erase := UIStyle.button("Apagar", 10)
	erase.pressed.connect(backspace)
	row.add_child(erase)
	_done = UIStyle.button("Pronto", 11)
	_done.pressed.connect(confirm)
	row.add_child(_done)


## Pergunta e espera. Só volta com um nome de verdade (não vazio).
func run(prompt: String) -> String:
	_prompt.text = prompt
	field.text = ""
	_refresh()
	visible = true
	Sfx.play(&"ui_open")
	(_grid.get_child(0) as Control).grab_focus()
	var result: String = await submitted
	visible = false
	return result


func type_letter(letter: String) -> void:
	if field.text.length() >= MAX_LENGTH:
		return
	if letter == " " and (field.text.is_empty() or field.text.ends_with(" ")):
		return
	field.text += letter
	field.caret_column = field.text.length()
	Sfx.play(&"ui_click")
	_refresh()


func backspace() -> void:
	field.text = field.text.left(field.text.length() - 1)
	field.caret_column = field.text.length()
	_refresh()


## Maiúsculas ↔ minúsculas na grade (para quem joga de controle).
func toggle_case() -> void:
	_lower = not _lower
	for key in _grid.get_children():
		var button := key as Button
		button.text = button.text.to_lower() if _lower else button.text.to_upper()
	_shift.text = "ABC" if _lower else "abc"


## O nome limpo: sem espaços nas pontas nem espaços repetidos.
static func clean(text: String) -> String:
	var parts := text.strip_edges().split(" ", false)
	return " ".join(parts).left(MAX_LENGTH)


func confirm() -> void:
	var name_text := clean(field.text)
	if name_text.is_empty():
		Sfx.play(&"ui_click")
		return  # obrigatório: sem nome, não sai daqui
	Sfx.play(&"ui_open")
	submitted.emit(name_text)


func _refresh() -> void:
	if _done:
		_done.disabled = clean(field.text).is_empty()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	# ○ apaga (não fecha: o nome é obrigatório).
	if event.is_action_pressed(&"ui_cancel"):
		backspace()
		get_viewport().set_input_as_handled()

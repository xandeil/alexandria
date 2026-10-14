@tool
class_name Level
extends Node2D
## Monta uma área a partir de um MAPA EM TEXTO (levels/*.txt).
##
## Cada caractere do .txt vira um tile, um objeto ou um personagem — dá para
## redesenhar o Teatro num editor de texto qualquer. Com @tool, o mapa também
## aparece no editor do Godot ao abrir a cena (marque "Rebuild" para atualizar).
##
## Legenda (veja também levels/LEGENDA.md):
##   #  parede        n  parede com arco    |  cortina        (espaço) vazio/céu
##   .  piso          ,  tapete/calçada     { } tapete vermelho do corredor
##   =  palco/faixa   -  borda do palco     _  soleira        :  piso escuro
##   k  piso c/ lascas ~ rachadura em brasa ;  entulho        g  terra/grama
##   r R t  poltronas (vermelha, quebrada, bege)   T  tocha   I  pilar
##   C  Câmara (descanso)   D  saída para outra área    P  início
##   H  Helena (plateia)    Y  ponto onde o chefe aterrissa   M  névoa da arena
##   F  Fada   V  Vendedor   A  Ferreiro   O  Orbe Branco   B  boneco   W  armas
##   S  Soldado Remendado   X  barricada  x  entulho   f  fogo   L  poste
##   c  caixote   K  carro destruído   G  portão do Aldir   e  borda (inspecionar)
##   Z  Aldir Cornélios (ajoelhado)    Q  cobertura de concreto destrutível
##   Laboratório (Prólogo): a o q  cápsulas (ocupada, vazia, quebrada)   l  terminal
##   b  caminha   u  brinquedos   p  planta   i  cabos   m  mesa comprida
##   % & $ j  na parede: riscos de giz, desenho, luz verde, trepadeira
##   *  criança   +  adolescente   J  a Criança Poupada (Teatro)
##   1–9  ponto de inspeção (o texto vem de lore_points, no Inspector)
##   Cidade: d  Cão de Guerra   y  Atirador de Telhado   v  Civil Cinzento
##   Mini-chefes: h  Sargento Sem Pelotão   w  Couraça Andante
##   @  item no chão (qual item: item_points, no Inspector, na ordem de leitura)
##   >  segunda saída (exit2_scene / exit2_spawn) — no Teatro, a porta do Bosque
##   Bosque: ~ lago (sólido)  ( árvore  ) arbusto  [ tronco caído  ] soldado dormindo em pé
##           < cachoeira (na borda da ilha)   z Sonâmbulo  s Flor de Pólen
##           ^ Cervo de Musgo  ? Fada Murcha   U Vigia que Dormiu  0 Mãe dos Esporos
##           /  Nyssa Lumevel, deitada no ar (Clareira de Nyssa)
##   '  terceira saída (exit3_scene / exit3_spawn) — no Teatro, a porta das Raízes
##   Raízes da Fome (MESMOS caracteres do Bosque, outro significado — veja
##   THEME_ENTITIES/THEME_PROPS): ~ poça de seiva  ( raiz retorcida  ) fruto de carne
##           [ canteiro da estufa  ] fogão   z Boca de Raiz  s Inchado  ^ Colhedor
##           ? Larvas de Seiva (enxame de 3)  U O Banqueteiro  0 A Ninhada  / Mabel

const TILE := 16
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const SOLDIER_SCENE := preload("res://scenes/enemies/soldado_remendado.tscn")
const CHILD_SCENE := preload("res://scenes/enemies/crianca.tscn")
const DOG_SCENE := preload("res://scenes/enemies/cao_de_guerra.tscn")
const SNIPER_SCENE := preload("res://scenes/enemies/atirador.tscn")
const CIVIL_SCENE := preload("res://scenes/enemies/civil_cinzento.tscn")
const SLEEPER_SCENE := preload("res://scenes/enemies/sonambulo.tscn")
const FLOWER_SCENE := preload("res://scenes/enemies/flor_polen.tscn")
const DEER_SCENE := preload("res://scenes/enemies/cervo.tscn")
const WITHER_SCENE := preload("res://scenes/enemies/fada_murcha.tscn")
const WATERFALL_TEXTURE := preload("res://assets/props/waterfall.png")
## O ASCII acabou: cada ILHA pode dar outro significado ao mesmo caractere.
## Ex.: no Bosque "z" é o Sonâmbulo; nas Raízes é a Boca de Raiz. O tema da fase
## decide (o mapa continua legível e o código não precisa de 1 letra por inimigo).
const THEME_ENTITIES := {
	"raizes": {
		"z": {"enemy": preload("res://scenes/enemies/boca_de_raiz.tscn")},
		"s": {"enemy": preload("res://scenes/enemies/inchado.tscn")},
		"^": {"enemy": preload("res://scenes/enemies/colhedor.tscn")},
		"?": {"enemy": preload("res://scenes/enemies/larva_seiva.tscn"), "swarm": 3},
		"U": {"miniboss": "banqueteiro", "scene": preload("res://scenes/bosses/banqueteiro.tscn")},
		"0": {"miniboss": "ninhada", "scene": preload("res://scenes/bosses/ninhada.tscn")},
		"/": {"boss": preload("res://scenes/bosses/mabel.tscn"), "memorial": {"dialogue": "mesa_de_mabel",
			"name": "Mesa posta", "texture": "res://assets/props/mabel_table.png"}},
	},
}
## Cenário próprio de cada ilha (mesma ideia): sobrepõe PROPS.
const THEME_PROPS := {
	"raizes": {
		"(": {"tex": "res://assets/props/root_tangle.png", "box": Vector2(14, 7)},
		")": {"tex": "res://assets/props/flesh_pod.png", "frames": 2, "fps": 1.6},
		"[": {"tex": "res://assets/props/planter.png", "box": Vector2(28, 8), "dx": 8},
		"]": {"tex": "res://assets/props/stove.png", "box": Vector2(14, 8),
			"light": [Color(1.0, 0.45, 0.25), 0.6, 0.6, Vector2(0, -8)]},
	},
}
## Mini-chefes do mapa: caractere → [id na ficha BossData, cena].
const MINIBOSSES := {
	"h": ["sargento", preload("res://scenes/bosses/sargento.tscn")],
	"w": ["couraca", preload("res://scenes/bosses/couraca.tscn")],
	"U": ["vigia", preload("res://scenes/bosses/vigia.tscn")],
	"0": ["mae_esporos", preload("res://scenes/bosses/mae_esporos.tscn")],
}
const HELENA_SCENE := preload("res://scenes/bosses/helena_altiva.tscn")
const ALDIR_SCENE := preload("res://scenes/bosses/aldir_cornelios.tscn")
const ALDIR_ARENA := "res://scenes/world/arena_aldir.tscn"
const NYSSA_SCENE := preload("res://scenes/bosses/nyssa.tscn")
const NPC_SCENE := preload("res://scenes/world/npc.tscn")
const REST_SCENE := preload("res://scenes/world/rest_chamber.tscn")
const DUMMY_SCENE := preload("res://scenes/world/training_dummy.tscn")
const FOG_SCENE := preload("res://scenes/world/fog_wall.tscn")
const EXIT_SCENE := preload("res://scenes/world/area_exit.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const LIGHT_TEXTURE := preload("res://assets/fx/light.png")

const FLOOR_CHARS := ".,{}=-_:k~;g<"
## Personagens/objetos ficam por cima do piso "vizinho mais comum".
const ENTITY_CHARS := "rRtTICDPHYMFVAOBWSXxfLcKGeZQaoqlbupim%&$j*+NEJ!123456789dyvhw@>()[]zs^?U0/'"
## Falas da Criança Poupada, uma por conversa (dicas para quem não feriu ninguém).
const SPARED_CHILD_TALKS := "crianca_poupada_1,crianca_poupada_2,crianca_poupada_3,crianca_poupada_4,crianca_poupada_5,crianca_poupada_6"

const THEMES := {
	"teatro": {
		"floor": {
			".": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
			",": [Vector2i(4, 0), Vector2i(4, 0), Vector2i(4, 0), Vector2i(5, 0)],
			"{": [Vector2i(6, 0)], "}": [Vector2i(7, 0)],
			"=": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(3, 1)],
			"-": [Vector2i(2, 1)], "_": [Vector2i(4, 2)], ":": [Vector2i(5, 2)], "k": [Vector2i(3, 0)],
		},
		"default_floor": ".",
		"wall_top": Vector2i(4, 1),
		"wall_face": [Vector2i(5, 1), Vector2i(5, 1), Vector2i(5, 1), Vector2i(7, 1)],
		"arch": Vector2i(6, 1),
		"curtain": [Vector2i(0, 2), Vector2i(2, 2)],
		"curtain_hem": Vector2i(1, 2),
		"barrier": Vector2i(3, 2),
	},
	"cidade": {
		"floor": {
			".": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
			"~": [Vector2i(3, 0)], "=": [Vector2i(7, 1)],
			",": [Vector2i(4, 0), Vector2i(5, 0)], ";": [Vector2i(6, 0)], "g": [Vector2i(7, 0)],
			"_": [Vector2i(5, 0)], "k": [Vector2i(6, 0)],
		},
		"default_floor": ".",
		"wall_top": Vector2i(0, 1),
		"wall_face": [Vector2i(1, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
		"arch": Vector2i(3, 1),
		"cliff": Vector2i(4, 1),
		"cliff_low": Vector2i(5, 1),
		"barrier": Vector2i(6, 1),
	},
	"bosque": {
		"floor": {
			".": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
			",": [Vector2i(2, 0), Vector2i(2, 0), Vector2i(0, 0)],
			":": [Vector2i(3, 0), Vector2i(3, 2)], ";": [Vector2i(4, 0)], "k": [Vector2i(5, 0)],
			"=": [Vector2i(6, 0)], "g": [Vector2i(7, 0)], "_": [Vector2i(2, 2)],
		},
		"default_floor": ".",
		"wall_top": Vector2i(0, 1),
		"wall_face": [Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 1)],
		"arch": Vector2i(3, 1),
		"cliff": Vector2i(4, 1),
		"cliff_low": Vector2i(5, 1),
		"barrier": Vector2i(6, 1),
		# Chão SÓLIDO (vai na camada de paredes, com colisão): o lago parado.
		"solid": {"~": [Vector2i(7, 1), Vector2i(7, 1), Vector2i(0, 2)]},
		# Água encostada em terra por cima: a margem de grama.
		"shore": Vector2i(1, 2),
		# A mata fechada chega até a borda da ilha: penhasco embaixo dela também.
		"cliff_under_walls": true,
	},
	"raizes": {
		"floor": {
			".": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
			",": [Vector2i(3, 0), Vector2i(3, 0), Vector2i(2, 2)],
			":": [Vector2i(4, 0), Vector2i(4, 2)], ";": [Vector2i(5, 0), Vector2i(5, 2)],
			"=": [Vector2i(6, 0)], "k": [Vector2i(7, 0)], "g": [Vector2i(3, 2)], "_": [Vector2i(6, 0)],
		},
		"default_floor": ".",
		"wall_top": Vector2i(0, 1),
		"wall_face": [Vector2i(1, 1), Vector2i(1, 1), Vector2i(2, 1)],
		"arch": Vector2i(3, 1),
		"cliff": Vector2i(4, 1),
		"cliff_low": Vector2i(5, 1),
		"barrier": Vector2i(6, 1),
		# Poças de seiva vermelha: sólidas, como o lago do Bosque.
		"solid": {"~": [Vector2i(7, 1), Vector2i(7, 1), Vector2i(0, 2)]},
		"shore": Vector2i(1, 2),
		"cliff_under_walls": true,
	},
	"laboratorio": {
		"floor": {
			".": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(1, 0)],
			",": [Vector2i(2, 2)], "k": [Vector2i(2, 0)], "~": [Vector2i(3, 0)], ";": [Vector2i(4, 0)],
			":": [Vector2i(5, 0)], "=": [Vector2i(6, 0), Vector2i(3, 2), Vector2i(7, 0), Vector2i(4, 2)],
			"-": [Vector2i(0, 2)], "_": [Vector2i(1, 2)],
		},
		"default_floor": ".",
		"wall_top": Vector2i(0, 1),
		"wall_face": [Vector2i(1, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 1), Vector2i(3, 1), Vector2i(7, 1), Vector2i(4, 1)],
		"arch": Vector2i(5, 1),
		"barrier": Vector2i(6, 1),
	},
}

## Objetos de cenário simples, montados por código: textura, quadros, colisão.
const PROPS := {
	"r": {"tex": "res://assets/props/seat_red.png", "box": Vector2(12, 6)},
	"R": {"tex": "res://assets/props/seat_red_broken.png", "box": Vector2(12, 6)},
	"t": {"tex": "res://assets/props/seat_tan.png", "box": Vector2(12, 6)},
	"I": {"tex": "res://assets/props/pillar.png", "box": Vector2(12, 8)},
	"W": {"tex": "res://assets/props/weapon_rack.png", "box": Vector2(10, 6)},
	"X": {"tex": "res://assets/props/barricade.png", "box": Vector2(26, 8)},
	"x": {"tex": "res://assets/props/rubble.png"},
	"c": {"tex": "res://assets/props/crate.png", "box": Vector2(12, 8)},
	"K": {"tex": "res://assets/props/car_wreck.png", "box": Vector2(28, 10)},
	"L": {"tex": "res://assets/props/lamp_post.png", "box": Vector2(6, 4), "light": [Color(1.0, 0.7, 0.35), 0.6, 0.9, Vector2(4, -34)]},
	"f": {"tex": "res://assets/props/fire.png", "frames": 4, "fps": 9.0, "box": Vector2(12, 6), "light": [Color(1.0, 0.55, 0.2), 1.0, 1.2, Vector2(0, -8)]},
	"T": {"tex": "res://assets/props/torch.png", "frames": 3, "fps": 8.0, "light": [Color(1.0, 0.72, 0.35), 0.9, 1.0, Vector2(0, -10)], "dy": 2, "wall": true},
	# Laboratório do Prólogo. "dx": 8 = ocupa 2 células para a direita (como a Câmara).
	"a": {"tex": "res://assets/props/capsule_occupied.png", "box": Vector2(26, 9), "dx": 8},
	"o": {"tex": "res://assets/props/capsule_empty.png", "box": Vector2(26, 9), "dx": 8},
	"q": {"tex": "res://assets/props/capsule_broken.png", "box": Vector2(26, 9), "dx": 8},
	"l": {"tex": "res://assets/props/terminal.png", "box": Vector2(12, 7), "light": [Color(0.45, 0.95, 0.6), 0.6, 0.45, Vector2(0, -14)]},
	"b": {"tex": "res://assets/props/cot.png", "box": Vector2(12, 14)},
	"u": {"tex": "res://assets/props/toys.png"},
	"p": {"tex": "res://assets/props/plant.png"},
	"i": {"tex": "res://assets/props/cables.png"},
	"m": {"tex": "res://assets/props/long_table.png", "box": Vector2(34, 74), "dx": 8},
	# "wall": true = desenhado POR CIMA de uma parede (a célula continua sólida).
	"%": {"tex": "res://assets/props/lab_tally.png", "wall": true},
	"&": {"tex": "res://assets/props/lab_drawing.png", "wall": true},
	"$": {"tex": "res://assets/props/lab_lamp.png", "wall": true, "light": [Color(0.4, 0.95, 0.55), 0.9, 0.9, Vector2(0, -8)]},
	"j": {"tex": "res://assets/props/lab_vines.png", "wall": true},
	# Bosque do Sono Eterno.
	"(": {"tex": "res://assets/props/tree.png", "box": Vector2(10, 6)},
	")": {"tex": "res://assets/props/bush.png"},
	"[": {"tex": "res://assets/props/log.png", "box": Vector2(30, 8), "dx": 8},
	"]": {"tex": "res://assets/props/sleeping_soldier.png", "box": Vector2(12, 6)},
}

@export_file("*.txt") var layout_file := ""
@export var area_name := ""
@export var area_subtitle := ""
@export_enum("teatro", "cidade", "laboratorio", "bosque", "raizes") var theme := "teatro"
@export var ambience: StringName = &"amb_theater"
## Cor geral da área (CanvasModulate). Mais escuro = as tochas brilham mais.
@export var darkness := Color(1, 1, 1)
## Área a céu aberto: desenha o céu e as nuvens passando por baixo da ilha.
@export var outdoor := false
## Arena do chefe em TILES (x, y, largura, altura).
@export var arena_rect_tiles := Rect2i()
@export_file("*.tscn") var exit_scene := ""
@export var exit_spawn := ""
## Segunda saída (caractere ">"). Quem chega por ela aparece em "lateral".
@export_file("*.tscn") var exit2_scene := ""
@export var exit2_spawn := ""
## Id do chefe que destranca a segunda saída ("" = sempre aberta) e a fala dela trancada.
@export var exit2_requires := ""
@export var exit2_locked_dialogue := ""
## Terceira saída (caractere "'"), com as mesmas regras. Quem chega aparece em "oeste".
@export_file("*.tscn") var exit3_scene := ""
@export var exit3_spawn := ""
@export var exit3_requires := ""
@export var exit3_locked_dialogue := ""
## Pontos de inspeção do mapa: dígito → id da fala em data/dialogos.json.
## Ex.: {"1": "terminal"} — o "1" do .txt vira algo que dá para Examinar.
@export var lore_points := {}
## Itens do chão: um por "@" do mapa, na ORDEM DE LEITURA (esquerda→direita,
## cima→baixo). Formato "id" ou "id:quantidade" — ex.: "sucata_temperada:2".
## Pegos uma vez, não voltam (ficam no save com a posição: "cidade@13,3").
@export var item_points: Array[String] = []
## Marque no Inspector para reconstruir o mapa dentro do editor.
@export var rebuild := false:
	set(value):
		rebuild = false
		if value and Engine.is_editor_hint() and is_inside_tree():
			build()

@onready var floor_layer: TileMapLayer = $Floor
@onready var wall_layer: TileMapLayer = $Walls
@onready var entities: Node2D = $Entities
@onready var camera: GameCamera = $Camera
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

var player: Player
var hud: HUD
var spawns := {}
var boss_arena: BossArena
var rest_chamber: RestChamber

var _grid: Array[String] = []
var _width := 0
var _height := 0
## Inimigos que (re)nascem ao descansar: {"scene": PackedScene, "at": Vector2, "variant": int}.
var _enemy_spawns: Array[Dictionary] = []
var _fog_walls: Array[FogWall] = []
## O chefe desta área (se houver) e o NPC que o representa antes da luta
## (a Helena sentada na plateia). Aldir não tem: ele já está na arena.
var _boss: Boss
var _boss_npc: NPC
var _landing := Vector2.ZERO
## O que fica no cenário depois da vitória (lore pelo cenário).
var _memorial := {}
var _memorial_point := Vector2.ZERO
var _talking := false
var _leaving := false
## Quantos "@" já foram lidos nesta montagem (índice em item_points).
var _item_index := 0


func _ready() -> void:
	build()
	if Engine.is_editor_hint():
		return
	_start_runtime()


# =============================================================================
# Construção do mapa (roda no jogo E no editor)
# =============================================================================

func build() -> void:
	_clear()
	if not _load_layout():
		return
	var tiles: Dictionary = THEMES[theme]
	# Uma "moldura" de 1-2 células além do texto: garante barreira nas bordas
	# (o .txt pode terminar sem linhas de vazio) e desenha a rocha sob a ilha.
	for y in range(-1, _height + 2):
		for x in range(-1, _width + 1):
			_build_cell(x, y, _char_at(x, y), tiles)
	canvas_modulate.color = darkness
	if outdoor:
		_add_sky()


func _clear() -> void:
	floor_layer.clear()
	wall_layer.clear()
	for child in entities.get_children():
		child.free()
	spawns.clear()
	_enemy_spawns.clear()
	_fog_walls.clear()
	_boss_npc = null
	_boss = null
	_memorial = {}
	_memorial_point = Vector2.ZERO
	_item_index = 0
	var sky := get_node_or_null("Sky")
	if sky:
		sky.free()


func _load_layout() -> bool:
	if layout_file.is_empty() or not FileAccess.file_exists(layout_file):
		push_warning("Level: layout não encontrado: %s" % layout_file)
		return false
	var text := FileAccess.get_file_as_string(layout_file)
	_grid.clear()
	for line in text.split("\n"):
		_grid.append(line.trim_suffix("\r"))
	while not _grid.is_empty() and _grid[-1].strip_edges().is_empty():
		_grid.pop_back()
	_height = _grid.size()
	_width = 0
	for row in _grid:
		_width = maxi(_width, row.length())
	return _height > 0


func _char_at(x: int, y: int) -> String:
	if y < 0 or y >= _height or x < 0:
		return " "
	var row := _grid[y]
	return row[x] if x < row.length() else " "


func _is_floor_char(c: String) -> bool:
	return FLOOR_CHARS.contains(c) or ENTITY_CHARS.contains(c)


func _is_wall_char(c: String) -> bool:
	return c == "#" or c == "n" or c == "|" or _is_wall_prop(c)


## Objeto desenhado numa parede (tocha, luz, riscos de giz): a célula é parede.
func _is_wall_prop(c: String) -> bool:
	return _prop_def(c).get("wall", false)


## O objeto de cenário deste caractere NESTA ilha ({} = não é objeto).
func _prop_def(c: String) -> Dictionary:
	var local: Dictionary = THEME_PROPS.get(theme, {})
	if local.has(c):
		return local[c]
	return PROPS.get(c, {})


## Variação "aleatória" mas estável: o mesmo mapa sempre gera os mesmos tiles.
func _pick(options: Array, x: int, y: int) -> Vector2i:
	var h := absi((x * 73856093) ^ (y * 19349663))
	return options[h % options.size()]


func _cell_center(x: int, y: int) -> Vector2:
	return Vector2(x * TILE + TILE * 0.5, y * TILE + TILE * 0.5)


func _cell_feet(x: int, y: int) -> Vector2:
	return Vector2(x * TILE + TILE * 0.5, y * TILE + TILE - 2)


func _build_cell(x: int, y: int, c: String, tiles: Dictionary) -> void:
	var cell := Vector2i(x, y)
	var floors: Dictionary = tiles["floor"]
	if floors.has(c):
		floor_layer.set_cell(cell, 0, _pick(floors[c], x, y))
		return
	var solids: Dictionary = tiles.get("solid", {})
	if solids.has(c) or (c == "<" and solids.has("~")):
		_build_water(x, y, c, tiles)
		return
	match c:
		"#", "n":
			var below := _char_at(x, y + 1)
			var face := not _is_wall_char(below) and below != " "
			var atlas: Vector2i = tiles["wall_top"]
			if face:
				atlas = tiles["arch"] if c == "n" else _pick(tiles["wall_face"], x, y)
			wall_layer.set_cell(cell, 0, atlas)
		"|":
			var hem := _char_at(x, y + 1) != "|"
			wall_layer.set_cell(cell, 0, tiles["curtain_hem"] if hem else _pick(tiles["curtain"], x, y))
		" ":
			_build_void(x, y, tiles)
		_:
			floor_layer.set_cell(cell, 0, _pick(floors[_underlay_char(x, y, tiles)], x, y))
			_build_entity(x, y, c)


## Lago (sólido) — com margem de grama quando há terra logo acima.
## "<" é água também, mais a cachoeira que despenca da borda da ilha.
func _build_water(x: int, y: int, c: String, tiles: Dictionary) -> void:
	var solids: Dictionary = tiles["solid"]
	var above := _char_at(x, y - 1)
	var atlas: Vector2i = _pick(solids.get(c, solids["~"]), x, y)
	if tiles.has("shore") and above != "~" and above != "<" and _is_floor_char(above):
		atlas = tiles["shore"]
	wall_layer.set_cell(Vector2i(x, y), 0, atlas)
	if c == "<":
		_add_waterfall(x, y)


## "Cachoeiras que caem em câmera lenta": 3 quadros a 3 fps, pendurada sob a borda.
func _add_waterfall(x: int, y: int) -> void:
	var anim := AnimatedSprite2D.new()
	var sprite_frames := SpriteFrames.new()
	sprite_frames.set_animation_speed(&"default", 3.0)
	var frame_w := WATERFALL_TEXTURE.get_width() / 3
	for i in 3:
		var atlas := AtlasTexture.new()
		atlas.atlas = WATERFALL_TEXTURE
		atlas.region = Rect2(i * frame_w, 0, frame_w, WATERFALL_TEXTURE.get_height())
		sprite_frames.add_frame(&"default", atlas)
	anim.sprite_frames = sprite_frames
	anim.centered = false
	anim.position = Vector2(x * TILE, (y + 1) * TILE - 2)
	anim.z_as_relative = false
	anim.z_index = -9  # acima do chão e do penhasco (-10), abaixo de tudo que anda
	anim.autoplay = "default"
	floor_layer.add_child(anim)


func _build_void(x: int, y: int, tiles: Dictionary) -> void:
	var cell := Vector2i(x, y)
	if tiles.has("cliff"):
		var above := _char_at(x, y - 1)
		var above2 := _char_at(x, y - 2)
		var walls_too: bool = tiles.get("cliff_under_walls", false)
		if _is_floor_char(above) or (walls_too and above == "#"):
			floor_layer.set_cell(cell, 0, tiles["cliff"])
		elif above == " " and (_is_floor_char(above2) or (walls_too and above2 == "#")):
			floor_layer.set_cell(cell, 0, tiles["cliff_low"])
	# Vazio é sólido (barreira invisível): ninguém cai da ilha neste protótipo.
	if _touches_walkable(x, y):
		wall_layer.set_cell(cell, 0, tiles["barrier"])


func _touches_walkable(x: int, y: int) -> bool:
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		if _is_floor_char(_char_at(x + offset.x, y + offset.y)):
			return true
	return false


## Piso que vai embaixo de um objeto: o mais comum entre os vizinhos.
func _underlay_char(x: int, y: int, tiles: Dictionary) -> String:
	var floors: Dictionary = tiles["floor"]
	var counts := {}
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n := _char_at(x + offset.x, y + offset.y)
		if floors.has(n):
			counts[n] = counts.get(n, 0) + 1
	var best: String = tiles["default_floor"]
	var best_count := 0
	for key in counts:
		if counts[key] > best_count:
			best = key
			best_count = counts[key]
	return best


## Onde aparece quem chega por uma porta: 2 células para DENTRO do mapa
## (para baixo/cima numa porta de parede, para o lado numa porta na borda).
func _inward_of(x: int, y: int) -> Vector2:
	if x <= 1:
		return _cell_feet(x + 2, y)
	if x >= _width - 2:
		return _cell_feet(x - 2, y)
	var inward := -1 if y > _height / 2 else 1
	return _cell_feet(x, y + inward * 2)


func _build_entity(x: int, y: int, c: String) -> void:
	var feet := _cell_feet(x, y)
	var prop := _prop_def(c)
	if not prop.is_empty():
		entities.add_child(_make_prop(prop, feet))
		if _is_wall_prop(c):  # tocha, luz, riscos: a célula continua sendo parede
			wall_layer.set_cell(Vector2i(x, y), 0, _pick(THEMES[theme]["wall_face"], x, y))
		return
	var local: Dictionary = THEME_ENTITIES.get(theme, {})
	if local.has(c):
		_build_theme_entity(local[c], x, y, feet)
		return
	if c >= "1" and c <= "9":
		_add_lore_point(c, feet)
		return
	if c == "@":
		_add_item_pickup(x, y, feet)
		return
	match c:
		"P":
			spawns["inicio"] = feet
		"C":
			rest_chamber = REST_SCENE.instantiate()
			rest_chamber.position = feet + Vector2(8, 0)
			entities.add_child(rest_chamber)
			spawns["camara"] = feet + Vector2(8, 22)
		"D":
			var exit := EXIT_SCENE.instantiate() as AreaExit
			exit.position = _cell_center(x, y)
			exit.target_scene = exit_scene
			exit.target_spawn = exit_spawn
			entities.add_child(exit)
			spawns["porta"] = _inward_of(x, y)
		">":
			# Porta trancada até vencer o chefe pedido (o Bosque abre depois do Aldir).
			_add_side_exit(x, y, exit2_scene, exit2_spawn, exit2_requires, exit2_locked_dialogue, "lateral")
		"'":
			# A porta das Raízes (Teatro, parede esquerda) abre depois de Nyssa.
			_add_side_exit(x, y, exit3_scene, exit3_spawn, exit3_requires, exit3_locked_dialogue, "oeste")
		"H":
			_boss_npc = _make_npc("helena", "Mulher na plateia", "res://assets/sprites/helena_seated.png", 1, feet)
			_boss = HELENA_SCENE.instantiate()
			_boss.position = feet
			entities.add_child(_boss)
			# A espada partida fica no palco (onde ela aterrissou para lutar).
			_memorial = {"dialogue": "espada_helena", "name": "Espada partida",
				"texture": "res://assets/sprites/helena_sword.png", "rotation": 0.4}
		"Z":
			_boss = ALDIR_SCENE.instantiate()
			_boss.position = feet
			entities.add_child(_boss)
			_memorial_point = feet
			# O martelo fica cravado onde ele caiu.
			_memorial = {"dialogue": "martelo_aldir", "name": "Martelo do Detentor",
				"texture": "res://assets/sprites/aldir_hammer.png", "planted": true, "at_death": true}
		"/":
			_boss = NYSSA_SCENE.instantiate()
			_boss.position = feet
			entities.add_child(_boss)
			_memorial_point = feet
			# Onde ela dormia fica uma cama de flores lilases.
			_memorial = {"dialogue": "cama_de_nyssa", "name": "Cama de flores",
				"texture": "res://assets/props/flower_bed.png"}
		"Q":
			var cover := DestructibleCover.new()
			cover.position = feet
			entities.add_child(cover)
		"Y":
			_landing = feet
		"M":
			var fog := FOG_SCENE.instantiate() as FogWall
			fog.position = _cell_center(x, y)
			entities.add_child(fog)
			_fog_walls.append(fog)
		"F":
			var fada := _make_npc("fada", "Fada", "res://assets/sprites/npc_fada.png", 2, feet)
			fada.hover = true
			fada.get_node("CollisionShape2D").disabled = true  # flutua: não bloqueia a passagem
			_add_light(fada, Color(0.7, 0.95, 1.0), 0.8, 0.7, Vector2(0, -10))
		"V":
			_make_npc("vendedor,vendedor_extra", "Vendedor Dragonoide", "res://assets/sprites/npc_vendedor.png", 2, feet)
			entities.add_child(_make_prop({"tex": "res://assets/props/counter.png", "box": Vector2(30, 6)}, feet + Vector2(0, 9)))
		"A":
			_make_npc("ferreiro,ferreiro_forja", "Ferreiro Anão", "res://assets/sprites/npc_ferreiro.png", 2, feet)
			var forge := _make_prop({"tex": "res://assets/props/forge.png", "frames": 2, "fps": 5.0, "box": Vector2(22, 8),
				"light": [Color(1.0, 0.55, 0.22), 1.1, 1.3, Vector2(0, -12)]}, feet + Vector2(-22, -4))
			entities.add_child(forge)
			entities.add_child(_make_prop({"tex": "res://assets/props/anvil.png", "box": Vector2(10, 5)}, feet + Vector2(14, 4)))
		"O":
			var orb := _make_npc("orbe", "Orbe Branco", "res://assets/sprites/npc_orbe.png", 2, feet)
			orb.hover = true
			orb.wander_distance = 110.0
			orb.get_node("CollisionShape2D").disabled = true
			_add_light(orb, Color(0.95, 0.97, 1.0), 0.7, 0.6, Vector2(0, -8))
		"B":
			var dummy := DUMMY_SCENE.instantiate()
			dummy.position = feet
			entities.add_child(dummy)
		"S":
			_add_enemy_spawn({"scene": SOLDIER_SCENE, "at": feet})
		"d":
			_add_enemy_spawn({"scene": DOG_SCENE, "at": feet})
		"y":
			_add_enemy_spawn({"scene": SNIPER_SCENE, "at": feet})
		"v":
			_add_enemy_spawn({"scene": CIVIL_SCENE, "at": feet})
		"z":
			_add_enemy_spawn({"scene": SLEEPER_SCENE, "at": feet})
		"s":
			_add_enemy_spawn({"scene": FLOWER_SCENE, "at": feet})
		"^":
			_add_enemy_spawn({"scene": DEER_SCENE, "at": feet})
		"?":
			_add_enemy_spawn({"scene": WITHER_SCENE, "at": feet})
		"h", "w", "U", "0":
			# Mini-chefe: vencido uma vez, não volta (nem ao descansar).
			var spec: Array = MINIBOSSES[c]
			if Engine.is_editor_hint() or not Game.is_boss_defeated(spec[0]):
				var mini := (spec[1] as PackedScene).instantiate() as Node2D
				mini.position = feet
				mini.add_to_group("minibosses")
				entities.add_child(mini)
		"*":
			# Duas "caras" de criança, alternadas pelo lugar no mapa (variedade estável).
			_add_enemy_spawn({"scene": CHILD_SCENE, "at": feet, "variant": (x + y) % 2})
		"+":
			_add_enemy_spawn({"scene": CHILD_SCENE, "at": feet, "variant": 2})
		"J":
			# A Criança Poupada: só existe se você atravessou o prólogo sem ferir ninguém.
			if Engine.is_editor_hint() or Game.spared_child:
				var spared := _make_npc(SPARED_CHILD_TALKS, "Criança", "res://assets/sprites/crianca_poupada.png", 2, feet)
				spared.get_node("CollisionShape2D").disabled = true  # sentada no chão: não atrapalha a luta da Helena
		"G":
			var opened := not Engine.is_editor_hint() and Game.is_boss_defeated("aldir")
			var gate := _make_npc("portao_aldir_aberto" if opened else "portao_aldir", "Portão do Detentor", "res://assets/props/gate.png", 1, feet)
			var gate_shape := gate.get_node("CollisionShape2D") as CollisionShape2D
			gate_shape.shape = gate_shape.shape.duplicate()  # forma própria: não altera os outros NPCs
			(gate_shape.shape as RectangleShape2D).size = Vector2(44, 10)
			spawns["portao"] = _cell_feet(x, y + 2)  # quem volta da arena aparece diante do portão
		"e":
			var edge := _make_npc("borda", "Borda da ilha", "", 1, feet, "Examinar")
			edge.get_node("CollisionShape2D").disabled = true


## Saída extra: trancada (vira um ponto "Examinar") até vencer o chefe pedido.
func _add_side_exit(x: int, y: int, scene: String, spawn: String, requires: String, locked_dialogue: String, arrival: String) -> void:
	if not requires.is_empty() and not Engine.is_editor_hint() and not Game.is_boss_defeated(requires):
		_make_npc(locked_dialogue, "", "", 1, _cell_feet(x, y), "Examinar")
		return
	var side_exit := EXIT_SCENE.instantiate() as AreaExit
	side_exit.position = _cell_center(x, y)
	side_exit.target_scene = scene
	side_exit.target_spawn = spawn
	entities.add_child(side_exit)
	spawns[arrival] = _inward_of(x, y)


## Inimigo, mini-chefe ou chefe que só existe nesta ilha (THEME_ENTITIES).
func _build_theme_entity(spec: Dictionary, x: int, y: int, feet: Vector2) -> void:
	if spec.has("enemy"):
		var count: int = spec.get("swarm", 1)
		for i in count:
			# Enxame: espalhados em volta da célula (posição estável, sem sorteio).
			var offset := Vector2.ZERO if count == 1 else Vector2.from_angle(TAU * i / count + x) * 7.0
			_add_enemy_spawn({"scene": spec["enemy"], "at": feet + offset})
	elif spec.has("miniboss"):
		if Engine.is_editor_hint() or not Game.is_boss_defeated(spec["miniboss"]):
			var mini := (spec["scene"] as PackedScene).instantiate() as Node2D
			mini.position = feet
			mini.add_to_group("minibosses")
			entities.add_child(mini)
	elif spec.has("boss"):
		_boss = (spec["boss"] as PackedScene).instantiate()
		_boss.position = feet
		entities.add_child(_boss)
		_memorial_point = feet
		_memorial = spec.get("memorial", {})


func _make_prop(def: Dictionary, feet: Vector2) -> Node2D:
	var root: Node2D
	if def.has("box"):
		var body := StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = def["box"]
		shape.shape = rect
		shape.position = Vector2(0, -rect.size.y * 0.5)
		body.add_child(shape)
		root = body
	else:
		root = Node2D.new()
	root.position = feet + Vector2(def.get("dx", 0), def.get("dy", 0))
	var texture: Texture2D = load(def["tex"])
	var frames: int = def.get("frames", 1)
	var frame_w := texture.get_width() / frames
	if frames > 1:
		var anim := AnimatedSprite2D.new()
		var sprite_frames := SpriteFrames.new()
		sprite_frames.set_animation_speed(&"default", def.get("fps", 8.0))
		for i in frames:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_w, 0, frame_w, texture.get_height())
			sprite_frames.add_frame(&"default", atlas)
		anim.sprite_frames = sprite_frames
		anim.offset = Vector2(0, -texture.get_height() * 0.5)
		anim.autoplay = "default"
		anim.frame = randi() % frames
		root.add_child(anim)
		if not Engine.is_editor_hint():
			anim.play(&"default")
	else:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.offset = Vector2(0, -texture.get_height() * 0.5)
		root.add_child(sprite)
	if def.has("light"):
		var light: Array = def["light"]
		_add_light(root, light[0], light[1], light[2], light[3])
	return root


func _add_light(parent: Node2D, color: Color, energy: float, scale_factor: float, offset: Vector2) -> void:
	var light := PointLight2D.new()
	light.texture = LIGHT_TEXTURE
	light.color = color
	light.energy = energy
	light.texture_scale = scale_factor
	light.position = offset
	parent.add_child(light)


func _make_npc(dialogue_id: String, display_name: String, texture_path: String, frames: int, feet: Vector2, prompt: String = "Falar") -> NPC:
	var npc := NPC_SCENE.instantiate() as NPC
	npc.dialogue_id = dialogue_id
	npc.display_name = display_name
	npc.position = feet
	(npc.get_node("Interactable") as Interactable).prompt = prompt
	var sprite := npc.get_node("Sprite") as AnimatedSprite2D
	if texture_path.is_empty():
		sprite.visible = false
	else:
		var texture: Texture2D = load(texture_path)
		var sprite_frames := SpriteFrames.new()
		sprite_frames.add_animation(&"idle")
		sprite_frames.set_animation_speed(&"idle", 2.5)
		var frame_w := texture.get_width() / frames
		for i in frames:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_w, 0, frame_w, texture.get_height())
			sprite_frames.add_frame(&"idle", atlas)
		sprite.sprite_frames = sprite_frames
		sprite.offset = Vector2(0, -texture.get_height() * 0.5 + 1)
	entities.add_child(npc)
	return npc


func _add_enemy_spawn(spawn: Dictionary) -> void:
	_enemy_spawns.append(spawn)
	if Engine.is_editor_hint():
		_spawn_enemy(spawn)  # pré-visualização no editor


func _spawn_enemy(spawn: Dictionary) -> Node2D:
	var enemy := (spawn["scene"] as PackedScene).instantiate() as Node2D
	enemy.position = spawn["at"]
	if spawn.has("variant"):
		enemy.set("variant", spawn["variant"])
	enemy.add_to_group("respawnable")
	entities.add_child(enemy)
	return enemy


## Ponto de inspeção (lore pelo cenário): invisível, não bloqueia, "Examinar".
func _add_lore_point(digit: String, feet: Vector2) -> void:
	var dialogue_id := str(lore_points.get(digit, ""))
	if dialogue_id.is_empty():
		return
	var point := _make_npc(dialogue_id, "", "", 1, feet, "Examinar")
	point.get_node("CollisionShape2D").disabled = true



## "@" do mapa: um item no chão. A chave inclui a posição — dois "@" do mesmo
## item na mesma área continuam sendo itens diferentes no save.
func _add_item_pickup(x: int, y: int, feet: Vector2) -> void:
	var index := _item_index
	_item_index += 1
	if index >= item_points.size():
		push_warning("Level: '@' em (%d,%d) sem item em item_points" % [x, y])
		return
	var spec := item_points[index].split(":")
	var item_id := spec[0].strip_edges()
	var amount := int(spec[1]) if spec.size() > 1 else 1
	var key := "%s@%d,%d" % [layout_file.get_file().get_basename(), x, y]
	if not Engine.is_editor_hint() and Game.is_pickup_collected(key):
		return
	var pickup := ItemPickup.create(item_id, amount, key)
	pickup.position = feet
	entities.add_child(pickup)


func _add_sky() -> void:
	var sky := preload("res://scripts/world/sky_background.gd").new() as Node2D
	sky.name = "Sky"
	sky.set("area_size", Vector2(_width * TILE, _height * TILE))
	add_child(sky)
	move_child(sky, 0)


# =============================================================================
# Jogo rodando
# =============================================================================

func _start_runtime() -> void:
	Game.session_active = true  # vale também ao rodar a fase direto pelo editor (F6)
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	for spawn in _enemy_spawns:
		_spawn_enemy(spawn)
	var spawn_id := _spawn_player()
	# Ao ar livre a câmera pode passar um pouco da borda: mostra o céu sob a ilha.
	var margin := TILE * 4 if outdoor else 0
	camera.limit_left = -margin
	camera.limit_top = 0
	camera.limit_right = _width * TILE + margin
	camera.limit_bottom = _height * TILE + margin
	camera.target = player
	camera.snap_to_target()
	hud.bind_player(player)
	if not area_name.is_empty():
		hud.show_area_title(area_name, area_subtitle)
	_connect_world()
	Sfx.play_ambience(ambience, -12.0)
	# Novo jogo / depois da queda: o herói sai da cápsula (a Câmara).
	if Game.wake_from_capsule:
		Game.wake_from_capsule = false
		if spawn_id == "camara" and rest_chamber:
			_play_wake_up()


## Cria o herói no ponto pedido pelo Game e devolve o id do ponto usado.
func _spawn_player() -> String:
	player = PLAYER_SCENE.instantiate()
	var spawn_id := Game.pending_spawn
	if not spawns.has(spawn_id):
		for fallback in ["inicio", "camara", "porta"]:
			if spawns.has(fallback):
				spawn_id = fallback
				break
	var at: Vector2 = spawns.get(spawn_id, Vector2(64, 64))
	player.position = at
	entities.add_child(player)
	player.died.connect(_on_player_died)
	Game.pending_spawn = ""
	# Chegou por uma porta: continua com a vida e os frascos que tinha.
	if Game.carry_health > 0.0:
		player.stats.set_health(minf(Game.carry_health, player.stats.max_health))
	if Game.carry_flasks >= 0:
		player.health_flasks = mini(Game.carry_flasks, player.health_flasks_max)
		player.health_flasks_changed.emit(player.health_flasks, player.health_flasks_max)
	Game.clear_carry()
	return spawn_id


func _connect_world() -> void:
	for node in entities.get_children():
		if node is NPC:
			(node as NPC).talked.connect(_on_npc_talked)
			node.add_to_group("npcs")
	if rest_chamber:
		rest_chamber.rest_requested.connect(_on_rest_requested)
	for node in entities.get_children():
		var mini := node as MiniBoss
		if mini:
			mini.fight_started.connect(_on_miniboss_started)
			mini.fight_reset.connect(_on_miniboss_ended.bind(false))
			mini.fight_won.connect(_on_miniboss_ended.bind(true))
		if node is VigiaQueDormiu:
			(node as VigiaQueDormiu).sneaked_past.connect(func(): hud.toast("O Vigia não acordou. Você passou em silêncio."))
	if _boss:
		var rect := Rect2(Vector2(arena_rect_tiles.position * TILE), Vector2(arena_rect_tiles.size * TILE))
		boss_arena = BossArena.new()
		add_child(boss_arena)
		boss_arena.setup(_boss, _boss_npc, _fog_walls, rect, _landing)
		boss_arena.sealed.connect(func(boss: Boss): camera.focus = boss)  # a câmera revela o chefe
		boss_arena.fight_started.connect(_on_fight_started)
		boss_arena.fight_ended.connect(_on_fight_ended)
		if boss_arena.state == BossArena.State.DONE:
			_place_memorial()
		elif _auto_arm_boss():
			boss_arena.arm()  # sem diálogo antes: a névoa já está lá, é só entrar


## Arma a arena assim que a fase abre? Padrão: sim, se o chefe não tem diálogo
## antes (Aldir). A Helena arma pelo diálogo; o Prólogo decide pela escolha moral.
func _auto_arm_boss() -> bool:
	return _boss_npc == null


# --- Diálogos e ações ---------------------------------------------------------------

func _on_npc_talked(npc: NPC) -> void:
	if _talking or player.is_dead() or (boss_arena and boss_arena.is_busy()):
		return
	_begin_modal()
	var ids := npc.dialogue_id.split(",")
	var talk_count: int = npc.get_meta("talks", 0)
	npc.set_meta("talks", talk_count + 1)
	var entry := DialogueData.get_entry(_dialogue_variant(ids[talk_count % ids.size()].strip_edges()))
	if entry.is_empty():
		entry = DialogueData.get_entry(ids[0].strip_edges())
	var action: String = await hud.dialogue.run(entry, npc.display_name)
	await _on_dialogue_action(action)
	if not _leaving:  # trocando de área: fica travado até a tela escurecer
		_end_modal()


## Algumas falas dependem do estado do jogo. Um ponto só decide qual versão
## usar (em vez de "if" espalhados pelos NPCs).
func _dialogue_variant(dialogue_id: String) -> String:
	match dialogue_id:
		"orbe":
			if Game.has_item("fragmento_turvo"):
				return "orbe_purificar" if Game.can_purify_fragment() else "orbe_cheio"
		"fada":
			# Bíblia: "A Fada do Teatro — diálogo novo depois de Nyssa (irmã)".
			if Game.is_boss_defeated("nyssa"):
				return "fada_irma"
	return dialogue_id


## Diálogos, menu da Fada e descanso PAUSAM o mundo: ninguém apanha de um
## soldado enquanto lê uma fala. (Caixa de diálogo, menus e Fader usam
## PROCESS_MODE_ALWAYS, então continuam funcionando com a árvore pausada.)
func _begin_modal() -> void:
	_talking = true
	player.lock_input(true)
	hud.touch.set_enabled(false)
	get_tree().paused = true


func _end_modal() -> void:
	get_tree().paused = false
	player.lock_input(false)  # o Player ignora a tecla que fechou o diálogo
	hud.touch.set_enabled(true)
	_talking = false


## Cena curta (acordar, lembrança, queda): trava o herói e esconde os botões,
## mas NÃO pausa o mundo — a cena é feita de coisas que se mexem.
func begin_cutscene() -> void:
	_talking = true
	hud.cutscene = true
	player.lock_input(true)
	hud.touch.set_enabled(false)


func end_cutscene() -> void:
	player.lock_input(false)
	hud.touch.set_enabled(true)
	hud.cutscene = false
	_talking = false


## A cápsula se abre "com um som baixo, quase respeitoso" e o herói sai dela.
func _play_wake_up() -> void:
	begin_cutscene()
	var goal := player.global_position
	player.global_position = rest_chamber.global_position + Vector2(0, 9)
	player.visual.modulate.a = 0.0
	camera.snap_to_target()
	await _wait(0.6)
	Sfx.play(&"capsule_open")
	Fx.dust(rest_chamber.global_position + Vector2(0, -6), 12)
	var tween := create_tween()
	tween.tween_property(player.visual, "modulate:a", 1.0, 0.7)
	tween.parallel().tween_property(player, "global_position", goal, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	await _wait(0.25)
	if not player.is_dead():
		end_cutscene()


func _on_dialogue_action(action: String) -> void:
	match action:
		"subir_nivel":
			await hud.level_up_menu.run(player)
		"melhorar_arma":
			await hud.smith_menu.run(player)
		"purificar":
			if Game.purify_fragment():
				player.apply_progress(false)
				Sfx.play(&"purify")
				Fx.splash(player.global_position + Vector2(0, -12), Color(0.95, 0.97, 1.0), 18)
				hud.toast("O caco clareou. Frascos de Vida: %d" % Game.health_flasks_max)
			else:
				Sfx.play(&"ui_click")
		"comprar_sucata":
			if Game.buy_item("sucata_temperada", Game.SUCATA_PRICE):
				Sfx.play(&"memory")
			else:
				Sfx.play(&"ui_click")
				hud.toast("Memórias insuficientes.")
		"comprar_sanidade":
			if Game.buy_sanity_flask():
				Sfx.play(&"memory")
				hud.toast("Frasco de Sanidade obtido. De quem era?")
			else:
				Sfx.play(&"ui_click")
				hud.toast("Memórias insuficientes.")
		"desafiar_helena":
			if boss_arena:
				boss_arena.arm()
		"entrar_aldir":
			_leaving = true
			Game.carry(player.stats.health, player.health_flasks)
			Sfx.play(&"door")
			Game.travel(ALDIR_ARENA, "porta")


# --- Descanso, morte, chefe ----------------------------------------------------------------

func _on_rest_requested(chamber: RestChamber) -> void:
	if _talking or (boss_arena and boss_arena.is_busy()) or player.is_dead():
		return
	_begin_modal()
	Sfx.play(&"rest")
	await Fader.fade_out(0.6)
	player.rest()
	player.global_position = spawns.get(chamber.spawn_id, player.global_position)
	_respawn_enemies()
	Game.set_rest_point(scene_file_path, chamber.spawn_id)
	camera.snap_to_target()
	await _wait(0.3)
	await Fader.fade_in(0.6)
	_end_modal()
	var lines: Array = DialogueData.get_entry("descanso").get("falas", [])
	if not lines.is_empty():
		hud.toast(lines.pick_random())


func _respawn_enemies() -> void:
	for node in get_tree().get_nodes_in_group("respawnable"):
		node.queue_free()
	for spawn in _enemy_spawns:
		_spawn_enemy(spawn)


func _on_player_died() -> void:
	# A punição vale NA HORA (e já fica salva): fechar o app ou voltar ao título
	# durante a animação não "desfaz" a morte. A tela vem depois, com calma.
	var lost := Game.register_death()
	hud.touch.set_enabled(false)
	await _wait(1.2)
	hud.show_death(lost, Game.deaths)
	await _wait(3.2)
	Game.respawn()


## Espera que conta mesmo com o jogo pausado (e ignora a câmera lenta) e que
## MORRE junto com a fase: se a cena for trocada no meio (porta, título), a
## corrotina simplesmente não continua. Com get_tree().create_timer(), o Godot
## tentaria retomar a função num nó que já foi apagado.
func _wait(seconds: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.ignore_time_scale = true
	add_child(timer)
	timer.start(seconds)
	await timer.timeout
	timer.queue_free()


func _on_fight_started(boss: Boss) -> void:
	hud.show_boss(boss)
	camera.focus = boss
	Sfx.play_ambience(&"amb_boss", -12.0)
	if rest_chamber:
		rest_chamber.set_available(false)
	for npc in get_tree().get_nodes_in_group("npcs"):
		(npc as NPC).interactable.enabled = false


func _on_fight_ended(victory: bool) -> void:
	camera.focus = null
	var subtitle := ""
	if is_instance_valid(boss_arena.boss):
		subtitle = boss_arena.boss.victory_subtitle()
		if _memorial.get("at_death", false):
			_memorial_point = boss_arena.boss.global_position
	await _wait(2.5)
	hud.hide_boss()
	if victory:
		await _celebrate_victory(subtitle)
	Sfx.play_ambience(ambience, -12.0)
	if rest_chamber:
		rest_chamber.set_available(true)
	for npc in get_tree().get_nodes_in_group("npcs"):
		(npc as NPC).interactable.enabled = true


## Mini-chefe acordou: barra de chefe e música de luta (sem névoa, sem arena).
func _on_miniboss_started(mini: Boss) -> void:
	hud.show_boss(mini)
	Sfx.play_ambience(&"amb_boss", -12.0)


func _on_miniboss_ended(mini: Boss, victory: bool) -> void:
	hud.hide_boss()
	Sfx.play_ambience(ambience, -12.0)
	if victory:
		hud.show_victory("INIMIGO VENCIDO", mini.display_name())


## Gancho da vitória (padrão: o título "MEMÓRIA RECUPERADA" e a arma do chefe
## no cenário). O Prólogo troca isto pela lembrança da Governanta.
func _celebrate_victory(subtitle: String) -> void:
	hud.show_victory("MEMÓRIA RECUPERADA", subtitle)
	_place_memorial()


## Depois da vitória, a arma do chefe fica no cenário (lore pelo cenário):
## a espada partida da Helena no palco, o martelo do Aldir cravado na praça.
func _place_memorial() -> void:
	if _memorial.is_empty():
		return
	var at := _memorial_point if _memorial_point != Vector2.ZERO else _landing
	if at == Vector2.ZERO:
		return
	var memorial := _make_npc(_memorial["dialogue"], _memorial["name"], _memorial["texture"], 1, at)
	var sprite := memorial.get_node("Sprite") as AnimatedSprite2D
	if _memorial.get("planted", false):
		# Cabeça do martelo no chão, cabo para cima (a empunhadura fica no alto).
		sprite.offset = Vector2(13, 0)
		sprite.position = Vector2(0, -27)
		sprite.rotation = PI * 0.5 - 0.12
	else:
		sprite.rotation = _memorial.get("rotation", 0.0)
	memorial.talked.connect(_on_npc_talked)
	memorial.add_to_group("npcs")

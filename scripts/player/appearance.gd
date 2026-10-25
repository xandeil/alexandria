class_name Appearance
extends RefCounted
## Aparência do personagem (criação de personagem).
##
## A arte de TODAS as combinações já vem pronta num atlas (player_aparencias.png,
## gerado por tools/art/aparencia.py): uma linha por combinação, 4 quadros por
## linha. Aqui só calculamos QUAL linha usar e montamos o SpriteFrames com as
## mesmas animações do player_frames.tres ("idle" e "walk").
##
## Por que um atlas pronto em vez de colar camadas no jogo? O contorno preto do
## pixel art precisa ser desenhado em volta da silhueta FINAL (cabelo + rosto +
## corpo). Montar no Python resolve isso uma vez só, e no celular é só recortar.

const ATLAS_PATH := "res://assets/sprites/player_aparencias.png"
const FRAME_SIZE := Vector2i(24, 24)
const FRAMES_PER_ROW := 4

const SEXES: Array[String] = ["Homem", "Mulher"]
const BODIES: Array[String] = ["Magro", "Forte", "Gordo"]
const FACES := {
	0: ["Sereno", "Barbudo", "Marcado"],
	1: ["Serena", "Olhar vivo", "Sardas"],
}
const HAIRS := {
	0: ["Curto", "Raspado", "Desgrenhado", "Rabo preso", "Comprido"],
	1: ["Chanel", "Rabo de cavalo", "Longo", "Coque", "Curtinho"],
}

## As 4 escolhas, na ordem em que aparecem na tela de criação.
const FIELDS: Array[String] = ["sexo", "corpo", "rosto", "cabelo"]

static var _cache := {}  # linha do atlas -> SpriteFrames (o atlas é compartilhado)


static func default_data() -> Dictionary:
	return {"sexo": 0, "corpo": 0, "rosto": 0, "cabelo": 0}


## Quantas opções existem em cada campo (rosto e cabelo dependem do sexo).
static func option_count(field: String, sex: int = 0) -> int:
	match field:
		"sexo":
			return SEXES.size()
		"corpo":
			return BODIES.size()
		"rosto":
			return FACES[sex].size()
		"cabelo":
			return HAIRS[sex].size()
	return 1


static func option_name(field: String, data: Dictionary) -> String:
	var sex: int = data.get("sexo", 0)
	var index: int = data.get(field, 0)
	match field:
		"sexo":
			return SEXES[index]
		"corpo":
			return BODIES[index]
		"rosto":
			return FACES[sex][index]
		"cabelo":
			return HAIRS[sex][index]
	return ""


## Corrige qualquer valor fora do lugar (save editado, versão antiga...).
## Devolve um dicionário NOVO: quem chamou continua com o seu intacto.
static func sanitized(data: Variant) -> Dictionary:
	var clean := default_data()
	if typeof(data) != TYPE_DICTIONARY:
		return clean
	for field in FIELDS:
		var count := option_count(field, clean["sexo"])
		clean[field] = clampi(int(data.get(field, 0)), 0, count - 1)
	return clean


## Mesma fórmula de index_of() em tools/art/aparencia.py (um teste confere).
static func row(data: Dictionary) -> int:
	var d := sanitized(data)
	var faces: int = FACES[0].size()
	var hairs: int = HAIRS[0].size()
	return ((d["sexo"] * BODIES.size() + d["corpo"]) * faces + d["rosto"]) * hairs + d["cabelo"]


static func row_count() -> int:
	return SEXES.size() * BODIES.size() * FACES[0].size() * HAIRS[0].size()


static func sprite_frames(data: Dictionary) -> SpriteFrames:
	var r := row(data)
	if _cache.has(r):
		return _cache[r]
	var atlas: Texture2D = load(ATLAS_PATH)
	var textures: Array[AtlasTexture] = []
	for i in FRAMES_PER_ROW:
		var tex := AtlasTexture.new()
		tex.atlas = atlas
		tex.region = Rect2(Vector2(i * FRAME_SIZE.x, r * FRAME_SIZE.y), Vector2(FRAME_SIZE))
		textures.append(tex)
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"idle")
	frames.set_animation_speed(&"idle", 5.0)
	frames.add_frame(&"idle", textures[0])
	frames.add_animation(&"walk")
	frames.set_animation_speed(&"walk", 8.0)
	for tex in textures:
		frames.add_frame(&"walk", tex)
	_cache[r] = frames
	return frames

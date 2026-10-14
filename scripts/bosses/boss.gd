class_name Boss
extends Enemy
## Base dos chefes (os Sete Pecados): ficha BossData, fases e barra de chefe.
## A barra (HUD), a arena (BossArena) e a fase (Level) só conversam com esta
## classe — nunca com "HelenaAltiva" ou "AldirCornelios" diretamente.
##
## POLIMORFISMO na prática: cada chefe sobrescreve os métodos "virtuais" abaixo
## (enter_arena, phase_label, armor_ratio...). Quem usa a classe base não
## precisa de nenhum "if chefe is Helena" — e o próximo Pecado entra sem mexer
## no HUD nem na arena (princípio aberto/fechado do SOLID).

signal fight_started(boss: Boss)
signal phase_changed(phase_name: String)
signal armor_ratio_changed(ratio: float)
signal title_changed(display_name: String, title: String)
signal speech(text: String)
signal fight_won(boss: Boss)
## Emitido quando o chefe termina a entrada e está pronto para lutar.
signal ready_to_fight

@export var data: BossData
## > 0: depois que a névoa fecha, o chefe só começa a lutar quando o herói chega
## a esta distância (dá tempo de VER o chefe antes). 0 = começa na hora.
@export var wake_distance := 0.0

## Limites da arena (em coordenadas do mundo), preenchidos pela BossArena.
var arena_rect := Rect2()
var active := false


func _ready() -> void:
	super._ready()
	remove_from_group("enemies")  # só vira alvo quando a luta começa
	hurtbox.invulnerable = true


func is_targetable() -> bool:
	return active and not dead


## Entrada do chefe (chamada pela BossArena). Padrão: aparece e já está pronto.
func enter_arena(_landing: Vector2) -> void:
	visible = true
	ready_to_fight.emit()


func start_fight() -> void:
	active = true
	add_to_group("enemies")
	hurtbox.invulnerable = false
	fight_started.emit(self)


func display_name() -> String:
	return data.display_name if data else name


func display_title() -> String:
	return data.title if data else ""


## Texto da fase atual para a barra de chefe ("" = sem texto).
func phase_label() -> String:
	return ""


## Armadura 0..1 para a barra (-1 = este chefe não tem armadura).
func armor_ratio() -> float:
	return -1.0


## Subtítulo da tela de vitória, tirado da ficha: "Ira — Impotência".
func victory_subtitle() -> String:
	if data == null:
		return ""
	return "%s — %s" % [data.sin, data.sin_meaning]


## Mantém um ponto dentro da arena (com margem), para saltos e efeitos.
func clamp_to_arena(point: Vector2, margin: float = 12.0) -> Vector2:
	if arena_rect.size == Vector2.ZERO:
		return point
	var inner := arena_rect.grow(-margin)
	return Vector2(clampf(point.x, inner.position.x, inner.end.x), clampf(point.y, inner.position.y, inner.end.y))

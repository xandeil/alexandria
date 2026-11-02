class_name SpellData
extends ItemData
## v0.50 (Etapa 10) — UMA MAGIA (data/spells/*.tres). É um item como os outros
## (inventário, loja, save), com os números de quando você lança.
##
## Três escolas, três vendedores:
##   feitiço     (Dalva)    — escala com Magia
##   piromancia  (Cícero)   — escala com Magia
##   milagre     (Benedita) — escala com Fé
## Cinco formas (SpellCaster faz cada uma):
##   projetil  um tiro reto (bola de fogo, lança de raio)
##   frente    um golpe em leque à sua frente (lâmina, chicote de chamas)
##   area      tudo em volta de você (explosão, tempestade)
##   cura      cura você (e, com "em_area", os aliados perto)
##   barreira  menos dano por alguns segundos

@export_enum("feitico", "piromancia", "milagre") var school := "feitico"
@export_enum("projetil", "frente", "area", "cura", "barreira") var form := "projetil"
@export_enum("magia", "fogo", "raio", "gelo") var damage_type := "magia"
@export var stamina_cost := 25.0
## Preparo (o herói para e brilha): a janela para o inimigo reagir — e você.
@export var cast_time := 0.45
## Dano base (projetil/frente/area) ou cura base (cura).
@export var power := 30.0
@export var poise_damage := 20.0
@export var knockback := 120.0
## Alcance: raio da área/leque, ou distância máxima do tiro.
@export var reach := 60.0
@export var projectile_speed := 220.0
## Barreira: quanto do dano entra (0.5 = metade) e por quanto tempo.
@export var barrier_ratio := 0.5
@export var duration := 6.0
## Cura: também cura os aliados por perto.
@export var em_area := false
@export var color := Color(0.6, 0.8, 1.0)


## O atributo que faz a magia crescer.
func scaling_attribute() -> String:
	return "fe" if school == "milagre" else "magia"


const SCHOOL_NAMES := {"feitico": "Feitiço", "piromancia": "Piromancia", "milagre": "Milagre"}


func school_name() -> String:
	return SCHOOL_NAMES.get(school, "Magia")

class_name BossData
extends Resource
## Ficha de um Pecado (chefe), tirada da Bíblia do Jogo.
## Os 7 Pecados + o chefe final estão em data/bosses/*.tres — mesmo os que ainda
## não têm luta programada. A barra de chefe e os textos do jogo leem daqui.

@export var id := ""
@export var display_name := ""
@export var title := ""
@export var sin := ""
## O que o pecado significa nesta história (ex.: Luxúria = Apego).
@export var sin_meaning := ""
@export var race := ""
@export var attribute := ""
@export var area := ""
@export var scaling := ""
@export var suggested_order := ""
@export var memory_reward := 1000
@export_multiline var unique_mechanic := ""
@export var phases: Array[String] = []
@export_multiline var history := ""
@export_multiline var meaning := ""
## true = já tem luta jogável neste projeto.
@export var implemented := false

class_name FarmSpot
extends Node2D
## O "farm" de uma fase: o ciclo Bezerro Dourado → Minotauro → Bezerro de novo.
##
##   1. O bezerro pasta na rota. Sete golpes e ele cai.
##   2. O chão treme: o Minotauro despenca no campo e a barra de chefe aparece.
##   3. O Minotauro morre (4000 memórias + 10 Sucata) ou o herói desiste/morre:
##      alguns segundos depois o bezerro está pastando de novo, como se nada
##      tivesse acontecido.
##
## Por que um nó só para isso (e não regras dentro do bezerro e do minotauro)?
## Cada bicho cuida do próprio corpo; quem sabe que "um chama o outro" é este
## nó. É o padrão MEDIADOR: os dois nunca se conhecem. Trocar o bezerro por
## outro bicho amanhã é mexer só aqui.
##
## A morte do herói recarrega a fase inteira — e uma fase nova sempre começa
## com o bezerro. Descansar na Câmara também reinicia o ciclo (reset_cycle).

const CALF_SCENE := preload("res://scenes/enemies/bezerro_dourado.tscn")
const MINOTAUR_SCENE := preload("res://scenes/bosses/minotauro.tscn")
## Do bezerro cair até o pai despencar (o chão treme antes).
const MINOTAUR_DELAY := 1.4
## Do fim da luta até o bezerro voltar.
const CALF_RETURN_DELAY := 3.0

var route: Array[Vector2] = []
var field := Rect2()
var calf: BezerroDourado
var minotaur: Minotauro

var _level: Level
## Cada ciclo novo invalida as esperas do ciclo velho (descansou no meio da espera).
var _cycle := 0


func setup(level: Level, points: Array[Vector2], field_rect: Rect2) -> void:
	_level = level
	route = points
	field = field_rect
	add_to_group("farm_spots")


func _ready() -> void:
	spawn_calf()


func spawn_calf() -> void:
	if is_instance_valid(calf) and not calf.dead:
		return
	calf = CALF_SCENE.instantiate() as BezerroDourado
	calf.position = route[0]
	calf.set_route(route, 1)
	_level.entities.add_child(calf)
	calf.defeated.connect(_on_calf_defeated)


## Descansou na Câmara: tudo como no começo (sem chefe pela metade).
func reset_cycle() -> void:
	_cycle += 1
	if is_instance_valid(minotaur) and not minotaur.dead:
		minotaur.reset_fight()  # a fase esconde a barra; _on_minotaur_done tira o corpo
	if is_instance_valid(calf):
		calf.queue_free()
	calf = null
	spawn_calf()


func is_minotaur_active() -> bool:
	return is_instance_valid(minotaur) and not minotaur.dead


func _on_calf_defeated(_enemy: Enemy) -> void:
	var cycle := _cycle
	var at := calf.global_position
	Fx.shake(3.0, MINOTAUR_DELAY)
	Sfx.play(&"hooves", 0.0)
	await _wait(MINOTAUR_DELAY)
	if cycle != _cycle:
		return
	_spawn_minotaur(at)


func _spawn_minotaur(at: Vector2) -> void:
	minotaur = MINOTAUR_SCENE.instantiate() as Minotauro
	minotaur.field = field
	minotaur.position = at
	_level.entities.add_child(minotaur)
	_level.register_miniboss(minotaur)  # barra de chefe, música e "INIMIGO VENCIDO"
	minotaur.fight_won.connect(_on_minotaur_done.bind(true))
	minotaur.fight_reset.connect(_on_minotaur_done.bind(false))
	minotaur.erupt(at)


func _on_minotaur_done(boss: Boss, won: bool) -> void:
	var cycle := _cycle
	if not won and is_instance_valid(boss):
		# Desistiu (o herói saiu do campo ou foi descansar): some no ar.
		var tween := boss.create_tween()
		tween.tween_property(boss, "modulate:a", 0.0, 0.6)
		tween.tween_callback(boss.queue_free)
	await _wait(CALF_RETURN_DELAY)
	if cycle != _cycle:
		return
	spawn_calf()


## Espera que morre junto com a fase (mesmo cuidado do Enemy.wait).
func _wait(seconds: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(seconds)
	await timer.timeout
	timer.queue_free()

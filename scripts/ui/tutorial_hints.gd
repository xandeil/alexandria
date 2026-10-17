class_name TutorialHints
extends Node
## Dicas de primeiros passos: aparecem UMA vez cada, na hora em que fazem
## sentido (o primeiro inimigo por perto, o primeiro golpe levado, a estamina
## no fim...), em vez de um texto longo antes de jogar.
## Bíblia: "Lore pelo mundo, não por texto" — o tutorial segue a mesma ideia.
##
## Ficam marcadas no save (`Game.flags["dicas"]`); um jogo novo mostra de novo.
## As Opções desligam todas (`Settings.hints`).

## Uma dica de cada vez, com folga entre elas (ninguém lê duas ao mesmo tempo).
const GAP := 5.0
const ENEMY_NEAR := 120.0

## id → [texto no celular, texto no teclado/controle]
const TEXTS := {
	"andar": ["Arraste o polegar no lado ESQUERDO da tela para andar.", "WASD ou setas para andar."],
	"atacar": ["Toque na ESPADA para atacar. SEGURE para o golpe forte.", "J ataca. Segure J (ou K) para o golpe forte."],
	"esquivar": ["O botão » é a esquiva: durante ela, nenhum golpe acerta.", "ESPAÇO esquiva: durante ela, nenhum golpe acerta."],
	"estamina": ["Barra VERDE: estamina. Golpes e esquivas gastam; pare um instante para ela voltar.", "Barra VERDE: estamina. Golpes e esquivas gastam; pare um instante para ela voltar."],
	"curar": ["Vida baixa: toque no FRASCO VERMELHO para beber.", "Vida baixa: E bebe um frasco de vida."],
	"camara": ["Câmara: descansar enche a vida e os frascos — e os inimigos voltam.", "Câmara: descansar enche a vida e os frascos — e os inimigos voltam."],
	"memorias": ["Memórias são a moeda: a Fada do Teatro as troca por força. Morrer faz perder metade.", "Memórias são a moeda: a Fada do Teatro as troca por força. Morrer faz perder metade."],
}

var show_hint: Callable  ## quem mostra (o HUD); recebe o texto
var _player: Player
var _queue: Array[String] = []
var _cooldown := 1.5
var _poll := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE  # diálogo/pausa abertos: nada de dica por cima


func bind(player: Player) -> void:
	_player = player
	player.hurt.connect(func(_amount: float): want("esquivar"))
	player.interact_target_changed.connect(func(target: Interactable):
		if target and target.get_parent() is RestChamber:
			want("camara"))
	Game.memories_changed.connect(func(total: int):
		if total > 0:
			want("memorias"))
	want("andar")


## Pede uma dica (se ainda não foi vista e as dicas estão ligadas).
func want(id: String) -> void:
	if not Settings.hints or seen(id) or _queue.has(id):
		return
	_queue.append(id)


func seen(id: String) -> bool:
	return (Game.flags.get("dicas", []) as Array).has(id)


static func text_for(id: String) -> String:
	var pair: Array = TEXTS.get(id, ["", ""])
	return pair[0] if OS.has_feature("mobile") else pair[1]


func _process(delta: float) -> void:
	if not is_instance_valid(_player) or _player.is_dead():
		return
	if get_parent().get(&"cutscene") == true:
		return  # cena curta: a dica espera
	_cooldown -= delta
	_poll -= delta
	if _poll <= 0.0:
		_poll = 0.3
		_check_conditions()
	if _cooldown <= 0.0 and not _queue.is_empty():
		_show(_queue.pop_front())


## As condições que não têm um sinal próprio (olhadas algumas vezes por segundo).
func _check_conditions() -> void:
	if not seen("atacar"):
		for node in get_tree().get_nodes_in_group("enemies"):
			var enemy := node as Node2D
			if enemy and enemy.global_position.distance_to(_player.global_position) <= ENEMY_NEAR:
				want("atacar")
				break
	if _player.stats.stamina_ratio() < 0.3:
		want("estamina")
	if _player.stats.health_ratio() < 0.5 and _player.health_flasks > 0:
		want("curar")


func _show(id: String) -> void:
	if not Settings.hints or seen(id):
		return
	var done: Array = Game.flags.get("dicas", [])
	done.append(id)
	Game.flags["dicas"] = done
	_cooldown = GAP
	if show_hint.is_valid():
		show_hint.call(text_for(id))

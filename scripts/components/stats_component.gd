class_name StatsComponent
extends Node
## Vida, Estamina, Exaustão e Atributos — o "estado" de qualquer lutador.
##
## Ele NÃO sabe nada de input, física ou desenho: só números e regras, e avisa
## o mundo por sinais (padrão Observer). O HUD escuta health_changed, o herói
## escuta died, e ninguém precisa conhecer ninguém. É o "S" do SOLID
## (responsabilidade única) — e por isso o mesmo componente serve para o herói,
## para os Soldados Remendados e para a Helena Altiva.
##
## Regras da Estamina (pedidas no design):
##   • Regenera sozinha, depois de uma pausa curta sem gastar (regen_delay).
##   • Zerou → EXAUSTÃO: não ataca, não dá dash, regenera mais devagar.
##   • Só sai da Exaustão ao recuperar uma fração mínima (exhaustion_recovery_ratio).

signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal exhaustion_changed(is_exhausted: bool)
signal damaged(amount: float)
signal healed(amount: float)
signal died

const ATTRIBUTE_NAMES: Array[String] = ["vitalidade", "folego", "forca", "destreza", "magia", "fe", "sorte"]
const BASE_ATTRIBUTE := 10

@export_group("Atributos (nível)")
@export var vitalidade := 10  ## Vida máxima.
@export var folego := 10  ## Estamina máxima.
@export var forca := 10  ## Dano dos golpes fortes.
@export var destreza := 10  ## Dano dos golpes leves (escala da Helena).
@export var magia := 10  ## Reservado: fogo e gelo (Rachel, Cassian).
@export var fe := 10  ## Reservado: milagres (Durgan, Nyssa).
@export var sorte := 10  ## Mais memórias por inimigo (escala da Mabel).

@export_group("Fórmulas")
@export var base_health := 60.0
@export var health_per_vitalidade := 4.0
@export var base_stamina := 50.0
@export var stamina_per_folego := 5.0
## Acima deste valor cada ponto rende METADE (retorno decrescente, como nos Souls).
@export var soft_cap := 25

@export_group("Regeneração de Estamina")
@export var stamina_regen_per_second := 42.0
## Pausa depois de gastar estamina antes de voltar a regenerar.
## É o que pune o "spam" de botão: quem ataca sem parar não regenera.
@export var regen_delay := 0.55
## Exausto regenera mais devagar — a punição é sentir o tempo passar.
@export var exhausted_regen_multiplier := 0.6
## Fração da estamina máxima necessária para SAIR da Exaustão.
@export_range(0.05, 1.0) var exhaustion_recovery_ratio := 0.35

var max_health := 0.0
var max_stamina := 0.0
var health := 0.0
var stamina := 0.0
var is_exhausted := false
var is_dead := false

## Multiplicador de regeneração vindo de FORA (escudo erguido regenera devagar).
var regen_scale := 1.0
var _regen_delay_left := 0.0


func _ready() -> void:
	recalculate(true)


func _physics_process(delta: float) -> void:
	_regenerate_stamina(delta)


# --- Atributos ----------------------------------------------------------------------

## Recalcula os máximos a partir dos atributos (chame ao subir de nível).
func recalculate(refill: bool = false) -> void:
	max_health = base_health + _scaled(vitalidade, health_per_vitalidade)
	max_stamina = base_stamina + _scaled(folego, stamina_per_folego)
	if refill:
		health = max_health
		stamina = max_stamina
	else:
		health = minf(health, max_health)
		stamina = minf(stamina, max_stamina)
	health_changed.emit(health, max_health)
	stamina_changed.emit(stamina, max_stamina)


func apply_attributes(values: Dictionary, refill: bool = false) -> void:
	for attribute in ATTRIBUTE_NAMES:
		if values.has(attribute):
			set(attribute, int(values[attribute]))
	recalculate(refill)


func get_attributes() -> Dictionary:
	var values := {}
	for attribute in ATTRIBUTE_NAMES:
		values[attribute] = get(attribute)
	return values


## Nível = quantos pontos foram investidos acima da base (começa no 1).
func get_level() -> int:
	var total := 0
	for attribute in ATTRIBUTE_NAMES:
		total += int(get(attribute))
	return total - ATTRIBUTE_NAMES.size() * BASE_ATTRIBUTE + 1


## Multiplicador de dano pelo atributo de escala do golpe (ex.: destreza).
func damage_multiplier(attribute: String, per_point: float) -> float:
	if not ATTRIBUTE_NAMES.has(attribute):
		return 1.0
	var points := int(get(attribute))
	return maxf(0.5, 1.0 + (points - BASE_ATTRIBUTE) * per_point)


func _scaled(points: int, per_point: float) -> float:
	var full := mini(points, soft_cap)
	var reduced := maxi(points - soft_cap, 0)
	return full * per_point + reduced * per_point * 0.5


# --- Estamina -----------------------------------------------------------------------

## Regra Souls: basta ter QUALQUER estamina (> 0) e não estar exausto.
## Com 5 pontos você ainda dá um golpe de 18 — e entra em Exaustão.
func can_spend_stamina() -> bool:
	return not is_dead and not is_exhausted and stamina > 0.0


## Tenta gastar. Padrão "try_": retorna false e quem chamou decide o que fazer.
func try_spend_stamina(cost: float) -> bool:
	if not can_spend_stamina():
		return false
	_consume_stamina(cost)
	return true


## Drena estamina à força, ignorando as regras acima.
## Pensado para o Cassian Virel ("rouba estamina") e o Ácaro de Cristal.
func drain_stamina(amount: float) -> void:
	if not is_dead:
		_consume_stamina(amount)


func stamina_ratio() -> float:
	return stamina / max_stamina if max_stamina > 0.0 else 0.0


func _consume_stamina(amount: float) -> void:
	stamina = maxf(stamina - amount, 0.0)
	_regen_delay_left = regen_delay
	stamina_changed.emit(stamina, max_stamina)
	if stamina <= 0.0 and not is_exhausted:
		_set_exhausted(true)


func _regenerate_stamina(delta: float) -> void:
	if is_dead or stamina >= max_stamina:
		return
	if _regen_delay_left > 0.0:
		_regen_delay_left -= delta
		return
	var rate := stamina_regen_per_second * regen_scale
	if is_exhausted:
		rate *= exhausted_regen_multiplier
	stamina = minf(stamina + rate * delta, max_stamina)
	stamina_changed.emit(stamina, max_stamina)
	if is_exhausted and stamina >= max_stamina * exhaustion_recovery_ratio:
		_set_exhausted(false)


func _set_exhausted(value: bool) -> void:
	is_exhausted = value
	exhaustion_changed.emit(is_exhausted)


# --- Vida ---------------------------------------------------------------------------

## Aplica dano e devolve quanto realmente tirou.
func take_damage(amount: float) -> float:
	if is_dead or amount <= 0.0:
		return 0.0
	var applied := minf(amount, health)
	health -= applied
	damaged.emit(applied)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		is_dead = true
		died.emit()
	return applied


func heal(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	var before := health
	health = minf(health + amount, max_health)
	healed.emit(health - before)
	health_changed.emit(health, max_health)


## Define a vida diretamente (ex.: chefe que muda de fase com X% da vida).
func set_health(value: float) -> void:
	health = clampf(value, 0.0, max_health)
	health_changed.emit(health, max_health)


func health_ratio() -> float:
	return health / max_health if max_health > 0.0 else 0.0


## Volta à vida com tudo cheio (Câmara de descanso / renascer).
func revive() -> void:
	is_dead = false
	_regen_delay_left = 0.0
	if is_exhausted:
		_set_exhausted(false)
	recalculate(true)

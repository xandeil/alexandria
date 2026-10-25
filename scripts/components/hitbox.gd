class_name Hitbox
extends Area2D
## Área que CAUSA dano.
##
## Fica sempre monitorando, mas só machuca enquanto `active` for true (a janela
## ativa do golpe). Cada ativação acerta cada alvo no máximo UMA vez.
## Por que não ligar/desligar `monitoring`? A lista de sobreposições só atualiza
## no frame de física seguinte — o golpe chegaria atrasado.

signal hit_landed(hurtbox: Hurtbox, info: HitInfo)

## Quem desfere o golpe. Usado para não acertar a si mesmo e para o empurrão.
@export var source: Node2D

var active := false
var _damage := 0.0
var _poise_damage := 0.0
var _knockback := 0.0
var _is_heavy := false
var _unblockable := false
var _parryable := false
var _attack_name := ""
var _already_hit: Array[Area2D] = []


func _ready() -> void:
	monitoring = true
	monitorable = false


func activate_with(attack: AttackData, damage: float) -> void:
	activate_raw(damage, attack.poise_damage, attack.knockback, attack.is_heavy, attack.display_name, attack.unblockable,
		attack.parryable and not attack.unblockable)


## parryable: golpe "cru" (sem AttackData) não dá para aparar, a menos que diga.
func activate_raw(damage: float, poise_damage: float, knockback: float, is_heavy: bool = false, attack_name: String = "",
		unblockable: bool = false, parryable: bool = false) -> void:
	_damage = damage
	_poise_damage = poise_damage
	_knockback = knockback
	_is_heavy = is_heavy
	_attack_name = attack_name
	_unblockable = unblockable
	_parryable = parryable
	_already_hit.clear()
	active = true
	_scan()  # já testa no mesmo frame


func deactivate() -> void:
	active = false


func _physics_process(_delta: float) -> void:
	if active:
		_scan()


func _scan() -> void:
	for area in get_overlapping_areas():
		var hurtbox := area as Hurtbox
		if hurtbox == null or _already_hit.has(hurtbox):
			continue
		if hurtbox.owner_body != null and hurtbox.owner_body == source:
			continue
		_already_hit.append(hurtbox)
		var info := _build_info(hurtbox)
		if hurtbox.receive_hit(info):
			hit_landed.emit(hurtbox, info)


func _build_info(target: Hurtbox) -> HitInfo:
	var from := source.global_position if is_instance_valid(source) else global_position
	var info := HitInfo.create(_damage, from, target.global_position)
	info.poise_damage = _poise_damage
	info.knockback = _knockback
	info.is_heavy = _is_heavy
	info.unblockable = _unblockable
	info.parryable = _parryable
	info.attack_name = _attack_name
	info.source = source
	return info

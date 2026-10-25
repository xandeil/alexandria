class_name HitInfo
extends RefCounted
## "Pacote" com tudo sobre um golpe que acertou.
##
## Em vez de a Hurtbox receber o nó Hitbox inteiro (e depender dele), ela recebe
## só os dados. Isso é desacoplamento: amanhã uma armadilha de espinhos ou o
## hálito de fogo da Rachel podem criar um HitInfo sem ter Hitbox nenhuma.

var damage := 0.0
var poise_damage := 0.0
var knockback := 0.0
var is_heavy := false
## Passa por cima do escudo (grito, ondas no chão, agarrões).
var unblockable := false
## Dá para aparar (parry)? Só golpes de arma com AttackData.parryable. Tiros,
## ondas e agarrões montam o HitInfo na mão e ficam com false.
var parryable := false
var attack_name := ""
## Quem bateu (pode ser null, ex.: dano do cenário).
var source: Node2D
## De onde veio o golpe — usado para empurrão e para checar o escudo.
var source_position := Vector2.ZERO
## Direção normalizada do golpe (da fonte para o alvo).
var direction := Vector2.ZERO


static func create(amount: float, from_position: Vector2, to_position: Vector2) -> HitInfo:
	var info := HitInfo.new()
	info.damage = amount
	info.source_position = from_position
	info.direction = (to_position - from_position).normalized()
	return info

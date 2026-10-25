class_name WeaponSkill
extends RefCounted
## Habilidade única de uma arma — padrão STRATEGY.
##
## O herói não tem um "if arma == martelo ... elif arma == arco ...". Ele só
## chama os ganchos abaixo em momentos fixos do golpe; cada arma traz a SUA
## estratégia (WeaponSkills.create). Arma nova = classe nova, sem mexer no herói
## (aberto para extensão, fechado para modificação).
##
## Linha do tempo de um golpe e onde cada gancho entra:
##   apertou ──► extra_stamina()          (custa mais? ex.: Presa de Caelis)
##   ACTIVE  ──► fires_projectile()? fire() : liga a hitbox + on_active()
##   acertou ──► on_hit()

var weapon: WeaponData


## Estamina a mais que o golpe custa (no lugar de "mana", que o jogo não tem).
func extra_stamina(_attack: AttackData) -> float:
	return 0.0


## true = o golpe dispara um projétil (besta, arco) e NÃO liga a hitbox.
func fires_projectile(_attack: AttackData) -> bool:
	return false


func fire(_player: Player, _attack: AttackData, _damage: float, _direction: Vector2) -> void:
	pass


## A hitbox acabou de ligar (o instante do impacto).
func on_active(_player: Player, _attack: AttackData, _damage: float) -> void:
	pass


## O golpe acertou alguém (inimigo, cobertura...).
func on_hit(_player: Player, _target: Hurtbox, _info: HitInfo, _attack: AttackData) -> void:
	pass


# --- Ajudantes para as estratégias ----------------------------------------------------

## O inimigo dono da hurtbox (null para coberturas e afins).
static func enemy_of(target: Hurtbox) -> Enemy:
	if target == null or not is_instance_valid(target.owner_body):
		return null
	return target.owner_body as Enemy


## Inimigos vivos dentro de um círculo (vista 3/4: o círculo é achatado em Y).
static func enemies_in(tree: SceneTree, center: Vector2, radius: float) -> Array[Enemy]:
	var found: Array[Enemy] = []
	for node in tree.get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.dead or not enemy.is_visible_in_tree():
			continue
		var d := enemy.global_position - center
		if (d.x * d.x) + (d.y * d.y) / 0.6 <= radius * radius:
			found.append(enemy)
	return found


## Dano "de arma" fora da hitbox (onda, sangramento, raio...).
static func strike(enemy: Enemy, player: Player, damage: float, poise: float, name: String,
		heavy: bool = false, unblockable: bool = false, knockback: float = 60.0) -> void:
	if enemy == null or enemy.dead:
		return
	var info := HitInfo.create(damage, player.global_position, enemy.global_position)
	info.poise_damage = poise
	info.knockback = knockback
	info.is_heavy = heavy
	info.unblockable = unblockable
	info.attack_name = name
	info.source = player
	enemy.hurtbox.receive_hit(info)


## Imunes a puxão/empurrão: chefes e gigantes (Âncora da Gravidade).
static func is_heavyweight(enemy: Enemy) -> bool:
	return enemy is Boss or enemy.knockback_taken <= 0.05 or enemy.is_in_group("giants")

class_name WeaponSkills
extends RefCounted
## Fábrica das habilidades das armas (uma classe interna por arma).
## Todos os números de equilíbrio moram aqui em cima, com nome — nada de
## "número mágico" escondido no meio da lógica.

# Lâmina Desolada (Luxúria): a estocada que devolve fôlego.
const LAMINA_STAMINA_BACK := 0.75  ## fração do custo da estocada devolvida...
const LAMINA_STAMINA_FLAT := 6.0  ## ...mais este tanto. SÓ se acertar um inimigo.
# Pilar da Estilhaçada (Ira): onda de choque.
const PILAR_RADIUS := 42.0
const PILAR_DAMAGE := 0.5  ## fração do golpe que a onda causa em volta
# Presa de Caelis (Orgulho): rastro de fogo.
const CAELIS_EXTRA_STAMINA := 14.0  ## o "custo de mana"
const CAELIS_TRAIL_SECONDS := 3.0
const CAELIS_DPS_RATIO := 0.3  ## dano por segundo de cada chama = 30% do golpe
# Fuso do Arconte (Ganância): rouba o fôlego.
const FUSO_STEAL_LIGHT := 8.0
const FUSO_STEAL_HEAVY := 16.0
const FUSO_DRAIN_SECONDS := 3.0
# Replicador de Bronze (Inveja): o virote que salta.
const BRONZE_CHAIN_RADIUS := 80.0
const BRONZE_CHAIN_DAMAGE := 0.6
# Presas da Vorágine (Gula): sangramento + um gole de vida.
const VORAGEM_HEAL_BASE := 2.0
const VORAGEM_HEAL_PER_LUCK := 0.2  ## cura = 2 + Sorte × 0.2 (valor FIXO, não %)
const VORAGEM_BLEED_LIGHT := 22.0
const VORAGEM_BLEED_HEAVY := 40.0
const VORAGEM_BLEED_SPECIAL := 55.0  ## o Frenesi: cada estocada enche muito mais
const VORAGEM_BURST_RATIO := 0.15  ## estouro: 15% da vida máxima...
const VORAGEM_BURST_BOSS_RATIO := 0.04  ## ...4% num chefe
# Arco do Sono Eterno (Preguiça): nuvem de pólen.
const SONO_CLOUD_RADIUS := 34.0
const SONO_CLOUD_SECONDS := 4.0
# Âncora da Gravidade (Núcleo): o vórtice.
const ANCORA_RADIUS := 72.0
const ANCORA_SECONDS := 2.2
const ANCORA_BURST := 0.6


static func create(weapon: WeaponData) -> WeaponSkill:
	var skill: WeaponSkill
	match weapon.skill if weapon else "":
		"estocada_desolada":
			skill = LaminaDesolada.new()
		"onda_estilhacada":
			skill = PilarEstilhacada.new()
		"rastro_caelis":
			skill = PresaCaelis.new()
		"dreno_arconte":
			skill = FusoArconte.new()
		"virote_replicante":
			skill = ReplicadorBronze.new()
		"fome_voragem":
			skill = PresasVoragem.new()
		"polen_sono":
			skill = ArcoSono.new()
		"vortice_ancora":
			skill = AncoraGravidade.new()
		_:
			skill = WeaponSkill.new()  # Espada inicial: sem habilidade (Objeto Nulo)
	skill.weapon = weapon
	return skill


class LaminaDesolada extends WeaponSkill:
	func on_hit(player: Player, target: Hurtbox, _info: HitInfo, attack: AttackData) -> void:
		# Só inimigo conta: acertar uma caixa não vira "dash infinito" pelo mapa.
		if is_special(attack) and WeaponSkill.enemy_of(target) != null:
			player.stats.restore_stamina(attack.stamina_cost * LAMINA_STAMINA_BACK + LAMINA_STAMINA_FLAT)
			Fx.sparks(target.global_position, Vector2.UP, Color(0.85, 0.95, 1.0), 6)


class PilarEstilhacada extends WeaponSkill:
	func on_active(player: Player, attack: AttackData, damage: float) -> void:
		if not is_special(attack):
			return
		var center := player.hitbox_shape.global_position
		WeaponFx.ring(player.get_parent(), center, PILAR_RADIUS, Color(1.0, 0.7, 0.35))
		Fx.shake(6.0, 0.25)
		Sfx.play(&"shockwave", -4.0)
		for enemy in WeaponSkill.enemies_in(player.get_tree(), center, PILAR_RADIUS):
			# Postura 999 + "não bloqueável": escudo nenhum segura, todo mundo cambaleia.
			WeaponSkill.strike(enemy, player, damage * PILAR_DAMAGE, 999.0, "Onda Estilhaçada", true, true, 140.0)
		for node in player.get_tree().get_nodes_in_group(&"covers"):
			var cover := node as DestructibleCover
			if cover and cover.global_position.distance_to(center) <= PILAR_RADIUS + 10.0:
				cover.smash()


class PresaCaelis extends WeaponSkill:
	func extra_stamina(attack: AttackData) -> float:
		return CAELIS_EXTRA_STAMINA if is_special(attack) else 0.0

	func on_active(player: Player, attack: AttackData, damage: float) -> void:
		if not is_special(attack):
			return
		var direction := Vector2.from_angle(player.hitbox_pivot.rotation)
		for i in 3:  # três chamas em linha, no rastro do corte
			var at := player.global_position + direction * (12.0 + i * 13.0)
			FirePatch.spawn(player.get_parent(), at, 11.0, CAELIS_TRAIL_SECONDS, damage * CAELIS_DPS_RATIO, player)


class FusoArconte extends WeaponSkill:
	func on_hit(player: Player, target: Hurtbox, _info: HitInfo, attack: AttackData) -> void:
		var enemy := WeaponSkill.enemy_of(target)
		if enemy == null:
			return
		player.stats.restore_stamina(FUSO_STEAL_HEAVY if attack.is_heavy else FUSO_STEAL_LIGHT)
		EnemyStatus.of(enemy).apply_drain(FUSO_DRAIN_SECONDS)
		Fx.sparks(target.global_position, Vector2.UP, Color(0.7, 0.88, 1.0), 5)


class ReplicadorBronze extends WeaponSkill:
	func fires_projectile(_attack: AttackData) -> bool:
		return true

	func fire(player: Player, attack: AttackData, damage: float, direction: Vector2) -> void:
		var shot := PlayerShot.fire(player.get_parent(), player.global_position + direction * 6.0, direction,
			player, damage, PlayerShot.BOLT)
		var jumps := 2 if is_special(attack) else 1
		shot.struck.connect(func(target: Hurtbox, _info: HitInfo): _chain(player, target, damage, jumps))

	## O raio salta para o inimigo mais perto de quem levou o virote.
	func _chain(player: Player, first: Hurtbox, damage: float, jumps: int) -> void:
		var hit: Array[Node] = [first.owner_body]
		var from := first.global_position
		for j in jumps:
			var best: Enemy = null
			var best_d := BRONZE_CHAIN_RADIUS
			for enemy in WeaponSkill.enemies_in(player.get_tree(), from, BRONZE_CHAIN_RADIUS):
				var d := enemy.global_position.distance_to(from)
				if not hit.has(enemy) and d < best_d:
					best = enemy
					best_d = d
			if best == null or not is_instance_valid(player):
				return
			hit.append(best)
			var to := best.global_position + Vector2(0, -8)
			WeaponFx.lightning(player.get_parent(), from, to)
			WeaponSkill.strike(best, player, damage * BRONZE_CHAIN_DAMAGE, 12.0, "Raio Replicado")
			from = to


class PresasVoragem extends WeaponSkill:
	func on_hit(player: Player, target: Hurtbox, _info: HitInfo, attack: AttackData) -> void:
		var enemy := WeaponSkill.enemy_of(target)
		if enemy == null:
			return
		var luck := int(Game.attributes.get("sorte", 10))
		player.stats.heal(VORAGEM_HEAL_BASE + luck * VORAGEM_HEAL_PER_LUCK)
		var amount := VORAGEM_BLEED_LIGHT
		if is_special(attack):
			amount = VORAGEM_BLEED_SPECIAL
		elif attack.is_heavy:
			amount = VORAGEM_BLEED_HEAVY
		if EnemyStatus.of(enemy).add_bleed(amount):
			var ratio := VORAGEM_BURST_BOSS_RATIO if enemy is Boss else VORAGEM_BURST_RATIO
			var burst := maxf(10.0, enemy.stats.max_health * ratio)
			# Sangramento é por DENTRO: escudo não segura e não empurra ninguém.
			Fx.sparks(enemy.global_position + Vector2(0, -8), Vector2.UP, Color(0.75, 0.05, 0.1), 14)
			Fx.flash(enemy.body_sprite, 0.12, Color(1.0, 0.2, 0.25))
			Sfx.play(&"splat", -4.0)
			enemy.stats.take_damage(burst)


class ArcoSono extends WeaponSkill:
	func fires_projectile(_attack: AttackData) -> bool:
		return true

	func fire(player: Player, attack: AttackData, damage: float, direction: Vector2) -> void:
		var kind := PlayerShot.POLLEN if is_special(attack) else PlayerShot.ARROW
		var shot := PlayerShot.fire(player.get_parent(), player.global_position + direction * 6.0, direction,
			player, damage, kind)
		if is_special(attack):
			shot.landed.connect(func(at: Vector2, parent: Node):
				SlumberPollen.spawn(parent, at, SONO_CLOUD_RADIUS, SONO_CLOUD_SECONDS))


class AncoraGravidade extends WeaponSkill:
	func on_active(player: Player, attack: AttackData, damage: float) -> void:
		if not is_special(attack):
			return
		var center := player.hitbox_shape.global_position
		GravityVortex.spawn(player.get_parent(), center, ANCORA_RADIUS, ANCORA_SECONDS, damage * ANCORA_BURST, player)
		Fx.shake(4.0, 0.2)

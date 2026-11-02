class_name SpellCaster
## v0.50 (Etapa 10) — O QUE CADA MAGIA FAZ quando sai da mão do herói.
## O Player só cuida do estado (CAST: parar, brilhar, gastar estamina); a
## forma da magia mora aqui. Uma função por forma, fácil de ler e de testar.

const HURTBOX_MASK := 16  # a camada das hurtboxes inimigas (a mesma da espada)
## +4% de poder por ponto acima de 10 no atributo da escola.
const PER_POINT := 0.04


## O poder desta magia com os atributos de agora.
static func power_of(spell: SpellData, caster: Player) -> float:
	# v0.51: Conjunto de Aprendiz / Vestes de Romeira somam poder ("magia_poder").
	return spell.power * caster.stats.damage_multiplier(spell.scaling_attribute(), PER_POINT) \
		* (1.0 + Game.armor_bonus("magia_poder"))


static func release(spell: SpellData, caster: Player, direction: Vector2) -> void:
	var power := power_of(spell, caster)
	Sfx.play(_sound(spell), -2.0)
	match spell.form:
		"projetil":
			var shot := PlayerShot.fire(caster.get_parent(), caster.global_position + direction * 8.0, direction,
				caster, power, PlayerShot.SPELL)
			shot.color = spell.color
			shot.damage_type = spell.damage_type
			shot.poise_damage = spell.poise_damage
			shot.knockback = spell.knockback
			shot.max_distance = spell.reach
			shot.speed = spell.projectile_speed
			shot.attack_name = spell.display_name
		"frente":
			_hit_around(spell, caster, power, direction, 70.0)
			SpellBurst.spawn(caster.get_parent(), caster.global_position + Vector2(0, -6), spell.reach, spell.color, direction)
		"area":
			_hit_around(spell, caster, power, Vector2.ZERO, 180.0)
			SpellBurst.spawn(caster.get_parent(), caster.global_position + Vector2(0, -6), spell.reach, spell.color)
			Fx.splash(caster.global_position + Vector2(0, -6), spell.color, 28)
			Fx.shake(3.0, 0.2)
		"cura":
			caster.stats.heal(power)
			Fx.splash(caster.global_position + Vector2(0, -12), spell.color, 14)
			if spell.em_area:
				for node in caster.get_tree().get_nodes_in_group(&"allies"):
					var ally := node as Ally
					if ally and not ally.fallen and ally.global_position.distance_to(caster.global_position) <= spell.reach:
						ally.health = minf(ally.health + power, ally.max_health)
						Fx.splash(ally.global_position + Vector2(0, -10), spell.color, 8)
		"barreira":
			caster.raise_barrier(spell.barrier_ratio, spell.duration, spell.color)


## Acerta todo inimigo no raio (e, com "direction", só num leque de ±half_angle).
static func _hit_around(spell: SpellData, caster: Player, power: float, direction: Vector2, half_angle: float) -> int:
	var hits := 0
	var center := caster.global_position
	for node in caster.get_tree().get_nodes_in_group(&"enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.dead or not enemy.is_targetable():
			continue
		var to := enemy.global_position - center
		if to.length() > spell.reach:
			continue
		if direction != Vector2.ZERO and to.length() > 1.0 and absf(rad_to_deg(direction.angle_to(to))) > half_angle:
			continue
		var info := HitInfo.create(power, center, enemy.global_position)
		info.poise_damage = spell.poise_damage
		info.knockback = spell.knockback
		info.attack_name = spell.display_name
		info.damage_type = spell.damage_type
		info.source = caster
		if enemy.hurtbox.receive_hit(info):
			hits += 1
	return hits


static func _sound(spell: SpellData) -> StringName:
	match spell.damage_type:
		"fogo":
			return &"fireball"
		"raio":
			return &"zap"
		"gelo":
			return &"ice_shot"
	return &"chime" if spell.form in ["cura", "barreira"] else &"echo"

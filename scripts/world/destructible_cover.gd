@tool
class_name DestructibleCover
extends StaticBody2D
## Cobertura de concreto da arena do Aldir.
##
## • É sólida: bloqueia a passagem E a Onda de Choque (camada "mundo").
## • Recebe golpes por uma Hurtbox, exatamente como um personagem: quem bate
##   não precisa saber que é uma barreira (mesma interface = polimorfismo).
## • Bíblia: na fase 1 o Aldir "ainda pensa" (mal arranha as coberturas); na
##   fase 2 ele destrói o cenário. Quem diz o quanto um golpe estraga é o
##   AUTOR do golpe, pelo método opcional cover_damage_multiplier().

signal destroyed(cover: DestructibleCover)

const TEXTURE := preload("res://assets/props/cover.png")

@export var max_health := 70.0
## Aparência própria de cada ilha (3 quadros: inteira, rachada, quebrada).
## Vazio = o concreto da Cidade. Na Montanha, são rochas.
@export var texture_override: Texture2D

var health := 70.0
var broken := false
var _sprite: Sprite2D
var _shape: CollisionShape2D
var _hurtbox: Hurtbox
var _shake_tween: Tween


func _ready() -> void:
	add_to_group(&"covers")
	collision_layer = 1  # mundo: bloqueia corpos, raios de visão e ondas de choque
	collision_mask = 0
	health = max_health
	_shape = CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(24, 9)
	_shape.shape = box
	_shape.position = Vector2(0, -5)
	add_child(_shape)
	_sprite = Sprite2D.new()
	_sprite.texture = texture_override if texture_override else TEXTURE
	_sprite.hframes = 3
	_sprite.offset = Vector2(0, -11)
	add_child(_sprite)
	if Engine.is_editor_hint():
		return  # no editor (@tool) só o desenho: a Hurtbox não roda lá
	_hurtbox = Hurtbox.new()
	_hurtbox.collision_layer = 8  # mesma camada da hurtbox do herói: golpes de inimigos acertam
	_hurtbox.collision_mask = 0
	_hurtbox.owner_body = self
	var hurt_shape := CollisionShape2D.new()
	var hurt_box := RectangleShape2D.new()
	hurt_box.size = Vector2(26, 16)
	hurt_shape.shape = hurt_box
	hurt_shape.position = Vector2(0, -8)
	_hurtbox.add_child(hurt_shape)
	add_child(_hurtbox)
	_hurtbox.hit_received.connect(_on_hit_received)


func _on_hit_received(info: HitInfo) -> void:
	var multiplier := 1.0
	if is_instance_valid(info.source) and info.source.has_method("cover_damage_multiplier"):
		multiplier = info.source.cover_damage_multiplier()
	take_damage(info.damage * multiplier, info.direction)


func take_damage(amount: float, direction: Vector2 = Vector2.ZERO) -> void:
	if broken or amount <= 0.0:
		return
	health -= amount
	Fx.sparks(global_position + Vector2(0, -8), -direction if direction != Vector2.ZERO else Vector2.UP, Color(0.86, 0.84, 0.78), 6)
	Sfx.play(&"block", -8.0)
	_jolt()
	if health <= 0.0:
		smash()
	else:
		_sprite.frame = 1 if health <= max_health * 0.5 else 0


## Destrói na hora (investida, salto, buraco abrindo embaixo).
func smash() -> void:
	if broken:
		return
	broken = true
	health = 0.0
	_sprite.frame = 2
	_sprite.z_index = -8  # vira entulho no chão: não cobre mais ninguém
	_shape.set_deferred("disabled", true)
	_hurtbox.set_deferred("monitorable", false)
	remove_from_group(&"covers")
	Fx.dust(global_position + Vector2(0, -4), 16)
	Fx.sparks(global_position + Vector2(0, -8), Vector2.UP, Color(0.8, 0.78, 0.72), 14, 150.0)
	Sfx.play(&"crumble")
	Fx.shake(3.0, 0.2)
	destroyed.emit(self)


func _jolt() -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	_sprite.position = Vector2.ZERO
	_shake_tween = create_tween()
	_shake_tween.tween_property(_sprite, "position:x", 1.5, 0.04)
	_shake_tween.tween_property(_sprite, "position:x", -1.5, 0.05)
	_shake_tween.tween_property(_sprite, "position:x", 0.0, 0.04)

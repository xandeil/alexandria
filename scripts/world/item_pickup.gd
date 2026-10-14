class_name ItemPickup
extends Area2D
## Item no chão: brilha, flutua e é pego ao ENCOSTAR (sem botão).
##
## Por que encostar e não "Interagir"? No celular o botão de interação é o
## mesmo da cura: um item caído no meio da luta roubaria o seu frasco. Pegar
## andando por cima é o padrão de jogos de ação no touch.
##
## Dois tipos, mesma classe:
##   • do MAPA (caractere "@"): têm persist_key e nunca voltam depois de pegos;
##   • DROP de inimigo: sem chave, somem ao trocar de área.

signal collected(pickup: ItemPickup)

const LIGHT_TEXTURE := preload("res://assets/fx/light.png")
## Cor do brilho por tipo de item (o jogador aprende a ler o chão).
const GLOW := {
	ItemData.Kind.EQUIPAMENTO: Color(1.0, 0.85, 0.55),
	ItemData.Kind.MATERIAL: Color(0.85, 0.9, 1.0),
	ItemData.Kind.LEMBRANCA: Color(1.0, 0.6, 0.5),
	ItemData.Kind.CONSUMIVEL: Color(1.0, 0.5, 0.5),
}

var item_id := ""
var count := 1
## "" = drop de inimigo (não fica salvo).
var persist_key := ""

var _sprite: Sprite2D
var _time := 0.0
var _taken := false
var _popping := false


static func create(id: String, amount: int = 1, key: String = "") -> ItemPickup:
	var pickup := ItemPickup.new()
	pickup.item_id = id
	pickup.count = amount
	pickup.persist_key = key
	pickup.name = "Item_%s" % id
	return pickup


## Drop de inimigo: "salta" do corpo para o chão ao lado.
## Usa call_deferred: o inimigo morre DENTRO de um callback de física (o golpe),
## e o Godot não deixa criar áreas de colisão no meio dessa conta.
static func drop(parent: Node, at: Vector2, id: String, amount: int = 1) -> void:
	var pickup := create(id, amount)
	pickup.position = at
	parent.call_deferred("add_child", pickup)
	pickup.ready.connect(pickup._pop, CONNECT_ONE_SHOT)


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # só o corpo do herói
	monitorable = false
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 9.0
	shape.shape = circle
	shape.position = Vector2(0, -4)
	add_child(shape)
	var item := Items.get_item(item_id)
	var glow: Color = GLOW.get(item.kind, Color.WHITE) if item else Color.WHITE
	var light := PointLight2D.new()
	light.texture = LIGHT_TEXTURE
	light.color = glow
	light.energy = 0.7
	light.texture_scale = 0.3
	light.position = Vector2(0, -8)
	add_child(light)
	_sprite = Sprite2D.new()
	_sprite.texture = item.icon if item else null
	_sprite.scale = Vector2(0.8, 0.8)
	_sprite.position = Vector2(0, -8)
	_sprite.material = Fx.unshaded  # brilha mesmo nas áreas escuras
	add_child(_sprite)
	_time = randf() * TAU
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _taken or _popping:
		return
	_time += delta
	_sprite.position.y = -8.0 + sin(_time * 3.0) * 1.5
	_sprite.modulate = Color(1, 1, 1).lerp(Color(1.4, 1.4, 1.4), (sin(_time * 4.0) + 1.0) * 0.5)


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player and not player.is_dead():
		take()


func take() -> void:
	if _taken:
		return
	_taken = true
	Game.add_item(item_id, count)
	if not persist_key.is_empty():
		Game.collect_pickup(persist_key)
		Game.save_game()  # item do mapa: pegou, está pego (mesmo se o app fechar agora)
	Sfx.play(&"pickup", -3.0)
	Fx.splash(global_position + Vector2(0, -8), Color(1.0, 1.0, 0.9), 8)
	collected.emit(self)
	set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property(_sprite, "position:y", -22.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_sprite, "modulate:a", 0.0, 0.35)
	tween.tween_callback(queue_free)


func _pop() -> void:
	_popping = true
	var landing := global_position + Vector2(randf_range(-10.0, 10.0), randf_range(-4.0, 6.0))
	var tween := create_tween()
	tween.tween_property(self, "global_position", landing, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_sprite, "position:y", -18.0, 0.15).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(_sprite, "position:y", -8.0, 0.15).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): _popping = false)

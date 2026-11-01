class_name CollapsingFloor
extends Node
## CHÃO QUE DESABA DURANTE UMA LUTA (v0.35, Etapa 6): o Viaduto Partido cede
## aos poucos enquanto você luta com a Couraça Andante.
##
## Liga quando o mini-chefe acorda; a cada `interval` segundos um pedaço do
## retângulo racha (aviso) e vira buraco (ArenaPit: o dash passa por cima,
## andar para dentro = cair). No fim da luta, ganhe ou fuja, os buracos
## entopem de entulho — o caminho volta a existir.
##
## No mapa: Level.collapse_fights → {"boss": "couraca", "rect": Rect2i(14, 5, 30, 3),
##   "interval": 2.6, "max": 10}

const TILE := 16

var rect := Rect2()
var interval := 2.6
var max_pits := 10
var _left := 0.0
var _pits: Array[ArenaPit] = []
var active := false


static func create(parent: Node, def: Dictionary) -> CollapsingFloor:
	var floor_node := CollapsingFloor.new()
	var cells: Rect2i = def.get("rect", Rect2i())
	floor_node.rect = Rect2(Vector2(cells.position * TILE), Vector2(cells.size * TILE))
	floor_node.interval = float(def.get("interval", 2.6))
	floor_node.max_pits = int(def.get("max", 10))
	parent.add_child(floor_node)
	return floor_node


func start() -> void:
	active = true
	_left = interval * 0.5


## A luta acabou: o entulho tapa tudo.
func stop() -> void:
	active = false
	for pit in _pits:
		if is_instance_valid(pit) and pit.is_active():
			pit.fill()
	_pits.clear()


func _physics_process(delta: float) -> void:
	if not active:
		return
	_left -= delta
	if _left > 0.0:
		return
	_left = interval
	var alive := _pits.filter(func(p): return is_instance_valid(p) and p.is_active())
	if alive.size() >= max_pits:
		return
	var at := Vector2(randf_range(rect.position.x + 12.0, rect.end.x - 12.0), randf_range(rect.position.y + 8.0, rect.end.y - 8.0))
	var pit := ArenaPit.create(at, Vector2(14, 9), 1.0)
	get_parent().add_child(pit)
	_pits.append(pit)
	Fx.shake(1.5, 0.2)

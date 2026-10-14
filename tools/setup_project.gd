extends SceneTree
## Ferramenta (rode UMA vez, na raiz do projeto):
##   godot --headless --script res://tools/setup_project.gd
## 1) Registra as ações de controle no project.godot (Input Map).
## 2) Gera os TileSets (com colisão nas paredes) a partir dos atlas em assets/tiles.
## Usar o próprio Godot para escrever esses arquivos garante o formato certo.

const TILE := Vector2i(16, 16)

const ACTIONS := {
	"move_left": {"keys": [KEY_A, KEY_LEFT], "axis": [JOY_AXIS_LEFT_X, -1.0], "pad": [JOY_BUTTON_DPAD_LEFT]},
	"move_right": {"keys": [KEY_D, KEY_RIGHT], "axis": [JOY_AXIS_LEFT_X, 1.0], "pad": [JOY_BUTTON_DPAD_RIGHT]},
	"move_up": {"keys": [KEY_W, KEY_UP], "axis": [JOY_AXIS_LEFT_Y, -1.0], "pad": [JOY_BUTTON_DPAD_UP]},
	"move_down": {"keys": [KEY_S, KEY_DOWN], "axis": [JOY_AXIS_LEFT_Y, 1.0], "pad": [JOY_BUTTON_DPAD_DOWN]},
	"attack": {"keys": [KEY_J], "pad": [JOY_BUTTON_X]},
	"attack_heavy": {"keys": [KEY_K], "pad": [JOY_BUTTON_RIGHT_SHOULDER]},
	"dash": {"keys": [KEY_SPACE], "pad": [JOY_BUTTON_B]},
	"heal": {"keys": [KEY_E, KEY_H], "pad": [JOY_BUTTON_Y]},
	"sanity": {"keys": [KEY_Q], "pad": [JOY_BUTTON_LEFT_SHOULDER]},
	"block": {"keys": [KEY_L, KEY_SHIFT], "axis": [JOY_AXIS_TRIGGER_LEFT, 1.0]},
	"inventory": {"keys": [KEY_I, KEY_TAB], "pad": [JOY_BUTTON_BACK]},
	"pause": {"keys": [KEY_ESCAPE, KEY_P], "pad": [JOY_BUTTON_START]},
}

## Atlas → tiles com colisão (coordenadas no atlas). O resto é só piso.
const TILESETS := {
	"res://assets/tiles/teatro_tileset.tres": {
		"texture": "res://assets/tiles/teatro_tiles.png", "size": Vector2i(8, 3),
		"solid": [Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1),
			Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],
	},
	"res://assets/tiles/cidade_tileset.tres": {
		"texture": "res://assets/tiles/cidade_tiles.png", "size": Vector2i(8, 2),
		"solid": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(6, 1)],
	},
	"res://assets/tiles/bosque_tileset.tres": {
		"texture": "res://assets/tiles/bosque_tiles.png", "size": Vector2i(8, 3),
		# Mata fechada (copas e troncos), barreira e a ÁGUA: o lago parado é sólido.
		"solid": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(6, 1),
			Vector2i(7, 1), Vector2i(0, 2), Vector2i(1, 2)],
	},
	"res://assets/tiles/raizes_tileset.tres": {
		"texture": "res://assets/tiles/raizes_tiles.png", "size": Vector2i(8, 3),
		# Raízes (topo, faces, vidraça, arco), barreira e as poças de seiva.
		"solid": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(6, 1),
			Vector2i(7, 1), Vector2i(0, 2), Vector2i(1, 2)],
	},
	"res://assets/tiles/laboratorio_tileset.tres": {
		"texture": "res://assets/tiles/laboratorio_tiles.png", "size": Vector2i(8, 3),
		"solid": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
			Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1)],
	},
}


func _init() -> void:
	_setup_input()
	_make_tilesets()
	quit()


func _setup_input() -> void:
	for action in ACTIONS:
		var spec: Dictionary = ACTIONS[action]
		var events: Array = []
		for keycode in spec.get("keys", []):
			var key := InputEventKey.new()
			key.device = -1  # -1 = qualquer dispositivo
			key.physical_keycode = keycode
			events.append(key)
		if spec.has("axis"):
			var motion := InputEventJoypadMotion.new()
			motion.device = -1
			motion.axis = spec["axis"][0]
			motion.axis_value = spec["axis"][1]
			events.append(motion)
		for button in spec.get("pad", []):
			var pad := InputEventJoypadButton.new()
			pad.device = -1
			pad.button_index = button
			events.append(pad)
		ProjectSettings.set_setting("input/" + action, {"deadzone": 0.2, "events": events})
	var error := ProjectSettings.save()
	print("Input Map salvo: ", error_string(error))


func _make_tilesets() -> void:
	for path in TILESETS:
		var spec: Dictionary = TILESETS[path]
		var tileset := TileSet.new()
		tileset.tile_size = TILE
		tileset.add_physics_layer()
		tileset.set_physics_layer_collision_layer(0, 1)  # camada "mundo"
		tileset.set_physics_layer_collision_mask(0, 0)
		var source := TileSetAtlasSource.new()
		source.texture = load(spec["texture"])
		source.texture_region_size = TILE
		tileset.add_source(source, 0)
		var size: Vector2i = spec["size"]
		var half := Vector2(TILE) * 0.5
		var square := PackedVector2Array([-half, Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])
		for y in size.y:
			for x in size.x:
				var coords := Vector2i(x, y)
				source.create_tile(coords)
				if spec["solid"].has(coords):
					var data := source.get_tile_data(coords, 0)
					data.add_collision_polygon(0)
					data.set_collision_polygon_points(0, 0, square)
		var error := ResourceSaver.save(tileset, path)
		print("TileSet ", path, ": ", error_string(error))

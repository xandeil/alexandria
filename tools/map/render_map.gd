extends Node
## Fotografa cada região INTEIRA (o mapa todo, não só o que a câmera mostra) e
## salva em PNG. Depois, tools/map/compose_world_map.py monta o mapa-múndi.
##
## Uso (na raiz do projeto, com tela — xvfb-run no servidor):
##   godot --path . res://tools/map/render_map.tscn -- --out=PASTA
##
## Como funciona: cada fase é carregada dentro de um SubViewport do tamanho do
## mapa em texto (levels/*.txt × 16 px). Uma câmera nossa mostra tudo; o HUD e
## a escuridão (CanvasModulate) ficam desligados para o mapa ficar legível.

const REGIONS := ["prologo", "teatro", "cidade", "arena_aldir", "bosque", "arena_nyssa", "raizes", "arena_mabel",
	"forjas", "arena_durgan", "montanha", "arena_rachel", "dominio", "arena_cassian", "nucleo", "coracao"]
const TILE := 16

var out_dir := "user://mapa"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out_dir)
	Game.persistence_enabled = false
	Game.scene_changes_enabled = false
	Game.reset_progress()
	Game.prologue_done = true
	for region in REGIONS:
		await _render(region)
	get_tree().quit()


func _map_size(region: String) -> Vector2i:
	var scene := load("res://scenes/world/%s.tscn" % region) as PackedScene
	var probe := scene.instantiate() as Level
	var path := probe.layout_file
	probe.free()
	var lines := FileAccess.get_file_as_string(path).split("\n")
	var width := 0
	var height := 0
	for line in lines:
		if line.strip_edges(false, true).is_empty() and height == 0:
			continue
		width = maxi(width, line.length())
		height += 1
	return Vector2i(width, height) * TILE


func _render(region: String) -> void:
	var size := _map_size(region)
	var viewport := SubViewport.new()
	viewport.size = size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.transparent_bg = false
	add_child(viewport)
	Game.pending_spawn = "camara" if region != "coracao" else "inicio"
	var level := (load("res://scenes/world/%s.tscn" % region) as PackedScene).instantiate() as Level
	viewport.add_child(level)
	for i in 20:
		await get_tree().process_frame
	# Tudo visível e claro: sem HUD, sem escuridão, sem a câmera que segue o herói.
	if level.hud:
		level.hud.visible = false
		for child in level.hud.get_children():
			if child is CanvasLayer:
				(child as CanvasLayer).visible = false
	for node in level.find_children("*", "CanvasModulate", true, false):
		(node as CanvasModulate).color = Color(1, 1, 1)
	for node in level.find_children("*", "CanvasLayer", true, false):
		(node as CanvasLayer).visible = false
	var camera := Camera2D.new()
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera.position = Vector2.ZERO
	camera.limit_left = -100000
	camera.limit_top = -100000
	camera.limit_right = 100000
	camera.limit_bottom = 100000
	camera.position_smoothing_enabled = false
	viewport.add_child(camera)
	camera.make_current()
	get_tree().paused = false
	for i in 8:
		await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	image.save_png(out_dir.path_join("%s.png" % region))
	print("mapa: %s %dx%d" % [region, size.x, size.y])
	viewport.queue_free()
	await get_tree().process_frame

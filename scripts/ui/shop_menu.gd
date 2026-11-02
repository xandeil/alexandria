class_name ShopMenu
extends SoulsMenu
## A loja do Vendedor Dragonoide: COMPRAR (o que ele tem) e VENDER (o que ele
## aceita da sua mochila). Mesmo esqueleto do inventário (SoulsMenu), com a
## cor de brasa dele e o retrato no canto.
##
## O menu não sabe preços nem estoque: pergunta tudo ao Game (shop_price,
## shop_left, sell_price...). Trocar um preço é mexer num lugar só.
##
## v0.49 (Etapa 10): a mesma tela serve a TODAS as lojas (Game.MERCHANTS).
## run(player, "damiao") abre a do Damião, com a cor, o retrato e a fala dele.

const ICON_MEMORY := preload("res://assets/ui/icon_memory.png")
## O que ele diz quando não dá (motivo vem do Game).
const REASONS := {
	"memories": "\"Memórias de menos. Volte quando lembrar de mais coisas.\"",
	"esgotado": "\"Acabou. Não pergunte de onde vinham.\"",
	"cheio": "\"Você já carrega o máximo disso.\"",
}


var merchant := "vendedor"


func _init() -> void:
	_apply_merchant()


func _apply_merchant() -> void:
	var info: Dictionary = Game.MERCHANTS[merchant]
	accent = info["cor"]
	keeper_name = info["nome"]
	keeper_line = info["fala"]
	portrait_texture = load(info["retrato"])


## Abre a loja deste vendedor (padrão: o Dragonoide).
func open_shop(player: Player = null, merchant_id: String = "vendedor") -> void:
	merchant = merchant_id if Game.MERCHANTS.has(merchant_id) else "vendedor"
	_apply_merchant()
	apply_keeper()
	await run(player)


func _tabs() -> Array[String]:
	return ["Comprar", "Vender"]


func _entries(tab_index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if tab_index == 0:
		for stock: Dictionary in Game.merchant_stock(merchant):
			var id: String = stock["id"]
			var reason := Game.shop_block_reason(id, merchant)
			result.append({"id": id, "icon": Items.get_item(id).icon, "corner": str(Game.shop_price(id, merchant)),
				"dim": reason == "esgotado"})
	else:
		for entry in Game.sellable_items(merchant):
			result.append({"id": entry["id"], "icon": Items.get_item(entry["id"]).icon, "corner": "x%d" % entry["count"]})
	return result


func _show_detail(id: String) -> void:
	var item := Items.get_item(id)
	detail_icon.texture = item.icon
	detail_name.text = item.display_name
	detail_kind.text = ItemData.KIND_NAMES[item.kind] if not item is WeaponData else (item as WeaponData).weapon_class
	detail_text.text = item.description
	if item is WeaponData:
		add_scaling_table(item as WeaponData)
	if _tab == 0:
		var left := Game.shop_left(id, merchant)
		var have := Game.sanity_flasks if id == "frasco_sanidade" else Game.item_count(id)
		detail_stats.text = "Você tem: %d%s" % [have, "\nRestam: %d" % left if left >= 0 else ""]
		add_cost_line(ICON_MEMORY, "Preço: %d memórias" % Game.shop_price(id, merchant), Game.memories >= Game.shop_price(id, merchant))
		detail_status.text = REASONS.get(Game.shop_block_reason(id, merchant), "")
	else:
		var count := 0
		for entry in Game.sellable_items(merchant):
			if entry["id"] == id:
				count = entry["count"]
		detail_stats.text = "Você tem: %d para vender" % count
		add_cost_line(ICON_MEMORY, "Ele paga: %d memórias" % Game.sell_price(id, merchant), true)
		if item is WeaponData:
			detail_status.text = "A arma que está na sua mão não entra na venda."


func _activate(id: String) -> void:
	var done := Game.buy_from_shop(id, merchant) if _tab == 0 else Game.sell_to_shop(id, merchant)
	if not done:
		Sfx.play(&"ui_click")
		_selected = ""
		select(id)
		return
	Sfx.play(&"memory")
	_line.text = "\"Negócio fechado.\"" if _tab == 0 else "\"Hm. Aceito. Não pergunto de onde veio.\""
	_selected = ""
	refresh()
	flash_slot(id)


func _hint_items() -> Array:
	return [["cross", "Enter", "Comprar" if _tab == 0 else "Vender"], ["circle", "Esc", "Sair"], ["L1/R1", "Q/E", "Comprar/Vender"]]

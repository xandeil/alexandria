class_name Ice
extends RefCounted
## A regra do chão escorregadio (Domínio Congelado), num lugar só.
##
## Há dois tipos de gelo: o do MAPA (o caractere "=" no tema "gelo" vira
## `Level.ice_cells`) e o que aparece na luta (as `FrostZone` do Cassian).
## O herói não precisa saber de onde vem o gelo: ele só pergunta
## `Ice.is_slippery(self)`. Se amanhã surgir um terceiro tipo, muda aqui.


static func is_slippery(node: Node2D) -> bool:
	if node == null or not node.is_inside_tree():
		return false
	var level := Level.find(node)
	if level and level.is_ice(Level.cell_at(node.global_position)):
		return true
	for zone in node.get_tree().get_nodes_in_group(&"frost_zones"):
		if (zone as FrostZone).is_frozen() and (zone as FrostZone).covers(node.global_position):
			return true
	return false

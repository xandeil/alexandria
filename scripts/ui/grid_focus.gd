class_name GridFocus
## Navegação do CONTROLE numa grade de espaços (inventário, Loja, Forja).
##
## O defeito (feedback, v0.30.4): sem vizinhos definidos, o Godot escolhe "o
## botão mais perto" na direção apertada. Na última coluna, → não tinha nada à
## direita... e o mais perto era o "Voltar" lá embaixo: o cursor fugia da grade.
##
## A regra, num lugar só:
##   • ←/→ andam NA MESMA LINHA, dando a volta (→ na última coluna volta à 1ª);
##     se a tela tiver uma coluna à esquerda (o "Equipado" do inventário),
##     ← na 1ª coluna vai para ela;
##   • ↑/↓ trocam de linha; ↑ na 1ª linha fica parado;
##     ↓ na última linha vai para o botão de baixo ("Voltar"/"Sair").


## slots: os espaços na ordem da grade. columns: colunas da GridContainer.
## below: para onde ↓ sai da grade. left_exit: para onde ← sai (null = dá a volta).
static func link(slots: Array[Button], columns: int, below: Control, left_exit: Control = null) -> void:
	var count := slots.size()
	if count == 0:
		return
	for i in count:
		var slot := slots[i]
		var row_start := i - i % columns
		var row_size := mini(columns, count - row_start)
		var column := i - row_start
		var left: Control = slots[row_start + posmod(column - 1, row_size)]
		if column == 0 and left_exit:
			left = left_exit
		var right: Control = slots[row_start + posmod(column + 1, row_size)]
		var up: Control = slots[i - columns] if i >= columns else slot
		var down: Control = below
		if i + columns < count:
			down = slots[i + columns]
		elif row_start + columns < count:
			down = slots[count - 1]  # linha de baixo mais curta: vai para o último
		slot.focus_neighbor_left = slot.get_path_to(left)
		slot.focus_neighbor_right = slot.get_path_to(right)
		slot.focus_neighbor_top = slot.get_path_to(up)
		slot.focus_neighbor_bottom = slot.get_path_to(down) if down else NodePath()
		slot.focus_previous = slot.get_path_to(slots[posmod(i - 1, count)])
		slot.focus_next = slot.get_path_to(slots[posmod(i + 1, count)])
	if below:
		below.focus_neighbor_top = below.get_path_to(slots[0])
		below.focus_neighbor_left = below.get_path_to(below)
		below.focus_neighbor_right = below.get_path_to(below)

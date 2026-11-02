class_name ButtonData
extends ItemData
## v0.53 (Etapa 12) — UM BOTÃO. O jogo não tem anéis nem talismãs: tem botões,
## caídos da roupa de alguém. Só funciona o que está DENTRO da Lata de Botões
## (4 espaços); na mochila não faz nada.
##
## Os efeitos são regras pequenas (~10%), lidas por Game.button_bonus(efeito):
##   rolamento, magia_dano, postura, folego, def_fogo, sono, acordar, feitico,
##   milagre, def_raio, pos_esquiva, memoria, fragil, frasco, socorro, carga,
##   dano_fogo, firme, def_gelo, sem_escorregar, custo_magia, pouca_vida.
## Um botão pode mexer em mais de uma (o Arrancado: mais memórias, menos defesa).

@export var effects := {}
## O que o botão faz, para a ficha ("Rolamento +15%").
@export var effect_text := ""

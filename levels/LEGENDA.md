# Legenda dos mapas (levels/*.txt)

Cada caractere = uma célula de 16×16 px. Edite o `.txt` em qualquer editor de
texto e rode o jogo (ou marque **Rebuild** no nó da fase, dentro do editor).

| Caractere | O que é | Sólido? |
|---|---|---|
| `#` | parede (vira "face" de tijolo/concreto se houver chão embaixo) | sim |
| `n` | parede com arco | sim |
| `\|` | cortina vermelha (Teatro) | sim |
| ` ` (espaço) | vazio — na Cidade é o céu; borda invisível impede cair | sim |
| `.` | piso (pedra no Teatro, asfalto na Cidade) | não |
| `,` | tapete (Teatro) / calçada (Cidade) | não |
| `{` `}` | tapete vermelho do corredor (borda esquerda/direita) | não |
| `=` | palco (Teatro) / faixa pintada na rua (Cidade) | não |
| `-` | borda do palco com luzes de ribalta | não |
| `_` | soleira de porta | não |
| `:` | piso escuro | não |
| `k` | piso com lascas / entulho | não |
| `~` | rachadura em brasa (Cidade) | não |
| `;` | entulho (Cidade) | não |
| `g` | terra e grama (borda da ilha) | não |
| `r` `R` `t` | poltrona vermelha, vermelha quebrada, bege | sim |
| `T` | tocha (fica numa parede) | sim |
| `I` | pilar | sim |
| `C` | Câmara de descanso (ocupa 2 células para a direita; uma por área) | sim |
| `D` | saída para outra área (configure no nó da fase: `exit_scene`/`exit_spawn`) | não |
| `P` | ponto de início alternativo | não |
| `H` | Helena sentada na plateia | sim |
| `Y` | onde o chefe aterrissa ao começar a luta | não |
| `M` | névoa da arena do chefe (aparece no desafio) | só na luta |
| `F` `V` `A` `O` | Fada, Vendedor (com balcão), Ferreiro (com forja e bigorna), Orbe | sim (Fada/Orbe não) |
| `B` | boneco de treino | sim |
| `W` | estante de armas | sim |
| `S` | Soldado Remendado (renasce ao descansar) | — |
| `d` `y` `v` | Cão de Guerra, Atirador de Telhado, Civil Cinzento (renascem ao descansar) | — |
| `h` `w` | mini-chefes: Sargento Sem Pelotão, Couraça Andante (não voltam depois de vencidos) | — |
| `>` | segunda saída (`exit2_scene`/`exit2_spawn`; com `exit2_requires` fica trancada até vencer aquele chefe) — no Teatro, a porta do Bosque | só trancada |
| **Bosque do Sono Eterno** | | |
| `~` | lago parado (sólido; com margem de grama se há terra acima) | sim |
| `<` | lago na borda da ilha + cachoeira caindo para o céu | sim |
| `(` `)` `[` `]` | árvore, arbusto, tronco caído (2 células), soldado dormindo em pé | árvore/tronco/soldado |
| `z` `s` `^` `?` | Sonâmbulo, Flor de Pólen, Cervo de Musgo, Fada Murcha (renascem ao descansar) | — |
| `U` `0` | mini-chefes: o Vigia que Dormiu, a Mãe dos Esporos | — |
| `/` | Nyssa Lumevel, deitada no ar (`arena_nyssa.txt`) | — |
| `'` | terceira saída (`exit3_scene`/`exit3_spawn`/`exit3_requires`; quem chega aparece em "oeste") — no Teatro, a porta das Raízes | só trancada |
| **Raízes da Fome** (os MESMOS caracteres do Bosque, outro significado: `THEME_ENTITIES`/`THEME_PROPS` no `level.gd`) | | |
| `.` `,` `:` `;` | terra oliva, ladrilho da estufa, xadrez da cozinha, chão de veias | não |
| `~` | poça de seiva (sólida, com margem) | sim |
| `(` `)` `[` `]` | raiz retorcida, fruto de carne, canteiro da estufa (2 células), fogão | raiz/canteiro/fogão |
| `z` `s` `^` `?` | Boca de Raiz, Inchado, Colhedor, Larvas de Seiva (um enxame de 3) | — |
| `U` `0` | mini-chefes: O Banqueteiro, A Ninhada | — |
| `/` | Mabel Vorágine (`arena_mabel.txt`) | — |
| **Forjas Ocas** (tema "forjas") | | |
| `.` `,` `:` `;` | laje de pedra, cinza, grade da fábrica, entulho | não |
| `=` | **placa de metal**: conduz o raio das torretas e de Durgan | não |
| `~` | canal de metal derretido (sólido) | sim |
| `(` `)` `[` `]` | corrente da Âncora, engrenagens, prensa (2 células), estátua de bronze | corrente/prensa/estátua |
| `z` `s` `^` `?` | Autômato de Bronze, Torreta de Faísca, Minerador Oco, Imitador | — |
| `U` `0` | mini-chefes: O Protótipo, O Guardião da Âncora | — |
| `/` | Durgan Vell (`arena_durgan.txt`) | — |
| **Montanha Carbonizada** (tema "montanha") | | |
| `.` `,` `g` `;` | cinza, basalto, mato queimado, entulho | não |
| `k` `:` | rachadura em brasa, ossos (decoração) | não |
| `~` | lava (sólida, com margem) | sim |
| `(` `)` `[` `]` | árvore queimada, costelas, crânio de dragão (2 células), espinho de obsidiana | árvore/crânio/espinho |
| `z` `s` `^` `?` | Dragonoide Atirador, Dragão Bestial, Dragão Alado, Brasas Vivas (2) | — |
| `U` `0` | mini-chefes: O Capitão Dragonoide, A Matriarca Bestial | — |
| `/` | Rachel, dormindo no Ninho (`arena_rachel.txt`) | — |
| `Q` | aqui é um **pilar de rocha** (segura o hálito; o rugido derruba) | sim, até quebrar |
| **Domínio Congelado** (tema "gelo") | | |
| `.` `,` `g` `;` | laje com neve, taco da biblioteca, neve, entulho | não |
| `=` | **GELO**: o herói escorrega (`Level.ice_cells`) | não |
| `k` `:` | veio de cristal, páginas soltas (decoração) | não |
| `~` | buraco no lago congelado (água escura, sólida) | sim |
| `(` `)` `[` `]` | cristais, leitor preso no gelo, estante congelada (2 células), vitrine | todos |
| `z` `s` `^` `?` | Bibliotecário de Gelo, Estátua Viva, Ácaros de Cristal (3), Aprendiz Arcano | — |
| `U` `0` | mini-chefes: A Curadora de Vitrines, O Golem do Arquivo (deixa o livro) | — |
| `/` | Cassian Virel (`arena_cassian.txt`) | — |
| `!` | o Estudioso (congelado até a Curadora cair) | sim |
| **O Núcleo** (tema "nucleo") | | |
| `.` `,` `g` `;` | mármore, grama, flores, musgo | não |
| `k` `=` | veio dourado, caminho de luz | não |
| `~` | espelho d'água (sólido) | sim |
| `(` `)` `[` `]` | coluna partida, arbusto, arco partido (2 células), estátua de um dos Sete | coluna/arco/estátua |
| `/` | o Cavaleiro Desolado (`coracao.txt`) | — |
| `U` | a mulher ligada ao núcleo (a escolha final) | sim |
| `` ` `` | quarta saída (`exit4_*`; quem chega aparece em "palco") — no Teatro, a escada de luz até o Núcleo (`"sete"`) | só trancada |
| `@` | item no chão; QUAL item vem de `item_points` no nó da fase, na ordem de leitura (`"escudo_remendado"`, `"sucata_temperada:2"`) — pego uma vez, não volta | não |
| `X` `x` `f` `L` `c` `K` | barricada, entulho, fogo, poste, caixote, carro destruído | variam |
| `G` | portão do Detentor do Caos: falar com ele leva à arena do Aldir | sim |
| `Z` | Aldir Cornélios, ajoelhado diante do martelo (acorda quando você chega perto) | sim |
| `Q` | cobertura de concreto destrutível (segura a Onda de Choque) | sim, até quebrar |
| `e` | ponto de inspeção na borda da ilha | não |
| **Laboratório (Prólogo)** | | |
| `a` `o` `q` | cápsula ocupada, vazia, quebrada (2 células para a direita) | sim |
| `l` | terminal com a tela verde | sim |
| `b` | caminha de criança | sim |
| `m` | mesa comprida do refeitório (2 células de largura, sobe 5 células a partir daqui) | sim |
| `u` `p` `i` | brinquedos, planta, cabos no chão | não |
| `%` `&` `$` `j` | numa parede: riscos de giz, desenho, luz verde, trepadeira | sim (é parede) |
| `*` `+` | criança, adolescente (renascem ao descansar) | — |
| `N` | a Governanta, sentada na cabeceira (5 células acima do `m`) | sim |
| `E` | porta de saída (2 células: `E.`); tranca se ela lutar | só fechada |
| `!` | o chão que some (a queda até o Teatro) | não |
| `J` | a Criança Poupada (Teatro; só aparece se ninguém foi ferido) | não |
| `1`–`9` | ponto de inspeção: o texto vem de `lore_points` no nó da fase | não |

A arena de cada chefe é o retângulo `arena_rect_tiles` no nó da fase
(x, y, largura, altura em células): Helena no `Teatro`, Aldir na `ArenaAldir`, Nyssa na `ArenaNyssa`, Mabel na `ArenaMabel`, Durgan na `ArenaDurgan`,
a Governanta (o refeitório) no `Prologo`.
Os buracos do martelo não ficam no mapa: abrem durante a luta.

## v0.31 — Listas do Inspector (sem caractere no mapa)

Algumas coisas não usam letra no `.txt`: ficam em listas no nó da fase, com a
célula (x, y) em tiles. Assim não faltam caracteres e não há conflito entre temas.

| Lista | Para quê | Exemplo |
|---|---|---|
| `exits` | saídas extras, sem o limite de 4 | `{"cell": Vector2i(40, 6), "scene": "res://scenes/world/teatro.tscn", "spawn": "tunel", "requires": "flag:atalho_tunel", "locked_dialogue": "tunel_trancado", "arrival": "tunel"}` |
| `zones` | retângulo com regra para os inimigos de dentro e fio de alarme | `{"id": "quartel", "rect": Rect2i(10, 4, 8, 6), "requires": "!flag:corneteiro_morto", "triggers": [Vector2i(12, 9)]}` |
| `objects` | alavanca, baú, porta de atalho (lembram o estado para sempre) | `{"kind": "atalho", "cell": Vector2i(12, 5), "key": "atalho_galho", "abre_de": "oeste", "locked_dialogue": "galho_trancado"}` |
| `traps` | armadilha que dispara num ritmo | `{"kind": "pilao", "cells": [Vector2i(8, 6)], "period": 2.4, "offset": 0.0, "damage": 30}` |
| `extra_capsules` | Câmaras extras (a `C` do mapa é a 1ª, ponto `camara`; estas viram `camara_2`...) | `[Vector2i(32, 18)]` |
| `collapse_fights` | chão que desaba durante a luta de um mini-chefe (o entulho tapa no fim) | `{"boss": "couraca", "rect": Rect2i(14, 5, 30, 3), "interval": 2.6, "max": 10}` |
| `decor` | enfeite solto (com `dialogue` vira Examinar) | `{"cell": Vector2i(70, 13), "texture": "res://assets/props/aviso_cadaver_mesa.png"}` |

`objects` também aceita `{"kind": "mimico", "cell": ..., "key": "mimico_cidade", "item": "fragmento_turvo"}`
— o mímico é o baú comum espelhado; vencido, não volta nunca.

Chefe com a arena mudando de fase: `phase_arena` no nó do chefe (`ArenaShift`), ex.
`{2: {"fogo_borda": 2, "cresce": 14.0, "max": 4, "dps": 12.0}}` — anel de fogo
que fecha a arena. Também há `"escuro": 0.4` (a luz cai).


# Alexandria — Guia de Arte

Este guia mostra **onde mora cada desenho do jogo**: personagens, chefes, inimigos, NPCs, armas, armaduras, botões, magias, cenários e interface. Se você vai ajudar com o design, comece por aqui.

> Você **não precisa saber programar**. Para trocar um desenho, basta substituir o arquivo `.png` (veja [Como entregar um desenho](#como-entregar-um-desenho)).

*Atualizado para a versão **0.53.0**.*

---

## Índice

1. [Regras de ouro](#regras-de-ouro)
2. [Quero desenhar… (atalho)](#quero-desenhar-atalho)
3. [Protagonista e aparências](#protagonista-e-aparências)
4. [Chefes](#chefes)
5. [Inimigos comuns por área](#inimigos-comuns-por-área)
6. [NPCs, lojistas e aliados](#npcs-lojistas-e-aliados)
7. [Armas](#armas)
8. [Armaduras](#armaduras)
9. [Botões (a Lata de Botões)](#botões-a-lata-de-botões)
10. [Magias](#magias)
11. [Outros itens](#outros-itens)
12. [Cenário: tiles e objetos](#cenário-tiles-e-objetos)
13. [Efeitos, interface e ícones](#efeitos-interface-e-ícones)
14. [Desenhos que estão "emprestados" (oportunidade!)](#desenhos-que-estão-emprestados-oportunidade)
15. [Como entregar um desenho](#como-entregar-um-desenho)
16. [Referências visuais](#referências-visuais)

---

## Regras de ouro

| Regra | Por quê |
|---|---|
| **Pixel art**, sem suavização (sem *anti-aliasing*) | O jogo é todo em pixels nítidos. |
| **Fundo transparente** (PNG) | O jogo desenha por cima do cenário. |
| **Personagens olham para a DIREITA** | O jogo espelha sozinho quando precisa olhar para a esquerda. |
| **Mantenha o tamanho do arquivo** | O jogo corta a imagem em quadros iguais. Mudar o tamanho desalinha a animação. |
| **Mantenha o nome do arquivo** | O jogo acha a imagem pelo nome. |
| **Use a [paleta do jogo](referencias/paleta.png)** | Mantém tudo com a mesma cara (cores tiradas das imagens de referência). |
| **Estilo "chibi"** (cabeça grande) | É a direção de arte: crianças do prólogo, Soul Knight. |

**Animações:** a maioria dos sprites é uma **faixa horizontal de quadros do mesmo tamanho** (ex.: o herói tem 4 quadros de 24×24, então o arquivo tem 96×24). Para saber a divisão de um sprite, divida a largura do arquivo pela largura do quadro.

### Tamanhos de referência

| O quê | Tamanho |
|---|---|
| Herói, Soldado, crianças | quadro de 24×24 |
| Helena Altiva | quadro de 32×32 |
| Governanta | quadro de 32×40 |
| Aldir | quadro de 40×40 |
| Aliados (Lúcia, Galeno, Tião, Bastião, Heitor) | arquivo de 80×26 |
| NPCs lojistas e de história (Damião, Dalva, Amaro…) | arquivo de 40×26 |
| Tiles (chão, parede…) | quadradinhos de 16×16 |
| Ícones de item, armadura, botão e magia | 16×16 |
| Ícones de interface | 16×16 |
| Miniaturas das Câmaras | 64×40 |

Os demais variam. Quando tiver dúvida, **abra o arquivo original e use o tamanho dele**.

---

## Quero desenhar… (atalho)

| Quero desenhar… | Vá em… |
|---|---|
| O herói / a heroína | [assets/sprites/](../assets/sprites/) → `player*.png` |
| Rosto, corpo, cabelo da criação de personagem | [player_aparencias.png](../assets/sprites/player_aparencias.png) |
| Um chefe | [Chefes](#chefes) |
| Um inimigo comum | [Inimigos comuns](#inimigos-comuns-por-área) |
| Um NPC, lojista ou aliado | [NPCs, lojistas e aliados](#npcs-lojistas-e-aliados) |
| Uma arma (na mão ou ícone) | [Armas](#armas) |
| Uma peça de armadura | [Armaduras](#armaduras) |
| Um botão da Lata | [Botões](#botões-a-lata-de-botões) |
| Um ícone de magia | [Magias](#magias) |
| Chão, parede, água de uma região | [assets/tiles/](../assets/tiles/) |
| Árvore, pilar, estátua, baú, poço… | [assets/props/](../assets/props/) |
| Fogo, poeira, sombra, nuvem | [assets/fx/](../assets/fx/) |
| Botões e ícones na tela | [assets/ui/](../assets/ui/) |
| Ícone do app | [assets/icon/](../assets/icon/) |
| Imagens da loja (Play Store) | [docs/loja/](loja/) |

---

## Protagonista e aparências

Pasta: [assets/sprites/](../assets/sprites/)

| Arquivo | O que é |
|---|---|
| `player.png` | Corpo do herói (4 quadros de 24×24) |
| `player_sword.png` | Espada inicial na mão (15×6) |
| `escudo_heroi.png` | Escudo na mão |
| `punhos.png` | Punhos (quando está sem arma) |
| `player_aparencias.png` | **Todas as aparências da criação de personagem.** Faixa vertical de **90 combinações** (2 sexos × 3 corpos × 3 rostos × 5 cabelos), 24×24 cada |

As cores de **cabelo e olhos** do herói são "cores-chave": o jogo clareia esses tons a cada morte. Se mudar o desenho, **mantenha os mesmos tons** (`HAIR`, `HAIR_LIGHT`, `EYE` em [palette.py](../tools/art/palette.py)).

O **Experimento Anterior** (chefe do NG+ e do final "Proteger") usa o **mesmo sprite do herói**, então mexer no `player.png` muda os dois.

---

## Chefes

Pasta: [assets/sprites/](../assets/sprites/)

### Os Sete Pecados

| Pecado | Chefe | Área | Arquivos |
|---|---|---|---|
| Luxúria | **Helena Altiva** | Teatro Alexandria | `helena_body`, `helena_helmet`, `helena_pauldron_back`, `helena_pauldron_front`, `helena_breastplate`, `helena_cape`, `helena_sword`, `helena_seated` |
| Ira | **Aldir Cornélios** | Cidade Estilhaçada | `aldir_body`, `aldir_eyes`, `aldir_hammer`, `aldir_kneel` |
| Preguiça | **Nyssa Lumevel** | Bosque do Sono Eterno | `nyssa` |
| Gula | **Mabel Vorágine** | Raízes da Fome | `mabel` |
| Inveja | **Durgan Vell** | Forjas Ocas | `durgan`, `durgan_chave` |
| Orgulho | **Rachel Azheryon Caelis** | Montanha Carbonizada | `rachel` |
| Ganância | **Cassian Virel** | Domínio Congelado | `cassian` |

> A armadura da Helena é **em peças separadas** (elmo, ombreiras, peitoral, capa). Ela perde as peças ao longo das fases, então desenhe cada uma por si.

### Chefe final e prólogo

| Chefe | Arquivos |
|---|---|
| **Cavaleiro Desolado** (final, Núcleo) | `cavaleiro`, `mulher_nucleo` |
| **A Governanta** (Prólogo) | `governanta_body`, `governanta_chaves`, `governanta_olhando`, `governanta_sentada`, `governanta_solto` |
| **Experimento Anterior** (NG+) | usa o sprite do herói |

### Mini-chefes

| Área | Mini-chefe | Arquivos |
|---|---|---|
| Cidade | O Sargento Sem Pelotão | `sargento`, `sabre` |
| Cidade | A Couraça Andante | `couraca`, `couraca_clava` |
| Bosque | O Vigia que Dormiu | `vigia`, `vigia_clava` |
| Bosque | A Mãe dos Esporos | `mae_esporos` |
| Raízes | O Banqueteiro | `banqueteiro` |
| Raízes | A Ninhada | `ninhada` |
| Raízes | **Pitoco** (a Toca do Pitoco) | `pitoco` |
| Forjas | O Protótipo | `prototipo` |
| Forjas | O Guardião da Âncora | `guardiao_ancora` |
| Forjas | A Dançarina de Engrenagem (opcional) | `dancarina` |
| Montanha | O Capitão Dragonoide | `capitao_dragonoide` |
| Montanha | A Matriarca Bestial | `matriarca_bestial` |
| Domínio | A Curadora de Vitrines | `curadora_vitrines` |
| Domínio | O Golem do Arquivo | `golem_arquivo` |
| Laboratório | **Galeno, O Escudo Que Chegou Tarde** | `galeno_chefe`, `galeno_sem_escudo` |
| Bosque | **Os Sebastiões** (dupla, duas barras de vida) | `tiao_aliado`, `bastiao_aliado` |
| Bosque | O Sino de Despertar (opcional) | `sino_despertar` |
| Raízes | O Socorro (opcional, na Enfermaria) | `socorro` |

### Farm da Montanha

| Quem | Arquivo |
|---|---|
| Bezerro Dourado | `bezerro_dourado` |
| Minotauro | `minotauro` |

---

## Inimigos comuns por área

Pasta: [assets/sprites/](../assets/sprites/). Cada inimigo tem `nome.png` e, se for animado, `nome_frames.tres`: **não mexa no `.tres`**.

| Área | Inimigos |
|---|---|
| **Prólogo** | `crianca_a`, `crianca_b`, `adolescente`, `crianca_poupada`, `tito`, `wooden_sword` |
| **Cidade Estilhaçada** | Soldado Remendado (`soldier`, `soldier_shield`, `soldier_baton`) · Cão de Guerra (`cao`) · Atirador de Telhado (`atirador`, `fuzil`) · Civil Cinzento (`civil`) |
| **Bosque do Sono Eterno** | Sonâmbulo (`sonambulo`) · Flor de Pólen (`flor_polen`) · Cervo de Musgo (`cervo`) · Fada Murcha (`fada_murcha`) |
| **Raízes da Fome** | Boca de Raiz (`boca_de_raiz`) · Inchado (`inchado`) · Colhedor (`colhedor`) · Larva de Seiva (`larva_seiva`) · Raiz Velha (`raiz_veia`) |
| **Forjas Ocas** | Autômato de Bronze (`automato`) · Torreta de Faísca (`torreta`) · Minerador Oco (`minerador`) · Imitador (`imitador`, `imitador_espada`, `imitador_escudo`) |
| **Montanha Carbonizada** | Dragonoide Atirador (`dragonoide_atirador`) · Dragão Bestial (`dragao_bestial`) · Dragão Alado (`dragao_alado`) · Brasa Viva (`brasa_viva`) |
| **Domínio Congelado** | Bibliotecário de Gelo (`bibliotecario_gelo`) · Estátua Viva (`estatua_viva`) · Ácaro de Cristal (`acaro_cristal`) · Aprendiz Arcano (`aprendiz_arcano`) |

---

## NPCs, lojistas e aliados

Pasta: [assets/sprites/](../assets/sprites/)

### Teatro (hub)

| Quem | Arquivo |
|---|---|
| Ferreiro (anão) | `npc_ferreiro` |
| Vendedor Dragonoide | `npc_vendedor` |
| Fada | `npc_fada` |
| Orbe Branco | `npc_orbe` |
| Boneco de treino | `training_dummy` |

### Lojistas (vão se mudando para o Teatro)

| Quem | Vende | Arquivos |
|---|---|---|
| **Damião**, o Sucateiro (Viaduto) | itens baratos, compra "Algo Quebrado" | `damiao_npc` |
| **Dona Dalva** (Bosque) | feitiços | `dalva_npc`, `dalva_xale_npc` (versão com xale) |
| **Seu Cícero** (quartel da Cidade) | piromancias | `cicero_npc` |
| **Dona Benedita** (beirada do Bosque) | milagres | `benedita_npc` |

### História e aliados

Cada aliado tem **duas versões**: `_npc` (conversando) e `_aliado` (lutando ao seu lado).

| Quem | Arquivos | Onde |
|---|---|---|
| **Lúcia Avelar** | `lucia_npc`, `lucia_aliado` | Viaduto, Borda, Galeria |
| **Galeno Vaz** | `galeno_npc`, `galeno_aliado` | Forjas, Raízes, Montanha |
| **Tião** | `tiao_npc`, `tiao_aliado` | Dormitório do Bosque |
| **Bastião** | `bastiao_npc`, `bastiao_aliado` | Encosta |
| **Heitor** (marido de Helena) | `heitor_npc`, `heitor_aliado` | Cidade, Forjas, Domínio |
| **Amaro Bonfim** | `amaro_npc` | Cidade, Bosque, Forjas, Varanda |
| **Tito** (filho do Galeno) | `tito` | Dormitório do laboratório |
| **Estudioso** | `estudioso`, `estudioso_congelado` | Domínio Congelado |

> **Guarda Sem Posto:** `guarda`, `guarda_npc`, `posto_vazio` e `anel_do_guarda` são **antigos**. O Heitor substituiu o Guarda (v0.45), e esses arquivos já não são usados.

---

## Armas

Cada arma tem **dois desenhos**:

| Desenho | Pasta | Como desenhar |
|---|---|---|
| **Na mão** (o que o herói segura) | [assets/sprites/](../assets/sprites/) → `arma_NOME.png` | **Deitada, apontando para a DIREITA, cabo na esquerda.** O jogo gira e espelha. |
| **Ícone** (inventário e chão) | [assets/items/](../assets/items/) → `NOME.png` | 16×16, a mesma arma **na diagonal**. |

### Armas de chefe (forjadas pelo Ferreiro com a Lembrança)

A arma não é uma cópia do que o chefe usa: é a **"alma"** dele virando ferramenta. Use as cores do chefe.

| Arma | Chefe | Visual |
|---|---|---|
| `lamina_desolada` | Helena (Luxúria) | Sabre fino, aço claro com fio carmesim |
| `pilar_estilhacada` | Aldir (Ira) | Martelo de cabo longo e cabeça rachada |
| `presa_caelis` | Rachel (Orgulho) | Espada larga de escama, fio em brasa |
| `fuso_arconte` | Cassian (Ganância) | Lança dourada com ponta de cristal de gelo |
| `replicador_bronze` | Durgan (Inveja) | Besta de bronze com bobina elétrica |
| `presas_voragem` | Mabel (Gula) | Adaga curva, lâmina cor de carne |
| `arco_sono` | Nyssa (Preguiça) | Arco de galho com flores |
| `ancora_gravidade` | Cavaleiro (Núcleo) | Machado pesado de lâmina negra |

### Outras armas

| Arma | Observação |
|---|---|
| `corrente_igual` | A **Corrente do Igual** (chicote), do Fosso das Correntes. Na mão: `arma_corrente_igual` (28×5) |
| `espada` | Espada inicial |
| `espada_grande_cobaia`, `lanca_cobaia`, `martelo_cobaia`, `adaga_cobaia`, `arco_cobaia` | As 5 armas comuns da "Cobaia" (uma é escolhida na criação de personagem) |
| `espada_madeira_pequena` | A Espada de Madeira Pequena (do Tito) |

### Escudos

`escudo_remendado` (ícone em `assets/items/`), `escudo_heroi` (na mão, em `assets/sprites/`) e `escudo_sem_dono` (o escudo do Galeno).

---

## Armaduras

São **10 conjuntos de 5 peças = 50 ícones**, todos **16×16**, em [assets/items/](../assets/items/).

O nome do arquivo é `armadura_CONJUNTO_PEÇA.png`. Exemplo: `armadura_eco_botas.png`.

**Peças (5):** `capacete` · `peitoral` · `luvas` · `calca` · `botas`

| Conjunto (arquivo) | Nome no jogo | Efeito |
|---|---|---|
| `vigilia` | Traje da Vigília | Vida |
| `detentor` | Armadura do Detentor | Força |
| `sono` | Vestes do Sono Leve | Recuperação de estamina |
| `banquete` | Trapos do Banquete | Drops (fartura) |
| `eco` | Couraça do Eco | Alcance |
| `caelis` | Escamas de Caelis | Velocidade de passo |
| `arconte` | Manto do Arconte | Memórias |
| `aprendiz` | Conjunto de Aprendiz | Poder de magia |
| `bombeiro` | Conjunto do Bombeiro | Vida |
| `romeira` | Vestes de Romeira | Poder de magia |

> **Dica de design:** a forma de cada peça é igual em todos os conjuntos, e o que muda é a **paleta** (cada conjunto tem a sua). Se for redesenhar, o ideal é entregar **a forma e a paleta** separadas, ou então as 50 imagens prontas.

---

## Botões (a Lata de Botões)

**20 botões**, todos **16×16**, em [assets/items/](../assets/items/) (`botao_NOME.png`). Cada um é um botão de roupa de alguém (o jogo os guarda numa lata, e eles dão efeitos). Mais o ícone da lata: `lata_de_botoes`.

| | | | | |
|---|---|---|---|---|
| `botao_arrancado` | `botao_avental` | `botao_bombeiro` | `botao_bronze` | `botao_cerzido` |
| `botao_corneteiro` | `botao_corrente` | `botao_de_casaco` | `botao_engrenagem` | `botao_escama` |
| `botao_farda` | `botao_giz` | `botao_jaleco` | `botao_musgo` | `botao_pijama` |
| `botao_romeira` | `botao_sino` | `botao_socorro` | `botao_tunica_azul` | `botao_vestido` |
| `botao_vidro` | | | | |

O script é [botoes_etapa12.py](../tools/art/botoes_etapa12.py).

---

## Magias

**13 magias**, ícones **16×16** em [assets/items/](../assets/items/). Três escolas, cada uma com um lojista:

| Escola | Lojista | Ícones |
|---|---|---|
| **Feitiço** (Dona Dalva) | Dalva | `projetil_arcano`, `lamina_magica`, `escudo_de_geada`, `feitico_dalva` |
| **Piromancia** (Seu Cícero) | Cícero | `bola_de_fogo`, `explosao_curta`, `chicote_de_chamas`, `rua_em_chamas` |
| **Milagre** (Dona Benedita) | Benedita | `milagre_cura`, `milagre_barreira`, `cura_em_area`, `lanca_de_raio`, `tempestade` |

> Há também o item `gelo_perpetuo`, ligado à história do Seu Cícero (também 16×16). O script das magias é [magias_etapa10.py](../tools/art/magias_etapa10.py).

---

## Outros itens

Pasta: [assets/items/](../assets/items/) (todos 16×16)

| Tipo | Arquivos |
|---|---|
| **Lembranças** (uma por pecado) | `lembranca_helena`, `lembranca_aldir`, `lembranca_rachel`, `lembranca_cassian`, `lembranca_durgan`, `lembranca_mabel`, `lembranca_nyssa`, `lembranca_cavaleiro`, `lembranca_governanta` |
| **Materiais** | `sucata_temperada`, `fragmento_turvo`, `fragmento_de_loja`, `algo_quebrado` |
| **De história (lore)** | `bilhete_dobrado`, `bolinha_de_gude`, `dente_de_leite`, `fita_desbotada`, `oculos_rachados`, `meio_pingente`, `desenho_a_giz`, `caixa_musica_bronze`, `flor_de_pedra`, `licor_da_vigilia` |
| **Especiais** | `apito_sargento` |

---

## Cenário: tiles e objetos

### Tiles (chão, paredes, água…)

Pasta: [assets/tiles/](../assets/tiles/). Um arquivo por região, com quadradinhos de **16×16** numa grade.

| Região | Arquivo |
|---|---|
| Prólogo (laboratório) | `laboratorio_tiles.png` |
| Teatro Alexandria | `teatro_tiles.png` |
| Cidade Estilhaçada | `cidade_tiles.png` |
| Bosque do Sono Eterno | `bosque_tiles.png` |
| Raízes da Fome | `raizes_tiles.png` |
| Forjas Ocas | `forjas_tiles.png` |
| Montanha Carbonizada | `montanha_tiles.png` |
| Domínio Congelado | `gelo_tiles.png` |
| O Núcleo | `nucleo_tiles.png` |

> A **ordem dos quadradinhos importa**: o jogo sabe que "coluna 2, linha 1" é uma parede, por exemplo. **Não mude a posição**, só o desenho dentro de cada quadrado.

### Objetos de cenário (props)

Pasta: [assets/props/](../assets/props/)

| Região | Objetos |
|---|---|
| **Prólogo** | `capsule`, `capsule_occupied`, `capsule_empty`, `capsule_broken`, `capsule_body`, `capsule_lid`, `terminal`, `cot`, `toys`, `plant`, `cables`, `long_table`, `lab_door`, `lab_tally`, `lab_drawing`, `lab_lamp`, `lab_vines` |
| **Teatro** | `seat_red`, `seat_red_broken`, `seat_tan`, `debris`, `torch`, `pillar`, `forge`, `anvil`, `counter`, `weapon_rack` |
| **Teatro em ruínas** (depois da Helena) | `lustre_caido`, `camarote_caido`, `cortina_rasgada`, `heitor_memorial`, `elmo_heitor` |
| **Cidade** | `barricade`, `rubble`, `fire`, `lamp_post`, `gate`, `crate`, `car_wreck`, `cover`, `quartel_bombeiros`, `poco`, `buraco_gritos`, `mochila_damiao`, `heitor_no_gelo` |
| **Bosque** | `tree`, `bush`, `log`, `sleeping_soldier`, `waterfall`, `flower_bed` |
| **Raízes** | `root_tangle`, `flesh_pod`, `planter`, `stove`, `mabel_table`, `aviso_cadaver_mesa` |
| **Forjas** | `chain_post`, `gear_pile`, `press`, `bronze_statue`, `estatua_sem_rosto` |
| **Montanha** | `burnt_tree`, `ribcage`, `dragon_skull`, `obsidian_spike`, `rock_cover`, `scale_memorial`, `aviso_soldado_queimado`, `escudo_jogado` |
| **Domínio Congelado** | `crystal_cluster`, `frozen_reader`, `frozen_bookshelf`, `display_case`, `ice_pillar`, `lore_book`, `arconte_staff`, `mesa_de_cha` |
| **Núcleo** | `ruin_column`, `flower_bush`, `broken_arch`, `sin_statue` |
| **Em várias áreas** | `bau_fechado`, `bau_aberto`, `bau_quebrado`, `mimico_aberto`, `placa_capsula` |
| **Antigo (não usado)** | `posto_vazio` |

### Cada região em uma frase (para se inspirar)

| Região | Clima |
|---|---|
| Teatro Alexandria | Pedra verde-acinzentada, tapete oliva, poltronas vermelhas e bege, palco de madeira, cortinas carmim, tochas quentes |
| Cidade Estilhaçada | Cidade futurista partida, asfalto escuro, rachaduras em brasa, fogo que nunca apaga |
| Bosque do Sono Eterno | Floresta verde demais, lago parado, cachoeiras lentas |
| Raízes da Fome | Raízes vermelhas que pulsam como veias, estufas de vidro, cozinha de xadrez |
| Forjas Ocas | Ruínas de pedra por cima, fábrica subterrânea por baixo, metal derretido |
| Montanha Carbonizada | Floresta queimada, ossos de dragões, lava, cinza no ar |
| Domínio Congelado | Cidade de cristais de gelo, bibliotecas congeladas, pessoas presas no gelo |
| O Núcleo | A ilha mais alta, jardim com ruínas |

---

## Efeitos, interface e ícones

| O quê | Pasta | Exemplos |
|---|---|---|
| **Efeitos** (partículas, sombras, rachaduras, projéteis) | [assets/fx/](../assets/fx/) | `spark`, `dust`, `shadow`, `bola_de_fogo`, `estilhaco_gelo`, `zzz`, `pollen_cloud`, `bala`, nuvens `cloud_1..3` |
| **Ícones dos botões do jogo** (16×16) | [assets/ui/](../assets/ui/) | `icon_attack`, `icon_dash`, `icon_heal`, `icon_sanity`, `icon_interact`, `icon_memory`, `icon_pause`, `icon_block` |
| **Miniaturas das Câmaras** (64×40) | [assets/ui/](../assets/ui/) | `capsula_prologo`, `capsula_teatro`, `capsula_cidade`, `capsula_bosque`, `capsula_raizes`, `capsula_forjas`, `capsula_montanha`, `capsula_dominio`, `capsula_nucleo` |
| **Mapa da tela de título** | [assets/ui/](../assets/ui/) | `title_map.jpg` |
| **Ícone do app** | [assets/icon/](../assets/icon/) | `icon_foreground`, `icon_background`, `icon_monochrome` |
| **Imagens da loja** | [docs/loja/](loja/) | `icone_512.png`, `destaque_1024x500.png`, `capturas/` |
| **Vídeo de abertura** | [assets/cutscenes/](../assets/cutscenes/) | `abertura.ogv` (1280×720, ~69 s) |

As miniaturas das Câmaras são montadas com **os próprios tiles da região**, então elas mudam sozinhas quando você muda os tiles.

> Os **ícones dos botões do controle** (✕, ○, ▢, △…) não são arquivos de imagem: o jogo os desenha por código, e mudam conforme o controle (PlayStation, Xbox, Nintendo, genérico).

---

## Desenhos que estão "emprestados" (oportunidade!)

Alguns mini-chefes ainda **usam o desenho de outro personagem**. Se quiser dar uma cara própria a eles, esta é uma boa tarefa:

| Quem | Usa hoje o desenho de |
|---|---|
| O Corneteiro (Cidade) | Sargento |
| Couraça Queimada (Montanha) | Couraça Andante |
| Mãe Faminta (Raízes) | Mãe dos Esporos |
| Mestre do Arconte (Domínio) | Bibliotecário de Gelo |
| O Último Igual (Montanha) | Dragão Bestial |
| Mímico "O Que Guardou Demais" | Boca de Raiz (mais o baú `mimico_aberto`) |
| Protótipo na vitrine (Domínio) | Protótipo |
| Os Sebastiões | Tião e Bastião (as versões `_aliado`) |

Para dar um desenho novo, é preciso criar um arquivo novo e avisar o dono do projeto, que liga ele ao personagem.

---

## Como entregar um desenho

1. **Pegue o arquivo original** (nas pastas acima) e abra no seu editor de pixel art (Aseprite, Piskel, Photoshop, etc.).
2. **Desenhe por cima**, mantendo **o mesmo tamanho** e o fundo transparente.
3. **Salve como PNG com o mesmo nome.**
4. Mande o arquivo, ou coloque-o na mesma pasta do projeto.

Quando o Godot abre o projeto, ele reimporta a imagem sozinho. **Não precisa mexer** nos arquivos `.import` nem `.tres` (são gerados automaticamente).

### Para ver no jogo

Abra o projeto no Godot e aperte **F5**. Há imagens de como o jogo deve ficar em [docs/screenshots/](screenshots/).

### Para quem faz mapas e história

Os mapas das fases ficam em [levels/](../levels/) e a legenda dos símbolos está em [levels/LEGENDA.md](../levels/LEGENDA.md). As ferramentas de história estão em [FERRAMENTAS_DE_HISTORIA.md](FERRAMENTAS_DE_HISTORIA.md).

### ⚠️ Atenção: os desenhos atuais são gerados por código

Toda a arte atual é **provisória** e gerada por scripts em [tools/art/](../tools/art/) (cada pixel é um caractere numa grade de texto). Isso significa:

- Se **alguém rodar `python3 tools/art/gen_art.py`**, ele **recria todos os PNGs e apaga os desenhos novos** com o mesmo nome.
- Por isso, depois que um desenho feito à mão entrar no jogo, o script daquele sprite deve ser **desligado** em `tools/art/gen_art.py`. Avise o dono do projeto para fazer isso.

Quem quiser mexer direto nas grades (para pequenas edições) encontra cada coisa neste mapa:

| Script | O que gera |
|---|---|
| `characters.py` | Herói, Soldado, Helena, Ferreiro, Vendedor, Fada |
| `aparencia.py` | As 90 aparências da criação de personagem |
| `aldir.py` · `cidade.py` | Aldir e os inimigos da Cidade |
| `bosque.py` | Bosque: inimigos, Nyssa, cenário |
| `raizes.py` · `raizes_extra.py` | Raízes: inimigos, Mabel, cenário e extras |
| `forjas.py` · `forjas_extra.py` | Forjas: inimigos, Durgan, cenário e extras |
| `montanha.py` · `minotauro.py` | Montanha: inimigos, Rachel, Bezerro e Minotauro |
| `gelo.py` | Domínio: inimigos, Cassian, cenário |
| `nucleo.py` | Núcleo e o Cavaleiro Desolado |
| `prologo.py` | Prólogo, crianças, Governanta, cápsulas |
| `aliados.py` | Guarda Sem Posto (antigo) |
| `aliados_etapa7.py` | Lúcia, Galeno, Tião e Bastião |
| `heitor_etapa8.py` · `ruinas_etapa8.py` | Heitor e o Teatro em ruínas |
| `tito_etapa9.py` · `galeno_etapa9.py` | Tito e o chefe Galeno |
| `vendedores_etapa10.py` · `magias_etapa10.py` | Damião, Dalva, Cícero, Benedita e as magias |
| `amaro_pitoco_etapa11.py` | Amaro e Pitoco |
| `botoes_etapa12.py` | Os 20 botões e a Lata |
| `armas.py` | As armas (mão e ícone) |
| `armaduras.py` | Os ícones de armadura (moldes + paletas) |
| `itens.py` | Itens do inventário |
| `baus.py` · `avisos.py` · `bombeiros.py` · `sino.py` | Baús e mímico, avisos de cenário, quartel de bombeiros, sino |
| `props.py` | Objetos, efeitos, ícones da interface |
| `tiles.py` | Tilesets |
| `capsulas.py` | Miniaturas das Câmaras |
| `palette.py` | **A paleta de cores** (todas as cores do jogo) |

---

## Referências visuais

Pasta: [docs/referencias/](referencias/)

| Arquivo | Para quê |
|---|---|
| [mapa_do_mundo.jpg](referencias/mapa_do_mundo.jpg) | Como as ilhas se conectam |
| [teatro_alexandria.jpg](referencias/teatro_alexandria.jpg) | Visual do Teatro (hub) e da Helena |
| [prologo_capsulas.jpg](referencias/prologo_capsulas.jpg) | Visual do Prólogo e das crianças |
| [paleta.png](referencias/paleta.png) | **A paleta de cores oficial** |

Para entender a história e os personagens, leia o [GDD.md](GDD.md) (seções 3 a 8 e 12).

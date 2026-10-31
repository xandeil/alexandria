# Alexandria — Guia de Arte

Este guia mostra **onde mora cada desenho do jogo**: personagens, chefes, inimigos, NPCs, armas, armaduras, cenários e interface. Se você vai ajudar com o design, comece por aqui.

> Você **não precisa saber programar**. Para trocar um desenho, basta substituir o arquivo `.png` (veja [Como entregar um desenho](#como-entregar-um-desenho)).

---

## Índice

1. [Regras de ouro](#regras-de-ouro)
2. [Quero desenhar… (atalho)](#quero-desenhar-atalho)
3. [Protagonista e aparências](#protagonista-e-aparências)
4. [Chefes](#chefes)
5. [Inimigos comuns por área](#inimigos-comuns-por-área)
6. [NPCs e aliados](#npcs-e-aliados)
7. [Armas](#armas)
8. [Armaduras](#armaduras)
9. [Itens](#itens)
10. [Cenário: tiles e objetos](#cenário-tiles-e-objetos)
11. [Efeitos, interface e ícones](#efeitos-interface-e-ícones)
12. [Como entregar um desenho](#como-entregar-um-desenho)
13. [Referências visuais](#referências-visuais)

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

**Animações:** a maioria dos sprites é uma **faixa horizontal de quadros do mesmo tamanho** (ex.: o herói tem 4 quadros de 24×24, então o arquivo tem 96×24). Para saber como é a divisão de um sprite, divida a largura do arquivo pela largura do quadro.

### Tamanhos de referência

| O quê | Tamanho do quadro |
|---|---|
| Herói, Soldado, crianças | 24×24 |
| Helena Altiva | 32×32 |
| Governanta | 32×40 |
| Aldir | 40×40 |
| Tiles (chão, parede…) | 16×16 |
| Ícones de item e armadura | 16×16 |
| Ícones de interface | 16×16 |
| Miniaturas das Câmaras | 64×40 |

Os demais variam. Quando tiver dúvida, **abra o arquivo original e use o tamanho dele**.

---

## Quero desenhar… (atalho)

| Quero desenhar… | Vá em… |
|---|---|
| O herói / a heroína | [assets/sprites/](../assets/sprites/) → `player*.png` |
| Opções da criação de personagem (rosto, corpo, cabelo) | [assets/sprites/player_aparencias.png](../assets/sprites/player_aparencias.png) |
| Um chefe | [Chefes](#chefes) |
| Um inimigo comum | [Inimigos comuns](#inimigos-comuns-por-área) |
| Uma arma (na mão ou ícone) | [Armas](#armas) |
| Uma peça de armadura | [Armaduras](#armaduras) |
| O Ferreiro, a Fada, o Vendedor… | [NPCs e aliados](#npcs-e-aliados) |
| Chão, parede, água de uma região | [assets/tiles/](../assets/tiles/) |
| Árvore, pilar, estátua, poltrona… | [assets/props/](../assets/props/) |
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
| `player_aparencias.png` | **Todas as aparências da criação de personagem.** Uma faixa vertical de **90 combinações** (2 sexos × 3 corpos × 3 rostos × 5 cabelos), 24×24 cada |

As cores de **cabelo e olhos** do herói são "cores-chave": o jogo clareia esses tons a cada morte. Se mudar o desenho, **mantenha os mesmos tons** (`HAIR`, `HAIR_LIGHT`, `EYE` na paleta).

O herói de aparência padrão é Homem / Magro / Sereno / Curto.

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
| **Experimento Anterior** (NG+) | usa o sprite do jogador |

### Mini-chefes (dois por área)

| Área | Mini-chefe | Arquivos |
|---|---|---|
| Cidade | O Sargento Sem Pelotão | `sargento`, `sabre` |
| Cidade | A Couraça Andante | `couraca`, `couraca_clava` |
| Bosque | O Vigia que Dormiu | `vigia`, `vigia_clava` |
| Bosque | A Mãe dos Esporos | `mae_esporos` |
| Raízes | O Banqueteiro | `banqueteiro` |
| Raízes | A Ninhada | `ninhada` |
| Forjas | O Protótipo | `prototipo` |
| Forjas | O Guardião da Âncora | `guardiao_ancora` |
| Montanha | O Capitão Dragonoide | `capitao_dragonoide` |
| Montanha | A Matriarca Bestial | `matriarca_bestial` |
| Domínio | A Curadora de Vitrines | `curadora_vitrines` |
| Domínio | O Golem do Arquivo | `golem_arquivo` |

### Farm da Montanha

| Quem | Arquivo |
|---|---|
| Bezerro Dourado | `bezerro_dourado` |
| Minotauro | `minotauro` |

---

## Inimigos comuns por área

Pasta: [assets/sprites/](../assets/sprites/) (cada inimigo tem `nome.png` e, se for animado, `nome_frames.tres`: **não mexa no `.tres`**)

| Área | Inimigos |
|---|---|
| **Prólogo** | `crianca_a`, `crianca_b`, `adolescente`, `crianca_poupada`, `wooden_sword` |
| **Cidade Estilhaçada** | Soldado Remendado (`soldier`, `soldier_shield`, `soldier_baton`) · Cão de Guerra (`cao`) · Atirador de Telhado (`atirador`, `fuzil`) · Civil Cinzento (`civil`) |
| **Bosque do Sono Eterno** | Sonâmbulo (`sonambulo`) · Flor de Pólen (`flor_polen`) · Cervo de Musgo (`cervo`) · Fada Murcha (`fada_murcha`) |
| **Raízes da Fome** | Boca de Raiz (`boca_de_raiz`) · Inchado (`inchado`) · Colhedor (`colhedor`) · Larva de Seiva (`larva_seiva`) · Raiz Velha (`raiz_veia`) |
| **Forjas Ocas** | Autômato de Bronze (`automato`) · Torreta de Faísca (`torreta`) · Minerador Oco (`minerador`) · Imitador (`imitador`, `imitador_espada`, `imitador_escudo`) |
| **Montanha Carbonizada** | Dragonoide Atirador (`dragonoide_atirador`) · Dragão Bestial (`dragao_bestial`) · Dragão Alado (`dragao_alado`) · Brasa Viva (`brasa_viva`) |
| **Domínio Congelado** | Bibliotecário de Gelo (`bibliotecario_gelo`) · Estátua Viva (`estatua_viva`) · Ácaro de Cristal (`acaro_cristal`) · Aprendiz Arcano (`aprendiz_arcano`) |

---

## NPCs e aliados

Pasta: [assets/sprites/](../assets/sprites/)

| Quem | Arquivo | Onde aparece |
|---|---|---|
| Ferreiro (anão) | `npc_ferreiro` | Teatro |
| Vendedor Dragonoide | `npc_vendedor` | Teatro |
| Fada | `npc_fada` | Teatro |
| Orbe | `npc_orbe` | Teatro |
| Guarda Sem Posto | `guarda`, `guarda_npc` | Cidade |
| Estudioso | `estudioso`, `estudioso_congelado` | Domínio Congelado |
| Boneco de treino | `training_dummy` | Teatro |

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

### Armas comuns (a "Cobaia")

`espada` (inicial), `espada_grande_cobaia`, `lanca_cobaia`, `martelo_cobaia`, `adaga_cobaia`, `arco_cobaia`. Mesmas duas versões (mão + ícone).

### Escudos

`escudo_remendado` (ícone em `assets/items/`) e `escudo_heroi` (na mão, em `assets/sprites/`).

---

## Armaduras

São **7 conjuntos de 5 peças = 35 ícones**, todos **16×16**, em [assets/items/](../assets/items/).

O nome do arquivo é `armadura_CONJUNTO_PEÇA.png`. Exemplo: `armadura_eco_botas.png`.

| Peças (5) | `capacete` · `peitoral` · `luvas` · `calca` · `botas` |
|---|---|

| Conjunto (arquivo) | Nome no jogo | Efeito |
|---|---|---|
| `vigilia` | Traje da Vigília | Vida |
| `detentor` | Armadura do Detentor | Força |
| `sono` | Vestes do Sono Leve | Recuperação de estamina |
| `banquete` | Trapos do Banquete | Drops (fartura) |
| `eco` | Couraça do Eco | Alcance |
| `caelis` | Escamas de Caelis | Velocidade de passo |
| `arconte` | Manto do Arconte | Memórias |

> **Dica de design:** a forma de cada peça é igual em todos os conjuntos, e o que muda é a **paleta** (cada conjunto tem a sua). Se for redesenhar, o ideal é entregar **a forma e a paleta** separadas, ou então as 35 imagens prontas.

---

## Itens

Pasta: [assets/items/](../assets/items/) (todos 16×16)

| Tipo | Arquivos |
|---|---|
| **Lembranças** (uma por pecado) | `lembranca_helena`, `lembranca_aldir`, `lembranca_rachel`, `lembranca_cassian`, `lembranca_durgan`, `lembranca_mabel`, `lembranca_nyssa`, `lembranca_cavaleiro`, `lembranca_governanta` |
| **Materiais** | `sucata_temperada`, `fragmento_turvo` |
| **Especiais** | `anel_do_guarda`, `apito_sargento` |
| **Armas, escudo, armaduras** | veja as seções acima |

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
| **Cidade** | `barricade`, `rubble`, `fire`, `lamp_post`, `gate`, `crate`, `car_wreck`, `cover` |
| **Bosque** | `tree`, `bush`, `log`, `sleeping_soldier`, `waterfall`, `flower_bed` |
| **Raízes** | `root_tangle`, `flesh_pod`, `planter`, `stove`, `mabel_table` |
| **Forjas** | `chain_post`, `gear_pile`, `press`, `bronze_statue` |
| **Montanha** | `burnt_tree`, `ribcage`, `dragon_skull`, `obsidian_spike`, `rock_cover`, `scale_memorial` |
| **Domínio Congelado** | `crystal_cluster`, `frozen_reader`, `frozen_bookshelf`, `display_case`, `ice_pillar`, `lore_book`, `arconte_staff` |
| **Núcleo** | `ruin_column`, `flower_bush`, `broken_arch`, `sin_statue` |
| **Aliados** | `posto_vazio` |

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
| **Ícones dos botões** (16×16) | [assets/ui/](../assets/ui/) | `icon_attack`, `icon_dash`, `icon_heal`, `icon_sanity`, `icon_interact`, `icon_memory`, `icon_pause`, `icon_block` |
| **Miniaturas das Câmaras** (64×40) | [assets/ui/](../assets/ui/) | `capsula_teatro`, `capsula_cidade`, `capsula_bosque`, `capsula_raizes`, `capsula_forjas`, `capsula_montanha`, `capsula_dominio`, `capsula_nucleo` |
| **Mapa da tela de título** | [assets/ui/](../assets/ui/) | `title_map.jpg` |
| **Ícone do app** | [assets/icon/](../assets/icon/) | `icon_foreground`, `icon_background`, `icon_monochrome` |
| **Imagens da loja** | [docs/loja/](loja/) | `icone_512.png`, `destaque_1024x500.png`, `capturas/` |
| **Vídeo de abertura** | [assets/cutscenes/](../assets/cutscenes/) | `abertura.ogv` (1280×720, ~69 s) |

As miniaturas das Câmaras são montadas com **os próprios tiles da região**, então elas mudam sozinhas quando você muda os tiles.

---

## Como entregar um desenho

1. **Pegue o arquivo original** (nas pastas acima) e abra no seu editor de pixel art (Aseprite, Piskel, Photoshop, etc.).
2. **Desenhe por cima**, mantendo **o mesmo tamanho** e o fundo transparente.
3. **Salve como PNG com o mesmo nome.**
4. Mande o arquivo, ou coloque-o na mesma pasta do projeto.

Quando o Godot abre o projeto, ele reimporta a imagem sozinho. **Não precisa mexer** nos arquivos `.import` nem `.tres` (são gerados automaticamente).

### Para ver no jogo

Abra o projeto no Godot e aperte **F5**. Há imagens de como o jogo deve ficar em [docs/screenshots/](screenshots/).

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
| `raizes.py` | Raízes: inimigos, Mabel, cenário |
| `forjas.py` | Forjas: inimigos, Durgan, cenário |
| `montanha.py` · `minotauro.py` | Montanha: inimigos, Rachel, Bezerro e Minotauro |
| `gelo.py` | Domínio: inimigos, Cassian, cenário |
| `nucleo.py` | Núcleo e o Cavaleiro Desolado |
| `prologo.py` | Prólogo, crianças, Governanta, cápsulas |
| `aliados.py` | Guarda Sem Posto |
| `armas.py` | As armas (mão e ícone) |
| `armaduras.py` | Os 35 ícones de armadura (moldes + paletas) |
| `itens.py` | Itens do inventário |
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

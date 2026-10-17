# Alexandria — A Ilha Que Não Cai · GDD de desenvolvimento

Resumo da **Bíblia do Jogo** (out/2026) organizado para programar, com o que
já está implementado nesta versão marcado com ✅. Imagens de referência em
`docs/referencias/` (mapa do mundo, prólogo das cápsulas, Teatro e a paleta
extraída delas).

## 1. Visão

Soulslike psicológico 2D top-down em pixel art, sobre uma ilha flutuante onde
nada consegue terminar seu ciclo. O jogador acorda sem memória e precisa
recuperar as memórias dos Sete Pecados para chegar ao núcleo da ilha.

- **Pergunta central:** quando algo deixa de ser proteção e vira prisão?
- **Plataforma:** mobile (Android/iOS) — joystick à esquerda; Ataque, Dash e
  Interação/Cura à direita. ✅
- **Referências:** Dark Souls, Hyper Light Drifter, Titan Souls, Soul Knight.

### Pilares
1. **Proteção pode virar prisão** — todo chefe, NPC e cenário mostra um cuidado que deu errado.
2. **Imortalidade é condenação** — ninguém morre de verdade: volta, mas volta menor.
3. **Memória é a única libertação** — memórias são moeda, XP, lore e a chave do final. ✅ (moeda/XP)
4. **Lore pelo mundo, não por texto** — inimigos, NPCs e cenário contam a história.

**Loop:** explorar ilha → inimigos e mini-chefes → morrer e perder memórias →
recuperar sanidade → derrotar o Pecado → levar a memória ao Teatro → evoluir →
escolher a próxima ilha.

## 2. A Queda de Alexandria (pré-história)

1. **Um mundo que não sabia parar** — experimentos proibidos com crianças, animais e humanos; agências de segurança privadas. Helena e o marido eram os melhores agentes de uma delas.
2. **O Projeto Alexandria** — compreender a imortalidade. As cobaias voltavam incompletas: memórias sumiam, olhos e cabelos ficavam brancos, o corpo regredia, a mente ficava instável. A humanidade podia ser extraída como líquido e absorvida por outro corpo — sempre com um custo que envolvia morte.
3. **A primeira ruptura** — o governo mandou o exército; o marido de Helena deixou o posto por um instante e morreu. Helena virou guardiã do passado.
4. **O Cientista da Gravidade** — buscava uma saída; achou uma criatura frágil cercada por gravidade impossível, capaz de virar um núcleo que ergue uma cidade.
5. **O nascimento da ilha** — selado com a criatura, ele arrancou parte do mundo e lançou-a aos céus. As memórias se perderam.
6. **Os dragões** — Rachel Azheryon Caelis chegou primeiro e tomou as montanhas.
7. **O despertar** — uma cápsula se abre: o jogador.

Ligações: as crianças de olhos brancos são cobaias que morreram tantas vezes que
regrediram ✅ (Prólogo: elas encolhem a cada queda); o **Frasco de Sanidade é humanidade líquida** ✅; os soldados do
governo subiram com a ilha e ainda estão nela ✅ (Soldados Remendados).

## 3. Mapa do mundo

| Nº | Área | Pecado / chefe | Visual | Ordem |
|---|---|---|---|---|
| 6 | Teatro Alexandria (hub) ✅ | Luxúria — Helena Altiva ✅ | ruínas de teatro no centro | última dos Sete |
| 1 | Cidade Estilhaçada ✅ (entrada) | Ira — Aldir Cornélios ✅ | cidade em ruínas pegando fogo | 1ª |
| 4 (dir.) | Bosque do Sono Eterno ✅ | Preguiça — Nyssa Lumevel ✅ | floresta, lagos, cachoeiras | 2ª |
| 4 (esq.) | Raízes da Fome ✅ | Gula — Mabel Vorágine ✅ | raízes vermelhas retorcidas | 3ª |
| 5 | Forjas Ocas ✅ | Inveja — Durgan Vell ✅ | ruínas de pedra com torres | 4ª |
| 3 | Montanha Carbonizada ✅ | Orgulho — Rachel Azheryon Caelis ✅ | vulcão com lava | 5ª |
| 2 | Domínio Congelado ✅ | Ganância — Cassian Virel ✅ | cidade de cristais de gelo | 6ª |
| 7 | O Núcleo | Chefe final — o Cavaleiro Desolado | ilha mais alta, jardim com ruínas | final |

Conexão entre ilhas: elevadores e túneis longos (escondem o carregamento).
Nesta versão: transição com fade (`AreaExit` + `Fader`) ✅.

## 4. Prólogo: o Complexo das Cápsulas ✅

Primeira escolha moral, sem aviso: atravessar o complexo **sem ferir nenhuma
criança** ou enfrentar a **Governanta**.

### Como foi implementado ✅
- **O despertar:** Novo jogo → texto de abertura (as frases do despertar) → a
  sua cápsula se abre "com um som baixo, quase respeitoso" e o herói sai dela.
  A sala tem cápsulas ocupadas (um vulto de olhos brancos atrás do vidro),
  vazias e quebradas, e mato vivo demais. A sua cápsula é a Câmara do prólogo
  (descansa e salva). Mapa: `levels/prologo.txt` (tema "laboratorio").
- **As crianças** (`Crianca`): olhos brancos, a mesma túnica branca do herói,
  espadas de madeira. Brincam no seu cantinho; quando você chega, fazem
  pega-pega: espetam (golpe fraco, bem avisado) e fogem **rindo** ("hi hi").
  Não morrem: **caem** e levantam de novo, **menores** a cada queda (a
  regressão). Não dão memórias.
- **As salas seguintes** contam que tudo já aconteceu muitas vezes: riscos de
  giz em grupos de cinco (milhares), o desenho da mulher de jaleco com as
  crianças de olhos pintados de branco, caminhas pequenas demais, espadas
  gastas, a amarelinha no chão, pratos limpos na mesa. Tudo com **Examinar**.
- **O contador:** `Game.criancas_feridas` (salvo). Qualquer golpe do herói numa
  criança soma 1. Nada na tela avisa.
- **A Governanta** (`Governanta`), na cabeceira da mesa comprida, cabeça baixa:
  - 0 crianças feridas → ela **levanta os olhos** quando você passa e deixa ir.
    Sem diálogo, sem explicação (nem dá para atacá-la).
  - 1 ou mais → ela se levanta **gritando** e cresce, a névoa fecha o refeitório
    e a porta tranca (luz vermelha). Mini-chefe:
    - **Fase 1 — A Que Ainda Cuida:** molho de chaves (leque largo), Abraço
      (linha vermelha que trava antes do avanço) e o **Grito**: um anel que se
      expande — fique fora do alcance ou atravesse o anel com o dash.
    - **Fase 2 — A Conta Que Não Fecha** (metade da vida): o coque se desfaz,
      grito duplo, chaves em dois tempos e os **ecos** das crianças correndo em
      linha reta até onde você estava.
  - Falas (provisórias, reescreva!): "Eu contei. Todas as noites, eu contei." ·
    "A conta nunca fecha. NUNCA FECHA." · "Era para eles crescerem..."
- **A lembrança (ao derrotá-la):** a tela clareia e ecos brancos se sentam à
  mesa, com o texto da Bíblia frase a frase: crianças brincando, o tempo
  passando (a luz pisca), a morte retirada daquele lugar (um eco cai e levanta
  menor), a eternidade mal concedida (todos encolhem), até restarem só ecos… e
  uma mesa vazia. "O grito dela não era de raiva. Era de falha." Ela dá 250
  memórias e deixa o molho de chaves no chão.
- **A queda:** passando pela porta, o chão de metal racha e some; o herói cai,
  vem o fim do texto de abertura ("A porta se abriu. E o chão desapareceu." …)
  e ele acorda saindo da cápsula do Teatro. Daqui em diante, morrer leva à
  Câmara do Teatro.
- **A Criança Poupada:** se ninguém foi ferido, ela está sentada ao lado da sua
  cápsula no Teatro, desenhando a giz, e dá dicas (escudo dos soldados, Fada,
  armadura da Helena, buracos do Aldir, o frasco branco...).

**Recompensas da escolha:** lutar = 250 memórias (≈ 2 níveis) e a lembrança;
poupar = a aliada no Teatro e as dicas. A Bíblia pede exatamente esse tipo de
troca no Vigia que Dormiu (Bosque do Sono Eterno).

## 5. Morte, memórias e sanidade ✅

"Morrer não é o problema; esquecer é." Ao morrer o jogador:
- perde memórias (moeda/XP/lore) — `Game.MEMORY_LOSS_RATIO = 0.5` ✅
- fica com olhos (e cabelo) mais pálidos — shader troca as cores-chave ✅
- vê a tela escurecer pelas bordas; com ~8 mortes, quase só ele fica visível — `shaders/vision.gdshader` ✅

**Frasco de Sanidade:** jogado no próprio rosto; a pele absorve e a visão volta ✅.
Na lore, é humanidade de outra pessoa: de quem era? (o Vendedor vende por 150 memórias ✅)

**Inimigos comuns** morreram muitas vezes e ficaram remendados, vazios e
repetitivos (patrulha repetitiva dos soldados ✅). Contraste: o jogador morre e
aprende; eles morrem e estagnam.

### Sistemas da Bíblia × esta versão
1. Combate e movimento (fraco/forte, dash, esquiva) ✅ — mão esquerda: Escudo Remendado ✅ (segura pela frente com estamina; guarda quebra; grito/onda/agarrão indefensáveis)
2. Vida e dano ✅
3. Memórias como moeda e XP ✅
4. Contador de mortes ligado à visão ✅
5. Frasco de Sanidade e frascos de vida ✅
6. Câmara de descanso (salvar, recuperar, reaparecer) ✅
7. Inventário ✅ (fichas `ItemData` + catálogo `Items`; equipamento, consumíveis, materiais e lembranças com lore; save v3)

## 6. Hub: Teatro Alexandria ✅

Base segura e arena do último Pecado. Todos estão presos a um papel numa peça
que nunca termina.

| Personagem | Onde | Função | Nesta versão |
|---|---|---|---|
| Vendedor Dragonoide | balcão à direita | troca memórias por itens | ✅ Frasco de Sanidade e Sucata Temperada |
| Ferreiro Anão | forja à esquerda | melhora armas | ✅ forja +1..+3 (memórias + sucata; +4/+5 depois de Durgan) + boneco de treino |
| Fada | perto do palco | sobe nível por memórias | ✅ menu de atributos |
| Orbe Branco | sob o palco, de um lado a outro | purifica fragmentos, aumenta frascos | ✅ Fragmento Turvo → +1 Frasco de Vida (até 8) |
| Câmara do jogador | cápsula diante do palco | descanso e salvamento | ✅ |
| Helena | sentada na plateia | guardiã e chefe da Luxúria | ✅ diálogo → luta |

Atmosfera: todos pálidos, com frio e levemente insanos; o jogador não sente o
frio (mistério sem resposta ainda). Saída: escada e porta levam ao topo da ilha,
com o céu passando por baixo ✅ (Cidade Estilhaçada a céu aberto, nuvens sob a borda).

## 7. Os Sete Pecados

Fichas completas em `data/bosses/*.tres` (uma por chefe).

| Pecado | Chefe | Raça | Atributo | Mecânica única | Escala |
|---|---|---|---|---|---|
| Luxúria | Helena Altiva, A Cavaleira Desolada ✅ | humana | destreza | três fases; última sem armadura, dano altíssimo | Destreza |
| Ira | Aldir Cornélios, O Detentor do Caos ✅ | humano | força | arena destrutível: martelo abre buracos e derruba coberturas | Força |
| Orgulho | Rachel Azheryon Caelis, O Orgulho do Céu ✅ | dragão ígneo | fogo | arena que desmorona aos poucos | Magia |
| Ganância | Cassian Virel, O Arconte do Zero ✅ | humano | gelo | rouba estamina e congela partes da arena | Magia |
| Inveja | Durgan Vell, O Eco de Bronze ✅ | anão | raio | copia os ataques que o jogador mais usou | Fé |
| Gula | Mabel Vorágine, A Fome Que Lembra ✅ | giganta | sangue | agarra, engole e drena memórias; regenera comendo lacaios | Sorte |
| Preguiça | Nyssa Lumevel, A Que Não Desperta ✅ | fada | sono | Barra de Sonolência: parado/curando = dormir | Fé |

### Helena Altiva — como foi implementada ✅
- **Fase 1 — A Cavaleira Técnica:** corte duplo, estocada longa (linha vermelha de aviso que TRAVA antes do avanço), passo lateral elegante e recuo.
- **Fase 2 — O Desespero (50% da vida):** muito mais rápida; Fúria (4 golpes que corrigem a mira) e Salto (círculo vermelho no chão).
- **Fase 3 — A Mulher Sem Armadura:** ela "morre", fica caída, e levanta sem espada e sem armadura. Mais lenta, alcance curto, golpe de 55 de dano (mais da metade da vida inicial).
- **"Perde a armadura com o tempo":** armadura 0–1 cai sozinha (≈80 s na fase 1, o dobro na 2) e a cada golpe; reduz o dano recebido em até 40%; quanto menos armadura, windups mais curtos, menos pausa e mais velocidade. As peças (ombreiras, elmo, peitoral) caem DE VERDADE e ficam espalhadas no palco; quando o elmo cai, o cabelo ruivo aparece.
- Falas (provisórias, reescreva!): "Não. Não de novo." · "...Eu ainda estou no posto." · "Ninguém ocupa o lugar de ninguém..."
- Depois da vitória: "MEMÓRIA RECUPERADA — Luxúria · Apego" e a espada partida fica no palco (lore pelo cenário).

### Aldir Cornélios — como foi implementado ✅
- **Onde:** Praça do Detentor, atrás do portão da Cidade Estilhaçada (falar com o portão → "Atravessar"). Câmara de descanso diante do portão. Ele espera ajoelhado diante do martelo; a névoa fecha quando você entra e ele acorda quando você chega perto.
- **Fase 1 — O Soldado que Ainda Pensa:** Martelada (círculo no chão; racha o chão sem abrir buraco), Varredura (leque de 200°), Empurrão com o cabo (quem fica colado é empurrado, às vezes para um buraco) e Golpe Sísmico (abre um buraco e solta a Onda de Choque). **As coberturas de concreto seguram a onda**; nesta fase ele mal arranha as coberturas. Contorna a cobertura quando você se esconde ("Atrás da cobertura. Bom. Foi o que eu ensinei.").
- **Buracos:** o chão racha em brasa (~0,8 s de aviso) e desaba; pelo rombo aparece o céu embaixo da ilha. Andar para dentro = cair (20% da vida, volta para a borda). O dash passa por cima (como em Hyper Light Drifter). No máximo 6 abertos: o mais velho entope de entulho.
- **Fase 2 — O Caos (50% da vida):** três marteladas no chão — as duas primeiras racham as coberturas, a terceira derruba todas; olhos em brasa. Golpes encadeados com tempo sorteado (imprevisível, mas sempre com aviso), cada martelada abre um buraco, ondas em leque, Salto do Martelo (ondas em cruz), Investida em linha reta (atravessa coberturas; bateu na parede, fica tonto = janela de punição).
- Falas (provisórias, reescreva!): "Mais um recruta. Quem te mandou? ...Ninguém manda mais ninguém." · "CHEGA DE PENSAR. Se eu não protejo nada... eu quebro tudo." · "Eu tinha alguém para proteger... Não lembro o nome."
- Depois da vitória: "MEMÓRIA RECUPERADA — Ira · Impotência"; o martelo fica cravado na praça, com "para os meus" riscado à faca. O portão da cidade muda de fala.

### Nyssa Lumevel — como foi implementada ✅
- **Fase 1 — O Sonho Leve:** flutua deitada num "oito" preguiçoso. Quem luta é o bosque: 2–3 Sonâmbulos já acordados, bolhas de sono lentas (estouram com um golpe), as flores da clareira. A Barra de Sonolência sobe com o herói **parado** (22/s), **curando** (40/s) ou **perto de flores**; cada golpe a esvazia. 4 golpes em 2 s: ela "vira de lado" (anel de sono).
- **Fase 2 — O Pesadelo (50%):** a luz da área escurece em lilás; manchas escuras viram buracos (o `ArenaPit` do Aldir com outra textura) e **voltam** depois de 5 s; ecos (`DreamEcho`, com o shader de eco) dos chefes já vencidos, cada um com UM golpe conhecido.
- Fala de abertura muda com `Game.flags["vigia_evitado"]`. Vencida: cama de flores no lugar dela; a Fada do Teatro ganha o diálogo da irmã (`fada_irma`).

### Mabel Vorágine — como foi implementada ✅
- **O agarrão** (a dica da Bíblia): estado `GRABBED` do herói — toques em Ataque para escapar (a tela conta), memórias (fração, com mínimo) e um pouco de vida por segundo preso; o dash na hora certa evita; escapar deixa quem agarrou tonto. Mesma regra para a Boca de Raiz e a Ninhada.
- **Fase 1 — A Anfitriã:** lenta e enorme (64×64). Tapa de palma aberta (leque; às vezes tapa + tapa de volta), frutos de carne arremessados em arco até círculos no chão (`FleshBurst`), e o agarrão: linha da mão até o herói que TRAVA; pegou = engole (o herói some), ela se cura e "prova" uma lembrança alheia; escapou = engasgo (dano dobrado).
- **Fase 2 — A Vorágine (50%):** boca no ventre (golpes de frente ×1,5; comendo/engasgada ×2), 4 Raízes-Veia ligadas a ela por linhas que pulsam: cada raiz viva cura ~0,6%/s e delas saem lacaios (larvas, às vezes um Inchado). Ela anda até um lacaio e o COME (aviso; golpe forte interrompe): cura 6% e cresce. Todas as raízes cortadas = a cura para ("Não... não tirem a minha mesa..."); uma volta a brotar se sobrarem menos de 2.
- Falas (provisórias, reescreva!): "Ah, visita! Sente-se, sente-se..." · "Ainda estou com FOME. Por que eu ainda estou com fome?!" · "...Eu só queria... que alguém dissesse que estava bom."
- Depois da vitória: "MEMÓRIA RECUPERADA — Gula · Vazio"; a mesa posta (pratos limpos) fica onde ela sentava; o Vendedor do Teatro passa a lembrar dela (`vendedor_mabel`).

### Durgan Vell — como foi implementado ✅
- **A contagem (a dica da Bíblia):** o herói emite `Player.action_used` (leve, forte, dash, escudo, cura); Durgan guarda um dicionário ação → número durante a luta inteira. Na fase 2, a próxima ação é sorteada com peso = contagem + 1.
- **Fase 1 — O Engenheiro:** chave-martelo (leque) e martelada elétrica (círculo; no impacto, um anel de placas acende e dá choque); constrói Torretas de Faísca (até 2) e chama Autômatos de Bronze (1); a cada ~6,5 s acende as placas em volta do herói.
- **Fase 2 — O Reflexo (50%):** armadura espelhada; os autômatos caem. Copia: o seu combo leve (1–3 cortes), o seu golpe forte, o seu dash (golpe em linha / esquiva — e, se você abusou do dash, ele **esquiva quando você ataca**), o seu escudo (escudo espelhado de frente: 15% do dano, apara e revida) e o seu frasco (bebe até 3 vezes; golpe forte interrompe).
- Falas (provisórias, reescreva!): "Mais um rosto. Fica parado... deixa eu ver como você é feito." · "Agora eu sou VOCÊ." · "...Diga a ele... que eu fazia igual. Às vezes melhor."
- Depois da vitória: "MEMÓRIA RECUPERADA — Inveja · Querer ser o outro"; a chave-martelo (com "D. VELL" no cabo) fica onde ele caiu; o Ferreiro do Teatro lembra do irmão (`ferreiro_irmao`) e a forja vai até +5.

### Ideias de implementação da Bíblia (para os próximos)
- **Nyssa:** os ecos da fase 2 reaproveitam animações de chefes que já existem.
- **Cassian:** `StatsComponent.drain_stamina()` já existe para o roubo de estamina.

## 8. Áreas: inimigos e mini-chefes

Cada ilha: 3–4 inimigos comuns e 2 mini-chefes (o 1º ensina a mecânica, o 2º testa).

**Cidade Estilhaçada (Ira):** cidade futurista partida, ruas levantadas, fogo que nunca apaga ✅ (cenário).
- Soldado Remendado — ataca em grupo, bloqueia com escudo ✅ (fichas de ataque: máx. 2 por vez)
- Cão de Guerra Mecânico — rápido, morde e recua ✅ (rodeia, agacha no aviso, bote, recua)
- Atirador de Telhado — tiro lento e telegrafado de longe ✅ (linha de mira que trava; `Projectile` com raycast por passo — não atravessa parede; dash passa pela bala)
- Civil Cinzento — passivo; só ataca se atacado ou se o jogador passar correndo ✅ ("..." → "?!"; alarma os vizinhos; acalma sozinho)
- Mini-chefes ✅ (base `MiniBoss`: acorda ao ver, desiste se você foge, vencido fica vencido): O Sargento Sem Pelotão (chama 2 reforços a cada 25% de vida; caiu o oficial, o pelotão é dispensado) · A Couraça Andante (só leva dano real pelas costas — 8% de frente; vira devagar; giro de 360° se você fica colado atrás)

**Bosque do Sono Eterno (Preguiça):** floresta verde demais, lago parado, cachoeiras lentas caindo da borda ✅ (cenário; porta lateral do Teatro, abre depois do Aldir).
- Sistemas da área ✅: **barulho** (`Player.make_noise` / `is_heard_from`; anel no chão perto de quem ouve) e **Barra de Sonolência** (`add_drowsiness`; cheia = dorme 2,5 s; atacar alivia; dash não respira o pólen) — prontos para Nyssa.
- Sonâmbulo ✅ (cego; acorda com barulho e vai até o SOM; volta a dormir) · Flor de Pólen ✅ (incha → nuvem de sono) · Cervo de Musgo ✅ (congelado no salto; mira que trava; investida que atropela e fica tonta ao bater) · Fada Murcha ✅ (cura os feridos, foge do herói)
- Mini-chefes ✅: O Vigia que Dormiu (passar em silêncio grava `Game.flags["vigia_evitado"]` para a fala de Nyssa; acordado: martelada, varredura, bocejo = anel de sono) · A Mãe dos Esporos (cipó, chuva de esporos, florescer; brota flores; cipó pesado em quem dorme)

**Raízes da Fome (Gula):** estufas de ladrilho e vidro, cozinha de xadrez, ninho de veias, poças de seiva ✅ (cenário; porta oeste do Teatro, abre depois de Nyssa).
- Boca de Raiz ✅ (enterrada → incha → agarra; exposta depois) · Inchado ✅ (lento; explode ao morrer, ferindo também os inimigos) · Colhedor ✅ (foice de 200° que alcança longe; gira se você cola) · Larva de Seiva ✅ (rouba memórias, brilha e foge; morta, devolve)
- Mini-chefes ✅: O Banqueteiro (serve lacaios; ferido, COME um para se curar — ensina a matar a fonte de cura; guarda a porta dos fundos) · A Ninhada (solta larvas a cada 20% de vida perdida; engole quem fica no círculo)

**Forjas Ocas (Inveja):** ruínas de pedra com a galeria de estátuas, a oficina, a fábrica de grades e placas, a mina e a câmara da Âncora; canais de metal derretido ✅ (cenário; trilha no alto do Bosque, abre depois de Mabel).
- Sistema da área ✅: **placas de raio** (`=` no mapa → `Level.plate_cells`; `PlateCharge`: acende → choque → apaga; o escudo não segura, o dash passa).
- Autômato de Bronze ✅ (rosto do Ferreiro; corte leve a 70%, golpe forte inteiro; às vezes dois golpes) · Torreta de Faísca ✅ (acende a trilha de placas até o herói e em volta dele) · Minerador Oco ✅ (três picaretadas, a terceira pesada) · Imitador ✅ (o seu equipamento; copia golpe, dash, escudo e frasco)
- Mini-chefes ✅: O Protótipo (o seu corte leve em sequências de 1–3 e o seu dash) · O Guardião da Âncora (carcaça 30%; depois de dois ataques, núcleo exposto 180%; corrente em leque e pilão que acende as placas; vencido, a ilha treme e a porta abre na hora)

**Montanha Carbonizada (Orgulho):** sopé de floresta queimada, ossário de dragões, rio de lava com pontes de basalto, acampamento do Capitão e a caldeira da Matriarca ✅ (cenário; ponte levadiça no alto da Cidade, desce depois de Durgan). O Ninho: arena oval com seis pilares de rocha.
- Sistema da área ✅: **fogo no chão** (`FirePatch`: queima um pouco a cada 0,5 s, sem cambalear; o dash passa). Bolas de fogo (`Projectile` com `fire`), o lança-chamas, o hálito e a Brasa deixam chamas.
- Dragonoide Atirador ✅ (guarda distância; rajada de 3 bolas de fogo; coronhada de perto) · Dragão Bestial ✅ (investida em linha que trava; tonto na parede; mordida) · Dragão Alado Menor ✅ (intocável no ar; mergulho anunciado; cospe fogo e fica no chão um instante) · Brasa Viva ✅ (persegue, incha e estoura; apagada a tempo, cancela)
- Mini-chefes ✅: O Capitão Dragonoide (escudo de frente 10% × costas 100%; lança-chamas em cone que incendeia; a troca de postura é a única hora em que cambaleia) · A Matriarca Bestial (investida que deixa tonta na parede; pisoteio que abre buracos — a arena encolhe; guarda a trilha do Ninho)
- Rachel ✅: hálito em varredura (relógio próprio; para na pedra), rugido (anel que o dash atravessa; derruba os pilares), cauda em quem fica atrás (quebra o chão), a borda desaba em 75/50/25% da vida. Vencida: escama, Lembrança "Orgulho · Domínio", falas novas do Vendedor Dragonoide.

**Domínio Congelado (Ganância):** praça de chegada com o Estudioso congelado, lago congelado com buracos, Galeria das Vitrines, salas de leitura e o Arquivo Central ✅ (cenário; túnel de gelo na parede oeste da Montanha, abre depois de Rachel). A Sala do Arconte: biblioteca oval com faixas de gelo e leitores congelados nos cantos.
- Sistema da área ✅: **gelo que escorrega** (`=` → `Level.ice_cells` + `FrostZone`; regra única em `Ice.is_slippery`; o herói usa `ice_grip`/`ice_brake`), **frio** (`player.apply_chill`: anda mais devagar) e **bloco de gelo** (`IceBlock` = o agarrão com toques).
- Bibliotecário de Gelo ✅ (mira, dois estilhaços que gelam; foge de perto) · Estátua Viva ✅ (só anda com o herói de costas; pedra = 15% de dano) · Ácaro de Cristal ✅ (enxame de 3; gruda e bebe estamina; o dash sacode) · Aprendiz Arcano ✅ (bolha que o golpe forte parte; anel de gelo de perto)
- Mini-chefes ✅: A Curadora de Vitrines (vitrine que prende em bloco de gelo; preso, ela "cataloga" com a bengala pesada; leque de estilhaços) · O Golem do Arquivo (não cambaleia; pilão que congela o chão, braço-estante, leque de livros; deixa o Livro do Arquivo — lore do Projeto — e abre a porta do Arconte)
- Cassian ✅: fase 1 (lanças, geada, pilares que derretem, piscar quando o herói cola) · fase 2 sem pular (congela metade da arena, Estátuas Vivas, roubo de estamina com regen suspensa). Vencido: cajado, Lembrança "Ganância · Possessão", o Estudioso descongelado comenta.

## 9. O Núcleo e os finais

As sete memórias reconstroem o pacto e abrem o Núcleo. O Cavaleiro Desolado
protege quem está ligada ao núcleo: enquanto ela existir, a ilha flutua.

| Final | O que o jogador faz | O que acontece | Mensagem |
|---|---|---|---|
| Proteger (Continuidade) | assume o lugar do cavaleiro | a ilha não cai; o mundo continua preso | algumas coisas sobrevivem, mas nunca vivem |
| Destruir (Ruptura) | mata quem sustenta o núcleo | a ilha começa a cair; o impacto não é mostrado | libertar algo pode ser o mesmo que destruí-lo |

## 10. Aliados

- **O marido de Helena** (nome a definir) — estilo Siegward: voltou sem memória, cabelo branco, mais jovem. Arco: Cidade Estilhaçada protegendo Civis Cinzentos → ajuda em mini-chefes → um fragmento por ilha (anel, voz, posto vazio) → sacrifica-se antes da luta de Helena → na fase 3 ela reconhece o anel dele com o jogador. (Gancho pronto: `HelenaAltiva.SPEECH_PHASE_3`.)
- A Criança Poupada · O Estudioso Descongelado · O Vendedor Dragonoide (desertor do ninho de Rachel) · O Ferreiro Anão (irmão de Durgan) · A Fada do Teatro (irmã de Nyssa; talvez quem acordou o jogador).

## 11. Pontas soltas (decisões suas)

- Quem é o chefe final (cavaleiro = cientista? criatura = mulher?)
- Dois "Desolados" (Helena e o chefe final) — mudar um título ou assumir o eco
- A culpa de Helena (versão antiga: ela convenceu o marido a sair do posto)
- O papel de Aldir, Rachel e Cassian no pacto
- Nome do hub: Teatro da Vigília × **Teatro Alexandria** (usei o novo)
- Nome do Orbe Branco e dos frascos de vida (usei "Frasco de Vida" provisório)
- Nome do marido de Helena
- Quantas ilhas no início (Bíblia sugere MVP: prólogo + Teatro + Cidade Estilhaçada — **é o que este protótipo começa a montar**)
- Por que o jogador não sente frio

## 12. Direção de arte usada no protótipo

- Pixel art top-down 3/4, chibi (cabeça grande) como as crianças do prólogo e Soul Knight.
- Personagens olham para a direita e o jogo espelha; a arma é um sprite separado que gira (golpes em 360°).
- Paleta amostrada das imagens de referência e clareada ~25% para tela de celular (`tools/art/palette.py`, `docs/referencias/paleta.png`).
- Teatro: pedra verde-acinzentada, tapete oliva, poltronas vermelhas e bege, palco de madeira, cortinas carmim, tochas quentes; Helena ruiva (como na imagem do Teatro).
- Cidade: asfalto escuro, concreto, rachaduras em brasa, fogo, céu e nuvens sob a borda da ilha (mapa do mundo).
- Aldir: casaco de oficial no verde do exército do governo (o mesmo dos Soldados Remendados), dragonas douradas, peitoral riscado, faixa vermelha (Ira), cabelo e barba grisalhos, cicatriz no olho; martelo de ferro com rachaduras em brasa.
- Fontes: Cinzel (títulos, "VOCÊ ESQUECEU"), Pixelify Sans (textos), Tiny5 (números). Todas OFL.

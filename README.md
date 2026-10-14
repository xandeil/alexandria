# Alexandria — A Ilha Que Não Cai

Soulslike psicológico 2D top-down em pixel art, feito para **celular (Android)**.
Este projeto é a primeira **fatia vertical** jogável, montada a partir da
*Bíblia do Jogo* (resumo em [`docs/GDD.md`](docs/GDD.md)).

**Motor:** Godot 4.7.2 (Standard) · **Linguagem:** GDScript · **Renderer:** Compatibility (OpenGL ES 3, roda em celular barato)

![Complexo das Cápsulas](docs/screenshots/p02_sala_das_capsulas.jpg)

## O que já dá para jogar

- **Prólogo — o Complexo das Cápsulas.** O Novo jogo começa aqui: a sua cápsula se abre numa sala cheia de outras (ocupadas, quebradas, vazias), com mato vivo demais para um lugar abandonado.
  - **Crianças de olhos brancos** com espadas de madeira atacam **rindo**, como numa brincadeira de pega-pega: espetam e fogem. Elas **não morrem**: caem, ficam no chão e levantam de novo, **menores** a cada vez (a regressão da Bíblia). Bater nelas não dá memória nenhuma.
  - **A escolha sem aviso:** cada golpe numa criança conta em `Game.criancas_feridas` (fica no save). O jogo não diz nada.
  - **A Governanta**, sentada na cabeceira da mesa, de cabeça baixa:
    - **ninguém ferido** → ela só levanta os olhos e deixa passar. Sem diálogo;
    - **alguém ferido** → ela se levanta **gritando**, a porta tranca e vira mini-chefe, maior que tudo até ali. Usa o molho de chaves, o abraço em linha reta e o **grito em anel** (atravesse com o dash). Na fase 2 o coque se desfaz e ela chama os **ecos** das crianças.
  - Vencida, **a lembrança dela** toma a tela: ecos brancos em volta da mesa, o texto da Bíblia, até sobrar **uma mesa vazia**.
  - **A queda:** depois da porta o chão some e você acorda no Teatro. Quem não feriu ninguém encontra lá **a Criança Poupada**, que dá dicas.
  - Riscos de giz, desenhos, terminais e camas pequenas demais: tudo tem **Examinar** (lore pelo cenário).
- **Teatro Alexandria (hub)** montado a partir da imagem de referência: palco, cortinas, plateia com poltronas vermelhas e bege, tapete do corredor, tochas.
  - **Câmara de descanso** (a cápsula diante do palco): recupera vida/estamina/frascos, faz os inimigos voltarem e **salva**.
  - **Fada:** sobe nível trocando memórias por Vitalidade, Fôlego, Força ou Destreza.
  - **Vendedor Dragonoide:** vende Frasco de Sanidade (humanidade líquida... de quem era?) e Sucata Temperada.
  - **Ferreiro Anão:** a **forja** troca memórias + **Sucata Temperada** por uma espada mais forte (+12% de dano por nível, até +3; o resto só depois de Durgan). Ao lado, o **boneco de treino** mostra o dano de cada golpe.
  - **Orbe Branco**, vagando sob o palco: entregue um **Fragmento Turvo** e ele o purifica em **mais um Frasco de Vida** (até 12).
  - **Helena Altiva, A Cavaleira Desolada:** sentada na plateia. Fale com ela e desembainhe.
- **Cidade Estilhaçada (entrada):** a céu aberto, com o céu e as nuvens passando **por baixo** da ilha. Nove **Soldados Remendados** com escudo, que atacam em grupo, e uma Câmara de descanso diante do portão do chefe.
  - **Cães de Guerra Mecânicos:** rodeiam rápido demais para você alcançar, agacham (aviso), dão o bote e recuam. Puna logo depois do bote.
  - **Atiradores de Telhado:** uma linha vermelha mira em você; quando ela **trava**, saia da linha ou atravesse a bala com o dash. A bala para nas paredes e nas coberturas.
  - **Civis Cinzentos:** passivos ("..."). Só atacam se você bater neles, der dash por perto ou passar correndo colado. Um alarmado alarma os vizinhos. Ande devagar entre eles.
  - **Mini-chefe — O Sargento Sem Pelotão:** a cada 25% de vida perdida, apita e chama dois soldados. Derrube **o Sargento** e o pelotão é dispensado na hora.
  - **Mini-chefe — A Couraça Andante:** de frente a chapa segura quase tudo (faíscas e "clang"). Ela **vira devagar**: contorne e bata **nas costas**. Ficou colado atrás tempo demais? Círculo no chão e giro de 360°.
  - Os mini-chefes acordam quando veem você e **desistem** (vida cheia) se você fugir para longe; vencidos, não voltam.
  - **Itens no chão** (brilham; é só encostar): o **Escudo Remendado** logo na entrada, sucata e um Fragmento Turvo no meio dos civis.
- **Escudo (mão esquerda):** segure o botão do escudo. Ele vira sozinho para o inimigo (ou a bala) mais perto e segura golpes **pela frente**, mas cada golpe segurado custa estamina e deixa passar um raspão. Sem estamina, a **guarda quebra** (cambaleio longo + Exaustão). O grito da Governanta, a onda do Aldir e os agarrões passam por cima dele.
- **Inventário** (pausa → Inventário, ou tecla I/Tab): equipamento, frascos, materiais e **lembranças** — o texto de cada item conta um pedaço da história. Inimigos da Cidade deixam sucata; cada chefe e mini-chefe deixa um Fragmento Turvo e uma lembrança na primeira vitória.
- **Aldir Cornélios, O Detentor do Caos (Ira):** atrás do portão, na **Praça do Detentor**. A arena é a mecânica:
  - **Fase 1 — O Soldado que Ainda Pensa:** marteladas calculadas e o **Golpe Sísmico**, cuja Onda de Choque corre pelo chão. As **coberturas de concreto seguram a onda**.
  - **O martelo abre buracos:** o chão racha (aviso) e desaba, mostrando o céu embaixo da ilha. Andou para dentro, **cai** e perde vida; o **dash atravessa**.
  - **Fase 2 — O Caos:** derruba todas as coberturas, salta com o martelo (ondas em cruz), avança em linha reta (bateu na parede, fica tonto) e encadeia golpes com tempo imprevisível, sempre com aviso no chão.
  - Vencendo: "MEMÓRIA RECUPERADA — Ira · Impotência", e o martelo fica cravado na praça.
- **Bosque do Sono Eterno (Preguiça)** — a porta lateral do Teatro abre depois de vencer o Aldir. "Floresta verde demais, lagos parados, cachoeiras que caem em câmera lenta. Tudo dorme."
  - **Barulho:** dash, golpe e passos apressados fazem barulho (um anel fraco no chão mostra o raio quando há alguém que ouve por perto). Andar **devagar** (joystick pela metade) é silencioso.
  - **Barra de Sonolência** (lilás, sob a estamina): sobe dentro do pólen; cheia, você **dorme 2,5 s** (um golpe te acorda). **Atacar espanta o sono**; o dash prende a respiração.
  - **Sonâmbulos:** cegos, dormem em pé. Acordam com barulho e andam até o **lugar do som** — fique quieto e eles voltam a dormir.
  - **Flores de Pólen:** incham (aviso) e soltam uma nuvem de sono. Corte-as logo depois que soltam.
  - **Cervos de Musgo:** congelados no meio do salto até você chegar perto; depois miram (a linha trava) e investem em linha reta. Bateu numa árvore ou tronco? Tonto.
  - **Fadas Murchas:** não atacam — **curam** os outros e fogem de você. Derrube-as primeiro.
  - **Mini-chefe — O Vigia que Dormiu:** dorme na passagem. **Passe em silêncio** (o jogo lembra que você passou) **ou** faça barulho e lute: martelada, varredura e um **bocejo** que solta um anel de sono.
  - **Mini-chefe — A Mãe dos Esporos:** cipó (linha que trava), chuva de esporos e o florescer (anel de sono enorme). Faz brotar flores. **Dormiu perto dela, leva o cipó pesado.**
  - Ao fundo, um muro de espinhos que só abre depois da Mãe dos Esporos.
- **Nyssa Lumevel, A Que Não Desperta (Preguiça)**, na Clareira de Nyssa:
  - **Fase 1 — O Sonho Leve:** ela flutua deitada e quase não ataca. O bosque luta por ela: sonâmbulos já acordados, bolhas de sono lentas (um golpe estoura) e flores. **Ficar parado ou beber frasco enche a Barra de Sonolência**; atacar esvazia. Colou nela batendo sem parar? Ela vira de lado e solta um anel de sono.
  - **Fase 2 — O Pesadelo (metade da vida):** a clareira escurece. Manchas escuras avisam e o **chão some** (o dash passa por cima; o chão volta depois). Ela chama **ecos dos chefes que você já venceu** — cada um com o golpe que você conhece (a estocada da Helena, a onda do Aldir, o grito da Governanta...).
  - O que ela diz ao começar depende de você ter **passado pelo Vigia em silêncio**. Vencida, fica uma cama de flores onde ela dormia, e **a Fada do Teatro passa a falar da irmã**.
- **Morte:** "VOCÊ ESQUECEU" — perde metade das memórias, a visão escurece pelas bordas e cabelo/olhos clareiam a cada morte.

| | |
|---|---|
| ![A criança rindo](docs/screenshots/p03_crianca_rindo.jpg) | ![A Governanta observa](docs/screenshots/p06_governanta_observa.jpg) |
| ![O grito em anel](docs/screenshots/p10_grito.jpg) | ![Os ecos](docs/screenshots/p12_fase2_ecos.jpg) |
| ![A lembrança](docs/screenshots/p13_lembranca.jpg) | ![A Criança Poupada](docs/screenshots/p18_crianca_dica.jpg) |
| ![Estocada da Helena](docs/screenshots/10_helena_estocada_aviso.jpg) | ![Fase 3](docs/screenshots/14_helena_fase3.jpg) |
| ![Aldir ajoelhado](docs/screenshots/20_aldir_ajoelhado.jpg) | ![Golpe Sísmico](docs/screenshots/21_aldir_sismico_aviso.jpg) |
| ![Atirador mirando](docs/screenshots/19a_atirador_mira.jpg) | ![Cães de Guerra](docs/screenshots/19b_cao_de_guerra.jpg) |
| ![Sargento e o pelotão](docs/screenshots/19e_sargento_pelotao.jpg) | ![Giro da Couraça](docs/screenshots/19f_couraca_giro.jpg) |
| ![A forja](docs/screenshots/08a_forja.jpg) | ![Inventário](docs/screenshots/08c_inventario_lembranca.jpg) |
| ![Pólen e sonolência](docs/screenshots/b04_polen_sonolencia.jpg) | ![O lago e a ponte](docs/screenshots/b06_lago_ponte.jpg) |
| ![O Vigia que Dormiu](docs/screenshots/b10_vigia_dormindo.jpg) | ![A Mãe dos Esporos](docs/screenshots/b13_mae_florescer.jpg) |
| ![Nyssa — O Sonho Leve](docs/screenshots/n03_sono_subindo.jpg) | ![Nyssa — O Pesadelo](docs/screenshots/n06_ecos.jpg) |
| ![Buracos na praça](docs/screenshots/25_aldir_salto.jpg) | ![Morte](docs/screenshots/15_morte.jpg) |

## Controles

| Ação | Celular | Teclado (PC) |
|---|---|---|
| Andar | joystick flutuante (metade esquerda da tela) | WASD / setas |
| Golpe leve (combo de 3) | **toque** em Ataque | J (toque) |
| Golpe forte | **segure** Ataque (0,25 s) | segure J, ou K |
| Dash / esquiva (i-frames) | botão » | Espaço |
| Cura / Interagir | botão do frasco (vira "Falar"/"Descansar"/"Examinar" perto de algo) | E |
| Frasco de Sanidade | botão branco pequeno | Q |
| Escudo (segurar) | botão do escudo (aparece quando você tem um) | L ou Shift (gatilho esquerdo) |
| Inventário | Pausa → Inventário | I ou Tab |
| Pausa | ❚❚ no canto / botão Voltar do Android (de novo fecha) | Esc |
| Menus e diálogos | toque | setas + Enter (ou controle) |

No PC o mouse também simula toque — dá para testar os botões da tela.
Na tela de título, o Voltar do Android fecha o jogo. Textos narrados (abertura,
lembrança, queda): toque na tela para pular a frase.

## Rodar no computador

1. Instale o Godot 4.7.2 (veja o [BUILD.md](BUILD.md), passo 1).
2. Abra o Godot → **Importar** → escolha o `project.godot` desta pasta.
3. Aperte **F5** (ou o ▶ no canto superior direito).

## Gerar o APK

Passo a passo completo, com os comandos exatos para Windows, Linux e macOS:
**[BUILD.md](BUILD.md)**. Resumo, depois de instalado:

```powershell
powershell -ExecutionPolicy Bypass -File .\build_apk.ps1
```

Os scripts assinam com a **chave de depuração do projeto** (`keystore/`): o APK
que você compila instala por cima do que eu te mando, sem perder o save
(explicação em [`keystore/LEIA-ME.md`](keystore/LEIA-ME.md)).

---

## Arquitetura (o raciocínio por trás)

```
alexandria/
├── project.godot / export_presets.cfg   ← config + preset "Android" pronto
├── scenes/            ← cenas (.tscn): herói, soldado, Helena, NPC, fases, UI
├── scripts/
│   ├── autoload/      ← Game (save, memórias, morte), Fx (impacto), Sfx (som), Fader
│   ├── components/    ← StatsComponent, Hitbox, Hurtbox  (peças reutilizáveis)
│   ├── combat/        ← AttackData (dados do golpe) + AttackRunner (Step and Anchor)
│   ├── player/        ← Player (máquina de estados)
│   ├── enemies/       ← Enemy (base) → SoldadoRemendado, Crianca
│   ├── bosses/        ← Boss (base) → HelenaAltiva, AldirCornelios, Governanta; Onda de Choque, grito, ecos, avisos
│   ├── world/         ← Level (monta o mapa do .txt) → Prologo; Câmara, portas, névoa, câmera, buracos, coberturas
│   └── ui/            ← HUD, joystick, botões, diálogo, Narração, menu da Fada, pausa, título
├── data/
│   ├── attacks/*.tres ← números de cada golpe (ajuste no Inspector)
│   ├── bosses/*.tres  ← ficha dos 7 Pecados + chefe final (da Bíblia)
│   └── dialogos.json  ← todas as falas (edite sem tocar em código)
├── levels/*.txt       ← os mapas em texto (veja levels/LEGENDA.md)
├── assets/            ← pixel art, sons e fontes (gerados por tools/)
├── shaders/           ← piscar/olhos brancos, perda de visão, névoa, ecos
├── tests/             ← testes automáticos, teste de resistência, screenshots
├── tools/             ← geradores de arte/som/dados (Python) e setup do Godot
├── keystore/          ← a chave de DEPURAÇÃO do projeto (a de publicação nunca entra aqui)
└── docs/              ← GDD (Bíblia resumida), referências, screenshots
```

### 1. Composição em vez de herança
O herói não *é* um "PersonagemComVida": ele *tem* um `StatsComponent`, uma
`Hurtbox` e uma `Hitbox`. O soldado e a Helena têm os mesmos três. Quando você
fizer o Aldir, ele reaproveita tudo — só muda o comportamento. É a mesma ideia
dos seus componentes reutilizáveis em React.

### 2. Estado de Vida/Estamina (`scripts/components/stats_component.gd`)
- Atributos calculam os máximos: **Vida = 60 + Vitalidade×4**, **Estamina = 50 + Fôlego×5** (acima de 25 pontos, cada ponto rende metade — retorno decrescente).
- `try_spend_stamina(custo)`: a ação só sai se **não** estiver exausto e tiver **qualquer** estamina > 0 (regra Souls: com 5 pontos ainda sai um golpe de 16).
- Zerou → **Exaustão**: não ataca, não dá dash, anda a 70%, regenera a 60%.
- Regenera sozinha depois de 0,55 s sem gastar; sai da Exaustão ao recuperar **35%**.
- Tudo avisado por **sinais** (`health_changed`, `exhaustion_changed`...): o HUD só escuta.

### 3. Combate "Step and Anchor" (`scripts/combat/attack_runner.gd`)
O **mesmo** código executa os golpes do herói, dos soldados e da Helena:

```
 WINDUP ──────► LUNGE ──► ACTIVE ──► RECOVERY ──────►
 movimento      micro-    FREIO     parado e
 travado,       impulso   SECO +    vulnerável
 corpo freia    p/ frente hitbox on (combo só no final)
```

O AttackRunner só diz "qual velocidade o corpo deve ter neste frame"; o dono
aplica e chama `move_and_slide()` — por isso **o avanço respeita as paredes**.
O peso vem do contraste aceleração → parada brusca → **hitstop** (o jogo congela
50–100 ms quando o golpe conecta) + tremor de câmera + vibração do celular.

Os tempos ficam em `data/attacks/*.tres`. Exemplo do golpe forte:
windup 0,32 s · impulso 240 px/s por 0,09 s · ativo 0,10 s · recuperação 0,42 s.

### 4. Máquina de Estados no herói (`scripts/player/player.gd`)
`FREE, ATTACK, DASH, HEAL, SANITY, STAGGER, LOCKED, DEAD` — um estado por vez,
cada um com sua função. Acabou o "inferno de booleanos". Também tem **buffer de
input** (o toque feito 0,2 s antes da hora não é "comido") e **mira assistida**
(o golpe puxa para o inimigo mais próximo num cone — essencial no touch).

### 5. Dados separados do código
Golpes e chefes são `Resource` (o equivalente ao ScriptableObject da Unity) e
as falas ficam num JSON. Balancear = mexer em números no Inspector, sem
recompilar nada.

### 6. Mapas em texto (`levels/*.txt`)
Cada caractere vira tile, objeto ou personagem. Dá para redesenhar o Teatro no
Bloco de Notas. Com `@tool`, o mapa aparece no editor ao abrir a cena.

### 7. A arena é a mecânica (Aldir)
Três peças pequenas, cada uma com UMA responsabilidade:
- `ArenaPit` (buraco): só responde "esse ponto está dentro de mim?". Quem decide
  cair é o `Player` (estado `FALL`, com o dash passando por cima).
- `DestructibleCover` (cobertura): é sólida e recebe golpes por uma `Hurtbox`,
  igual a um personagem. Quem bate decide o estrago (`cover_damage_multiplier`):
  na fase 1 o Aldir mal arranha, na fase 2 quebra tudo.
- `Shockwave` (onda): corre pelo chão e para na camada "mundo" (parede ou cobertura).

E o `Boss` virou uma base de verdade: `phase_label()`, `armor_ratio()`,
`enter_arena()`, `victory_subtitle()`. O HUD, a arena e a fase falam só com
`Boss` — o Aldir entrou sem nenhum `if chefe is Helena` (princípio aberto/fechado).

### 8. Celular não perdoa: robustez
Coisas que não aparecem no PC, mas aparecem no primeiro dia no celular:
- **Save à prova de queda** (`game.gd`): grava num `.tmp`, confere, guarda o
  anterior como `.bak` e só então renomeia. Save ilegível nunca é sobrescrito.
- **Só salva com partida em andamento**: minimizar o app na tela de título não
  grava o progresso zerado por cima do seu save.
- **Toques "perdidos"**: com o jogo pausado, o "soltar o dedo" não chega; por
  isso a pausa solta joystick e botões (senão o herói voltaria andando sozinho).
- **Diálogos e menus pausam o mundo**, e a tecla que fechou o diálogo (E, J,
  Espaço) é ignorada até ser solta — não vira cura, golpe ou dash sem querer.
- **Esperas que morrem com a cena**: `await get_tree().create_timer()` acorda
  mesmo se a cena já foi trocada; as fases e inimigos esperam com um `Timer`
  filho (`Level._wait`, `Enemy.wait`), que some junto com eles.
- **Autoload não cita classe do jogo** (`Game` não recebe um `Player`, só
  números): referência circular entre scripts = vazamento ao fechar.

### 9. A escolha sem aviso (Prólogo)
- **Um número, três leitores.** A `Crianca` só CONTA (`Game.register_child_hurt()`
  quando o golpe vem do herói). A fase `Prologo` só DECIDE (entrou no refeitório
  com `criancas_feridas > 0` → `BossArena.arm()`). A `Governanta` só sabe ficar
  sentada, observar e lutar. Ninguém conhece a regra inteira — e cada parte tem
  o seu teste.
- **Herança onde ela é verdade:** o `Prologo` *é* uma fase (`extends Level`) com
  três peças a mais (Governanta, porta, chão que some). A `Level` ganhou
  "ganchos" que a filha sobrescreve: `_auto_arm_boss()` (a arena não arma
  sozinha) e `_celebrate_victory()` (a lembrança no lugar do "MEMÓRIA
  RECUPERADA"). É o padrão *Template Method*.
- **Componente em vez de copiar e colar:** a abertura da tela de título virou a
  `Narration`, usada também na lembrança e na queda (DRY). O sinal
  `line_started(i)` deixa a cena acompanhar o texto frase a frase.
- **Save versionado com migração:** o save agora é a versão 2. Um save da 0.4.0
  (versão 1) é de antes do prólogo existir; ao carregar, ele conta como feito.
  Regra de ouro: nunca quebre o save de quem já joga.
- **Costura para testes:** toda troca de cena passa por `Game._change_scene()`.
  Nos testes, `Game.scene_changes_enabled = false` só anota o pedido — dá para
  testar a queda até o Teatro sem que o teste seja trocado pela fase.

### 10. Tempo do jogo: hitstop + câmera lenta
O `Fx` guarda uma lista de efeitos de tempo e aplica o MAIS LENTO enquanto ele
durar. Antes, o golpe final (hitstop de 0,1 s) "travava" a câmera lenta da
vitória inteira em 5% da velocidade — quase um congelamento de quase 1 s.

## Unity → Godot (cola rápida)

| Unity | Godot |
|---|---|
| GameObject | Node |
| Prefab | Cena (`.tscn`) instanciada |
| MonoBehaviour | Script anexado ao nó (`.gd`) |
| `Update()` / `FixedUpdate()` | `_process(delta)` / `_physics_process(delta)` |
| `Rigidbody2D` (kinematic) | `CharacterBody2D` + `move_and_slide()` |
| `OnTriggerEnter2D` | sinal `area_entered` / `body_entered` |
| UnityEvent / C# event | `signal` + `connect()` |
| ScriptableObject | `Resource` (`.tres`) |
| Tags / Layers | grupos (`add_to_group`) / camadas de física |
| `DontDestroyOnLoad` singleton | Autoload (Projeto → Configurações → Autoload) |
| Input Manager | Input Map (Projeto → Configurações → Mapa de Entrada) |

## Onde ajustar o "game feel"

| O quê | Onde |
|---|---|
| Velocidade, aceleração, dash, i-frames, cura | Inspector do `Player` (`scenes/player/player.tscn`) |
| Tempos e dano dos golpes | `data/attacks/*.tres` |
| Fórmulas de Vida/Estamina, regeneração, Exaustão | nó `Stats` de cada personagem |
| Perda de memórias, preço do Frasco de Sanidade | constantes no topo de `scripts/autoload/game.gd` |
| Forja: custo de cada nível, % de dano, teto antes de Durgan | `WEAPON_UPGRADES`, `WEAPON_DAMAGE_PER_LEVEL`, `WEAPON_LEVEL_CAP` em `game.gd` |
| O que cada chefe deixa; teto de frascos; preço da sucata | `BOSS_REWARDS`, `MAX_HEALTH_FLASKS`, `SUCATA_PRICE` em `game.gd` |
| Escudo: ângulo, quanto segura, custo de estamina, quebra de guarda | grupo "Escudo (mão esquerda)" no Inspector do `Player` |
| Chance de drop de cada inimigo | `drop_item` / `drop_chance` no Inspector de cada inimigo |
| Itens: nome, texto, ícone | `data/items/*.tres` (catálogo em `scripts/items/items.gd`) |
| Itens no chão de cada área | `@` no mapa + `item_points` no nó da fase |
| Sono: quanto sobe/desce, tempo dormindo; raio do barulho de cada ação | grupos "Sono" e "Barulho" no Inspector do `Player` |
| Nuvem de pólen (sono por segundo, tamanho, duração) | `scripts/world/pollen_cloud.gd` e Inspector da `FlorDePolen` |
| Sonâmbulo, Cervo, Fada Murcha | Inspector de `scenes/enemies/sonambulo.tscn`, `cervo.tscn`, `fada_murcha.tscn` |
| Vigia (bocejo, distância para "passar") e Mãe dos Esporos (cipó, flores) | Inspector de `scenes/bosses/vigia.tscn` e `mae_esporos.tscn` |
| Nyssa: sono por ficar parado/curar, bolhas, sonâmbulos, buracos e ecos | Inspector de `scenes/bosses/nyssa.tscn` (grupos "Sono", "Fase 1", "Fase 2") |
| O golpe de cada eco | `KINDS` em `scripts/bosses/dream_echo.gd` |
| Armadura da Helena (queda por segundo/por golpe, redução de dano) | Inspector da `HelenaAltiva` |
| Aldir: onda, salto, investida, tamanho dos buracos | Inspector do `AldirCornelios` (`scenes/bosses/aldir_cornelios.tscn`) |
| Golpes do Aldir | `data/attacks/aldir_*.tres` |
| Vida das coberturas | `max_health` em `scripts/world/destructible_cover.gd` |
| Quanto custa cair num buraco | grupo "Queda" no Inspector do `Player` |
| Quantos soldados atacam juntos | `MAX_ATTACKERS` em `soldado_remendado.gd` |
| Cão: distância em que rodeia, alcance do bote, intervalo | Inspector de `scenes/enemies/cao_de_guerra.tscn` |
| Atirador: tempo de mira, dano/velocidade/alcance da bala | Inspector de `scenes/enemies/atirador.tscn` |
| Civil: o que provoca (raio do dash, velocidade "correndo"), tempo para acalmar | Inspector de `scenes/enemies/civil_cinzento.tscn` |
| Sargento: soldados por apito, % de vida por apito | Inspector de `scenes/bosses/sargento.tscn` e `WHISTLE_STEP` |
| Couraça: velocidade de giro, dano de frente, paciência antes do giro | Inspector de `scenes/bosses/couraca.tscn` |
| Distância/tempo em que um mini-chefe desiste | `reset_distance` / `reset_time` (Inspector de cada mini-chefe) |
| Crianças: vida, velocidade, tempo no chão, quanto encolhem por queda | `VARIANTS` e Inspector de `scenes/enemies/crianca.tscn` |
| Governanta: grito (alcance, velocidade), ecos, distância em que ela observa | Inspector da `Governanta` (`scenes/bosses/governanta.tscn`) |
| Golpes da Governanta e das crianças | `data/attacks/governanta_*.tres`, `crianca_espetada.tres`, `adolescente_golpe.tres` |
| O que cada ponto "Examinar" diz | `lore_points` no nó `Prologo` + `data/dialogos.json` |

## Testes automáticos

```bash
godot --headless --fixed-fps 60 --path . res://tests/test_runner.tscn
```

59 grupos de teste cobrem: regras de estamina/Exaustão, a linha do tempo do
Step and Anchor, que o golpe avança para frente mesmo com o joystick para trás,
que nada atravessa parede (andar, golpe e dash), combo leve/forte, escudo do
soldado (frente × costas × golpe forte), frascos, morte/memórias/visão, as 3
fases da Helena, as 2 fases do Aldir (martelada, onda bloqueada pela
cobertura, buracos, transição que derruba as coberturas, salto, investida
até a parede, vitória), cair no buraco × atravessar com o dash, o **Prólogo inteiro** (a criança
espeta, foge, cai e levanta menor; só golpe do herói conta; o grito acerta
quem fica parado e não acerta quem atravessa com o dash; o abraço avisa; fase
2 com ecos; o caminho sem violência — ela só observa, a porta abre, o chão some,
Criança Poupada no Teatro; o caminho da violência — ela levanta, a porta
tranca, a lembrança, a porta destranca, a cadeira vazia depois), o save v2 com
migração do v1, o Novo jogo abrindo o prólogo, os inimigos da Cidade (o cão morde e recua; o atirador mira, trava a linha e atira; a bala para na parede e o dash a atravessa; o civil só reage quando provocado), os mini-chefes (o Sargento apita a cada 25% e o pelotão cai junto com ele; o mini-chefe desiste se você foge; a Couraça só sente golpe pelas costas), o inventário e o save v3 (com migração do v2: quem já venceu chefes recebe o que eles deixam), a forja (custo, +24% no golpe, teto antes e depois de Durgan), o Orbe (fragmento vira frasco), itens do chão que não voltam e drops, o escudo (frente × costas × indefensável, quebra de guarda, virar sozinho para a bala) e o menu de inventário, o Bosque (a Barra de Sonolência sobe e desce, dormir e acordar, o dash na nuvem; o barulho de cada ação; o sonâmbulo que vai até o som e volta a dormir; a flor que incha e solta; o cervo que trava a mira e fica tonto na parede; a fada que cura; passar pelo Vigia em silêncio ou acordá-lo; a Mãe dos Esporos e o cipó pesado em quem dorme; a porta do Bosque que abre depois do Aldir), Nyssa (a luta começa ao entrar; sono por ficar parado; bolhas; o anel quando você cola nela; dano enorme não pula o Pesadelo; o chão some e volta; ecos só de chefes vencidos; vitória, lembrança e a cama de flores; outra fala para quem passou pelo Vigia em silêncio; os espinhos que abrem depois da Mãe; a Fada que fala da irmã) e os ecos de cada chefe, os mapas (inclusive que são
**fechados**) e os controles de toque. E os testes de **regressão** de cada bug já corrigido: save com cópia de
segurança e save corrompido, minimizar no título, pausa soltando os toques,
tecla do diálogo ignorada, cura guardada no fim do golpe, porta mantendo
vida/frascos, morte registrada na hora, botão Voltar, fichas de ataque dos
soldados, postura/salto/pose da Helena, o Fader, a câmera lenta empilhada
e a pausa bloqueada durante as cenas curtas. Os testes usam um save
próprio (`user://teste_automatico_save.json`) — o seu nunca é tocado.

Há também `tests/soak_test.tscn` (um robô joga ~8 minutos de jogo — Prólogo
pelo caminho da violência até a queda, Cidade (de escudo), os dois mini-chefes, a forja e o Orbe, Helena, Aldir e o
Bosque com os mini-chefes dele e a Nyssa — procurando erros; aceita durações: `-- 90 150 150 120 90`, 0 pula) e
`tests/screenshot_tour.tscn` (tira as fotos desta página; `-- --only=bosque` tira só as do Bosque).
Para rodar só alguns testes enquanto mexe numa coisa: `... test_runner.tscn -- vigia sono`.

## Desempenho em celular fraco

O projeto desenha na resolução da tela (`stretch/mode = canvas_items`): textos
nítidos, mas mais pesado em telas 2K. Se o jogo ficar lento ou esquentar, troque
para `viewport` em *Projeto → Configurações do Projeto → Exibição → Janela →
Stretch → Mode* (ou no `project.godot`: `window/stretch/mode="viewport"`). O
jogo passa a ser desenhado em 480×270 e só ampliado: pixel art perfeita e bem
mais leve (os textos ficam mais "pixelados").

## Ferramentas (regerar assets)

```bash
python3 tools/art/gen_art.py         # pixel art (precisa de: pip install pillow)
python3 tools/audio/gen_sfx.py       # efeitos sonoros (precisa de: pip install numpy)
python3 tools/gen_resources.py       # .tres de golpes, chefes, itens e animações
godot --headless --path . --script res://tools/setup_project.gd   # Input Map + TileSets
```

Toda a arte é **provisória e gerada por código** com a paleta das suas imagens
de referência — feita para ser substituída pela arte final mantendo os mesmos
tamanhos de quadro (herói/soldado/crianças 24×24, Helena 32×32, Governanta
32×40, tiles 16×16).

## Próximos passos sugeridos (pela Bíblia)

1. **Raízes da Fome (Gula — Mabel Vorágine)**, a próxima ilha na ordem da Bíblia.
2. **A Criança Poupada como aliada de verdade:** segui-lo pelas áreas e reagir a cada Pecado vencido (hoje ela fica no Teatro e dá dicas).
3. Fazer o mundo lembrar da escolha: falas novas da Fada/Orbe para quem feriu as crianças; levar a memória do Aldir ao Teatro (fala nova da Fada/Orbe) e a ordem dos Pecados da Bíblia (Helena por último).
4. Arte final e animações (as cenas já separam corpo, arma e peças de armadura).

## Créditos e licenças

- Código e arte provisória: gerados para este projeto.
- Fontes (SIL Open Font License, textos em `assets/fonts/`): Cinzel, Pixelify Sans, Tiny5.
- Imagens de referência em `docs/referencias/`: arte conceitual do autor (Bíblia do Jogo).

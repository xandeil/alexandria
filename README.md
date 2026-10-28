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
- **Raízes da Fome (Gula)** — a porta **oeste** do Teatro (a do lado oposto ao Bosque: as duas metades da ilha 4 do mapa) abre depois de vencer Nyssa. "Raízes vermelhas que pulsam como veias. Antigas estufas e cozinhas viraram ninhos."
  - **O agarrão** (mecânica nova, a dica da Bíblia): algumas coisas te **prendem**. Preso, **toque rápido no Ataque** para se soltar (a tela mostra quantos toques faltam e o botão vira "Solte-se!"); a cada segundo preso você perde **uma parte das memórias** e um pouco de vida. O dash na hora certa evita o agarrão; escapar deixa quem agarrou **tonto**.
  - **Boca de Raiz:** um montinho de terra com uma fenda vermelha no caminho — dá para ver, se você olhar. Pisou perto, o monte incha (aviso) e ela **agarra**. Errou o bote ou você escapou: fica de pé, exposta, mordendo — é a hora de cortar.
  - **Inchado:** lento, tapa fácil de ler... e **explode ao morrer** (círculo vermelho enchendo). A explosão fere **os outros inimigos também**: mate-o no meio do grupo.
  - **Colhedor:** antigo trabalhador da estufa com uma foice longa. O arco (200°) alcança mais longe que a sua espada; entre na guarda dele depois do golpe — mas colado tempo demais, ele gira a foice em volta.
  - **Larva de Seiva:** enxame pequeno. Cada mordida **rouba memórias**; a larva que roubou **brilha e foge**. Matá-la **devolve tudo**.
  - **Mini-chefe — O Banqueteiro:** o cozinheiro **serve** lacaios (larvas ou um Inchado) e, ferido, anda até um deles e **o come para se curar** (aviso no chão; golpe forte interrompe). A lição de Mabel antes de Mabel: **mate a fonte de cura primeiro**. Ele guarda a porta dos fundos.
  - **Mini-chefe — A Ninhada:** um monte de larvas que **solta larvas** a cada pedaço de vida perdido e **engole** quem fica no círculo.
- **Mabel Vorágine, A Fome Que Lembra (Gula)**, na Mesa de Mabel:
  - **Fase 1 — A Anfitriã:** lenta e enorme. **Tapas** (leque vermelho), **frutos de carne** arremessados (círculos onde vão cair) e o **agarrão**: uma linha vai da mão até você — travou (pisca), saia. Pegou: ela **engole** você, prova suas lembranças ("Um aniversário... velas... quem era essa criança?") e se cura enquanto drena memórias. Escapou: ela **engasga** — dano dobrado.
  - **Fase 2 — A Vorágine (metade da vida):** uma **boca se abre no ventre** (de frente, o golpe dói mais). Quatro **Raízes-Veia** brotam e ficam ligadas a ela por linhas que pulsam: **curam Mabel** e delas saem lacaios, que ela **come para se curar e crescer**. Cortar as raízes interrompe a cura.
  - Vencida, fica **a mesa posta** onde ela sentava — e o **Vendedor** do Teatro passa a lembrar de quem comprava humanidade líquida "para as plantas".
- **Forjas Ocas (Inveja)** — no alto do Bosque, uma trilha de pedra presa por correntes (e pelas raízes de Mabel) se abre depois de vencer Mabel. "Ruínas de pedra por cima, fábrica por baixo. Placas metálicas no chão, correntes enormes descendo até as Âncoras."
  - **Placas de raio** (mecânica nova): o chão de metal conduz eletricidade. Placas que **acendem em amarelo** vão levar um choque daqui a pouco — saia delas (o escudo não segura; o dash por cima passa).
  - **Autômato de Bronze:** o rosto do Ferreiro do Teatro, em bronze. Lento e blindado — o corte leve perde força, o **golpe forte** entra inteiro. Às vezes emenda um segundo golpe.
  - **Torreta de Faísca:** não mira você, mira o **chão**: acende a trilha de placas até você e as placas em volta. Perto dela não há perigo — chegue e desmonte.
  - **Minerador Oco:** sempre **três** picaretadas (a terceira, pesada, com a picareta bem alto). Depois, fôlego longo: a janela.
  - **Imitador:** um reflexo de bronze com o **seu** equipamento (a sua espada; o seu escudo, se você usa um). Faz o que você faz, um instante depois: você corta, ele corta; você dá dash, ele também; você ergue o escudo ou bebe, ele copia. Varie.
  - **Mini-chefe — O Protótipo:** você, em bronze, maior e inacabado. Sabe só o **seu corte leve** (e o dash para chegar perto) — ler o próprio golpe de fora.
  - **Mini-chefe — O Guardião da Âncora:** máquina enorme presa a uma corrente da ilha. A carcaça segura quase tudo; depois de **dois ataques** ela superaquece e o **núcleo fica exposto**. Corrente (leque enorme) e pilão (círculo + raio nas placas em volta). Vencida, **a ilha treme** e a porta para Durgan se abre na hora.
- **Durgan Vell, O Eco de Bronze (Inveja)**, na Forja do Eco:
  - **Fase 1 — O Engenheiro:** chave-martelo elétrica (a martelada acende um anel de placas), **constrói torretas**, **chama autômatos** e acende as placas em volta de você de tempos em tempos.
  - **Fase 2 — O Reflexo (metade da vida):** armadura espelhada. Durante a luta inteira ele **contou** o que você fez (corte, golpe forte, dash, escudo, frasco) e agora **escolhe o que fazer com peso proporcional**: quem só deu golpe forte apanha de golpe forte; quem abusou do dash enfrenta alguém que **esquiva** quando você ataca; quem se escondeu no escudo encontra um escudo espelhado que **apara e revida**; quem bebeu muito vê ele beber também.
  - Vencido, a chave-martelo fica onde ele caiu — e o **Ferreiro do Teatro lembra do irmão** e passa a melhorar a arma **até +5**.
- **Montanha Carbonizada (Orgulho)** — da **ponte levadiça** no alto da Cidade (desce depois de vencer Durgan: o selo da trava é dos irmãos Vell). "Florestas queimadas, ossos de dragões, cavernas fundas e cinza no ar." Rios de lava cortam a ilha; só se atravessa pelas pontes de basalto.
  - **Fogo no chão** (mecânica nova): bolas de fogo, o lança-chamas e o hálito deixam **chamas que queimam** quem fica em cima — um pouco de vida a cada meio segundo, sem cambalear. O dash por cima passa ileso.
  - **Dragonoide Atirador:** anda, **guarda distância** e atira uma rajada de três bolas de fogo (a linha de mira trava antes). Colado nele: coronhada e um pulo para trás.
  - **Dragão Bestial:** rodeia, abaixa a cabeça (linha) e **dispara em linha reta**, atropelando. Bateu na parede: **tonto**. De perto, morde. Dash para o lado.
  - **Dragão Alado Menor:** no ar é **intocável** — só a sombra mostra onde está. Escolhe um ponto perto de você (círculo enchendo) e **mergulha**; no chão cospe fogo à frente e fica um instante parado: a janela.
  - **Brasa Viva:** chama pequena e rápida que persegue, **incha e estoura** (círculo laranja). Um golpe antes do estouro a apaga — e cancela a explosão.
  - **Mini-chefe — O Capitão Dragonoide:** alterna **escudo** (de frente quase nada passa; pelas costas, tudo) e **lança-chamas** (um cone que varre e incendeia o chão). A **troca de postura** é a janela — é o único momento em que ele cambaleia.
  - **Mini-chefe — A Matriarca Bestial:** investidas enormes (bateu na parede, fica tonta) e **pisoteios que abrem buracos** no chão — a arena vai ficando menor. Guarda a trilha do Ninho.
- **Rachel Azheryon Caelis, O Orgulho do Céu (Orgulho)**, no Ninho — dorme sobre o que sobrou das cidades:
  - **Hálito de fogo:** um leque vermelho avisa; depois um **jato** varre de um lado ao outro, passando por cima de você, e deixa o chão em chamas. Ficar colado nela **não** evita o fogo (o hálito tem relógio próprio). O jato **para na pedra**: os seis **pilares de rocha** da arena são o esconderijo.
  - **Rugido:** um anel que derruba quem não atravessa com o dash — e **derruba os pilares**. O esconderijo de agora não é o de daqui a pouco.
  - **Cauda:** quem fica atrás leva um golpe em círculo que **quebra o chão**.
  - **A arena desmorona:** a cada quarto de vida perdido, a borda inteira **desaba** (aviso, depois buraco para sempre). O espaço seguro encolhe até o fim.
  - Vencida, fica uma **escama** do tamanho de um escudo — e o **Vendedor Dragonoide** do Teatro (um desertor do ninho) fala do Capitão e dela.
- **Domínio Congelado (Ganância)** — por um **túnel de gelo** na parede oeste da Montanha (o gelo cede depois que Rachel cai). "Cidade de cristais de gelo, bibliotecas congeladas, pessoas presas no gelo em pose de leitura. O chão é escorregadio."
  - **Gelo no chão** (mecânica nova): no gelo azul o herói **escorrega** — demora a ganhar velocidade e demora a parar; o dash continua igual, mas desliza no fim. Correr atrás de alguém em linha reta no lago congelado é pedir para cair num buraco... de água escura.
  - **Frio:** estilhaços de gelo, o anel do Aprendiz e a geada deixam o herói **lento** por um instante (ele fica azulado).
  - **Bibliotecário de Gelo:** de longe, mira e lança dois estilhaços; chegou perto, **foge**. Encurrale-o.
  - **Estátua Viva:** só se mexe quando você está **de costas** para ela. Olhando, é pedra — e o golpe quase não entra. A regra ensina a posicionar o grupo: deixe a estátua sempre à sua frente.
  - **Ácaro de Cristal:** enxame que pula e **gruda**, bebendo estamina (não vida). O **dash sacode todos**.
  - **Aprendiz Arcano:** uma **bolha** segura tudo; o golpe forte a parte de uma vez (e ele fica atordoado). De perto, um anel de gelo em volta dele.
  - **O Estudioso**, congelado no meio de uma página na praça de chegada. Quando a Curadora cai, ele fica livre — e conta o que sabe; depois do Golem, lê o relatório do Projeto para você.
  - **Mini-chefe — A Curadora de Vitrines:** um retângulo azul enche em volta de você — saia, ou fica **preso num bloco de gelo** (toques rápidos no Ataque, como o agarrão das Raízes). Preso, ela vem **catalogar** com a bengala pesada.
  - **Mini-chefe — O Golem do Arquivo:** estantes congeladas de pé. Não cambaleia; pilão (o chão em volta congela), braço-estante e leque de **livros arremessados**. Vencido, deixa o **Livro do Arquivo**: o relatório do Projeto Alexandria.
- **Cassian Virel, O Arconte do Zero (Ganância)**, na Sala do Arconte:
  - **Fase 1 — O Arquimago:** lanças de gelo (leque, linha que trava), **geada** (retângulos no chão em volta de você), **pilares de gelo** entre vocês que derretem sozinhos (bloqueiam o caminho — e os estilhaços dele também) e, se você cola nele, ele **some num piscar** e reaparece longe.
  - **Fase 2 — O Colecionador (metade da vida; não dá para pular):** **congela metade da arena** (aviso longo; quem ficar vira peça da coleção), invoca **Estátuas Vivas** e **rouba a sua estamina** com um raio que trava — pegou, a barra zera e demora a voltar.
  - Vencido, fica o **cajado do Arconte** e o gelo começa a pingar.
- **O Núcleo (final)** — com as **sete memórias** (Aldir, Nyssa, Mabel, Durgan, Rachel, Cassian e Helena), uma **coluna de luz** desce sobre o palco do Teatro. "Quando as sete memórias se uniram, o caminho se abriu."
  - **O Jardim:** a ilha mais alta, um jardim com ruínas. **Nenhum inimigo** — o silêncio antes do fim. Sete estátuas sem rosto, uma para cada Pecado: examine cada uma e a memória dela conta o seu pedaço do pacto que ergueu a ilha.
  - **O Coração:** ela respira devagar, suspensa, presa por fios de luz à estrutura da ilha. Diante dela, **o Cavaleiro Desolado** — o que restou do Cientista da Gravidade (a leitura que a Bíblia sugere).
    - **Fase 1 — O Guardião:** ele fica **sempre entre você e ela**. Espadão em tempos; apanhou três vezes seguidas, **ergue a guarda** (de frente quase nada entra — e bater na guarda chama o contragolpe); longe dele, **a gravidade puxa** você (o dash escapa).
    - **Fase 2 — A Promessa (metade da vida; não dá para pular):** **pedras de mármore caem do alto** (círculos), um **anel de gravidade** empurra para longe e, ajoelhado diante dela, ele **renova o elo**: uma linha de luz o cura. **Fique no caminho da luz** para cortar a cura.
    - Vencido, ele **não some**: fica ajoelhado. Aproxime-se dela.
  - **A escolha** (Bíblia: "O jogo não diz qual é o certo; só mostra as consequências"):
    - **Proteger (Continuidade):** você assume o lugar do cavaleiro. A ilha não cai. *Algumas coisas sobrevivem, mas nunca vivem.*
    - **Destruir (Ruptura):** você rompe o elo. A ilha começa a cair; o impacto não é mostrado. *Libertar algo pode ser o mesmo que destruí-lo.*
    - Depois, a tela final e os créditos. O save lembra quais finais você já viu.
- **Opções** (no título e na pausa): volume dos **efeitos** e da **música/ambiente** (de 10 em 10%), **vibração**, **tamanho dos botões de toque** (pequenos, médios, grandes) e **dicas**. Ficam no aparelho (`user://opcoes.cfg`), não no save: começar um jogo novo não muda o seu volume.
- **Tema do título:** uma música curta em lá menor (harpa e sino), gerada por código como o resto do som.
- **Dicas de primeiros passos:** aparecem uma vez cada, na hora certa — andar ao chegar, atacar quando um inimigo chega perto, esquivar no primeiro golpe levado, estamina quando a barra acaba, beber quando a vida cai, a câmara de descanso, as memórias. No celular falam dos botões; no teclado, das teclas.
- **Kit de publicação:** scripts para criar a **chave de publicação fora do projeto** e compilar o APK/AAB de publicação pedindo a senha na hora (`tools/criar_chave_release`, `build_release`), um preset de exportação **AAB** para a Play Store e o kit da loja em `docs/loja/` (textos, ícone 512, destaque 1024×500, capturas, classificação indicativa, política de privacidade e checklist). Veja a seção "release" do `BUILD.md`.
- **O Guarda Sem Posto** — o marido de Helena, de volta sem memória (Bíblia: "voltou sem memória, de cabelo branco e um pouco mais jovem. Não lembra de Helena, só de que abandonou um posto e alguém pagou por isso"):
  - Você o encontra na **Cidade**, protegendo os Civis Cinzentos. Depois de conversar, ele vai para o **Teatro**.
  - **Um fragmento por ilha:** a cada Pecado vencido ele lembra um pedaço — um anel, uma voz de mulher, um posto vazio, a mulher da plateia que ele não consegue parar de olhar.
  - **"Venha comigo":** ele luta ao seu lado nas ilhas (não nas arenas dos Pecados): segue você, corta o inimigo mais perto de você e leva os golpes no meio da briga. Caiu de joelhos, volta para o Teatro.
  - **O sacrifício:** quando você desafia a mulher da plateia, ele entra na frente do golpe — "Eu não lembro de você. Mas lembro deste lugar." Fica o **posto vazio** e o **Anel do Guarda** vai para você.
  - **Fase 3 de Helena:** sem armadura, ela vê o anel na sua mão e **para** ("Esse anel... Ele esteve aqui? Todo esse tempo... e eu não..."). É o golpe emocional da luta — e uma janela de 3 segundos em que o golpe dói mais.
- **Título no estilo soulslike:** fundo preto com cinzas subindo, "PRESSIONE QUALQUER BOTÃO" e um menu só de texto branco — o item escolhido clareia com uma faixa de luz atrás (no mouse, no teclado e no controle). A pausa e as Opções seguem o mesmo estilo.
- **Controle no padrão soulslike:** R1 ataque · R2 golpe forte · ○ esquiva · □ frasco de vida · △ **Humanidade** (Frasco de Sanidade) · ✕ interagir/falar · L1/L2 escudo · Start pausa · Share/Select inventário. No teclado, F também interage.
- **Modo controle** (Opções): os botões de toque somem e, no lugar, aparece uma legenda discreta com os botões do PlayStation e o que cada um faz agora (o ✕ mostra "Falar"/"Examinar" perto de alguém; os frascos mostram quantos restam). As dicas e o "PRESO!" passam a falar dos botões do controle.
- **Criação de personagem** (depois de "Novo jogo", antes do despertar): Homem ou Mulher, 3 corpos (Magro, Forte, Gordo), 3 rostos e 5 cabelos para cada sexo — 90 combinações, com prévia andando e o botão "Aleatório". A escolha fica no save; saves antigos ficam com o visual de antes. O cabelo e os olhos de todas usam as cores-chave do shader, então continuam embranquecendo a cada morte.
- **Armas de chefe** (o Ferreiro forja na aba "Forjar com Lembrança"; a Lembrança **não é gasta**, porque ela abre o Núcleo):

  | Arma | Chefe | Classe | Escala | Habilidade |
  |---|---|---|---|---|
  | Lâmina Desolada | Helena | Espada | DES A | o golpe forte é uma estocada longa; se acertar um inimigo, devolve estamina |
  | Pilar da Estilhaçada | Aldir | Martelo | FOR S | onda de choque: postura de todos em volta zerada (escudo não segura) e coberturas quebradas |
  | Presa de Caelis | Rachel | Espada Grande | FOR B · MAG C | rastro de fogo por 3 s; custa estamina extra (no lugar de mana) |
  | Fuso do Arconte | Cassian | Lança | MAG A · DES C | rouba estamina e atrasa o próximo golpe do inimigo |
  | Replicador de Bronze | Durgan | Besta | FÉ B · DES B | virote elétrico que salta para o inimigo mais perto |
  | Presas da Vorágine | Mabel | Adagas | SOR A · DES B | sangramento (a barra enche e estoura) + cura fixa de 2 + Sorte × 0,2 |
  | Arco do Sono Eterno | Nyssa | Arco | FÉ S | flecha de pólen: metade da velocidade de movimento e de ataque |
  | Âncora da Gravidade | Cavaleiro | Machado | FOR A · FÉ A | vórtice que puxa os inimigos e explode; chefes e gigantes não saem do lugar |

  A Âncora é pós-final: vencer o Cavaleiro deixa a "Lembrança: O Posto Vazio" (saves antigos de quem já venceu também recebem). O reforço do Ferreiro (+1…+5) vale para todas as armas.
- **Parry e crítico (como no DS3):** L2 com escudo (ou de mão vazia, janela menor) **apara**. Golpe aparado = guarda do inimigo aberta (ele brilha dourado e aparece "ABERTO"); R1 perto dele faz o **crítico** (3× o golpe leve, + Sorte; em chefe, metade), invencível durante a animação. Pelas costas de um inimigo comum, R1 também é crítico. Dá para aparar golpes de arma (soldados, cães, Helena, Sargento, Cavaleiro I/II...); não dá para aparar agarrões, tiros, fogo e golpes de gigantes (Aldir, Rachel, Mabel, Golem, A Promessa).
- **Duas mãos e duas armas** (o L1/L2 muda com o que você segura — a legenda e os botões de toque acompanham):

  | Mãos | R1 / R2 | L1 | L2 |
  |---|---|---|---|
  | Escudo na esquerda | fraco / forte | defende (segura 85%) | aparar |
  | Mão esquerda vazia | fraco / forte | — | aparar (janela menor) |
  | Duas do mesmo tipo (ex.: duas espadas) | só a direita | as duas juntas: 75% da soma do dano, custa a média × 1,25 | forte da esquerda |
  | Tipos diferentes | ataques da direita | fraco da esquerda | forte da esquerda |
  | Duas mãos (segurar △) | +50% de dano e de estamina | guarda com a arma (segura 75%) | **ataque especial** da arma |

  O especial é onde mora a habilidade das armas de chefe (a onda do Pilar, o fogo da Presa de Caelis...); a espada inicial gira 360°. Arco e besta já atiram com as duas mãos (sem bônus). Toque rápido no △ continua sendo a Humanidade. O escudo só vai na mão esquerda. Para usar a MESMA arma nas duas mãos, o Ferreiro forja uma cópia (a espada inicial também).
- **Controle nos menus (v0.21.1):** ✕ confirma e ○ volta em todos os menus (título, Opções, pausa, inventário, Fada, Ferreiro, criação de personagem). O Godot 4 não traz botão de controle para "confirmar"; agora o mapa de controles define isso. E o autoload **PadMenus** garante que um menu nunca fica sem item selecionado no controle (no celular a seleção podia se perder): qualquer botão do controle seleciona o primeiro item, e o ✕ confirma na hora de apertar.
- **Correr (v0.22):** segurar ○ corre (60% mais rápido, gasta estamina enquanto corre e não deixa regenerar); o toque rápido continua sendo a esquiva — que agora sai ao SOLTAR o botão, como nos soulslike (só assim dá para saber se foi toque ou segurar). Funciona igual no teclado (Espaço) e no botão de toque.
- **Menu da Câmara e viagem (v0.22):** descansar abre o menu de descanso: à esquerda o SEU personagem (a aparência da criação) desce na cápsula e a tampa fecha; à direita, as Câmaras já desbloqueadas, cada uma com a miniatura da região (montada com os tiles dela). Escolher uma = viajar: você acorda dentro da outra cápsula e passa a renascer lá. Uma Câmara desbloqueia quando você descansa nela; o Teatro já vem aberto depois do Prólogo. ○ ou "Levantar" fecha.
- **Correção (v0.22.1):** no menu da Câmara, com menos de 4 Câmaras (uma linha só), o → do controle pulava para o "Levantar" e não deixava escolher as outras. Agora ←/→ passam por todas (dando a volta), ↓ vai para o "Levantar", e a Câmara onde você está nem recebe foco.
- **Mapa-múndi:** `tools/map/render_map.tscn` fotografa cada região inteira dentro do próprio Godot e `tools/map/compose_world_map.py` monta o mapa do mundo, com as ilhas ligadas pelas saídas reais de cada fase.
- **Modo Limpo (v0.24):** Opções → "Controles" agora tem 3 jeitos, em ciclo: **Toque** (botões na tela), **Controle** (legenda discreta do PlayStation) e **Limpo** (nada na tela além da vida e das memórias — nem os botões de toque, nem a legenda, nem o "II" da pausa; a pausa fica no Start/Esc). Para jogar no controle ou no teclado.
- **Armaduras (v0.25):** cinco espaços no corpo (capacete, peitoral, luvas, calça, botas) e **7 conjuntos**, um escondido em cada região de chefe (as 5 peças largadas no chão, num canto). Cada peça vestida soma um pouco do efeito do conjunto, como o Anel de Lâminas do DS2 em pedaços — e dá para misturar: Vigília (vida +6%/peça, Teatro), Detentor (dano +4%/peça, Cidade), Sono Leve (estamina volta +12%/peça, Bosque), Banquete (drops +15%/peça, Raízes), Eco (alcance +6%/peça, Forjas), Caelis (andar +12%/peça — com as 5, andar = correr — e correr ainda mais rápido, Montanha), Arconte (memórias +8%/peça, Domínio). Inventário: nova aba **Armadura** (✕ veste/tira) e os 5 espaços na coluna EQUIPADO. Os números moram numa tabela só: `scripts/items/armor_sets.gd`.
- **Farm da Montanha (v0.26):** no campo de baixo da Montanha Carbonizada (do lado da Câmara) pasta o **Bezerro Dourado**. Bateu nele, ele dispara pela mesma volta um pouco mais rápido que o herói correndo com as 5 Escamas de Caelis (178 contra 168) — por trás ninguém alcança; corte caminho por dentro da volta, espere na curva, use o dash. Morre com **exatamente 7 golpes**, qualquer arma. Caiu o bezerro, o chão treme e o pai despenca do céu: **O Minotauro**, que pula pelo campo todo (salto grande com círculo vermelho, três pulinhos seguidos para todo lado, machadada de perto). Vencido: **4000 memórias + 10 Sucata Temperada**. Ele não fica no save: venceu, morreu, saiu do campo ou descansou — o bezerro volta a pastar como se nada tivesse acontecido. Quem amarra o ciclo é o `FarmSpot` (padrão Mediador): o bezerro e o minotauro não se conhecem.
- **NG+ (v0.27):** depois dos créditos, dois botões: **Iniciar nova jornada** (vai direto para a criação do próximo experimento) e **Explorar o mundo atual** (volta para a Câmara; de lá, o menu da Câmara também oferece a nova jornada). O novo experimento herda **só o nível** (os atributos); memórias, armas, armaduras, reforço e frascos recomeçam. O mundo endurece: vida e dano dos inimigos (e as memórias que dão) ×1,5 no NG+, +0,25 por ciclo, até ×3 no NG+7. **Final Proteger:** no ciclo seguinte quem guarda o Núcleo não é o Cavaleiro — é o **Experimento Anterior**: o seu personagem, com a aparência, as armas nas mãos (escudo, duas armas, duas mãos, arco), a armadura e os atributos do momento do final, a arma no reforço máximo; ele desvia rolando quando você ataca, bebe frascos longe de você, ergue o escudo, e na metade da vida o Núcleo o escolhe (fica dourado, mais rápido, pedras de luz, anéis de gravidade). **Final Destruir:** o Cavaleiro de sempre, mais forte. **Criação de personagem:** agora escolhe a arma (Espada, Espadão, Lança, Martelo, Adaga ou Arco de Cobaia) — ela fica largada no chão do Prólogo; quem não vê, começa no soco. O Ferreiro copia a arma comum que você tem.
- **Câmara animada (v0.28):** descansar agora é uma cena: o herói vai até a frente da cápsula, a tampa de vidro sobe chiando, ele sobe e deita, a tampa fecha e o vidro embaça. Ao levantar (e ao acordar depois de viajar, de cair no Teatro ou de morrer), a luz pisca, sai vapor, a tampa abre, ele senta, pula para fora e se espreguiça. A cápsula virou PEÇAS (corpo, o seu sprite deitado e a tampa por cima) — por isso a cena funciona com qualquer uma das 90 aparências.
- **3 saves (v0.23), como nos soulslike:** cada slot é um personagem. A tela de saves mostra o personagem (a aparência da criação), o nível, onde parou, memórias, mortes, quantos Pecados caíram e o tempo de jogo. Título: **Continuar** (o último save usado), **Carregar** (escolher um dos 3) e **Novo jogo** (escolher o slot; num slot ocupado é preciso confirmar, porque ele é apagado). O save único das versões antigas vira o slot 1 sozinho.
- **Armas de chefe no chão (v0.23):** todo inimigo COMUM tem 3% de chance (a Sorte aumenta) de deixar cair uma das 8 armas de chefe que você ainda não tem duas. A arma caída brilha mais forte que os outros itens.
- **Loja do Vendedor (v0.23):** "Negociar" abre a loja, no estilo do inventário, com o retrato dele: **Comprar** (Frasco de Sanidade, Sucata Temperada e Fragmento Turvo — este com só 3 no estoque) e **Vender** (sucata, fragmentos e cópias de armas que não estão na mão; Lembranças e o escudo não se vendem). Depois da Rachel, ele vende 20% mais barato.
- **Ferreiro novo (v0.23):** mesmo estilo (retrato, abas Reforçar/Forjar, grade, ficha com letras de escala e custos com ícones). Loja e Ferreiro herdam da mesma base (`SoulsMenu`): só o conteúdo e a cor mudam.
- **Inventário soulslike** (uma mistura nossa de DS1/2/3 com Lies of P): abas com L1/R1 (Q/E no teclado), grade de espaços com quantidade no canto e "E" de equipado, coluna EQUIPADO à esquerda, ficha à direita com Ataque leve/forte, tabela de letras FOR DES MAG FÉ SOR e a habilidade. A legenda do rodapé desenha os símbolos do PlayStation no modo controle.
- **Correção:** derrotar um mini-chefe que tranca uma porta (a Mãe dos Esporos, o Banqueteiro, o Guardião) agora **abre a porta na hora**; antes era preciso sair e voltar.
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
| ![Boca de Raiz: preso](docs/screenshots/r04_boca_agarrou.jpg) | ![O Inchado vai estourar](docs/screenshots/r08_inchado_vai_estourar.jpg) |
| ![O Banqueteiro serve](docs/screenshots/r09_banqueteiro_serve.jpg) | ![A Ninhada vai engolir](docs/screenshots/r11_ninhada_engolir.jpg) |
| ![Mabel — o tapa](docs/screenshots/m03_tapa_aviso.jpg) | ![Mabel — engolido](docs/screenshots/m06_engolido.jpg) |
| ![Mabel — as raízes](docs/screenshots/m08_voragine_raizes.jpg) | ![Mabel come um lacaio](docs/screenshots/m09_come_lacaio.jpg) |
| ![A galeria das estátuas](docs/screenshots/f02_galeria_estatuas.jpg) | ![A torreta acende as placas](docs/screenshots/f05_torreta_placas.jpg) |
| ![O Guardião da Âncora](docs/screenshots/f08_guardiao_pilao_placas.jpg) | ![O núcleo exposto](docs/screenshots/f09_guardiao_nucleo.jpg) |
| ![Durgan — a martelada elétrica](docs/screenshots/d04_martelada_eletrica.jpg) | ![Durgan — o Reflexo](docs/screenshots/d06_reflexo_escudo.jpg) |
| ![Atirador e bolas de fogo](docs/screenshots/mt02_atirador_bolas_de_fogo.jpg) | ![O Dragão Bestial mira](docs/screenshots/mt04_ossario_bestial.jpg) |
| ![O Capitão — lança-chamas](docs/screenshots/mt08_capitao_lanca_chamas.jpg) | ![A Matriarca abre o chão](docs/screenshots/mt10_matriarca_buracos.jpg) |
| ![Rachel — o hálito](docs/screenshots/rc04_halito_de_fogo.jpg) | ![Rachel — a arena desaba](docs/screenshots/rc06_arena_desaba.jpg) |
| ![O lago congelado](docs/screenshots/gl02_lago_bibliotecario.jpg) | ![Preso na vitrine](docs/screenshots/gl06_preso_no_gelo.jpg) |
| ![O Aprendiz e a bolha](docs/screenshots/gl07_aprendiz_bolha.jpg) | ![O Golem do Arquivo](docs/screenshots/gl08_golem_pilao.jpg) |
| ![Cassian — geada e pilares](docs/screenshots/cv04_geada_e_pilares.jpg) | ![Cassian — metade da arena congela](docs/screenshots/cv06_metade_congela.jpg) |
| ![A escada de luz](docs/screenshots/nc00_escada_de_luz.jpg) | ![As estátuas dos Sete](docs/screenshots/nc02_estatuas_dos_sete.jpg) |
| ![A Promessa — pedras](docs/screenshots/nc06_a_promessa_pedras.jpg) | ![O elo](docs/screenshots/nc07_o_elo.jpg) |
| ![Final — Proteger](docs/screenshots/nc10_final_proteger.jpg) | ![Final — Destruir](docs/screenshots/nc10_final_destruir.jpg) |
| ![O Guarda na Cidade](docs/screenshots/gd01_guarda_na_cidade.jpg) | ![O Guarda lutando ao seu lado](docs/screenshots/gd02_guarda_lutando.jpg) |
| ![O sacrifício](docs/screenshots/gd03_o_sacrificio.jpg) | ![O posto vazio](docs/screenshots/gd04_posto_vazio.jpg) |
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

### 11. Uma regra, vários usuários (o agarrão das Raízes)
- **Quem agarra não controla o herói.** A Boca de Raiz, a Ninhada e a Mabel só
  chamam `player.grab(eu, toques, ...)`. O `Player` ganhou o estado `GRABBED` e
  cuida de TUDO: ficar preso no lugar, contar os toques, drenar memórias a cada
  segundo (`Game.drain_memories`), soltar sozinho se quem agarrou morrer ou
  sumir, e limpar ao sair do estado (por escapar, por um diálogo, por morrer).
  Quem agarrou só pergunta `player.is_grabbed_by(self)` para saber se você
  escapou. Uma regra, três inimigos, um teste — e o jogador aprende uma vez.
- **"Ligações de volta" opcionais:** a Mabel quer saber quando drenou memórias
  (para se curar e "provar" a lembrança). Em vez de o herói conhecer a Mabel,
  ele só faz `if grabber.has_method("on_memories_drained")`. Quem não precisa,
  não implementa (*duck typing*).
- **O ASCII acabou — e tudo bem.** Os mapas já usavam quase todos os
  caracteres. Em vez de inventar símbolos ilegíveis, cada ilha pode dar outro
  significado ao MESMO caractere: `THEME_ENTITIES`/`THEME_PROPS` no `level.gd`.
  No Bosque, `z` é o Sonâmbulo; nas Raízes, a Boca de Raiz. O mapa continua
  legível e acrescentar uma ilha não mexe nas outras.
- **Uma explosão, duas origens:** `FleshBurst` (aviso no chão → estouro → mancha)
  serve ao Inchado (que fere os outros inimigos também) e aos frutos da Mabel
  (que chegam voando em arco até o centro do círculo).
- **Contar em vez de adivinhar (Durgan):** o herói emite `action_used(&"leve" | &"forte" | &"dash" | &"escudo" | &"cura")`. Durgan só conta (um dicionário ação → número, a dica da Bíblia) e, na fase 2, sorteia a próxima ação com peso = contagem + 1 (ninguém fica com chance zero). O Imitador escuta o MESMO sinal para copiar na hora. Um sinal, dois usos — e o herói não sabe que nenhum dos dois existe.
- **Placas que dão choque como dado do mapa:** o `=` do tema "forjas" vira chão E entra em `Level.plate_cells`. Torretas, o Guardião e Durgan só perguntam à fase "quais placas estão perto daqui?" (`plates_near`, `plates_on_line`) e criam um `PlateCharge` (aviso → choque → apaga). Trocar o desenho do mapa muda a luta sem mexer em código.
- **Ciclo de carregamento:** a `Level` carrega a cena de Durgan, e a torreta usa a classe `Level`. Um `preload` da torreta dentro de Durgan fechava um ciclo e a cena chegava VAZIA ("node count is 0"). Solução: `load()` na hora de construir. Regra prática: `preload` só para o que não depende de quem te carrega.
- **Uma explosão, terceiro uso (Montanha):** a Brasa Viva não ganhou uma explosão nova — usa o MESMO `FleshBurst` com `style = "fogo"`, que em vez da mancha deixa um `FirePatch`. O jogador já aprendeu "círculo enchendo = saia"; a ilha nova só muda a cor e o que fica no chão.
- **Dano contínuo sem cambalear:** o fogo no chão chama `player.apply_burn(dano)` — tira vida, pisca, respeita os i-frames do dash, mas **não** passa por `Hurtbox` (sem empurrão nem cambaleio). Se queimar usasse o golpe normal, o herói ficaria preso cambaleando dentro do fogo. Um método pequeno com uma regra clara evita um bug de "trava".
- **O que se vê é o que acerta:** o jato da Rachel é desenhado com a mesma largura que queima (`breath_width`), e o raio para no primeiro obstáculo (`intersect_ray` na camada "mundo"), que é o mesmo pilar que você vê. O teste de "atrás da pedra está seguro" usa a mesma função do jogo.
- **Bateu na parede — depois de mover:** as investidas (Bestial, Matriarca) perguntam "colidi?" **depois** do `move_and_slide()`, não antes. A batida pode cair no exato quadro em que a corrida acaba; checando antes, ela se perdia e o bicho nunca ficava tonto. O teste automático pegou isso.
- **Uma regra num lugar só (o gelo):** há dois tipos de gelo — o do mapa (`=` no tema "gelo" → `Level.ice_cells`) e o que aparece na luta (as `FrostZone` do Cassian, da Curadora e do Golem). O herói não sabe de onde vem: pergunta só `Ice.is_slippery(self)` e, se for gelo, troca a aceleração e o freio por uma fração (`_grip()`/`_brake()`). Um terceiro tipo de gelo amanhã muda UM arquivo.
- **Reaproveitar regras, não código colado:** o bloco de gelo é o MESMO agarrão das Raízes (`player.grab`): o `IceBlock` é só "quem agarrou" — um nó parado. O HUD já sabia mostrar "Solte-se!". Os pilares de gelo do Cassian são `DestructibleCover` com outra textura e um `lifetime` (derretem sozinhos). O livro do Golem usa o mesmo "memorial" dos chefes, agora também para mini-chefes.
- **Um elemento, não vários booleanos:** o `Projectile` tinha `fire: bool`. Com o gelo viria `frost: bool`... e com os livros, `book: bool` — e combinações impossíveis ("fogo E gelo"). Agora é `element` (`Projectile.FIRE`, `FROST`, `TOME`): uma escolha só.
- **Um getter não muda o estado:** a bolha do Aprendiz primeiro foi escrita dentro de `_incoming_damage_multiplier` (que "só devolve um número") — e ele gastava a bolha toda vez que alguém perguntava. Foi para o `_on_hit_received`, onde o golpe realmente chega.
- **Primeiro prende, depois dói:** a geada que prende E fere tinha um bug sutil — o golpe dava i-frames ao herói e o bloco de gelo não "pegava". A ordem certa (prender, depois dano sem i-frames, pelo mesmo caminho da queimadura) saiu de um teste automático.
- **Uma condição com nome:** as portas pediam "o id de um chefe". O Núcleo pede as SETE memórias. Em vez de um caso especial no `Level`, a regra virou `Game.requirement_met(requires)`: um id de chefe, ou `"sete"`. O `Level` não sabe o que "sete" significa — só pergunta.
- **O chefe que não sai da frente:** o Cavaleiro não persegue você como os outros: calcula um `guard_point()` (o ponto entre você e ela) e volta para lá. A IA conta a história: proteção que virou prisão. E o elo de cura é uma pergunta geométrica (`Geometry2D.get_closest_point_to_segment`): você está no caminho da luz?
- **Pausa que sobra:** a escolha final acontece num diálogo, e diálogos PAUSAM o mundo. A cena final (andar até ela, a luz, o tremor) é feita de animações — que não andam com o jogo pausado. O teste automático passava porque chamava a ação sem o diálogo aberto; o passeio de fotos mostrou a tela congelada. Corrigido (sair do modal antes da cutscene) e o teste agora reproduz o caminho real: **teste o caminho que o jogador faz, não um atalho**.
- **Opções do aparelho × save do jogo:** são dois arquivos com responsabilidades diferentes. O save guarda a SUA história (chefes, itens, finais); `Settings` guarda o aparelho (volume, vibração, botões). Saves antigos que guardavam a vibração são lidos uma vez (migração) e a opção passa a morar no aparelho.
- **Volume por barramento:** os efeitos e o ambiente tocam em barramentos de áudio próprios (`Efeitos`, `Ambiente`), criados por código. O menu só muda o volume do barramento — nenhum dos 60 sons precisou mudar.
- **Dica na hora certa:** em vez de um texto de tutorial antes de jogar, `TutorialHints` observa sinais que já existiam (`hurt`, `interact_target_changed`, `memories_changed`) e mostra cada dica uma vez. Código novo que só escuta o que o jogo já anuncia — o herói não sabe que o tutorial existe.
- **Segredo não mora no código:** a chave de publicação e a senha dela nunca entram no projeto. Os scripts recusam uma chave dentro da pasta, pedem a senha na hora e a apagam do ambiente no fim; e um **teste-guarda** (`test_release_secrets_stay_out`) falha se alguém deixar uma chave ou senha no projeto. Um outro teste confere que a versão é a mesma no `project.godot` e nos dois presets — o tipo de erro bobo que só aparece na hora de enviar para a loja.
- **Presença por regra, não por código espalhado:** o Guarda aparece na Cidade, depois no Teatro, depois vira um posto vazio — e nada disso tem `if` no meio do `Level`. O NPC declara as regras no próprio mapa de entidades (`if_flag`, `unless_flag`, `instead`) e o `Level` só as aplica. Trocar a história de lugar é mudar dados, não lógica.
- **Aliado sem reescrever o combate:** o golpe do Guarda é um `HitInfo` entregue à hurtbox do inimigo — o inimigo não sabe se quem bateu foi você. E a hurtbox dele fica na mesma camada da sua, então as armadilhas e golpes de área o acertam sem nenhum código novo nos inimigos.
- **Ligadura de fonte:** a Pixelify Sans juntava "fi" num glifo próprio que,
  em 7 px, parecia um "Ã" ("A AnÃtriã"). A importação das fontes desliga a
  ligadura `liga` (`opentype_features` no `.import`).

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
| Agarrão: invencibilidade e empurrão ao escapar | grupo "Agarrão (preso)" no Inspector do `Player` |
| Boca de Raiz, Inchado, Colhedor, Larva de Seiva | Inspector de `scenes/enemies/boca_de_raiz.tscn`, `inchado.tscn`, `colhedor.tscn`, `larva_seiva.tscn` (toques para escapar, memórias por segundo, raio da explosão, quanto a larva rouba) |
| Banqueteiro (servir, comer, cura) e Ninhada (larvas por pedaço de vida, engolir) | Inspector de `scenes/bosses/banqueteiro.tscn` e `ninhada.tscn` |
| Mabel: frutos, agarrão, raízes (cura por raiz), lacaios, crescimento, ventre | Inspector de `scenes/bosses/mabel.tscn` (grupos "Fase 1", "Agarrão", "Fase 2") |
| Onde o raio corre (as placas) | `=` nos mapas do tema "forjas" (`levels/forjas.txt`, `arena_durgan.txt`); aviso/dano em cada `PlateCharge.spawn(...)` |
| Autômato, Torreta, Minerador, Imitador | Inspector de `scenes/enemies/automato_bronze.tscn`, `torreta_faisca.tscn`, `minerador_oco.tscn`, `imitador.tscn` (blindagem, alcance da trilha, combo, atraso da cópia) |
| Protótipo e Guardião da Âncora (carcaça × núcleo, leque, pilão) | Inspector de `scenes/bosses/prototipo.tscn` e `guardiao_ancora.tscn` |
| Durgan: torretas, autômatos, campo elétrico; esquiva, guarda, bebidas da fase 2 | Inspector de `scenes/bosses/durgan.tscn` (grupos "Fase 1", "Fase 2"); golpes copiados em `data/attacks/durgan_copia_*.tres` |

## Testes automáticos

```bash
godot --headless --fixed-fps 60 --path . res://tests/test_runner.tscn
```

142 grupos de teste cobrem: regras de estamina/Exaustão, a linha do tempo do
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
migração do v1, o Novo jogo abrindo o prólogo, os inimigos da Cidade (o cão morde e recua; o atirador mira, trava a linha e atira; a bala para na parede e o dash a atravessa; o civil só reage quando provocado), os mini-chefes (o Sargento apita a cada 25% e o pelotão cai junto com ele; o mini-chefe desiste se você foge; a Couraça só sente golpe pelas costas), o inventário e o save v3 (com migração do v2: quem já venceu chefes recebe o que eles deixam), a forja (custo, +24% no golpe, teto antes e depois de Durgan), o Orbe (fragmento vira frasco), itens do chão que não voltam e drops, o escudo (frente × costas × indefensável, quebra de guarda, virar sozinho para a bala) e o menu de inventário, o Bosque (a Barra de Sonolência sobe e desce, dormir e acordar, o dash na nuvem; o barulho de cada ação; o sonâmbulo que vai até o som e volta a dormir; a flor que incha e solta; o cervo que trava a mira e fica tonto na parede; a fada que cura; passar pelo Vigia em silêncio ou acordá-lo; a Mãe dos Esporos e o cipó pesado em quem dorme; a porta do Bosque que abre depois do Aldir), Nyssa (a luta começa ao entrar; sono por ficar parado; bolhas; o anel quando você cola nela; dano enorme não pula o Pesadelo; o chão some e volta; ecos só de chefes vencidos; vitória, lembrança e a cama de flores; outra fala para quem passou pelo Vigia em silêncio; os espinhos que abrem depois da Mãe; a Fada que fala da irmã) e os ecos de cada chefe, as Raízes da Fome (o agarrão: toques para escapar, memórias por segundo, dash que evita, agarrador que some, diálogo que solta; a Boca de Raiz que sobe, agarra e fica exposta; o Inchado que estoura no herói e nos outros inimigos; a foice que alcança de longe e gira; a larva que rouba, foge e devolve ao morrer; o Banqueteiro que serve, come e é interrompido; a Ninhada que se divide e engole; as portas oeste do Teatro e dos fundos da cozinha), Mabel (frutos, engolir e engasgar, fase 2 sem pular, raízes que curam e cospem lacaios, comer e crescer, ventre de frente, raízes cortadas param a cura, vitória e a mesa posta), as Forjas Ocas (placas que avisam e dão choque; o bronze que só sente o golpe forte; a torreta que acende a trilha e quem sai dela escapa; as três picaretadas; o Imitador que copia golpe, dash, escudo e frasco; o Protótipo com o seu corte; o Guardião de carcaça e núcleo; a trilha do Bosque, a porta da Forja e o Ferreiro depois de Durgan), Durgan (conta as suas ações; torreta, autômato e campo elétrico; martelada que acende o anel; o Reflexo sem pular; peso das escolhas; esquiva de quem abusa do dash; escudo que apara e revida; vitória e a chave-martelo), a Montanha Carbonizada (o fogo no chão que queima sem cambalear e que o dash atravessa; a bola de fogo que incendeia onde para; a rajada do Atirador e a coronhada; a investida do Bestial que deixa tonto na parede; o Alado intocável no ar e a janela no chão; a Brasa que estoura ou é apagada a tempo; o escudo do Capitão de frente e de costas, a troca e o lança-chamas; o pisoteio e os buracos da Matriarca; a ponte levadiça depois de Durgan e o Vendedor que lembra do Capitão e da Rachel), Rachel (dorme e acorda; o fogo que para na pedra; o hálito que queima; o rugido que derruba os pilares; a borda que desaba a cada quarto de vida; a cauda em quem fica atrás; vitória e a Lembrança), o Domínio Congelado (o gelo que faz deslizar; o estilhaço que deixa lento; o bloco de gelo que se quebra com toques, derrete sozinho e não pega quem está de dash; a geada que prende só quem ficou dentro; o Bibliotecário que mira e foge; a Estátua que só anda quando você está de costas; o Ácaro que gruda, bebe estamina e cai com o dash; a bolha do Aprendiz que só o golpe forte parte; a vitrine da Curadora e o bloco quebrado a tempo; o pilão, o gelo e os livros do Golem, o livro que fica e a porta que abre; o túnel da Montanha depois de Rachel e o Estudioso livre a cada chefe), Cassian (geada, pilares que derretem, o piscar para longe, o Colecionador sem pular, metade da arena congelada, estátuas da coleção, o roubo de estamina que demora a voltar, vitória e a Lembrança), o Núcleo (seis memórias não bastam, sete abrem a escada de luz; o jardim sem inimigos e as sete estátuas; o Cavaleiro que sabe quem protege e fica entre vocês, a guarda depois de três golpes, a gravidade que puxa, a Promessa sem pular, as pedras, o elo que cura e que você corta ficando no caminho, a vitória em que ele fica ajoelhado; a escolha com três opções; o final que não congela com o diálogo aberto, o save que lembra os finais vistos e as duas telas finais até os créditos), as Opções (barramentos de áudio, mudo no zero, botões de toque que crescem, a pausa que abre as opções e volta), as dicas (uma vez cada, na hora certa, desligáveis), a publicação (nenhuma chave nem senha de publicação dentro do projeto; versão igual nos três lugares), o Guarda Sem Posto (encontro na Cidade, um fragmento por ilha, o aliado que corta e cai, nenhum aliado no Teatro nem nas arenas, o sacrifício sem congelar a cena, o posto vazio que fica, Helena que reconhece o anel e hesita), as áreas novas montadas, **fechadas e com tudo alcançável a pé** (um teste de caminho da chegada até cada chefe, item e porta), a porta que abre na hora em que o mini-chefe cai, os mapas (inclusive que são
**fechados**) e os controles de toque. E os testes de **regressão** de cada bug já corrigido: save com cópia de
segurança e save corrompido, minimizar no título, pausa soltando os toques,
tecla do diálogo ignorada, cura guardada no fim do golpe, porta mantendo
vida/frascos, morte registrada na hora, botão Voltar, fichas de ataque dos
soldados, postura/salto/pose da Helena, o Fader, a câmera lenta empilhada
e a pausa bloqueada durante as cenas curtas. Os testes usam um save
próprio (`user://teste_automatico_save.json`) — o seu nunca é tocado.

Há também `tests/soak_test.tscn` (um robô joga ~8 minutos de jogo — Prólogo
pelo caminho da violência até a queda, Cidade (de escudo), os dois mini-chefes, a forja e o Orbe, Helena, Aldir e o
Bosque com os mini-chefes dele e a Nyssa, as Raízes com o Banqueteiro, a Ninhada e a Mabel (o robô se deixa agarrar e escapa tocando) e as Forjas com o Protótipo, o Guardião e o Durgan, a Montanha com o Capitão, a Matriarca e a Rachel, o Domínio com a Curadora, o Golem e o Cassian, e o Cavaleiro no Coração — procurando erros; aceita durações: `-- 90 150 150 120 90 90 90 90 90 180`, 0 pula) e
`tests/screenshot_tour.tscn` (tira as fotos desta página; `-- --only=bosque`, `--only=raizes`, `--only=forjas`, `--only=montanha`, `--only=dominio` ou `--only=nucleo` tira só as daquela área).
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

## Próximos passos

O que foi combinado para depois (vídeo de abertura, navegador, coop local e online, invasões) está anotado em [`docs/ROADMAP.md`](docs/ROADMAP.md).

### Sugestões da Bíblia

1. **A história inteira está jogável, do Prólogo aos dois finais.** Falta balancear dano, vida e memórias jogando no celular de verdade (os números estão nos `.tres` de `data/` e em `tools/gen_resources.py`) e, se quiser, músicas para as áreas e as lutas.
2. **Publicar:** criar a sua chave (`tools/criar_chave_release`), gerar o AAB (`build_release ... -Aab`), confirmar os direitos da arte do título e seguir o checklist de `docs/loja/LEIA-ME.md` — começando por um **teste interno** com amigos.
3. Fazer o mundo lembrar da escolha: falas novas da Fada/Orbe para quem feriu as crianças; levar a memória do Aldir ao Teatro (fala nova da Fada/Orbe) e a ordem dos Pecados da Bíblia (Helena por último).
4. Arte final e animações (as cenas já separam corpo, arma e peças de armadura).

## Créditos e licenças

- Código e arte provisória: gerados para este projeto.
- Fontes (SIL Open Font License, textos em `assets/fonts/`): Cinzel, Pixelify Sans, Tiny5.
- Imagens de referência em `docs/referencias/`: arte conceitual do autor (Bíblia do Jogo).

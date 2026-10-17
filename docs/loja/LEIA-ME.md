# Kit da loja (Google Play)

Tudo o que a Play Console pede, pronto para copiar. Revise os textos com calma:
são a primeira coisa que um jogador lê.

## Arquivos

| Arquivo | Para quê | Exigência da Play |
|---|---|---|
| `icone_512.png` | Ícone da página da loja | 512×512, PNG 32 bits |
| `destaque_1024x500.png` | Imagem de destaque (topo da página) | 1024×500, sem transparência |
| `capturas/*.png` | Capturas de tela (celular) | 2 a 8 imagens, 16:9, mín. 320 px |

Os três são gerados: o ícone por `python3 tools/art/gen_art.py`, o destaque e as
capturas pelo passeio de fotos (`tests/screenshot_tour.tscn -- --only=loja`).

> ⚠️ **Direitos de imagem:** o fundo do título e do destaque é o **mapa das ilhas da
> Bíblia do Jogo** (arte conceitual). Antes de publicar, confirme que você tem o
> direito de usar essa imagem comercialmente (se foi feita por você ou por uma
> ferramenta cujos termos permitem uso comercial). Se não tiver certeza, troque
> `assets/ui/title_map.jpg` por uma arte sua e gere o destaque de novo.

## Textos

**Nome do app** (máx. 30): `Alexandria: A Ilha Que Não Cai`

**Descrição curta** (máx. 80):
`Um soulslike sombrio numa ilha que flutua porque ninguém consegue terminar.`

**Descrição completa** (máx. 4000):

```
Você acorda numa cápsula, sem memória. Lá fora, uma ilha flutua no céu — e nada nela consegue terminar o próprio ciclo.

ALEXANDRIA é um soulslike psicológico em pixel art, feito para o celular. Sete guardiões, os Sete Pecados, carregam as memórias que faltam. Cada um acredita carregar uma culpa imperdoável. Nenhum deles morreu. Nenhum deles seguiu.

• Combate de leitura: cada golpe inimigo avisa antes. Esquive, apare com o escudo, gaste a estamina com cuidado.
• Morrer custa: você perde memórias, a visão escurece pelas bordas e os seus cabelos clareiam a cada volta.
• Sete ilhas, sete chefes: uma cidade em chamas, um bosque que faz dormir, raízes com fome, forjas de bronze, um vulcão de dragões, uma biblioteca congelada — e o teatro onde tudo começou.
• Chefes que contam histórias: um engenheiro que copia os seus golpes, uma dragoa cuja arena desaba aos poucos, um arquimago que congela o chão e rouba o seu fôlego.
• Escolhas sem aviso: o jogo lembra do que você fez, mesmo quando não diz nada.
• Dois finais. O jogo não diz qual é o certo.

Controles de toque pensados para o celular (joystick à esquerda, ações à direita), com botões de tamanho ajustável. Também funciona com teclado e controle.

Sem anúncios. Sem compras dentro do app. Sem coleta de dados.

Quanto tempo algo pode ser protegido antes de deixar de ser salvo?
```

**Categoria:** Jogos → Ação (ou RPG).
**Tags sugeridas:** soulslike, pixel art, ação, RPG, sombrio, história.

## Classificação indicativa (questionário da Play)

Responda com honestidade; pelo conteúdo atual, o esperado é **12 anos** (ClassInd/IARC):

- **Violência:** sim — fantasia, contra criaturas e humanos estilizados em pixel art; sem sangue realista (há "seiva"/carne estilizada nas Raízes).
- **Medo:** sim — temas sombrios (morte, perda de memória), sem sustos repentinos.
- **Crianças em perigo:** o Prólogo tem crianças-cobaia que atacam e podem ser feridas pelo jogador (sem sangue; elas não morrem). Declare isso no questionário — é a parte mais sensível do jogo.
- Linguagem imprópria, sexo, drogas, apostas: não.

## Privacidade

O jogo **não coleta dados**: o save e as opções ficam só no aparelho, não há
internet, anúncios nem análise. Mesmo assim a Play pede um link de **Política de
Privacidade** — use `politica_de_privacidade.md` (publique numa página simples, por
exemplo um GitHub Pages do seu repositório) e preencha a seção **Segurança dos
dados** como "nenhum dado coletado ou compartilhado".

## Checklist antes de enviar

- [ ] Chave de publicação criada FORA do projeto (`tools/criar_chave_release`) e com 2 cópias de segurança.
- [ ] `build_release` com `-Aab` / `--aab` gerou `build/alexandria.aab`.
- [ ] Testado no celular o APK de publicação (`build/alexandria-release.apk`).
- [ ] Versão nova em `project.godot` e nos dois presets (o teste `test_version_consistency` confere).
- [ ] Direitos da arte do título confirmados (aviso acima).
- [ ] Política de privacidade publicada e o link colado na Play Console.
- [ ] Teste interno (Play Console → Testes internos) com 2 ou 3 amigos antes da produção.

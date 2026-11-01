# Ferramentas de história (v0.31 — Etapa 1 do Pacote de Expansão)

O que dá para fazer **só editando dados** (`data/dialogos.json` e as listas do
nó da fase), sem programar.

## 1. A linguagem de condições

Vale em portas, NPCs, falas, opções e zonas. Fica num lugar só: `Game.requirement_met()`.

| Escreva | Quer dizer |
|---|---|
| `""` | sempre |
| `aldir` ou `chefe:aldir` | o chefe (ou mini-chefe) foi vencido |
| `sete` | as sete memórias |
| `memorias:3` | pelo menos 3 memórias de chefe |
| `flag:atalho_galho` | a flag está ligada |
| `item:flor_de_pedra` | o herói tem o item |
| `estado:bau_cidade_1` | o objeto do mundo já foi acionado |
| `!flag:x` | o contrário (vale para qualquer uma) |
| `a+b` | todas (E) |
| `a\|b` | qualquer uma (OU) |

## 2. Falas (`data/dialogos.json`)

```json
"ferreiro": {
  "nome": "Ferreiro Anão",
  "falas": ["Trouxe aço, ratinho?"],
  "variantes": [ {"quando": "chefe:durgan", "usar": "ferreiro_irmao"} ],
  "aparece_quando": "flag:ferreiro_chegou",
  "some_quando": "flag:ferreiro_foi_embora",
  "opcoes": [
    {"texto": "Melhorar a arma", "acao": "melhorar_arma"},
    {"texto": "Conte mais", "acao": "falar:ferreiro_conversa_2", "quando": "chefe:durgan"},
    {"tipo": "nome", "personagem": "ferreiro", "sim": "falar:ferreiro_nome_sim", "nao": "falar:ferreiro_nome_nao"}
  ]
}
```

- **O jogo é dublado: nenhuma fala usa o nome do jogador.** Cada personagem usa apelidos fixos (Governanta: "cobaia"/"você"; Helena: "aberração"/"rato de laboratório"; Amaro: "ratinho"/"Cobaia 22"; Tião e Bastião: "ô do pijama branco"; Galeno: "amigo"/"pequeno"; Heitor: "parceiro"; Damião: "freguês"; Cícero: "cabra"; Dalva: "criança"; Benedita: "filho"; Lúcia: "você").
- **`{nome}`** só vale em texto ESCRITO: botões de opção, terminal do laboratório, menus e a barra do Experimento Anterior. Um teste recusa `{nome}` dentro de `falas`.
- **`variantes`**: a primeira cuja condição valer troca a fala.
- **`aparece_quando` / `some_quando`**: decidem se o NPC está no mapa.
- **`quando`** numa opção esconde o botão quando não vale.
- **Opção `"tipo": "nome"`** mostra dois botões: "Não lembro" e o nome do herói. Escolher o nome liga `nome_dito_<personagem>`, que só muda a REAÇÃO do personagem (outra fala, via `variantes`); ele nunca diz o nome.

## 3. Ações de opção (o `"acao"`)

As ações antigas continuam valendo: `loja`, `subir_nivel`, `desafiar_helena`... As novas:

| Ação | O que faz |
|---|---|
| `flag:nome` | liga uma flag de história |
| `falar:id` | emenda outra fala (conversa em várias partes) |
| `lute_comigo:lucia` | o aliado entra na próxima luta de chefe |
| `nome:lucia:sim` | marca que você disse o seu nome a ele |
| `dar:caixa_musica_bronze` | entrega um item (sai da bolsa e liga `dado_<item>`) |
| `a;b` | várias ações em sequência (ex.: `flag:x;falar:y`) |

## 4. Aliados (base `Ally`)

- Todo companheiro herda de `scripts/allies/ally.gd` e é registrado em `Ally.REGISTRY`.
- **Seguir você** pelas ilhas: flag `<id>_acompanha`.
- **Entrar na arena de um Pecado**: ação `lute_comigo:<id>`, que vale para uma luta.
- **Nível**: `Game.ally_level(id)` sobe +1 a cada chefe ou mini-chefe vencido com ele de pé, e cada nível soma +15% de vida e dano. Cair não tira nível.

## 5. No mapa (listas do nó da fase)

São quatro listas: `exits`, `zones`, `objects` e `traps`. Os exemplos estão em `levels/LEGENDA.md`.

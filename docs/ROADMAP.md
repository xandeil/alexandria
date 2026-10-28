# Roadmap — o que vem depois

Anotado em 28/10/2026 (depois da v0.28). Nada aqui está feito ainda: é a
ordem combinada e as regras que o Alexandre definiu, para não se perderem.

## Ordem combinada

1. ~~**Vídeo de abertura**~~ — FEITO na v0.29 (versão provisória; o Alexandre vai refazer melhor e é só trocar `assets/cutscenes/abertura.ogv`). Era: o Alexandre está editando os vídeos curtos (feitos
   em outro chat, pixel art no estilo do jogo). Quando chegarem: converter para
   Ogg Theora (`.ogv`, o formato que o Godot toca), legendas da narração,
   transição para a cena da cápsula, tocar só no "Novo jogo" (toque pula).
   Roteiro dos planos: o mundo de antes → a criança de cabelo branco na
   cápsula → o preço (corredor, porta arranhada, cápsula quebrada) → os que
   ficaram → o Cavaleiro ativa as Âncoras → a ilha sobe → a ilha hoje → a
   cápsula verde (corta para o jogo). No NG+ a última frase muda.
2. **Lançamento** e depois a **versão para navegador** (export Web do Godot +
   itch.io). Junto com ela, estudar a parte de servidor.
3. **Coop** (abaixo).
4. **Invasões** (abaixo) — por último.

## Coop — regras definidas

### Onde começa
- Falando com a **Fada**: abaixo de "Subir de nível" aparece
  **"Jogar com amigo"**, que abre duas opções: **Offline** e **Online**.

### Quem entra
- O amigo entra com **um dos saves dele** (o personagem, o nível, as armas e
  armaduras daquele save) e joga **no mundo de quem chamou** (o anfitrião).

### Offline — tela dividida
- **Só no computador** (no celular não dá: tela pequena e um toque só).
- Dois jogadores na mesma máquina, cada um com seu controle (ou um no teclado).
- Escolhe-se o save do segundo jogador e ele aparece ao lado do anfitrião.

### Online — servidor e chave
- Ao escolher Online aparece o **servidor** e uma **chave**: só quem usa a
  mesma chave se encontra (amigos combinam a chave entre si).
- Quem quer ser chamado precisa estar **descansando numa Câmara** e ligar um
  botão do tipo **"Aceitar chamados"** (como deixar o sinal de invocação no
  Dark Souls).
- O anfitrião é o dono do mundo (o estado "oficial"); o convidado manda só os
  comandos do herói dele.

### O que o código vai precisar (preparação)
Hoje o jogo assume UM herói em vários lugares. Antes do coop:
- `Enemy.find_target()` pega "o" jogador → escolher o mais perto / quem bateu.
- `GameCamera` segue um alvo → enquadrar dois (ou tela dividida com duas
  câmeras/SubViewports).
- `HUD.bind_player()` é de um herói → uma barra de vida/estamina por jogador.
- Entrada: hoje as ações (`attack`, `dash`...) são globais → separar por
  dispositivo (controle 1, controle 2, teclado).
- `Game` guarda UM progresso → carregar o save do convidado ao lado do do
  anfitrião (sem misturar: o que o convidado ganha volta para o save dele).
- Regras de morte no coop (o convidado morto volta para o mundo dele?).
- Online: Godot High-Level Multiplayer (ENet no PC/celular, WebRTC no
  navegador), servidor de "apresentação" (lobby por chave), anfitrião
  autoritativo, cuidado com o lag (esquiva e parry dependem de milissegundos).

## Invasões — para depois do coop
- Um jogador entra no mundo de outro como inimigo (como no Dark Souls).
- Regras a definir: quando pode ser invadido, o que o invasor ganha, como
  recusar/evitar (offline nunca é invadido), equilíbrio de nível.

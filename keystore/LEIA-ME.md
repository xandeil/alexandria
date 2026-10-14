# Chave de depuração do projeto

`debug.keystore` assina os **APKs de teste** (`--export-debug`). Ela mora
dentro do projeto de propósito: assim **todo** APK de depuração — o que eu te
mando e o que você compila — sai com a **mesma assinatura**, e um instala por
cima do outro (`adb install -r` ou tocando no arquivo) **sem desinstalar e sem
perder o save**.

| Campo | Valor |
|---|---|
| Arquivo | `keystore/debug.keystore` (PKCS12) |
| Alias | `androiddebugkey` |
| Senha | `android` |
| SHA-256 do certificado | `43:C2:B4:74:A8:45:91:62:7D:A1:81:C2:1B:68:C7:59:05:3D:1D:06:95:A6:88:ED:43:51:8A:ED:62:7C:8C:73` |

Os scripts `build_apk.ps1` e `build_apk.sh` já usam esta chave (pelas variáveis
`GODOT_ANDROID_KEYSTORE_DEBUG_*`). Exportando pelo **editor** do Godot, aponte
para ela em *Editor → Configurações do Editor → Exportar → Android → Debug
Keystore* (usuário `androiddebugkey`, senha `android`).

## Por que isso é seguro aqui (e quando NÃO seria)

- Uma chave de **depuração** é pública por natureza: a senha padrão é
  "android" e a Play Store recusa APKs assinados com ela.
- A chave de **publicação** (release) é outra história: quem tiver o arquivo
  e a senha pode publicar atualizações "suas". Essa **nunca** entra no projeto
  nem no Git — guarde-a fora da pasta e com backup (veja o BUILD.md).

A pasta tem um `.gdignore`: o Godot não importa nem exporta nada daqui.

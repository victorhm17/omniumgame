# MODO BOT - ARQUIVOS PARA OMNIUMGAME

## 📁 INSTRUÇÕES DE EXTRAÇÃO

**EXTRAIR DIRETAMENTE EM:** `C:\Google Drive\OmniumGame\app\v07\`

**IMPORTANTE:** Extrair o conteúdo do zip DENTRO da pasta v07, não criar uma subpasta.

## 📋 ESTRUTURA DOS ARQUIVOS

### 🆕 ARQUIVOS NOVOS (serão criados):
```
lib/core/models/bot_player.dart
lib/features/trivia_game/screens/game_mode_selection_screen.dart
lib/features/trivia_game/screens/bot_game_screen.dart
lib/features/trivia_game/cubit/bot_game_cubit.dart
lib/features/trivia_game/cubit/bot_game_state.dart
```

### ✏️ ARQUIVOS MODIFICADOS (substituir os existentes):
```
lib/main.dart
pubspec.yaml
```

### 📚 DOCUMENTAÇÃO:
```
IMPLEMENTACAO_BOT.md
todo.md
INSTRUCOES_INSTALACAO.md
README_MODO_BOT.md (este arquivo)
```

## 🔧 APÓS EXTRAIR:

1. **Verificar se os arquivos estão nos lugares corretos**
2. **Executar:**
   ```bash
   flutter clean
   flutter pub get
   ```

## ✅ RESULTADO ESPERADO

Após extrair, você deve ter:
- Os 5 arquivos novos nas pastas corretas
- O main.dart e pubspec.yaml substituídos
- O modo bot funcionando após flutter clean + pub get

## ⚠️ SE ALGO DER ERRADO

Se a estrutura não ficar correta:
1. Delete os arquivos extraídos
2. Extraia novamente certificando-se de extrair DENTRO da pasta v07
3. Verifique se os arquivos estão nas pastas corretas conforme listado acima


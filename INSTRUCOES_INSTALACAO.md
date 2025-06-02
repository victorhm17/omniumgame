# INSTRUÇÕES DE INSTALAÇÃO - OmniumGame com Modo Bot

## 📁 ONDE EXTRAIR O ARQUIVO

**EXTRAIR EM:** `C:\Google Drive\OmniumGame\app\`

**RESULTADO FINAL:** `C:\Google Drive\OmniumGame\app\v07\` (substituindo a pasta v07 existente)

## 🔧 PASSOS PARA INSTALAÇÃO

### 1. **BACKUP (Recomendado)**
```
Renomeie a pasta atual v07 para v07_backup antes de extrair
```

### 2. **EXTRAIR ARQUIVO**
```
Extrair omniumgame_final.zip em: C:\Google Drive\OmniumGame\app\
Renomear a pasta "omniumgame" para "v07"
```

### 3. **LIMPEZA ANTES DO PUB GET**

**SIM, você precisa fazer limpeza manual:**

```bash
# Navegue até a pasta do projeto
cd "C:\Google Drive\OmniumGame\app\v07"

# Execute flutter clean (OBRIGATÓRIO)
flutter clean

# OU delete manualmente estas pastas se existirem:
# - build/
# - .dart_tool/
# - .flutter-plugins
# - .flutter-plugins-dependencies
```

### 4. **INSTALAR DEPENDÊNCIAS**
```bash
# Após o clean, execute:
flutter pub get
```

### 5. **VERIFICAR INSTALAÇÃO**
```bash
# Teste se está funcionando:
flutter analyze
```

## ⚠️ IMPORTANTE

- **SEMPRE execute `flutter clean` antes do `pub get`** quando substituir projeto
- **NÃO pule a etapa de limpeza** - pode causar conflitos de dependências
- **A pasta build/ será recriada automaticamente** após o primeiro build

## 🎯 FUNCIONALIDADES ADICIONADAS

Após a instalação, você terá acesso ao **Modo Bot** com:
- Seleção de dificuldade (Fácil, Médio, Difícil)
- Sistema de pontuação aprimorado
- Interface responsiva para jogos contra bot
- Integração completa com o sistema existente

## 🚀 COMO TESTAR

1. Execute o app normalmente
2. Após login, você verá a nova tela de "Seleção de Modo de Jogo"
3. Escolha "Jogar contra Bot"
4. Selecione a dificuldade desejada
5. Divirta-se jogando contra a IA!

## 📞 SUPORTE

Se houver algum problema na instalação, verifique:
- Se executou `flutter clean` antes do `pub get`
- Se todas as dependências foram instaladas corretamente
- Se o Firebase está configurado corretamente


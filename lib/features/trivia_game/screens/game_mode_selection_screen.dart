import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:omnium_game/core/models/bot_player.dart";

class GameModeSelectionScreen extends StatefulWidget {
  const GameModeSelectionScreen({super.key});

  @override
  State<GameModeSelectionScreen> createState() => _GameModeSelectionScreenState();
}

class _GameModeSelectionScreenState extends State<GameModeSelectionScreen> {
  BotDifficulty _selectedDifficulty = BotDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecionar Modo de Jogo"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Como você quer jogar?",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Modo Bot
                _buildGameModeCard(
                  title: "Jogar contra Bot",
                  subtitle: "Teste suas habilidades contra a inteligência artificial",
                  icon: Icons.smart_toy,
                  color: Colors.purple,
                  onTap: () => _showBotDifficultyDialog(),
                ),
                
                const SizedBox(height: 20),
                
                // Modo Local
                _buildGameModeCard(
                  title: "Modo Local",
                  subtitle: "Jogue com um amigo no mesmo dispositivo",
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () => _startLocalGame(),
                ),
                
                const SizedBox(height: 20),
                
                // Modo Online (existente)
                _buildGameModeCard(
                  title: "Jogar Online",
                  subtitle: "Encontre oponentes aleatórios ou convide amigos",
                  icon: Icons.public,
                  color: Colors.green,
                  onTap: () => context.go("/matchmaking/options"),
                ),
                
                const Spacer(),
                
                // Informações sobre o modo bot selecionado
                if (_selectedDifficulty != null) _buildBotInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotInfoCard() {
    final botPlayer = _getBotPlayerForDifficulty(_selectedDifficulty);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Configuração do Bot",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBotStat("Nome", botPlayer.username),
            _buildBotStat("Taxa de Acerto", "${(botPlayer.accuracyRate * 100).toInt()}%"),
            _buildBotStat("Tempo de Resposta", "${botPlayer.minResponseTimeMs ~/ 1000}-${botPlayer.maxResponseTimeMs ~/ 1000}s"),
          ],
        ),
      ),
    );
  }

  Widget _buildBotStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showBotDifficultyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Escolha a Dificuldade do Bot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDifficultyOption(BotDifficulty.easy, "Fácil", "60% de acerto, resposta lenta"),
              _buildDifficultyOption(BotDifficulty.medium, "Médio", "75% de acerto, resposta moderada"),
              _buildDifficultyOption(BotDifficulty.hard, "Difícil", "90% de acerto, resposta rápida"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startBotGame();
              },
              child: const Text("Iniciar Jogo"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDifficultyOption(BotDifficulty difficulty, String title, String description) {
    return RadioListTile<BotDifficulty>(
      title: Text(title),
      subtitle: Text(description),
      value: difficulty,
      groupValue: _selectedDifficulty,
      onChanged: (BotDifficulty? value) {
        setState(() {
          _selectedDifficulty = value!;
        });
      },
    );
  }

  BotPlayer _getBotPlayerForDifficulty(BotDifficulty difficulty) {
    switch (difficulty) {
      case BotDifficulty.easy:
        return BotPlayer.easy();
      case BotDifficulty.medium:
        return BotPlayer.medium();
      case BotDifficulty.hard:
        return BotPlayer.hard();
    }
  }

  void _startBotGame() {
    // TODO: Implementar navegação para jogo contra bot
    // Passar a dificuldade selecionada como parâmetro
    final botPlayer = _getBotPlayerForDifficulty(_selectedDifficulty);
    
    // Por enquanto, vamos para a tela de matchmaking com um parâmetro especial
    context.go("/game/bot?difficulty=${_selectedDifficulty.name}");
  }

  void _startLocalGame() {
    // TODO: Implementar navegação para jogo local
    context.go("/game/local");
  }
}


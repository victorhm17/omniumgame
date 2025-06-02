import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:omnium_game/core/models/bot_player.dart";
import "package:omnium_game/features/trivia_game/cubit/bot_game_cubit.dart";
import "package:omnium_game/features/trivia_game/repositories/trivia_game_repository.dart";

class BotGameScreen extends StatelessWidget {
  final BotDifficulty difficulty;

  const BotGameScreen({
    super.key,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final botPlayer = _getBotPlayerForDifficulty(difficulty);
    
    return BlocProvider(
      create: (context) => BotGameCubit(
        triviaGameRepository: RepositoryProvider.of<TriviaGameRepository>(context),
        botPlayer: botPlayer,
      )..startGame(),
      child: const BotGameView(),
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
}

class BotGameView extends StatelessWidget {
  const BotGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Duelo contra Bot"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: BlocConsumer<BotGameCubit, BotGameState>(
        listener: (context, state) {
          if (state is BotGameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BotGameLoading) {
            return const _LoadingView();
          } else if (state is BotGameQuestionLoaded) {
            return _QuestionView(state: state);
          } else if (state is BotGameQuestionResult) {
            return _ResultView(state: state);
          } else if (state is BotGameFinished) {
            return _FinishedView(state: state);
          } else if (state is BotGameError) {
            return _ErrorView(message: state.message);
          }
          
          return const _LoadingView();
        },
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Sair do Jogo"),
          content: const Text("Tem certeza que deseja sair? O progresso será perdido."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go("/game-mode-selection");
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Sair"),
            ),
          ],
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Preparando o duelo...",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionView extends StatefulWidget {
  final BotGameQuestionLoaded state;

  const _QuestionView({required this.state});

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> {
  int? _selectedOption;
  bool _hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header com scores e progresso
              _buildHeader(),
              const SizedBox(height: 20),
              
              // Pergunta
              _buildQuestionCard(),
              const SizedBox(height: 30),
              
              // Opções de resposta
              Expanded(
                child: _buildOptionsGrid(),
              ),
              
              // Status do bot
              _buildBotStatus(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pergunta ${widget.state.questionNumber}/${widget.state.totalQuestions}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.state.question.category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreItem("Você", widget.state.playerScore, Colors.blue),
                _buildScoreItem(widget.state.botPlayer.username, widget.state.botScore, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.quiz,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              widget.state.question.text,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.state.question.options.length,
      itemBuilder: (context, index) {
        final option = widget.state.question.options[index];
        final isSelected = _selectedOption == index;
        final isDisabled = _hasAnswered || widget.state.playerHasAnswered;
        
        return Card(
          elevation: isSelected ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected 
                ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: isDisabled ? null : () => _selectOption(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
              ),
              child: Center(
                child: Text(
                  option.text,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotStatus() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.smart_toy,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.state.botHasAnswered 
                    ? "${widget.state.botPlayer.username} já respondeu!"
                    : "${widget.state.botPlayer.username} está pensando...",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (!widget.state.botHasAnswered)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectOption(int index) {
    if (_hasAnswered || widget.state.playerHasAnswered) return;
    
    setState(() {
      _selectedOption = index;
      _hasAnswered = true;
    });
    
    context.read<BotGameCubit>().submitPlayerAnswer(index);
  }
}

class _ResultView extends StatelessWidget {
  final BotGameQuestionResult state;

  const _ResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header com scores
              _buildScoreHeader(context),
              const SizedBox(height: 20),
              
              // Pergunta e resposta correta
              _buildQuestionResult(context),
              const SizedBox(height: 20),
              
              // Resultados dos jogadores
              Expanded(
                child: _buildPlayersResults(context),
              ),
              
              // Botão para próxima pergunta
              ElevatedButton(
                onPressed: () => context.read<BotGameCubit>().proceedToNextQuestion(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  state.questionNumber < state.totalQuestions 
                      ? "Próxima Pergunta"
                      : "Ver Resultado Final",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreHeader(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildScoreItem(context, "Você", state.playerScore, Colors.blue),
            _buildScoreItem(context, state.botPlayer.username, state.botScore, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionResult(BuildContext context) {
    final correctOptionIndex = state.question.options.indexWhere((option) => option.isCorrect);
    
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              state.question.text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Resposta correta: ${state.question.options[correctOptionIndex].text}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersResults(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildPlayerResult(
            context,
            "Você",
            state.playerSelectedOption,
            state.playerIsCorrect,
            state.playerResponseTime,
            Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildPlayerResult(
            context,
            state.botPlayer.username,
            state.botSelectedOption,
            state.botIsCorrect,
            state.botResponseTime,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerResult(
    BuildContext context,
    String playerName,
    int selectedOption,
    bool isCorrect,
    int responseTime,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  playerName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Resposta: ${state.question.options[selectedOption].text}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              "Tempo: ${(responseTime / 1000).toStringAsFixed(1)}s",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinishedView extends StatelessWidget {
  final BotGameFinished state;

  const _FinishedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final isVictory = state.result == "Vitória!";
    final isDraw = state.result == "Empate!";
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isVictory ? Colors.green : isDraw ? Colors.orange : Colors.red).withOpacity(0.1),
            Theme.of(context).colorScheme.background,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de resultado
              Icon(
                isVictory ? Icons.emoji_events : isDraw ? Icons.handshake : Icons.sentiment_dissatisfied,
                size: 80,
                color: isVictory ? Colors.amber : isDraw ? Colors.orange : Colors.grey,
              ),
              const SizedBox(height: 20),
              
              // Resultado
              Text(
                state.result,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isVictory ? Colors.green : isDraw ? Colors.orange : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Scores finais
              Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        "Resultado Final",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFinalScore("Você", state.playerScore, Colors.blue),
                          _buildFinalScore(state.botPlayer.username, state.botScore, Colors.purple),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${state.totalQuestions} perguntas respondidas",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Botões de ação
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go("/game/bot?difficulty=${state.botPlayer.difficulty.name}"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Jogar Novamente",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go("/game-mode-selection"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Escolher Outro Modo",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalScore(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              "Ops! Algo deu errado",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => context.go("/game-mode-selection"),
              child: const Text("Voltar ao Menu"),
            ),
          ],
        ),
      ),
    );
  }
}


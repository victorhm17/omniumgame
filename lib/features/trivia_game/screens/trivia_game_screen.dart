import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:omnium_game/features/trivia_game/cubit/trivia_game_cubit.dart";
import "package:omnium_game/core/models/question_model.dart";
import "package:omnium_game/core/models/match_model.dart"; // Adicionado import para MatchModel
import "package:omnium_game/features/matchmaking/repositories/matchmaking_repository.dart"; // Para o TriviaGameCubit
import "package:omnium_game/features/trivia_game/repositories/trivia_game_repository.dart"; // Para o TriviaGameCubit

class TriviaGameScreen extends StatelessWidget {
  final String matchId;
  const TriviaGameScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TriviaGameCubit(
        matchId: matchId,
        triviaGameRepository: RepositoryProvider.of<TriviaGameRepository>(context),
        matchmakingRepository: RepositoryProvider.of<MatchmakingRepository>(context),
      )..loadGame(),
      child: const TriviaGameView(),
    );
  }
}

class TriviaGameView extends StatefulWidget {
  const TriviaGameView({super.key});

  @override
  State<TriviaGameView> createState() => _TriviaGameViewState();
}

class _TriviaGameViewState extends State<TriviaGameView> {
  int? _selectedOptionIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OmniumGame - Trivia!"),
        centerTitle: true,
        // TODO: Adicionar placar ou informações da partida no AppBar
      ),
      body: BlocConsumer<TriviaGameCubit, TriviaGameState>(
        listener: (context, state) {
          if (state is TriviaGameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro no jogo: ${state.message}")),
            );
            // TODO: Considerar navegação para fora do jogo ou tela de erro
          } else if (state is TriviaGameFinished) {
            // Navegar para tela de resultados
            // GoRouter.of(context).replace("/game/${state.match.id}/results");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${state.message} Vencedor: ${state.match.winnerId ?? 'Empate'}")),
            );
          }
        },
        builder: (context, state) {
          if (state is TriviaGameLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TriviaGameQuestionLoaded) {
            return _buildQuestionUI(context, state.question, state.questionNumber, state.totalQuestions, state.match);
          }

          if (state is TriviaGameAnswerProcessing) {
            return _buildQuestionUI(context, state.question, 
                (context.read<TriviaGameCubit>().state as TriviaGameQuestionLoaded?)?.questionNumber ?? 0, 
                (context.read<TriviaGameCubit>().state as TriviaGameQuestionLoaded?)?.totalQuestions ?? 0, 
                state.match, 
                isProcessing: true, 
                processingOptionIndex: state.selectedOptionIndex);
          }

          if (state is TriviaGameAnswerResult) {
            return _buildQuestionUI(context, state.question, 
                (context.read<TriviaGameCubit>().state as TriviaGameQuestionLoaded?)?.questionNumber ?? (context.read<TriviaGameCubit>().state as TriviaGameAnswerResult).questionNumber, // Precisa buscar o número da pergunta de forma mais robusta
                (context.read<TriviaGameCubit>().state as TriviaGameQuestionLoaded?)?.totalQuestions ?? (context.read<TriviaGameCubit>().state as TriviaGameAnswerResult).totalQuestions,
                state.match, 
                showResult: true, 
                isCorrect: state.isCorrect, 
                correctOptionIndex: state.question.options.indexWhere((opt) => opt.isCorrect),
                selectedOptionIndexForResult: state.selectedOptionIndex);
          }
          
          if (state is TriviaGameFinished) {
             return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 20),
                    Text("Vencedor: ${state.match.winnerId ?? 'Empate'}", style: Theme.of(context).textTheme.titleLarge),
                    // TODO: Botão para ir para a tela de desafios
                  ],
                ),
              );
          }

          return const Center(child: Text("Aguardando início do jogo..."));
        },
      ),
    );
  }

  Widget _buildQuestionUI(BuildContext context, QuestionModel question, int qNum, int qTotal, MatchModel match, 
                          {bool isProcessing = false, int? processingOptionIndex, 
                           bool showResult = false, bool? isCorrect, int? correctOptionIndex, int? selectedOptionIndexForResult}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TODO: Mostrar placar (scores do match)
          Text(
            "Pergunta $qNum de $qTotal",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Image.network(question.imageUrl!, height: 150, fit: BoxFit.contain),
            ),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                question.text,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(question.options.length, (index) {
            Color? tileColor;
            Color? borderColor;
            Icon? trailingIcon;

            if (showResult) {
              if (question.options[index].isCorrect) {
                tileColor = Colors.green.withOpacity(0.3);
                borderColor = Colors.green;
                trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
              } else if (index == selectedOptionIndexForResult && !isCorrect!) {
                tileColor = Colors.red.withOpacity(0.3);
                borderColor = Colors.red;
                trailingIcon = const Icon(Icons.cancel, color: Colors.red);
              }
            } else if (isProcessing && index == processingOptionIndex) {
              // Poderia ter um indicador de loading na opção selecionada
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: borderColor ?? Colors.transparent, width: 2)
              ),
              color: tileColor,
              child: ListTile(
                title: Text(question.options[index].text, style: Theme.of(context).textTheme.titleMedium),
                selected: _selectedOptionIndex == index && !showResult,
                trailing: trailingIcon,
                onTap: isProcessing || showResult 
                    ? null 
                    : () {
                        setState(() {
                          _selectedOptionIndex = index;
                        });
                        // Não submeter imediatamente, esperar um botão de confirmação ou submeter direto
                        // context.read<TriviaGameCubit>().submitAnswer(index);
                      },
              ),
            );
          }),
          const SizedBox(height: 24),
          if (showResult)
            ElevatedButton(
              onPressed: () {
                _selectedOptionIndex = null; // Limpa seleção para próxima pergunta
                context.read<TriviaGameCubit>().proceedToNextStep();
              },
              child: const Text("PRÓXIMA PERGUNTA / VER RESULTADO"),
            )
          else if (!isProcessing)
            ElevatedButton(
              onPressed: _selectedOptionIndex == null
                  ? null
                  : () {
                      if (_selectedOptionIndex != null) {
                        context.read<TriviaGameCubit>().submitAnswer(_selectedOptionIndex!);
                      }
                    },
              child: const Text("CONFIRMAR RESPOSTA"),
            ),
          if (isProcessing)
            const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )),
          if (question.explanation != null && showResult && isCorrect == true)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Card(
                color: Colors.blueGrey[800],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Explicação:", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(question.explanation!),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:omnium_game/features/matchmaking/cubit/matchmaking_cubit.dart";
import "package:go_router/go_router.dart";

class WaitingForOpponentScreen extends StatelessWidget {
  final String matchId;
  const WaitingForOpponentScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    // Iniciar a escuta da partida específica se ainda não estiver ativa no cubit
    // context.read<MatchmakingCubit>().subscribeToMatchUpdates(matchId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Aguardando Oponente..."),
        automaticallyImplyLeading: false, // Impede de voltar facilmente
      ),
      body: BlocConsumer<MatchmakingCubit, MatchmakingState>(
        listener: (context, state) {
          if (state is MatchmakingSuccess && state.match.id == matchId) {
            // Oponente encontrado, partida ativa
            GoRouter.of(context).replace("/game/${state.match.id}");
          } else if (state is MatchmakingCancelled && state.matchId == matchId) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("A partida foi cancelada.")),
            );
            GoRouter.of(context).pop(); // Voltar para a tela anterior (opções de matchmaking)
          } else if (state is MatchmakingError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro: ${state.message}")),
            );
            GoRouter.of(context).pop(); 
          }
        },
        builder: (context, state) {
          String message = "Procurando um oponente para você...";
          if (state is MatchmakingLookingForOpponent && state.match.id == matchId) {
            message = state.message;
          } else if (state is MatchmakingLoading) {
            message = state.message;
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 32),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MatchmakingCubit>().declineOrCancelMatch(matchId);
                      // O listener cuidará do pop
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text("CANCELAR BUSCA"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


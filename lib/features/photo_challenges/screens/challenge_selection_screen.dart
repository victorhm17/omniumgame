import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:omnium_game/core/models/challenge_model.dart";
import "package:omnium_game/features/photo_challenges/cubit/photo_challenges_cubit.dart";
import "package:go_router/go_router.dart";

class ChallengeSelectionScreen extends StatefulWidget {
  final String matchId;
  final String challengerId; // Vencedor do trivia, quem vai escolher
  final String challengedId; // Perdedor do trivia, quem vai cumprir

  const ChallengeSelectionScreen({
    super.key,
    required this.matchId,
    required this.challengerId,
    required this.challengedId,
  });

  @override
  State<ChallengeSelectionScreen> createState() => _ChallengeSelectionScreenState();
}

class _ChallengeSelectionScreenState extends State<ChallengeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PhotoChallengesCubit>().loadChallengeTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escolha o Desafio!"),
        centerTitle: true,
      ),
      body: BlocConsumer<PhotoChallengesCubit, PhotoChallengesState>(
        listener: (context, state) {
          if (state is PhotoChallengeCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Desafio '${state.challenge.chosenChallengeTypeName}' enviado para o oponente!")),
            );
            // Navegar para home ou tela de espera do desafio
            GoRouter.of(context).go("/home"); 
          } else if (state is PhotoChallengesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro: ${state.message}")),
            );
          }
        },
        builder: (context, state) {
          if (state is PhotoChallengesLoadingTypes) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PhotoChallengeTypesLoaded) {
            if (state.types.isEmpty) {
              return const Center(child: Text("Nenhum tipo de desafio disponível no momento."));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.types.length,
              itemBuilder: (context, index) {
                final type = state.types[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: type.iconUrl != null && type.iconUrl!.isNotEmpty 
                             ? Image.network(type.iconUrl!, width: 40, height: 40, fit: BoxFit.cover)
                             : const Icon(Icons.emoji_events, size: 40),
                    title: Text(type.name, style: Theme.of(context).textTheme.titleLarge),
                    subtitle: type.description != null ? Text(type.description!) : null,
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.read<PhotoChallengesCubit>().createChallenge(
                            matchId: widget.matchId,
                            chosenChallengeTypeId: type.id,
                            chosenChallengeTypeName: type.name,
                            challengerId: widget.challengerId,
                            challengedId: widget.challengedId,
                          );
                    },
                  ),
                );
              },
            );
          }
          if (state is PhotoChallengeCreating) {
             return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Criando desafio...")
                  ],
                )
              );
          }

          return const Center(child: Text("Carregando tipos de desafio..."));
        },
      ),
    );
  }
}


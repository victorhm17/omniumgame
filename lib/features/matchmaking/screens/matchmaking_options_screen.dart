import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omnium_game/features/matchmaking/cubit/matchmaking_cubit.dart';
import 'package:omnium_game/core/models/match_model.dart';

class MatchmakingOptionsScreen extends StatelessWidget {
  const MatchmakingOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("[MatchmakingOptionsScreen] Build executado.");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encontrar Oponente'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              print("[MatchmakingOptionsScreen] Botão de Configurações clicado!");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tela de configurações ainda não implementada.")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              print("[MatchmakingOptionsScreen] Botão de Perfil clicado!");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tela de perfil ainda não implementada.")),
              );
            },
          ),
        ],
      ),
      // BlocListener REMOVIDO TEMPORARIAMENTE PARA TESTE
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bem-vindo ao OmniumGame!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('JOGAR COM AMIGO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  print("[MatchmakingOptionsScreen] Botão 'Jogar com Amigo' clicado!");
                  GoRouter.of(context).push('/matchmaking/friends');
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.public),
                label: const Text('JOGAR ALEATÓRIO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  print("[MatchmakingOptionsScreen] Botão 'Jogar Aleatório' clicado!");
                  context.read<MatchmakingCubit>().findRandomMatch();
                },
              ),
              const SizedBox(height: 40),
              // BlocBuilder mantido para exibir convites, se houver
              BlocBuilder<MatchmakingCubit, MatchmakingState>(
                builder: (context, state) {
                  print("[MatchmakingOptionsScreen] BlocBuilder reconstruído com estado: ${state.runtimeType}");
                  if (state is MatchmakingInvitesLoaded && state.invites.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Convites Pendentes:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.invites.length,
                          itemBuilder: (context, index) {
                            final invite = state.invites[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text('Convite de ${invite.player1Username ?? "Jogador"}'),
                                subtitle: Text('Recebido em: ${_formatTimestamp(invite.createdAt)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: () {
                                        print("[MatchmakingOptionsScreen] Botão Aceitar Convite clicado para match ${invite.id}");
                                        context.read<MatchmakingCubit>().acceptInvite(invite.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        print("[MatchmakingOptionsScreen] Botão Recusar Convite clicado para match ${invite.id}");
                                        context.read<MatchmakingCubit>().declineOrCancelMatch(invite.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}


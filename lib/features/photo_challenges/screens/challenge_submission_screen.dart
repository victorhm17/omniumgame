import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:image_picker/image_picker.dart";
import "package:omnium_game/core/models/challenge_model.dart";
import "package:omnium_game/features/photo_challenges/cubit/photo_challenges_cubit.dart";
import "package:go_router/go_router.dart";

class ChallengeSubmissionScreen extends StatefulWidget {
  final String challengeId; // O ID do desafio que está sendo cumprido

  const ChallengeSubmissionScreen({super.key, required this.challengeId});

  @override
  State<ChallengeSubmissionScreen> createState() => _ChallengeSubmissionScreenState();
}

class _ChallengeSubmissionScreenState extends State<ChallengeSubmissionScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Carregar detalhes do desafio específico para mostrar ao usuário
    // context.read<PhotoChallengesCubit>().loadSpecificChallengeDetails(widget.challengeId);
    // Por enquanto, vamos assumir que o cubit já tem o desafio ou o usuário sabe qual é.
    // Idealmente, o PhotoChallengesCubit teria um estado para "ChallengeDetailsLoaded"
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao selecionar imagem: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cumprir Desafio"),
        centerTitle: true,
      ),
      body: BlocConsumer<PhotoChallengesCubit, PhotoChallengesState>(
        listener: (context, state) {
          if (state is PhotoChallengeSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Foto enviada com sucesso!")),
            );
            GoRouter.of(context).go("/home");
          } else if (state is PhotoChallengeSkipped) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Desafio pulado. Sua reputação pode ser afetada.")),
            );
            GoRouter.of(context).go("/home");
          } else if (state is PhotoChallengesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro: ${state.message}")),
            );
          }
        },
        builder: (context, state) {
          // Tentar obter o desafio do estado, se disponível
          PhotoChallengeModel? currentChallenge;
          if (state is PhotoChallengeStatusUpdate && state.challenge.id == widget.challengeId) {
            currentChallenge = state.challenge;
          } else if (state is PhotoChallengesPendingLoaded) {
            currentChallenge = state.challenges.firstWhere((c) => c.id == widget.challengeId, orElse: () => null as PhotoChallengeModel);
          }
          // TODO: Adicionar um estado específico no Cubit para carregar e exibir um único desafio.

          if (state is PhotoChallengeSubmitting || state is PhotoChallengeSkipping) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (currentChallenge != null)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Desafio Recebido:",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentChallenge.chosenChallengeTypeName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          if (currentChallenge.challengerId.isNotEmpty) // Adicionar nome do desafiante
                             Padding(
                               padding: const EdgeInsets.only(top: 4.0),
                               child: Text("Enviado por: ${currentChallenge.challengerId}", style: Theme.of(context).textTheme.bodySmall),
                             )
                        ],
                      ),
                    ),
                  )
                else
                  const Text("Carregando detalhes do desafio...", textAlign: TextAlign.center),
                
                const SizedBox(height: 32),
                if (_imageFile != null)
                  Column(
                    children: [
                      Text("Imagem Selecionada:", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Image.file(File(_imageFile!.path), height: 200, fit: BoxFit.contain),
                      const SizedBox(height: 16),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Câmera"),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Galeria"),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _imageFile == null
                      ? null
                      : () async {
                          final bytes = await _imageFile!.readAsBytes();
                          context.read<PhotoChallengesCubit>().submitPhoto(
                                challengeId: widget.challengeId,
                                photoBytes: bytes,
                                fileName: _imageFile!.name,
                              );
                        },
                  child: const Text("ENVIAR FOTO"),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5)
                  ),
                  onPressed: () {
                    // Confirmar antes de pular
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text("Pular Desafio?"),
                          content: const Text("Tem certeza que deseja pular este desafio? Isso pode afetar sua reputação no jogo."),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("Cancelar"),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                            TextButton(
                              child: const Text("PULAR", style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                context.read<PhotoChallengesCubit>().skipChallenge(widget.challengeId);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("PULAR DESAFIO"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


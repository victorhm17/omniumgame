import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniumGame - Início'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navegar para a tela de Configurações
              // Exemplo: GoRouter.of(context).push('/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navegar para a tela de Perfil
              // Exemplo: GoRouter.of(context).push('/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bem-vindo ao OmniumGame!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                // TODO: Lógica para iniciar matchmaking com amigo
                // Exemplo: GoRouter.of(context).push('/matchmaking/friend');
              },
              child: const Text('Jogar com Amigo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                // TODO: Lógica para iniciar matchmaking aleatório
                // Exemplo: GoRouter.of(context).push('/matchmaking/random');
              },
              child: const Text('Jogar Aleatório'),
            ),
            // TODO: Adicionar mais elementos conforme a tela principal evolui
          ],
        ),
      ),
    );
  }
}


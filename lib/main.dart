import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:firebase_core/firebase_core.dart";
import "package:go_router/go_router.dart";
import "dart:async"; // Adicionado import para StreamSubscription
import "package:omnium_game/firebase_options.dart";
import "package:omnium_game/features/auth/screens/login_screen.dart";
import "package:omnium_game/features/auth/screens/signup_screen.dart";
import "package:omnium_game/features/home/screens/home_screen.dart";
import "package:omnium_game/features/auth/repositories/auth_repository.dart";
import "package:omnium_game/features/auth/cubit/auth_cubit.dart";
import "package:omnium_game/features/matchmaking/repositories/matchmaking_repository.dart";
import "package:omnium_game/features/matchmaking/cubit/matchmaking_cubit.dart";
import "package:omnium_game/features/matchmaking/screens/matchmaking_options_screen.dart";
import "package:omnium_game/features/matchmaking/screens/waiting_for_opponent_screen.dart";
import "package:omnium_game/features/trivia_game/repositories/trivia_game_repository.dart";
// Removido import não utilizado de TriviaGameCubit
import "package:omnium_game/features/trivia_game/screens/trivia_game_screen.dart";
import "package:omnium_game/features/trivia_game/screens/game_mode_selection_screen.dart";
import "package:omnium_game/features/trivia_game/screens/bot_game_screen.dart";
import "package:omnium_game/core/models/bot_player.dart";
import "package:omnium_game/features/photo_challenges/repositories/photo_challenges_repository.dart";
import "package:omnium_game/features/photo_challenges/cubit/photo_challenges_cubit.dart";
import "package:omnium_game/features/photo_challenges/screens/challenge_selection_screen.dart";
import "package:omnium_game/features/photo_challenges/screens/challenge_submission_screen.dart";
import "package:omnium_game/features/reputation/repositories/reputation_repository.dart";
import "package:omnium_game/features/reputation/cubit/reputation_cubit.dart";

// Placeholder para a tela de amigos
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecionar Amigo")),
      body: const Center(child: Text("Tela de seleção de amigos (Placeholder)")),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(OmniumGame());
}

class OmniumGame extends StatelessWidget {
  OmniumGame({super.key});

  final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider<MatchmakingRepository>(
          create: (_) => MatchmakingRepository(),
        ),
        RepositoryProvider<TriviaGameRepository>(
          create: (_) => TriviaGameRepository(),
        ),
        RepositoryProvider<PhotoChallengesRepository>(
          create: (_) => PhotoChallengesRepository(),
        ),
        RepositoryProvider<ReputationRepository>(
          create: (_) => ReputationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authRepository: _authRepository)..appStarted(),
          ),
          BlocProvider<MatchmakingCubit>(
            create: (context) => MatchmakingCubit(matchmakingRepository: RepositoryProvider.of<MatchmakingRepository>(context)),
          ),
          BlocProvider<PhotoChallengesCubit>(
            create: (context) => PhotoChallengesCubit(challengesRepository: RepositoryProvider.of<PhotoChallengesRepository>(context)),
          ),
          BlocProvider<ReputationCubit>(
            create: (context) => ReputationCubit(reputationRepository: RepositoryProvider.of<ReputationRepository>(context)),
          ),
          // TriviaGameCubit não precisa ser global, será injetado na tela do jogo
        ],
        child: Builder(
          builder: (context) {
            final GoRouter _router = GoRouter(
              initialLocation: "/login", // Será gerenciado pelo redirect
              routes: [
                GoRoute(
                  path: "/login",
                  builder: (context, state) => const LoginScreen(),
                ),
                GoRoute(
                  path: "/signup",
                  builder: (context, state) => const SignupScreen(),
                ),
                GoRoute(
                  path: "/home",
                  builder: (context, state) => const HomeScreen(), // TODO: HomeScreen precisa ser criada ou definida
                  // Temporariamente apontando para MatchmakingOptionsScreen como tela inicial pós-login
                  // builder: (context, state) => const MatchmakingOptionsScreen(),
                ),
                GoRoute(
                  path: "/matchmaking/options",
                  builder: (context, state) => const MatchmakingOptionsScreen(),
                ),
                 GoRoute(
                  path: "/matchmaking/friends", // Rota adicionada
                  builder: (context, state) => const FriendsScreen(), // Apontando para o placeholder
                ),
                GoRoute(
                  path: "/matchmaking/waiting/:matchId",
                  builder: (context, state) {
                    final matchId = state.pathParameters["matchId"]!;
                    return WaitingForOpponentScreen(matchId: matchId);
                  },
                ),
                GoRoute(
                  path: "/game/:matchId", // Rota para a tela do jogo de trivia
                  builder: (context, state) {
                    final matchId = state.pathParameters["matchId"]!;
                    // Injetar TriviaGameCubit aqui, se necessário, ou na própria tela
                    return TriviaGameScreen(matchId: matchId);
                  },
                ),
                GoRoute(
                  path: "/challenge/select/:matchId/:challengerId/:challengedId",
                  builder: (context, state) {
                    final matchId = state.pathParameters["matchId"]!;
                    final challengerId = state.pathParameters["challengerId"]!;
                    final challengedId = state.pathParameters["challengedId"]!;
                    return ChallengeSelectionScreen(matchId: matchId, challengerId: challengerId, challengedId: challengedId);
                  },
                ),
                GoRoute(
                  path: "/challenge/submit/:challengeId",
                  builder: (context, state) {
                    final challengeId = state.pathParameters["challengeId"]!;
                    return ChallengeSubmissionScreen(challengeId: challengeId);
                  },
                ),
                GoRoute(
                  path: "/game-mode-selection",
                  builder: (context, state) => const GameModeSelectionScreen(),
                ),
                GoRoute(
                  path: "/game/bot",
                  builder: (context, state) {
                    final difficultyParam = state.uri.queryParameters["difficulty"] ?? "medium";
                    final difficulty = BotDifficulty.values.firstWhere(
                      (d) => d.name == difficultyParam,
                      orElse: () => BotDifficulty.medium,
                    );
                    return BotGameScreen(difficulty: difficulty);
                  },
                ),
                GoRoute(
                  path: "/game/local",
                  builder: (context, state) {
                    // TODO: Implementar tela de jogo local
                    return const Scaffold(
                      appBar: null,
                      body: Center(
                        child: Text("Modo Local - Em desenvolvimento"),
                      ),
                    );
                  },
                ),
                // TODO: Adicionar outras rotas necessárias (perfil, configurações, etc.)
              ],
              redirect: (BuildContext context, GoRouterState state) {
                final authState = context.read<AuthCubit>().state;
                final bool loggingIn = state.matchedLocation == "/login";
                final bool signingUp = state.matchedLocation == "/signup";

                if (authState is AuthUnauthenticated) {
                  return loggingIn || signingUp ? null : "/login";
                }
                if (authState is AuthAuthenticated) {
                  // Redireciona para a tela de seleção de modo de jogo após login/signup
                  return loggingIn || signingUp ? "/game-mode-selection" : null;
                }
                // Se AuthLoading ou AuthInitial, não redireciona ainda (pode mostrar splash)
                return null; 
              },
              refreshListenable: GoRouterRefreshStream(context.watch<AuthCubit>().stream),
              errorBuilder: (context, state) => Scaffold(
                appBar: AppBar(title: const Text("Erro")), // Adiciona AppBar para contexto
                body: Center(child: Text("Erro na rota: ${state.error}")),
              ),
            );

            return MaterialApp.router(
              title: "OmniumGame",
              theme: ThemeData(
                primarySwatch: Colors.purple,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.purple,
                  primary: Colors.purple,
                  secondary: Colors.pinkAccent,
                  background: Colors.blueGrey[900],
                  brightness: Brightness.dark,
                ),
                fontFamily: "Roboto",
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}

// Helper class to trigger GoRouter redirect on AuthCubit state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription; // Corrigido de Stream para StreamSubscription

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


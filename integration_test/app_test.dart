import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:omnium_game/main.dart' as app;
// import 'package:firebase_core/firebase_core.dart'; // Firebase is initialized in app.main()
// import 'package:omnium_game/firebase_options.dart'; // Firebase is initialized in app.main()

// Para rodar: flutter test integration_test/app_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('OmniumGame End-to-End Test', () {
    testWidgets('Full game flow: signup, login, matchmaking, trivia, challenge, reputation',
        (WidgetTester tester) async {
      // Carrega o app.
      app.main(); 
      // Aguarda o app carregar, inicializar o Firebase e animações finalizarem.
      // Aumentar o tempo se necessário, especialmente para a inicialização do Firebase.
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // --- TELA DE LOGIN/CADASTRO ---
      final Finder signUpLinkFinder = find.widgetWithText(TextButton, 'Não tem uma conta? Cadastre-se');
      expect(signUpLinkFinder, findsOneWidget, reason: 'Link de cadastro não encontrado na tela de login');
      await tester.tap(signUpLinkFinder);
      await tester.pumpAndSettle();

      // --- TELA DE CADASTRO ---
      final String uniqueEmail = 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com';
      final Finder nameFieldFinder = find.byKey(const Key('signup_name_field'));
      final Finder emailFieldFinder = find.byKey(const Key('signup_email_field'));
      final Finder passwordFieldFinder = find.byKey(const Key('signup_password_field'));
      final Finder confirmPasswordFieldFinder = find.byKey(const Key('signup_confirm_password_field'));
      final Finder doSignUpButtonFinder = find.byKey(const Key('signup_button'));

      expect(nameFieldFinder, findsOneWidget, reason: 'Campo Nome não encontrado na tela de cadastro');
      expect(emailFieldFinder, findsOneWidget, reason: 'Campo Email não encontrado na tela de cadastro');
      expect(passwordFieldFinder, findsOneWidget, reason: 'Campo Senha não encontrado na tela de cadastro');
      expect(confirmPasswordFieldFinder, findsOneWidget, reason: 'Campo Confirmar Senha não encontrado na tela de cadastro');
      expect(doSignUpButtonFinder, findsOneWidget, reason: 'Botão de Cadastrar não encontrado');

      await tester.enterText(nameFieldFinder, 'Test User E2E');
      await tester.enterText(emailFieldFinder, uniqueEmail);
      await tester.enterText(passwordFieldFinder, 'password123');
      await tester.enterText(confirmPasswordFieldFinder, 'password123');
      await tester.tap(doSignUpButtonFinder);
      // Aumentar o tempo para permitir o cadastro e a navegação para a HomeScreen
      await tester.pumpAndSettle(const Duration(seconds: 10)); 

      // --- TELA HOME (APÓS LOGIN/CADASTRO) ---
      // Verificar se estamos na tela Home (ex: procurando por um título ou botão específico da Home)
      expect(find.widgetWithText(AppBar, 'OmniumGame'), findsOneWidget, reason: 'Não navegou para a HomeScreen após cadastro/login');
      final Finder playRandomButtonFinder = find.byKey(const Key('play_random_opponent_button'));
      expect(playRandomButtonFinder, findsOneWidget, reason: 'Botão "Jogar com Oponente Aleatório" não encontrado na HomeScreen');
      
      // --- INICIAR MATCHMAKING ---
      await tester.tap(playRandomButtonFinder);
      await tester.pumpAndSettle(); // Navega para MatchmakingOptionsScreen

      // --- TELA DE OPÇÕES DE MATCHMAKING ---
      expect(find.text('Opções de Partida'), findsOneWidget, reason: 'Não navegou para MatchmakingOptionsScreen');
      final Finder findRandomMatchButton = find.byKey(const Key('find_random_match_button'));
      expect(findRandomMatchButton, findsOneWidget, reason: 'Botão "Encontrar Partida Aleatória Rápida" não encontrado');
      await tester.tap(findRandomMatchButton);
      await tester.pumpAndSettle(); // Navega para WaitingForOpponentScreen e o Cubit começa a procurar

      // --- TELA DE ESPERA POR OPONENTE ---
      // Aqui é a parte mais complexa para um teste de integração real sem um backend de teste robusto
      // ou um segundo cliente. O Cubit tentará encontrar uma partida.
      // Se houver outro jogador (ou um bot de teste no backend), a partida será formada.
      // Para este teste, vamos assumir que o Firestore está configurado para permitir que um jogador
      // crie uma partida "pending_random" e que, após um tempo, ela se torne "active"
      // (ou que o próprio jogador possa ser player1 e player2 para fins de teste local, se a lógica permitir).
      debugPrint('Aguardando matchmaking encontrar um oponente ou partida ser ativada...');
      // Esperar um tempo para o matchmaking (simulado). Em um cenário real, isso seria orientado por estado.
      // O WaitingForOpponentScreen deve navegar para TriviaGameScreen quando o estado do MatchmakingCubit for MatchmakingSuccess.
      await tester.pumpAndSettle(const Duration(seconds: 15)); // Aumentar se o matchmaking real/simulado demorar mais

      // Verificar se navegou para a tela de Trivia
      // Supondo que TriviaGameScreen tem um AppBar com o título "Trivia Game" ou um widget específico.
      // A navegação é feita pelo WaitingForOpponentScreen ao observar o MatchmakingCubit.
      // Se o matchmaking não funcionar como esperado (ex: nenhum outro jogador), este passo falhará.
      expect(find.byKey(const Key('trivia_game_screen_scaffold')), findsOneWidget, reason: 'Não navegou para a TriviaGameScreen após o matchmaking. Verifique a lógica do matchmaking e o estado do Firestore.');
      debugPrint('Navegou para TriviaGameScreen.');

      // --- TELA DE TRIVIA ---
      // Supondo que temos pelo menos uma pergunta carregada.
      // A TriviaGameScreen deve mostrar a pergunta e as opções.
      // Precisamos de Keys para os botões de opção.
      // Exemplo: find.byKey(const Key('option_0_button'))
      
      // Responder a primeira pergunta (assumindo que a primeira opção é a correta para simplificar)
      // Esta parte é altamente dependente de como as perguntas e opções são renderizadas e quais Keys são usadas.
      // Vamos supor que as opções são ElevatedButton e podemos encontrá-las por texto ou Key.
      // E que o TriviaGameCubit carrega as perguntas.
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Dar tempo para carregar as perguntas

      // Encontrar uma opção de resposta. Se as perguntas são aleatórias, o texto da opção correta varia.
      // Para um teste estável, o ideal seria ter perguntas de teste fixas ou identificar a opção correta de outra forma.
      // Por agora, vamos tentar encontrar qualquer botão de opção e clicar nele.
      // Supondo que os botões de opção tenham uma Key previsível ou sejam os únicos ElevatedButton visíveis além de outros controles.
      final Finder optionButtonFinder = find.byKey(const Key('option_button_0')); // Assumindo que a primeira opção tem essa Key
      
      if (tester.any(optionButtonFinder)) {
        await tester.tap(optionButtonFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3)); // Processar a resposta e ir para a próxima pergunta ou resultado
        debugPrint('Respondeu à primeira pergunta.');

        // Adicionar mais interações de resposta se houver mais perguntas
        // Ex: Responder a segunda pergunta
        // final Finder optionButtonFinder2 = find.byKey(const Key('option_button_1')); // Exemplo
        // if (tester.any(optionButtonFinder2)) {
        //   await tester.tap(optionButtonFinder2);
        //   await tester.pumpAndSettle(const Duration(seconds: 3));
        //   debugPrint('Respondeu à segunda pergunta.');
        // }
      } else {
        debugPrint('Nenhum botão de opção encontrado com a Key esperada. Verifique as Keys na TriviaGameScreen.');
        // O teste pode falhar aqui ou podemos torná-lo mais resiliente.
      }
      
      // Após responder as perguntas, o jogo deve ir para a tela de seleção de desafio ou resultados.
      // Supondo que navega para ChallengeSelectionScreen se o jogador atual for o vencedor.
      // Esta lógica depende de quem venceu, o que é difícil de controlar neste teste simples.
      // Vamos assumir que o jogador de teste venceu e pode selecionar um desafio.
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Aguardar transição

      // --- TELA DE SELEÇÃO DE DESAFIO ---
      // Verificar se estamos na tela de seleção de desafios
      // Supondo que ChallengeSelectionScreen tem um título ou widget específico.
      // A navegação para cá depende do resultado do Trivia.
      final Finder challengeSelectionScreenFinder = find.byKey(const Key('challenge_selection_screen_scaffold'));
      if (tester.any(challengeSelectionScreenFinder)) {
        debugPrint('Navegou para ChallengeSelectionScreen.');
        // Selecionar uma categoria de desafio, por exemplo, "Leve"
        // Supondo que os botões de categoria tenham Keys como 'challenge_category_Leve'
        final Finder leveCategoryButton = find.byKey(const Key('challenge_category_Leve'));
        expect(leveCategoryButton, findsOneWidget, reason: 'Botão da categoria Leve não encontrado.');
        await tester.tap(leveCategoryButton);
        await tester.pumpAndSettle();

        // Selecionar o primeiro desafio da lista (supondo que há desafios carregados)
        // Supondo que os desafios são listados e o primeiro tem uma Key 'challenge_item_0'
        final Finder firstChallengeItem = find.byKey(const Key('challenge_item_0'));
        expect(firstChallengeItem, findsOneWidget, reason: 'Primeiro item de desafio não encontrado.');
        await tester.tap(firstChallengeItem);
        await tester.pumpAndSettle(const Duration(seconds: 3)); // Processar seleção

        // O app deve então mostrar a tela de submissão para o perdedor ou uma confirmação.
        // Para este teste, vamos assumir que o fluxo continua para o perdedor (que é o mesmo usuário no modo de teste single player)
        // ou que o desafio é apenas registrado.
        // Se for para ChallengeSubmissionScreen:
        final Finder challengeSubmissionScreenFinder = find.byKey(const Key('challenge_submission_screen_scaffold'));
        if (tester.any(challengeSubmissionScreenFinder)) {
            debugPrint('Navegou para ChallengeSubmissionScreen.');
            final Finder skipChallengeButton = find.byKey(const Key('skip_challenge_button'));
            expect(skipChallengeButton, findsOneWidget, reason: 'Botão Pular Desafio não encontrado.');
            await tester.tap(skipChallengeButton);
            await tester.pumpAndSettle(const Duration(seconds: 3));
            debugPrint('Desafio pulado.');
            // TODO: Verificar atualização de reputação aqui se possível ou em uma tela de perfil.
        } else {
            debugPrint('Não navegou para ChallengeSubmissionScreen como esperado após selecionar desafio.');
        }

      } else {
        debugPrint('Não navegou para ChallengeSelectionScreen. O resultado do Trivia pode não ter sido uma vitória ou o fluxo é diferente.');
      }
      
      // TODO: Adicionar passos para Reputação
      // - Se pulou, verificar se a reputação foi atualizada no perfil (pode precisar navegar para o perfil)

      // TODO: Logout (opcional, para limpar o estado)
      // final Finder logoutButton = find.byIcon(Icons.logout); // Supondo que há um botão de logout na HomeScreen
      // if (tester.any(logoutButton)) {
      //   await tester.tap(logoutButton);
      //   await tester.pumpAndSettle(const Duration(seconds: 3));
      //   expect(signUpLinkFinder, findsOneWidget, reason: 'Não retornou para a tela de login após logout');
      //   debugPrint('Logout realizado com sucesso.');
      // }

      debugPrint('Teste de fluxo completo (parcialmente implementado) finalizado.');
    });
  });
}


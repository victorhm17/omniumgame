import "package:cloud_firestore/cloud_firestore.dart";
import "package:omnium_game/core/models/question_model.dart";

class TriviaGameRepository {
  final FirebaseFirestore _firestore;

  TriviaGameRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Busca um conjunto de perguntas para uma partida
  // A lógica de seleção (aleatória, por categoria/dificuldade) pode ser mais elaborada
  Future<List<QuestionModel>> getQuestionsForMatch({
    int count = 10, // Número de perguntas por partida
    String? category, // Opcional: filtrar por categoria
    String? difficulty, // Opcional: filtrar por dificuldade
  }) async {
    try {
      Query query = _firestore.collection("questions");

      if (category != null) {
        query = query.where("category", isEqualTo: category);
      }
      if (difficulty != null) {
        query = query.where("difficulty", isEqualTo: difficulty);
      }

      // Para pegar aleatoriamente, uma abordagem comum é buscar mais do que o necessário
      // e embaralhar no lado do cliente, ou usar técnicas mais avançadas no Firestore se possível.
      // Uma forma simples (mas não perfeitamente aleatória e pode ter problemas de performance
      // com muitos documentos) é usar .orderBy(FieldPath.documentId).limit() com um offset aleatório
      // ou buscar todos e selecionar aleatoriamente no cliente.
      // Por simplicidade, vamos apenas limitar a quantidade por enquanto.
      // TODO: Implementar uma melhor seleção aleatória de perguntas.
      
      QuerySnapshot snapshot = await query.limit(count * 2).get(); // Pega um pouco mais para ter margem
      
      List<QuestionModel> questions = snapshot.docs
          .map((doc) => QuestionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      questions.shuffle(); // Embaralha no cliente
      return questions.take(count).toList();

    } catch (e) {
      print("Erro ao buscar perguntas: $e");
      throw Exception("Falha ao carregar perguntas do jogo.");
    }
  }

  // Salva a resposta de um jogador para uma pergunta específica dentro de uma partida
  // Esta função assume que as respostas são armazenadas no documento da partida.
  Future<void> submitAnswer({
    required String matchId,
    required String playerId,
    required String questionId,
    required int selectedOptionIndex,
    required bool isCorrect,
    required int timeTakenMs,
  }) async {
    try {
      final matchRef = _firestore.collection("matches").doc(matchId);

      // Estrutura de como a resposta será salva
      Map<String, dynamic> answerData = {
        "question_id": questionId,
        "selected_option_index": selectedOptionIndex,
        "is_correct": isCorrect,
        "time_taken_ms": timeTakenMs,
        "answered_at": Timestamp.now(),
      };

      // Adiciona a resposta à lista de respostas do jogador
      // O campo player_answers deve ser um Map<String (playerId), List<Map<String, dynamic>>>
      // Ex: player_answers.playerId : [resposta1, resposta2]
      // Usamos FieldValue.arrayUnion para adicionar à lista de forma atômica.
      // Precisamos garantir que o campo do jogador exista.

      // Primeiro, verificamos se o campo do jogador existe em player_answers
      // Se não, criamos com a primeira resposta. Se sim, adicionamos à lista.
      // Isso pode ser simplificado se a estrutura do `player_answers` for inicializada quando o jogador entra na partida.

      // Uma forma mais robusta seria usar uma transação ou batched writes se múltiplas atualizações
      // no documento da partida forem necessárias (ex: atualizar score também).
      
      // Atualiza o campo específico do jogador dentro do mapa player_answers
      // Ex: player_answers.UID_DO_JOGADOR
      String playerAnswersField = "player_answers.$playerId";

      await matchRef.update({
        playerAnswersField: FieldValue.arrayUnion([answerData]),
        "updated_at": Timestamp.now(),
        // TODO: Atualizar score e current_turn aqui ou em uma função separada/Cloud Function
      });

    } catch (e) {
      print("Erro ao submeter resposta: $e");
      throw Exception("Falha ao registrar resposta.");
    }
  }
  
  // TODO: Adicionar métodos para popular o banco de perguntas (admin)
  // Future<void> addQuestion(QuestionModel question) async { ... }
}


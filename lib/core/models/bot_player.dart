import "package:equatable/equatable.dart";
import "dart:math";

enum BotDifficulty { easy, medium, hard }

class BotPlayer extends Equatable {
  final String id;
  final String username;
  final BotDifficulty difficulty;
  final double accuracyRate; // Taxa de acerto (0.0 a 1.0)
  final int minResponseTimeMs; // Tempo mínimo de resposta em ms
  final int maxResponseTimeMs; // Tempo máximo de resposta em ms

  const BotPlayer({
    required this.id,
    required this.username,
    required this.difficulty,
    required this.accuracyRate,
    required this.minResponseTimeMs,
    required this.maxResponseTimeMs,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        difficulty,
        accuracyRate,
        minResponseTimeMs,
        maxResponseTimeMs,
      ];

  // Factory constructors para diferentes dificuldades
  factory BotPlayer.easy() {
    return const BotPlayer(
      id: "bot_easy",
      username: "Bot Iniciante",
      difficulty: BotDifficulty.easy,
      accuracyRate: 0.6, // 60% de acerto
      minResponseTimeMs: 3000, // 3 segundos
      maxResponseTimeMs: 8000, // 8 segundos
    );
  }

  factory BotPlayer.medium() {
    return const BotPlayer(
      id: "bot_medium",
      username: "Bot Intermediário",
      difficulty: BotDifficulty.medium,
      accuracyRate: 0.75, // 75% de acerto
      minResponseTimeMs: 2000, // 2 segundos
      maxResponseTimeMs: 5000, // 5 segundos
    );
  }

  factory BotPlayer.hard() {
    return const BotPlayer(
      id: "bot_hard",
      username: "Bot Especialista",
      difficulty: BotDifficulty.hard,
      accuracyRate: 0.9, // 90% de acerto
      minResponseTimeMs: 1000, // 1 segundo
      maxResponseTimeMs: 3000, // 3 segundos
    );
  }

  // Método para simular resposta do bot
  BotResponse simulateResponse(List<bool> optionCorrectness) {
    final random = Random();
    
    // Determina se o bot vai acertar baseado na taxa de acurácia
    final bool shouldAnswerCorrectly = random.nextDouble() < accuracyRate;
    
    int selectedOptionIndex;
    
    if (shouldAnswerCorrectly) {
      // Encontra a opção correta
      selectedOptionIndex = optionCorrectness.indexWhere((isCorrect) => isCorrect);
      // Se não encontrar opção correta (erro nos dados), escolhe aleatoriamente
      if (selectedOptionIndex == -1) {
        selectedOptionIndex = random.nextInt(optionCorrectness.length);
      }
    } else {
      // Escolhe uma opção incorreta
      final incorrectIndices = <int>[];
      for (int i = 0; i < optionCorrectness.length; i++) {
        if (!optionCorrectness[i]) {
          incorrectIndices.add(i);
        }
      }
      
      if (incorrectIndices.isNotEmpty) {
        selectedOptionIndex = incorrectIndices[random.nextInt(incorrectIndices.length)];
      } else {
        // Se todas as opções são corretas (erro nos dados), escolhe aleatoriamente
        selectedOptionIndex = random.nextInt(optionCorrectness.length);
      }
    }
    
    // Calcula tempo de resposta aleatório dentro do range
    final responseTime = minResponseTimeMs + 
        random.nextInt(maxResponseTimeMs - minResponseTimeMs);
    
    return BotResponse(
      selectedOptionIndex: selectedOptionIndex,
      responseTimeMs: responseTime,
      isCorrect: optionCorrectness[selectedOptionIndex],
    );
  }

  BotPlayer copyWith({
    String? id,
    String? username,
    BotDifficulty? difficulty,
    double? accuracyRate,
    int? minResponseTimeMs,
    int? maxResponseTimeMs,
  }) {
    return BotPlayer(
      id: id ?? this.id,
      username: username ?? this.username,
      difficulty: difficulty ?? this.difficulty,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      minResponseTimeMs: minResponseTimeMs ?? this.minResponseTimeMs,
      maxResponseTimeMs: maxResponseTimeMs ?? this.maxResponseTimeMs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "difficulty": difficulty.name,
      "accuracy_rate": accuracyRate,
      "min_response_time_ms": minResponseTimeMs,
      "max_response_time_ms": maxResponseTimeMs,
    };
  }

  factory BotPlayer.fromMap(Map<String, dynamic> map) {
    return BotPlayer(
      id: map["id"] ?? "",
      username: map["username"] ?? "",
      difficulty: BotDifficulty.values.firstWhere(
        (d) => d.name == map["difficulty"],
        orElse: () => BotDifficulty.medium,
      ),
      accuracyRate: (map["accuracy_rate"] ?? 0.75).toDouble(),
      minResponseTimeMs: map["min_response_time_ms"] ?? 2000,
      maxResponseTimeMs: map["max_response_time_ms"] ?? 5000,
    );
  }
}

class BotResponse extends Equatable {
  final int selectedOptionIndex;
  final int responseTimeMs;
  final bool isCorrect;

  const BotResponse({
    required this.selectedOptionIndex,
    required this.responseTimeMs,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [selectedOptionIndex, responseTimeMs, isCorrect];
}


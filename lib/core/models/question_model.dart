import "package:equatable/equatable.dart";

class QuestionModel extends Equatable {
  final String id;
  final String text;
  final String category;
  final String difficulty;
  final List<OptionModel> options;
  final String? imageUrl;
  final String? explanation;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.category,
    required this.difficulty,
    required this.options,
    this.imageUrl,
    this.explanation,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        category,
        difficulty,
        options,
        imageUrl,
        explanation,
      ];

  factory QuestionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return QuestionModel(
      id: documentId,
      text: map["text"] ?? "",
      category: map["category"] ?? "Geral",
      difficulty: map["difficulty"] ?? "Médio",
      options: (map["options"] as List<dynamic>? ?? [])
          .map((optionMap) => OptionModel.fromMap(optionMap as Map<String, dynamic>))
          .toList(),
      imageUrl: map["image_url"],
      explanation: map["explanation"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "category": category,
      "difficulty": difficulty,
      "options": options.map((option) => option.toMap()).toList(),
      if (imageUrl != null) "image_url": imageUrl,
      if (explanation != null) "explanation": explanation,
    };
  }
}

class OptionModel extends Equatable {
  final String text;
  final bool isCorrect;

  const OptionModel({required this.text, required this.isCorrect});

  @override
  List<Object?> get props => [text, isCorrect];

  factory OptionModel.fromMap(Map<String, dynamic> map) {
    return OptionModel(
      text: map["text"] ?? "",
      isCorrect: map["is_correct"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "is_correct": isCorrect,
    };
  }
}


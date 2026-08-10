class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class LessonStep {
  final String title;
  final String description;
  final String initialFen;
  final String? targetMoveSan;
  final QuizQuestion? quiz;

  const LessonStep({
    required this.title,
    required this.description,
    this.initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
    this.targetMoveSan,
    this.quiz,
  });
}

class LessonCategory {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final List<ChessLesson> lessons;

  const LessonCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.lessons,
  });
}

class ChessLesson {
  final String id;
  final String categoryId;
  final String title;
  final String summary;
  final int estimatedMinutes;
  final List<LessonStep> steps;
  final bool isBookmarked;
  final bool isCompleted;

  const ChessLesson({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.summary,
    required this.estimatedMinutes,
    required this.steps,
    this.isBookmarked = false,
    this.isCompleted = false,
  });

  ChessLesson copyWith({
    bool? isBookmarked,
    bool? isCompleted,
  }) {
    return ChessLesson(
      id: id,
      categoryId: categoryId,
      title: title,
      summary: summary,
      estimatedMinutes: estimatedMinutes,
      steps: steps,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/lesson.dart';

class LearnState {
  final List<LessonCategory> categories;
  final String searchQuery;
  final String? selectedCategoryId;

  const LearnState({
    required this.categories,
    this.searchQuery = '',
    this.selectedCategoryId,
  });

  List<ChessLesson> get allLessons {
    return categories.expand((cat) => cat.lessons).toList();
  }

  List<ChessLesson> get filteredLessons {
    var list = allLessons;
    if (selectedCategoryId != null) {
      list = list.where((l) => l.categoryId == selectedCategoryId).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((l) => l.title.toLowerCase().contains(q) || l.summary.toLowerCase().contains(q)).toList();
    }
    return list;
  }
}

final learnProvider = StateNotifierProvider<LearnNotifier, LearnState>((ref) {
  return LearnNotifier();
});

class LearnNotifier extends StateNotifier<LearnState> {
  LearnNotifier() : super(LearnState(categories: _initialAcademyData()));

  void setSearchQuery(String query) {
    state = LearnState(
      categories: state.categories,
      searchQuery: query,
      selectedCategoryId: state.selectedCategoryId,
    );
  }

  void selectCategory(String? categoryId) {
    state = LearnState(
      categories: state.categories,
      searchQuery: state.searchQuery,
      selectedCategoryId: categoryId,
    );
  }

  void toggleBookmark(String lessonId) {
    final updatedCategories = state.categories.map((cat) {
      final updatedLessons = cat.lessons.map((l) {
        return l.id == lessonId ? l.copyWith(isBookmarked: !l.isBookmarked) : l;
      }).toList();
      return LessonCategory(
        id: cat.id,
        title: cat.title,
        description: cat.description,
        iconName: cat.iconName,
        lessons: updatedLessons,
      );
    }).toList();

    state = LearnState(
      categories: updatedCategories,
      searchQuery: state.searchQuery,
      selectedCategoryId: state.selectedCategoryId,
    );
  }

  static List<LessonCategory> _initialAcademyData() {
    return const [
      LessonCategory(
        id: 'basics',
        title: 'Chess Basics',
        description: 'Learn how board coordinates work and piece values.',
        iconName: 'school',
        lessons: [
          ChessLesson(
            id: 'l1',
            categoryId: 'basics',
            title: 'The Chess Board & Ranks/Files',
            summary: 'Understanding the 64 squares, ranks 1-8, and files a-h.',
            estimatedMinutes: 5,
            steps: [
              LessonStep(
                title: 'Square Notation',
                description: 'Each square is identified by a column letter (a-h) and row number (1-8). The bottom right square must always be light-colored!',
                quiz: QuizQuestion(
                  question: 'What is the notation of the bottom-left square for White?',
                  options: ['a1', 'h8', 'e4', 'a8'],
                  correctIndex: 0,
                  explanation: 'Rank 1 is White\'s home rank and File "a" is the left-most column.',
                ),
              ),
            ],
          ),
          ChessLesson(
            id: 'l2',
            categoryId: 'basics',
            title: 'Piece Values & Power',
            summary: 'Queen (9), Rook (5), Bishop (3), Knight (3), Pawn (1).',
            estimatedMinutes: 6,
            steps: [
              LessonStep(
                title: 'Material Advantage',
                description: 'Trading a knight (3 points) for a rook (5 points) gains +2 material value.',
              ),
            ],
          ),
        ],
      ),
      LessonCategory(
        id: 'special',
        title: 'Special Rules',
        description: 'Castling, En Passant, and Pawn Promotion.',
        iconName: 'star',
        lessons: [
          ChessLesson(
            id: 'l3',
            categoryId: 'special',
            title: 'Castling Rights & Execution',
            summary: 'Protect your King and activate your Rook in a single move.',
            estimatedMinutes: 8,
            steps: [
              LessonStep(
                title: 'Kingside vs Queenside',
                description: 'Kingside castling moves King to g1 and Rook to f1. Neither piece must have moved previously, and no square passed through can be under attack.',
                quiz: QuizQuestion(
                  question: 'Can you castle if your King is currently in check?',
                  options: ['Yes', 'No', 'Only Kingside', 'Only if taking a piece'],
                  correctIndex: 1,
                  explanation: 'You can NEVER castle out of check according to official FIDE rules.',
                ),
              ),
            ],
          ),
          ChessLesson(
            id: 'l4',
            categoryId: 'special',
            title: 'En Passant Captures',
            summary: 'The mysterious pawn capture in passing.',
            estimatedMinutes: 7,
            steps: [
              LessonStep(
                title: 'En Passant Timing',
                description: 'When an opponent moves a pawn 2 squares forward from its starting rank and lands adjacent to your pawn, you can capture it as if it only moved 1 square! This must be done on the VERY NEXT turn.',
              ),
            ],
          ),
        ],
      ),
      LessonCategory(
        id: 'tactics',
        title: 'Tactics & Openings',
        description: 'Forks, Pins, Skewers, and Opening Principles.',
        iconName: 'psychology',
        lessons: [
          ChessLesson(
            id: 'l5',
            categoryId: 'tactics',
            title: 'The Knight Fork',
            summary: 'Attacking two major pieces simultaneously.',
            estimatedMinutes: 10,
            steps: [
              LessonStep(
                title: 'Royal Fork',
                description: 'When a Knight attacks both the King and Queen simultaneously, the opponent MUST save their King, surrendering the Queen!',
              ),
            ],
          ),
          ChessLesson(
            id: 'l6',
            categoryId: 'tactics',
            title: 'Opening Principles',
            summary: 'Control the center, develop pieces, castle early.',
            estimatedMinutes: 12,
            steps: [
              LessonStep(
                title: 'Center Control',
                description: 'Move e4 or d4 early to command the d4, d5, e4, e5 squares.',
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

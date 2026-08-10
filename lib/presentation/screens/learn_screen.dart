import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/lesson.dart';
import '../../providers/learn_provider.dart';
import '../widgets/glass_card.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learnState = ref.watch(learnProvider);
    final learnNotifier = ref.read(learnProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Chess Academy & Practice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Field
              TextField(
                onChanged: (q) => learnNotifier.setSearchQuery(q),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search lessons, tactics, rules...',
                  hintStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryGold),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Modules'),
                      selected: learnState.selectedCategoryId == null,
                      selectedColor: AppColors.primaryGold,
                      labelStyle: TextStyle(
                        color: learnState.selectedCategoryId == null ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => learnNotifier.selectCategory(null),
                    ),
                    const SizedBox(width: 8),
                    ...learnState.categories.map((cat) {
                      final isSelected = learnState.selectedCategoryId == cat.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat.title),
                          selected: isSelected,
                          selectedColor: AppColors.primaryGold,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => learnNotifier.selectCategory(cat.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lessons List
              Expanded(
                child: learnState.filteredLessons.isEmpty
                    ? const Center(
                        child: Text('No lessons found matching search.', style: TextStyle(color: Colors.white54)),
                      )
                    : ListView.separated(
                        itemCount: learnState.filteredLessons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, index) {
                          final lesson = learnState.filteredLessons[index];
                          return _buildLessonCard(context, lesson, learnNotifier);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, ChessLesson lesson, LearnNotifier notifier) {
    return GlassCard(
      onTap: () => _openLessonDetailModal(context, lesson),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: AppColors.primaryGold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.summary,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.primaryGold),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.estimatedMinutes} mins',
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryGold),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${lesson.steps.length} Steps',
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              lesson.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: lesson.isBookmarked ? AppColors.primaryGold : Colors.white38,
            ),
            onPressed: () => notifier.toggleBookmark(lesson.id),
          ),
        ],
      ),
    );
  }

  void _openLessonDetailModal(BuildContext context, ChessLesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lesson.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.summary,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
                ),
                const Divider(color: Colors.white12, height: 32),

                ...lesson.steps.map((step) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          step.description,
                          style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
                        ),
                        if (step.quiz != null) ...[
                          const SizedBox(height: 12),
                          _QuizWidget(quiz: step.quiz!),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}

class _QuizWidget extends StatefulWidget {
  final QuizQuestion quiz;

  const _QuizWidget({required this.quiz});

  @override
  State<_QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<_QuizWidget> {
  int? _selectedIndex;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('KNOWLEDGE QUIZ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
          const SizedBox(height: 6),
          Text(widget.quiz.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
          const SizedBox(height: 12),
          ...List.generate(widget.quiz.options.length, (index) {
            final opt = widget.quiz.options[index];
            final isCorrect = index == widget.quiz.correctIndex;
            final isSelected = _selectedIndex == index;

            Color tileColor = Colors.white10;
            if (_submitted) {
              if (isCorrect) tileColor = Colors.green.withOpacity(0.3);
              if (isSelected && !isCorrect) tileColor = Colors.red.withOpacity(0.3);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: _submitted ? null : () => setState(() => _selectedIndex = index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? AppColors.primaryGold : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        size: 18,
                        color: isSelected ? AppColors.primaryGold : Colors.white38,
                      ),
                      const SizedBox(width: 10),
                      Text(opt, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_selectedIndex != null && !_submitted)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: () => setState(() => _submitted = true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
                child: const Text('Submit Answer'),
              ),
            ),
          if (_submitted)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.quiz.explanation,
                style: TextStyle(
                  color: _selectedIndex == widget.quiz.correctIndex ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

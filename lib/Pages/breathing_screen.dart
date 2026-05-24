import 'package:flutter/material.dart';

import '../Animations/breathing_cloud.dart';
import '../core/constants/app_constants.dart';
import '../core/models/breathing_technique.dart';
import '../core/widgets/common_widgets.dart';
import '../core/utils/navigation_utils.dart';
import 'audio_screen.dart';
import 'finish_screen.dart';

class BreathingScreen extends StatefulWidget {
  final DateTime startTime;

  const BreathingScreen({super.key, required this.startTime});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  BreathingTechnique _technique = BreathingTechnique.all[1]; // 4-7-8 по умолчанию
  String _phaseText = 'Вдох';

  void _selectTechnique(BreathingTechnique t) {
    setState(() {
      _technique = t;
      _phaseText = t.phases[0].name;
    });
  }

  void _onPhaseChanged(String name) {
    setState(() => _phaseText = name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Горизонтальный список техник
            _TechniqueSelector(
              selected: _technique,
              onSelected: _selectTechnique,
            ),

            const SizedBox(height: 8),

            // Динамические фазы выбранной техники
            _BreathingPhases(technique: _technique),

            const SizedBox(height: 8),

            // Текущая фаза
            Text(_phaseText, style: AppTextStyles.bodyLarge),

            const Spacer(),

            // Анимация (облако или коробка — зависит от техники)
            BreathingCloud(
              key: ValueKey(_technique.id),
              technique: _technique,
              onPhaseChanged: _onPhaseChanged,
            ),

            const Spacer(),

            // Кнопки навигации
            _NavigationButtons(startTime: widget.startTime),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Горизонтальный выбор техники ─────────────────────────────────────────────

class _TechniqueSelector extends StatelessWidget {
  final BreathingTechnique selected;
  final Function(BreathingTechnique) onSelected;

  const _TechniqueSelector({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: BreathingTechnique.all.length,
        itemBuilder: (context, index) {
          final t = BreathingTechnique.all[index];
          final isActive = t.id == selected.id;

          return GestureDetector(
            onTap: () => onSelected(t),
            child: Container(
              width: 82,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color:
                    isActive ? AppColors.primaryDark.withOpacity(0.1) : Colors.white,
                border: Border.all(
                  color: isActive ? AppColors.primaryDark : Colors.grey.shade300,
                  width: isActive ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Text(
                    t.cardTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? AppColors.primaryDark
                          : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Индикатор фаз ────────────────────────────────────────────────────────────

class _BreathingPhases extends StatelessWidget {
  final BreathingTechnique technique;

  const _BreathingPhases({required this.technique});

  @override
  Widget build(BuildContext context) {
    final compact = technique.phases.length > 3;
    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.06,
        ),
        child: Row(
          children: _buildCells(compact),
        ),
      ),
    );
  }

  List<Widget> _buildCells(bool compact) {
    final List<Widget> rows = [];
    for (int i = 0; i < technique.phases.length; i++) {
      if (i > 0) {
        rows.add(const VerticalDivider(
          color: AppColors.textPrimary,
          thickness: 2.0,
          indent: 18,
          endIndent: 10,
        ));
      }
      rows.add(Expanded(
        child: _PhaseCell(
          seconds: technique.phases[i].durationSeconds,
          label: technique.phases[i].name,
          compact: compact,
        ),
      ));
    }
    return rows;
  }
}

class _PhaseCell extends StatelessWidget {
  final int seconds;
  final String label;
  final bool compact;

  const _PhaseCell({
    required this.seconds,
    required this.label,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$seconds',
          style: TextStyle(
            fontSize: compact ? 16 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'сек',
          style: TextStyle(fontSize: compact ? 9 : 10),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 10 : 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── Кнопки навигации ─────────────────────────────────────────────────────────

class _NavigationButtons extends StatelessWidget {
  final DateTime startTime;

  const _NavigationButtons({required this.startTime});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppElevatedButton(
          text: 'Далее',
          widthRatio: AppSizes.buttonWidthRatio,
          onPressed: () => NavigationUtils.navigateToScreen(
            context,
            AudioScreen(startTime: startTime),
          ),
        ),
        AppTextButton(
          text: 'Завершить сеанс',
          onPressed: () => NavigationUtils.navigateToScreen(
            context,
            FinishScreen(startTime: startTime),
          ),
        ),
      ],
    );
  }
}

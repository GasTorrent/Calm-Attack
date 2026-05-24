import 'package:flutter/foundation.dart';

enum BreathingAnimationType { cloud, box }

enum PhaseDirection { expand, hold, contract }

@immutable
class BreathingPhase {
  final String name;
  final int durationSeconds;
  final PhaseDirection direction;
  final double? targetValue;

  const BreathingPhase({
    required this.name,
    required this.durationSeconds,
    required this.direction,
    this.targetValue,
  });

  double get effectiveTargetValue {
    if (targetValue != null) return targetValue!;
    return direction == PhaseDirection.expand ? 1.0 : 0.0;
  }
}

@immutable
class BreathingTechnique {
  final String id;
  final String name;
  final String cardTitle;
  final String description;
  final List<BreathingPhase> phases;
  final BreathingAnimationType animationType;

  const BreathingTechnique({
    required this.id,
    required this.name,
    required this.cardTitle,
    required this.description,
    required this.phases,
    this.animationType = BreathingAnimationType.cloud,
  });

  int get totalCycleDuration =>
      phases.fold(0, (sum, phase) => sum + phase.durationSeconds);

  static const List<BreathingTechnique> all = [
    BreathingTechnique(
      id: 'diaphragm',
      name: 'Диафрагмальное',
      cardTitle: 'Диафрагм.',
      description: 'Дышите животом — базовая техника',
      phases: [
        BreathingPhase(
            name: 'Вдох',
            durationSeconds: 4,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Выдох',
            durationSeconds: 4,
            direction: PhaseDirection.contract),
      ],
    ),
    BreathingTechnique(
      id: '478',
      name: 'Дыхание 4-7-8',
      cardTitle: '4 · 7 · 8',
      description: 'Классика для быстрого успокоения нервной системы',
      phases: [
        BreathingPhase(
            name: 'Вдох',
            durationSeconds: 4,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Задержка',
            durationSeconds: 7,
            direction: PhaseDirection.hold),
        BreathingPhase(
            name: 'Выдох',
            durationSeconds: 8,
            direction: PhaseDirection.contract),
      ],
    ),
    BreathingTechnique(
      id: 'box',
      name: 'Коробочное',
      cardTitle: '4·4·4·4',
      description: 'Метод Navy SEALs — визуализируй квадрат',
      phases: [
        BreathingPhase(
            name: 'Вдох',
            durationSeconds: 4,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Задержка',
            durationSeconds: 4,
            direction: PhaseDirection.hold),
        BreathingPhase(
            name: 'Выдох',
            durationSeconds: 4,
            direction: PhaseDirection.contract),
        BreathingPhase(
            name: 'Пауза',
            durationSeconds: 4,
            direction: PhaseDirection.hold),
      ],
      animationType: BreathingAnimationType.box,
    ),
    BreathingTechnique(
      id: 'coherent',
      name: 'Когерентное',
      cardTitle: '5 · 5',
      description: 'Синхронизирует ритм сердца — 6 циклов в минуту',
      phases: [
        BreathingPhase(
            name: 'Вдох',
            durationSeconds: 5,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Выдох',
            durationSeconds: 5,
            direction: PhaseDirection.contract),
      ],
    ),
    BreathingTechnique(
      id: 'extended',
      name: 'Удлинённый выдох',
      cardTitle: '4 · 8',
      description: 'Выдох в 2 раза длиннее — стимулирует блуждающий нерв',
      phases: [
        BreathingPhase(
            name: 'Вдох',
            durationSeconds: 4,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Выдох',
            durationSeconds: 8,
            direction: PhaseDirection.contract),
      ],
    ),
    BreathingTechnique(
      id: 'nadi',
      name: 'Нади Шодхана',
      cardTitle: 'Ноздри',
      description: 'Поочерёдное дыхание через ноздри — баланс полушарий',
      phases: [
        BreathingPhase(
            name: 'Вдох (лев.)',
            durationSeconds: 4,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Выдох (пр.)',
            durationSeconds: 4,
            direction: PhaseDirection.contract),
        BreathingPhase(
            name: 'Вдох (пр.)',
            durationSeconds: 4,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Выдох (лев.)',
            durationSeconds: 4,
            direction: PhaseDirection.contract),
      ],
    ),
    BreathingTechnique(
      id: 'lion',
      name: 'Дыхание льва',
      cardTitle: 'Лев',
      description: 'Снимает мышечное напряжение лица и шеи',
      phases: [
        BreathingPhase(
            name: 'Вдох через нос',
            durationSeconds: 4,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Выдох «Хааа»',
            durationSeconds: 3,
            direction: PhaseDirection.contract),
      ],
    ),
    BreathingTechnique(
      id: 'straw',
      name: 'Соломинка',
      cardTitle: 'Соломинка',
      description: 'Выдыхай через сложенные трубочкой губы',
      phases: [
        BreathingPhase(
            name: 'Вдох через нос',
            durationSeconds: 4,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Выдох-соломинка',
            durationSeconds: 8,
            direction: PhaseDirection.contract),
      ],
    ),
    BreathingTechnique(
      id: 'sigh',
      name: 'Физ. вздох',
      cardTitle: 'Физ.вздох',
      description: 'Самая быстрая техника, исследована в Стэнфорде',
      phases: [
        BreathingPhase(
            name: 'Вдох',
            durationSeconds: 2,
            direction: PhaseDirection.expand,
            targetValue: 0.75),
        BreathingPhase(
            name: 'Добирающий вдох',
            durationSeconds: 1,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Долгий выдох',
            durationSeconds: 6,
            direction: PhaseDirection.contract),
      ],
    ),
    BreathingTechnique(
      id: '4462',
      name: 'Дыхание 4-4-6-2',
      cardTitle: '4·4·6·2',
      description: 'Мягче, чем 4-7-8 — легче переносить задержку',
      phases: [
        BreathingPhase(
            name: 'Вдох',
            durationSeconds: 4,
            direction: PhaseDirection.expand),
        BreathingPhase(
            name: 'Задержка',
            durationSeconds: 4,
            direction: PhaseDirection.hold),
        BreathingPhase(
            name: 'Выдох',
            durationSeconds: 6,
            direction: PhaseDirection.contract),
        BreathingPhase(
            name: 'Пауза',
            durationSeconds: 2,
            direction: PhaseDirection.hold),
      ],
    ),
  ];
}

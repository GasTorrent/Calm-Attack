import 'dart:ui' show BlurStyle, MaskFilter;

import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/models/breathing_technique.dart';

class BreathingCloud extends StatefulWidget {
  final BreathingTechnique technique;
  final Function(String) onPhaseChanged;

  const BreathingCloud({
    super.key,
    required this.technique,
    required this.onPhaseChanged,
  });

  @override
  State<BreathingCloud> createState() => _BreathingCloudState();
}

class _BreathingCloudState extends State<BreathingCloud>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentPhaseIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startTechnique();
    });
  }

  void _startTechnique() {
    if (widget.technique.animationType == BreathingAnimationType.box) {
      _startBoxAnimation();
    } else {
      _startPhase(0);
    }
  }

  void _startBoxAnimation() {
    _controller.duration =
        Duration(seconds: widget.technique.totalCycleDuration);
    _controller.value = 0.0;
    _currentPhaseIndex = 0;
    widget.onPhaseChanged(widget.technique.phases[0].name);
    _controller.addListener(_onBoxTick);
    _controller.repeat();
  }

  void _onBoxTick() {
    if (!mounted) return;
    final numPhases = widget.technique.phases.length;
    final newIndex =
        (_controller.value * numPhases).floor().clamp(0, numPhases - 1);
    if (newIndex != _currentPhaseIndex) {
      setState(() => _currentPhaseIndex = newIndex);
      widget.onPhaseChanged(widget.technique.phases[newIndex].name);
    }
  }

  void _startPhase(int absoluteIndex) {
    if (!mounted) return;
    final phases = widget.technique.phases;
    final idx = absoluteIndex % phases.length;
    final phase = phases[idx];

    setState(() => _currentPhaseIndex = idx);
    widget.onPhaseChanged(phase.name);

    final dur = Duration(seconds: phase.durationSeconds);

    if (phase.direction == PhaseDirection.hold) {
      Future.delayed(dur, () {
        if (mounted) _startPhase(absoluteIndex + 1);
      });
    } else {
      _controller
          .animateTo(
            phase.effectiveTargetValue,
            duration: dur,
            curve: Curves.easeInOut,
          )
          .whenComplete(() {
        if (mounted) _startPhase(absoluteIndex + 1);
      });
    }
  }

  String get _cloudImagePath {
    final phases = widget.technique.phases;
    if (_currentPhaseIndex >= phases.length) return AppImages.inhaleImage;
    switch (phases[_currentPhaseIndex].direction) {
      case PhaseDirection.expand:
        return AppImages.inhaleImage;
      case PhaseDirection.hold:
        return AppImages.holdImage;
      case PhaseDirection.contract:
        return AppImages.exhaleImage;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onBoxTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.technique.animationType == BreathingAnimationType.box) {
      return _buildBoxAnimation();
    }
    return _buildCloudAnimation();
  }

  Widget _buildCloudAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final size = 100.0 + _controller.value * 100.0;
        return SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Image.asset(_cloudImagePath),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoxAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: _BoxPainter(progress: _controller.value),
          ),
        );
      },
    );
  }
}

class _BoxPainter extends CustomPainter {
  final double progress;

  const _BoxPainter({required this.progress});

  static const List<Color> _phaseColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const numPhases = 4;
    final phaseIdx = (progress * numPhases).floor().clamp(0, numPhases - 1);
    final withinPhase = (progress * numPhases) - phaseIdx;

    const padding = 24.0;
    final sideLen = size.width - padding * 2;
    final rect = Rect.fromLTWH(padding, padding, sideLen, sideLen);

    // Draw background fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(8), const Radius.circular(16)),
      Paint()..color = const Color(0xFFF0F4FF),
    );

    // Corners ordered clockwise: TL, TR, BR, BL
    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ];
    final nextCorners = [
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
      rect.topLeft,
    ];

    // Draw each side with its phase colour
    for (int i = 0; i < numPhases; i++) {
      final isActive = i == phaseIdx;
      canvas.drawLine(
        corners[i],
        nextCorners[i],
        Paint()
          ..color = _phaseColors[i].withOpacity(isActive ? 1.0 : 0.25)
          ..strokeWidth = isActive ? 4.0 : 2.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // Animated dot
    final start = corners[phaseIdx];
    final end = nextCorners[phaseIdx];
    final dotPos = Offset(
      start.dx + (end.dx - start.dx) * withinPhase,
      start.dy + (end.dy - start.dy) * withinPhase,
    );
    final activeColor = _phaseColors[phaseIdx];

    // Glow layer
    canvas.drawCircle(
      dotPos,
      16,
      Paint()
        ..color = activeColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Dot fill
    canvas.drawCircle(dotPos, 10, Paint()..color = activeColor);

    // Dot border
    canvas.drawCircle(
      dotPos,
      10,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_BoxPainter old) => old.progress != progress;
}

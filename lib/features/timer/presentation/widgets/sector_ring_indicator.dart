import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedSectorRing extends StatefulWidget {
  final bool isActive;
  final double calX;
  final double calY;
  final bool isDebouncing;
  final double targetAngle;
  final int debounceMs;
  final Color color;
  final double size;

  const AnimatedSectorRing({
    super.key,
    this.isActive = true,
    required this.calX,
    required this.calY,
    required this.isDebouncing,
    required this.targetAngle,
    required this.debounceMs,
    required this.color,
    this.size = 270.0,
  });

  @override
  State<AnimatedSectorRing> createState() => _AnimatedSectorRingState();
}

class _AnimatedSectorRingState extends State<AnimatedSectorRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _debounceController;
  
  double _continuousAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _debounceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.debounceMs),
    );
    if (widget.isDebouncing) {
      _debounceController.forward();
    }
    _continuousAngle = widget.isDebouncing ? widget.targetAngle : atan2(widget.calY, -widget.calX);
  }

  @override
  void didUpdateWidget(covariant AnimatedSectorRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.debounceMs != oldWidget.debounceMs) {
      _debounceController.duration = Duration(milliseconds: widget.debounceMs);
    }

    if (widget.isDebouncing && !oldWidget.isDebouncing) {
      _debounceController.forward(from: 0.0);
    } else if (!widget.isDebouncing && oldWidget.isDebouncing) {
      // Smoothly shrink back when cancelled instead of snapping
      _debounceController.animateBack(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    
    _updateContinuousAngle();
  }
  
  void _updateContinuousAngle() {
    double target;
    if (widget.isDebouncing) {
      target = widget.targetAngle;
    } else {
      target = atan2(widget.calY, -widget.calX);
    }
    
    // Shortest-path angle interpolation to prevent wrap-around spinning
    double diff = (target - _continuousAngle) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    _continuousAngle += diff;
  }

  @override
  void dispose() {
    _debounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final magnitude = sqrt(widget.calX * widget.calX + widget.calY * widget.calY);
    final isFlat = magnitude < 1.0;
    
    final targetOpacity = (!widget.isActive || (isFlat && !widget.isDebouncing)) ? 0.0 : 1.0;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: _continuousAngle),
      builder: (context, animAngle, _) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0.0, end: targetOpacity),
          builder: (context, animOpacity, _) {
            return AnimatedBuilder(
              animation: _debounceController,
              builder: (context, _) {
                return SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: _SectorPainter(
                      angle: animAngle,
                      debounceProgress: _debounceController.value,
                      opacity: animOpacity,
                      color: widget.color,
                    ),
                  ),
                );
              },
            );
          }
        );
      },
    );
  }
}

class _SectorPainter extends CustomPainter {
  final double angle;
  final double debounceProgress; // 0.0 to 1.0
  final double opacity;
  final Color color;

  _SectorPainter({
    required this.angle,
    required this.debounceProgress,
    required this.opacity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;

    final center = Offset(size.width / 2, size.height / 2);
    // Extra padding to avoid clipping the glow effect
    final baseRadius = (size.width - 24) / 2;
    // Elegant scale effect based on opacity
    final radius = baseRadius * (0.85 + 0.15 * Curves.easeOutCubic.transform(opacity));

    // Minimalist, elegant base sweep and expansion
    final baseSweep = pi / 6; // Slightly larger for better gradient visibility
    final maxSweep = pi / 2.2;
    // When fading in/out, also animate the sweep slightly for a "drawing" effect
    final sweepMultiplier = 0.5 + 0.5 * Curves.easeOutQuint.transform(opacity);
    final currentSweep = (baseSweep + (maxSweep - baseSweep) * debounceProgress) * sweepMultiplier;
    final startAngle = angle - (currentSweep / 2);

    // Refined stroke widths for a professional, sharp look
    final baseStrokeWidth = 2.0;
    final expandedStrokeWidth = 3.5;
    final currentStrokeWidth = baseStrokeWidth + (expandedStrokeWidth - baseStrokeWidth) * debounceProgress;

    // Faint full-ring background to ground the design
    final bgRingPaint = Paint()
      ..color = color.withOpacity(opacity * 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawCircle(center, radius, bgRingPaint);

    final sweepFraction = currentSweep / (2 * pi);
    
    // Sweep gradient for smooth fading edges (tapered comet-like effect)
    final sweepGradient = SweepGradient(
      center: Alignment.center,
      transform: GradientRotation(startAngle),
      colors: [
        color.withOpacity(0.0),
        color.withOpacity(opacity * 0.8),
        color.withOpacity(opacity * 1.0),
        color.withOpacity(0.0),
        color.withOpacity(0.0), // Padding for the rest of the circle
      ],
      stops: [
        0.0,
        sweepFraction * 0.2, // Fade in over first 20% of the arc
        sweepFraction * 0.8, // Fade out over last 20% of the arc
        sweepFraction,
        1.0,
      ],
    );

    final gradientShader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius));

    // Outer glow - softer and wider
    final glowPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = currentStrokeWidth * 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    // Solid active sweep line
    final activePaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = currentStrokeWidth;

    // Draw Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      glowPaint,
    );

    // Draw Active
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      activePaint,
    );
    
    // Core highlight - a sharp white accent in the exact center of the arc
    // Adds a premium "glass" or "luminous" feel
    final highlightOpacity = opacity * (0.3 + 0.7 * debounceProgress);
    final highlightSweep = pi / 48; // Very small sharp center
    final highlightStart = angle - (highlightSweep / 2);
    
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(highlightOpacity)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = currentStrokeWidth * 0.6; // Slightly thinner than main stroke
      
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      highlightStart,
      highlightSweep,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SectorPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.debounceProgress != debounceProgress ||
        oldDelegate.opacity != opacity ||
        oldDelegate.color != color;
  }
}

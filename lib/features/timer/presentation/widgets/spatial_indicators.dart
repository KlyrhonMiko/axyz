import 'package:flutter/material.dart';

class EdgeDotIndicator extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final bool isActive;

  const EdgeDotIndicator({
    super.key,
    required this.alignment,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(24.0),
          width: isActive ? 14.0 : 6.0,
          height: isActive ? 14.0 : 6.0,
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class CenterGlowIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const CenterGlowIndicator({
    super.key,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isActive ? 1.0 : 0.0,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}

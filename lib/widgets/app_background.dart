import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.scaffoldBackgroundColor;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final tertiary = theme.colorScheme.tertiary;

    final softBlend = Color.lerp(base, secondary, 0.18) ?? base;
    final deepBlend = Color.lerp(base, primary, 0.08) ?? base;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [base, softBlend, deepBlend],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -60,
            child: _BlurOrb(color: primary.withValues(alpha: 0.12), size: 200),
          ),
          Positioned(
            top: 120,
            right: -80,
            child: _BlurOrb(color: secondary.withValues(alpha: 0.16), size: 220),
          ),
          Positioned(
            bottom: -100,
            left: 40,
            child: _BlurOrb(color: tertiary.withValues(alpha: 0.18), size: 180),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

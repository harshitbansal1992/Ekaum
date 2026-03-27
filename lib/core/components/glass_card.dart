import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? frostColor;
  final double blurAmount;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20,
    this.onTap,
    this.frostColor,
    this.blurAmount = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = frostColor ?? Colors.white;
    final cardOpacity = isDark ? 0.24 : 0.40;
    final borderOpacity = isDark ? 0.34 : 0.50;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: baseColor.withOpacity(cardOpacity),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: baseColor.withOpacity(borderOpacity),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.20 : 0.05),
                    blurRadius: isDark ? 16 : 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

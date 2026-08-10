import 'package:flutter/material.dart';

class LabelChip extends StatelessWidget {
  const LabelChip({required this.label, required this.color, super.key});

  const LabelChip.cacheHit({super.key})
      : label = 'cache hit',
        color = const Color(0xFFFFF3C4);

  const LabelChip.slow({super.key})
      : label = 'slow',
        color = const Color(0xFFFFD9D9);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

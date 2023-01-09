import 'package:flutter/material.dart';

class ChipData {
  final String name;
  final Color color;
  final int id;

  const ChipData({
    required this.name,
    required this.color,
    required this.id,
  });

  ChipData copy({
    String? name,
    Color? color,
    int? id,
  }) =>
      ChipData(
        name: name ?? this.name,
        color: color ?? this.color,
        id: id ?? this.id,
      );

}

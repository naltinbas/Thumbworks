import 'package:flutter/material.dart';

/// The field's colours: warm faces at a dark table, each clink
/// count wearing its own tint so alike counts look alike.
class Palette {
  static const night = Color(0xFF171310);
  static const board = Color(0xFF241E17);

  static const ink = Color(0xFFEEE7DA);
  static const inkDim = Color(0xFFA79C8B);

  static const line = Color(0xFF453729);
  static const faint = Color(0xFF322A20);
  static const face = Color(0xFFE3D3B2);
  static const faceRim = Color(0xFF6E7562);
  static const wire = Color(0xFF9C8455);

  /// One tint per clink count, nought to four.
  static const tints = [
    Color(0xFF9BA48E),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
    Color(0xFFE0BE52),
    Color(0xFFC4614C),
  ];

  static const shown = Color(0xFF64B5F6);
  static const good = Color(0xFF81C784);
  static const bad = Color(0xFFE57373);
}

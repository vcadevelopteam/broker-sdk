import 'package:flutter/material.dart';

/*
Class that allow the conversion of HTML Colors to a custom format
 */
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    } else if (hexColor.length == 3) {
      hexColor = hexColor * 2;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

import 'package:flutter/material.dart';

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets contentPadding = EdgeInsets.all(xl);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  static const EdgeInsets actionPadding = EdgeInsets.only(right: sm);
  static const EdgeInsets actionPaddingLast = EdgeInsets.only(right: md);

  static const EdgeInsets listPadding = EdgeInsets.all(lg);
  static const EdgeInsets searchResultsPadding = EdgeInsets.fromLTRB(lg, md, lg, xl - xxs);
}

class AppRadii {
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

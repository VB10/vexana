import 'package:flutter/rendering.dart';

class PagePadding extends EdgeInsets {
  const PagePadding.all() : super.all(20);

  const PagePadding.vertical() : super.symmetric(vertical: 20);
  const PagePadding.horizontal() : super.symmetric(horizontal: 20);
}

import 'package:flutter/material.dart';

bool isWeb(BuildContext context) {
  return MediaQuery.of(context).size.width > 800;
}

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width <= 800;
}

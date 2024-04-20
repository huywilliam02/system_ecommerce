import 'package:flutter/material.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';

ThemeData dark({Color color = const Color(0xFF54b46b)}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color(0xFF009f67),
  disabledColor: const Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: const Color(0xFF30313C),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)), colorScheme: ColorScheme.dark(primary: color, secondary: color).copyWith(background: const Color(0xFF191A26)).copyWith(error: const Color(0xFFdd3135)),
);

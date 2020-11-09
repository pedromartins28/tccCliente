import 'package:flutter/material.dart';

ThemeData buildTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    primaryColor: Colors.red[500],
    backgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      color: Colors.red[200],
      textTheme: TextTheme(
        headline6: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red[500],
          fontSize: 20,
        ),
      ),
      iconTheme: IconThemeData(color: Colors.red[500]),
    ),
    //secondaryHeaderColor: const Color(),
    //backgroundColor: Color(0xfff1f8e9),
    accentColor: Colors.red[500],
    buttonColor: Colors.red[500],
    //hintColor: Colors.white,
  );
}

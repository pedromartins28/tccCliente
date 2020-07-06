import 'package:flutter/material.dart';

ThemeData buildTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    primaryColor: Color(0xff80c080),
    backgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      color: Colors.white,
      textTheme: TextTheme(
        title: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xff80c080),
          fontSize: 20,
        ),
      ),
      iconTheme: IconThemeData(color: Color(0xff80c080)),
    ),
    //secondaryHeaderColor: const Color(),
    //backgroundColor: Color(0xfff1f8e9),
    accentColor: Color(0xff80c080),
    buttonColor: Color(0xff80c080),
    //hintColor: Colors.white,
  );
}

import 'package:flutter/material.dart';

final themeData = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.lightBlue[800],
  fontFamily: 'Georgia',

  textTheme: const TextTheme(
    headline1: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
    headline4: TextStyle(fontSize: 16.0),
    headline6: TextStyle(fontSize: 25.0, fontStyle: FontStyle.italic),
    bodyText2: TextStyle(fontSize: 12.0, fontFamily: 'Hind'),
  ),
);



import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class GuardadoLocal{
  static var prefs;

  static var colores = [];

  static inicializar() async
  {
    await SharedPreferences.getInstance().then((e){
      prefs = e;
    })
    ;

  }

  static almacenarColores(Color primaryColor, Color backgroundColor, Color textColor) async
  {
    await prefs.setString('PrimaryColor', primaryColor.toString());
    await prefs.setString('BackgroundColor', backgroundColor.toString());
    await prefs.setString('TextColor', textColor.toString());
  }

  static eliminarColores() async
  {
      await prefs.remove('PrimaryColor');
      await prefs.remove('BackgroundColor');
      await prefs.remove('TextColor');
  }
}
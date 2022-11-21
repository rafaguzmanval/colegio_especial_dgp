

import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class GuardadoLocal{
  static var prefs;

  static inicializar() async
  {
    await SharedPreferences.getInstance().then((e){
      prefs = e;
      cambiarColor();
    })
    ;

  }

  static cambiarColor()
  {
    // se busca si existe almacenada una variable 'color' que es un string
    var ultimoColor = prefs.getString('color');
    print(ultimoColor);

    // Se vuelve a cambiar para que la proxima vez que se cargue la aplicación haya un nuevo valor
    ultimoColor = Random().nextInt(50).toString();
    prefs.setString('color',ultimoColor);
    print(ultimoColor);
  }
}
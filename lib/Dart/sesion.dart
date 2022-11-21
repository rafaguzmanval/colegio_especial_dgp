/*
*   Archivo: sesion.dart
*
*   Descripción:
*   Clase para guardar los datos de la sesión actual del dispositivo.
*
*   Includes:
*   passport_method.dart : Contiene el enum que indica el tipo de contraseña que va a usarse (clave, pin,...)
* */

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:colegio_especial_dgp/Dart/passport_method.dart';
import 'package:flutter/material.dart';

class Sesion {
  static var id;
  static var credenciales;
  static var nombre;
  static var rol;
  static var foto;
  static var tareas;
  static var tablon;
  static var seleccion;
  static var paginaActual;
  static var metodoLogin = "";
  static var argumentos = [];
  static var db;
  static var colores = [];

  /*******************TEMPORAL******************/
  static Map<int, Color> color = {
    50: Color.fromRGBO(143, 125, 178, .1),
    100: Color.fromRGBO(143, 125, 178, .2),
    200: Color.fromRGBO(143, 125, 178, .3),
    300: Color.fromRGBO(143, 125, 178, .4),
    400: Color.fromRGBO(143, 125, 178, .5),
    500: Color.fromRGBO(143, 125, 178, .6),
    600: Color.fromRGBO(143, 125, 178, .7),
    700: Color.fromRGBO(143, 125, 178, .8),
    800: Color.fromRGBO(143, 125, 178, .9),
    900: Color.fromRGBO(143, 125, 178, 1),
  };
  /*******************TEMPORAL******************/

  // Sesion por defecto
  static reload() {
    id = null;
    nombre = null;
    rol = null;
    tareas = [];
    seleccion = null;
    tablon = [];
    /*******************TEMPORAL******************/
    colores = [MaterialColor(Color.fromRGBO(143, 125, 178, 1).value, color),Colors.white,Colors.white];
    //colores = [Colors.green,Colors.black,Colors.black];
    /*******************TEMPORAL******************/
  }

  // Constructor por defecto
  Sesion() {
    id = null;
    nombre = null;
    rol = null;
    tareas = [];
    tablon = [];
    seleccion = null;
    /*******************TEMPORAL******************/
    colores = [MaterialColor(Color.fromRGBO(143, 125, 178, 1).value, color),Colors.white,Colors.white];
    //colores = [Colors.green,Colors.black,Colors.black];
    /*******************TEMPORAL******************/
  }
}

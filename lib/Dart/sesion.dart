/*
*   Archivo: sesion.dart
*
*   Descripción:
*   Clase para guardar los datos de la sesión actual del dispositivo.
*
*   Includes:
*   passport_method.dart : Contiene el enum que indica el tipo de contraseña que va a usarse (clave, pin,...)
* */

import 'package:colegio_especial_dgp/Dart/passport_method.dart';

class Sesion {
  static var id;
  static var credenciales;
  static var nombre;
  static var rol;
  static var tareas;
  static var seleccion;
  static var paginaActual;
  static var metodoLogin = "";

  // Sesion por defecto
  static reload() {
    id = null;
    nombre = null;
    rol = null;
    tareas = [];
    seleccion = null;
  }

  // Constructor por defecto
  Sesion() {
    id = null;
    nombre = null;
    rol = null;
    tareas = [];
    seleccion = null;
  }
}

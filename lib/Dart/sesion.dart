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
import 'package:colegio_especial_dgp/Dart/acceso_bd_firebase.dart';
import 'package:colegio_especial_dgp/Dart/passport_method.dart';
import 'package:flutter/material.dart';

class Sesion {
  static var id;
  static var credenciales;
  static var nombre;
  static var rol;
  static var foto;
  static var alumnos;
  static var profesores;
  static var tareas;
  static var tablon;
  static var seleccion;
  static var paginaActual;
  static var paginaChats;
  static var paginaChat;
  static var metodoLogin = "";
  static var argumentos = [];
  static AccesoBDFirebase db = new AccesoBDFirebase();
  static var posicion;
  static var chats = [];

  // Sesion por defecto
  static reload() {
    id = null;
    nombre = null;
    rol = null;
    tareas = [];
    seleccion = null;
    tablon = [];
  }

  // Constructor por defecto
  Sesion() {
    id = null;
    nombre = null;
    rol = null;
    tareas = [];
    tablon = [];
    seleccion = null;
  }
}

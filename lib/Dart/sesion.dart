
import 'package:colegio_especial_dgp/Dart/passport_method.dart';

class Sesion{
   static var id;
   static var credenciales;
   static var nombre;
   static var rol;
   static var tareas;
   static var seleccion;
   static var paginaActual;
   static var metodoLogin = "";

   static reload(){
      id = null;
      nombre = null;
      rol = null;
      tareas = [];
      seleccion = null;

   }

   Sesion(){
      id = null;
      nombre = null;
      rol = null;
      tareas = [];
      seleccion = null;
   }
}
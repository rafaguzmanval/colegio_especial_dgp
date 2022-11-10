import 'package:colegio_especial_dgp/Dart/firebase_options.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:colegio_especial_dgp/Dart/tarea.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';
import 'package:colegio_especial_dgp/Dart/aula.dart';
import 'package:firebase_core/firebase_core.dart';

void main () {

  /*###################### Usuario ########################################*/

  group ('Usuario', () {
    test ('Se debería crear con los valores establecidos', () async {
      var usuario = new Usuario();
      usuario.setUsuario("NombreP", "ApellidosP", "1234", "01/01/1990", "Profesor", null,null);

      expect ( usuario.nombre, "NombreP");
      expect ( usuario.apellidos , "ApellidosP");
      expect ( usuario.password , "1234");
      expect ( usuario.fechanacimiento , "01/01/1990");
      expect ( usuario.rol , "Profesor");
    });
  });

  /*###################### Clase ########################################*/
  group ('Clase', () {
    test ('Se debería crear con los valores establecidos', () async {
      var profesor = new Usuario();
      profesor.setUsuario("NombreP", "ApellidosP", "1234", "01/01/1990", "Profesor", null,null);

      var alumno = new Usuario();
      alumno.setUsuario("NombreA", "ApellidosA", "2345", "01/01/2005", "Alumno", null,null);

      var clase = new Aula("Prueba",[profesor],[alumno]);

      expect ( clase.nombreClase , "Prueba");
      expect ( clase.profesores[0] , profesor);
      expect ( clase.alumnos[0] , alumno);
    });
  });

  /*###################### Tareas ########################################*/
  group('Tarea',(){
    test ('Se debería crear con los valores establecidos', () async {
      var tarea = new Tarea();
      tarea.setTarea("EjemploTarea", "Tarea de ejemplo", null, null, []);

      expect ( tarea.nombre , "EjemploTarea");
      expect ( tarea.textos , "Tarea de ejemplo");
    });
  });
  
}
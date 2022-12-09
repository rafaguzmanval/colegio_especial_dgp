/*
* Archivo: tarea.dart
*
* Descripción :
*               Esta clase se encarga de instanciar las tareas que están almacenadas en la base de datos para poder visualizar la información que poseen.
*               En principio una tarea dispone de texto, imágenes, vídeos y un orden de aparición
*
* Includes :
*   cloud_firestore.dart : Para que los métodos puedan acceder a la base de datos para leer las tareas.
* */

import 'package:cloud_firestore/cloud_firestore.dart';

class Historial {
  var id;
  var idUsuario;
  var nombre;
  var retroalimentacion;

  // Constructor
  Historial(
        this.id,
        this.nombre,
        this.retroalimentacion,
        this.idUsuario,
      );

  // Obtiene los datos de la base de datos y los inserta en el objeto
}

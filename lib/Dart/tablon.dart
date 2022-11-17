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

class Tablon {
  var id;
  var nombres;
  var imagenes;
  var tipos;

  // Constructor
  Tablon(
      {this.id,
        this.nombres,
        this.imagenes,
        this.tipos});

  // Obtiene los datos de la base de datos y los inserta en el objeto
  factory Tablon.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Tablon(
      nombres: data?['nombres'] is Iterable ? List.from(data?['nombres']) : null,
      imagenes:
      data?['imagenes'] is Iterable ? List.from(data?['imagenes']) : null,
      tipos: data?['tipos'] is Iterable ? List.from(data?['tipos']) : null,
    );
  }

  // Obtiene los datos del objeto y los inserta en la base de datos
  Map<String, dynamic> toFirestore() {
    return {
      if (nombres != null) "nombres": nombres,
      if (imagenes != null) "imagenes": imagenes,
      if (tipos != null) "tipos": tipos,
    };
  }

  // Modificar una tarea
  setTablon(nombres,imagenes, tipos) {
    this.nombres = nombres;
    this.imagenes = imagenes;
    this.tipos = tipos;
  }
}

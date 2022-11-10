

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


class Tarea{
  var id;
  var idRelacion;
  var nombre;
  var textos;
  var imagenes;
  var videos;
  var controladoresVideo = [];
  var orden;


  Tarea({
          this.id,
          this.nombre,
          this.textos,
          this.imagenes,
          this.videos,
          this.orden
  });


  factory Tarea.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Tarea(
      nombre: data?['nombre'],
      textos: data?['textos'] is Iterable ? List.from(data?['textos']) : null,
      imagenes: data?['imagenes'] is Iterable ? List.from(data?['imagenes']) : null,
      videos: data?['videos'] is Iterable ? List.from(data?['videos']) : null,
      orden: data?['orden'] is Iterable ? List.from(data?['orden']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
      if (textos != null) "textos": textos,
      if (imagenes != null) "imagenes": imagenes,
      if (videos != null) "videos": videos,
      if (orden != null) "orden": orden,

    };
  }

  setTarea(nombre,textos,imagenes,videos,orden)
  {
    this.nombre = nombre;
    this.textos = textos;
    this.imagenes = imagenes;
    this.videos = videos;
    this.orden = orden;

  }

}

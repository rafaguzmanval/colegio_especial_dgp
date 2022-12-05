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

class Tarea {
  var id;
  var idRelacion;
  var nombre;
  var descripcion;
  var imagen;
  var textos;
  var imagenes;
  var videos;
  var formularios;
  var controladoresVideo = [];
  var controladoresComandas = [];
  var estado;
  var fechafinal;
  var fechaentrega;
  var respuesta;
  var fotoRespuesta;
  var retroalimentacion;


  // Constructor
  Tarea(
      {this.id,
      this.nombre,
      this.descripcion,
      this.imagen,
      this.textos,
      this.imagenes,
      this.videos,
      this.formularios,
      });

  // Obtiene los datos de la base de datos y los inserta en el objeto
  factory Tarea.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Tarea(
      nombre: data?['nombre'],
      descripcion: data?['descripcion'],
      imagen: data?['imagen'],
      textos: data?['textos'] is Iterable ? List.from(data?['textos']) : null,
      imagenes:
          data?['imagenes'] is Iterable ? List.from(data?['imagenes']) : null,
      videos: data?['videos'] is Iterable ? List.from(data?['videos']) : null,
      formularios: data?['formularios'] is Iterable? List.from(data?['formularios']):null,
    );
  }

  // Obtiene los datos del objeto y los inserta en la base de datos
  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
      if (descripcion != null) "descripcion" : descripcion,
      if (imagen != null) "imagen" : imagen,
      if (textos != null) "textos": textos,
      if (imagenes != null) "imagenes": imagenes,
      if (videos != null) "videos": videos,
      if(formularios != null) "formularios" : formularios,
    };
  }

  // Modificar una tarea
  setTarea(nombre,descripcion,imagen, textos, imagenes, videos, formularios) {
    this.nombre = nombre;
    this.descripcion = descripcion;
    this.imagen = imagen;
    this.textos = textos;
    this.imagenes = imagenes;
    this.videos = videos;
    this.formularios = formularios;
  }
}

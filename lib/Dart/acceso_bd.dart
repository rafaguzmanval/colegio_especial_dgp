/*
*   Archivo: acceso_bd.dart
*
*   Descripción:
*   Realiza la comunicación con la base de datos del firebase y de storage de firebase. Fundamentalmente se accede a la información de los usuarios
*   y de las tareas. 
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   passport_method.dart : Contiene el enum que indica el tipo de contraseña que va a usarse (clave, pin,...)
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   tarea.dart : Contiene los métodos para convertir la información de la base de datos al objeto del modelo. 
*   usuario.dart : Contiene los métodos para convertir la información de la base de datos al objeto del modelo. 
*   firebase_storage.dart : Contiene los métodos para acceder al almacenamiento de archivos del servidor. 
*   crypto.dart : Contiene los métodos para realizar encriptación en Sha256 de los datos.
*   video_player.dart : Necesario para cargar los videos del storage y cargarlos en el controlador de los reproductores de video. 
* */

//region imports
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/tablon.dart';
import 'package:colegio_especial_dgp/Dart/tarea.dart';
import 'package:colegio_especial_dgp/Dart/historialbd.dart';


import 'package:colegio_especial_dgp/Dart/usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'chat.dart';
import 'mensaje.dart';
//endregion

String encriptacionSha256(String password) {
  var data = utf8.encode(password);
  var hashvalue = sha256.convert(data);

  return hashvalue.toString();
}

abstract class AccesoBD {

  //region desactivacion de subscripciones
  //endregion

  //region Usuarios/Inicio de sesion
  // Metodo para registrar usuario
    Future<bool> registrarUsuario(Usuario usuario, String foto);

    // Metodo que comprueba la contraseña introducida con la guardada en la base de datos
    Future<bool> checkearPassword(id, password);

    //region Consultas
  // Metodo al que le pasas por parametro la id del usuario, comprueba si existe y te devuelve el objeto usuario
    consultarIDusuario(id) async {
    }

    // Metodo que te devuelve todos los usuarios de la base de datos
    consultarTodosUsuarios() async {
    }

    // Metodos que te devuelve todos los alumnos de la base de datos
    consultarTodosAlumnos() async {
    }

    // Metodo que te devuelve todos los profesores de la base de datos
    consultarTodosProfesores() async {
    }

    //endregion

    //region Edicion

    editarFotoUsuario(idUsuario,nuevaFoto) async{
    }

    editarApellidosUsuario(idUsuario,apellidos) async{
    }

    editarNombreUsuario(idUsuario,nombre) async{
    }

    editarNacimientoUsuario(idUsuario,fecha) async{
    }

    addFeedbackTarea(tarea,idUsuario, retroalimentacion) async {
    }
    //endregion

    //region Eliminacion

  Future eliminarAlumno(id) async {
  }

  Future eliminarProfesor(id) async {
  }

  //endregion

  //endregion

  //region Tareas

  //region Creacion
  // Metodo para crear una tarea
  crearTarea(tarea) async {
  }

  //endregion

  //region Consultas
  // Metodo que te devuelve todas las tareas del usuario
  consultarTodasLasTareas() async {
  }

  consultarTareasCompletas(id) async {
  }

  // Metodo que te devuelve la tarea segun el id de esta
  consultarIDTarea(id) async {

  }

  // Metodo para consultar las tareas asignadas a un usuario según el id pasado por parametro y te devuelve las tareas que tiene insertandolas en la
  // sesion

  consultarTareasAsignadasAlumno(id, completa) async {
  }

  //endregion

  //region Edicion
  editarTarea(tarea,nuevaImagen,nuevoVideo) async {
  }

  // Metodo para añadir una tarea con el id de tarea a un usuario en especifico con id de usuario
  addTareaAlumno(idUsuario, idTarea, fechafinal) async {
  }

  completarTarea(idTareaAsignada) async {
  }

  resetTarea(idTareaAsignada) async {
  }

  fallarTarea(idTareaAsignada) async {
  }

  addRespuestaTarea(idTareaAsignada, comentario, foto) async {
  }

  updateComanda(idTareaAsignada, formulario) async {
  }
  //endregion

  //region Eliminacion
  // Metodo para eliminar una tarea de un usuario pasandole el id de la relacion entre el usuario y la tarea
  Future eliminarTareaAlumno(id);

  Future eliminarTarea(id);

  //endregion

  //endregion

  //region Gestión de archivos
  subirArchivo(archivo,path) async
  {
  }

  // Metodo que te devuelve la URL según el PATH que tenga un archivo en el servidor
  leerArchivo(path) async {
  }

//endregion

  //region Geolocalizacion

  cambiarPosicion(idUsuario, latitud, longitud) async {
  }

  obtenerPosicion(idUsuario) async {
  }

  //endregion

  //region Tablon de comunicacion
  crearTablon(tablon) async {
  }

  editarTablon(tablon, tablonPerfil) async {

  }

  // Metodo que te devuelve todos los usuarios de la base de datos
  consultarTodosTablon() async {
  }

  Future eliminarTablon(id) async {
  }

  consultarIDTablon(id) async {
  }

  //endregion

  obtenerChats(id) async{
  }

  obtenerMensajes(idChat) async{
  }

  addMensaje(Mensaje mensaje) async{
  }

  eliminarTodosLosMensajes() {
  }

  buscarIdChat(id1, id2) async{
  }

  /*monitorizarPeticionesLectura(funcion)
  {
  }*/
}

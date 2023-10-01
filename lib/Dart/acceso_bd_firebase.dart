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
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
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

class AccesoBDFirebase implements AccesoBD {
  //region atributos de la clase
  var db = FirebaseFirestore.instance;
  var countPeticionesLectura = 0;
  var countPeticionesEscritura = 0;
  var countPeticionesEliminacion = 0;
  var storageRef = FirebaseStorage.instance.ref();
  var _subscripcion;
  var _subscripcionListaChat1;
  var _subscripcionLoc;
  var _subscripcionChat;
  var fotoDesconocido =
      "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fperfiles%2Fdesconocido.png?alt=media&token=98ba72ac-776e-4f83-9aaa-57761589c974";

  //endregion

  //region desactivacion de subscripciones
  desactivarSubscripcion() {
    if (_subscripcion != null) _subscripcion.cancel();
  }

  desactivarSubscripcionUbicacion() {
    if (_subscripcionLoc != null) _subscripcionLoc.cancel();
  }

  desactivarSubscripcionChat() {
    if (_subscripcionChat != null) _subscripcionChat.cancel();
  }

  desactivarSubscripcionListaChat() {
    if (_subscripcionListaChat1 != null) _subscripcionListaChat1.cancel();
  }

  //endregion

  //region Usuarios/Inicio de sesion
  // Metodo para registrar usuario
    Future<bool> registrarUsuario(Usuario usuario, String foto) async {
      try {
        //Se encripta la contaseña
        var nuevaPassword = encriptacionSha256(usuario.password);
        var nombrehaseao =
            encriptacionSha256(usuario.apellidos + usuario.fechanacimiento);

        var url = fotoDesconocido;
        var fotoPath = null;
        if (foto != null) {
          fotoPath =
          "Imágenes/perfiles/${usuario.nombre + usuario.apellidos +
              nombrehaseao}";

           url = await subirArchivo(foto, fotoPath);
        }

          var user = <String, dynamic>{
            "nombre": usuario.nombre,
            "apellidos": usuario.apellidos,
            "password": nuevaPassword,
            "fechanacimiento": usuario.fechanacimiento,
            "rol": usuario.rol,
            "foto": url,
            "metodoLogeo": usuario.metodoLogeo
          };

          await db.collection("usuarios").add(user);
          countPeticionesEscritura++;

          return true;


      } catch (e) {
        print(e);
        return false;
      }
    }

    // Metodo que comprueba la contraseña introducida con la guardada en la base de datos
  Future<bool> checkearPassword(id, password) async {
      try {
        var resultado = await consultarIDusuario(id);

        var PassEncriptada = encriptacionSha256(password);

        if (PassEncriptada == resultado.password) {
          return true;
        } else
          return false;
      } catch (e) {
        print(e);
        return false;
      }
    }

    //region Consultas
  // Metodo al que le pasas por parametro la id del usuario, comprueba si existe y te devuelve el objeto usuario
    consultarIDusuario(id) async {
      try {
        final ref = db.collection("usuarios");

        final consulta = ref.doc(id).withConverter(
            fromFirestore: Usuario.fromFirestore,
            toFirestore: (Usuario user, _) => user.toFirestore());

        final docSnap = await consulta.get();

        monitorizarPeticionesLectura("consultarIDusuario");

        var usuario = null;
        if (docSnap != null) {
          usuario = docSnap.data();
          usuario?.id = docSnap.id;
        }

        return usuario;
      } catch (e) {
        print(e);
      }
    }

    // Metodo que te devuelve todos los usuarios de la base de datos
    consultarTodosUsuarios() async {
      try {
        var usuarios = [];

        final ref = db.collection("usuarios").withConverter(
            fromFirestore: Usuario.fromFirestore,
            toFirestore: (Usuario user, _) => user.toFirestore());

        final consulta = await ref.get();

        monitorizarPeticionesLectura("consultarTodosUsuarios");

        consulta.docs.forEach((element) {
          final usuarioNuevo = element.data();
          usuarioNuevo.id = element.id;
          usuarios.add(usuarioNuevo);
        });

        return usuarios;
      } catch (e) {
        print(e);
        if(e.toString().contains("Quota exceeded"))
          {
            exit(0);
            throw "La base de datos se ha saturado";
          }
      }
    }

    // Metodos que te devuelve todos los alumnos de la base de datos
    consultarTodosAlumnos() async {
      try {
        var usuarios = [];

        final ref = db.collection("usuarios").withConverter(
            fromFirestore: Usuario.fromFirestore,
            toFirestore: (Usuario user, _) => user.toFirestore());

        final consulta = await ref.where("rol", isEqualTo: "Rol.alumno").get();

        monitorizarPeticionesLectura("consultarTodosAlumnos");

        consulta.docs.forEach((element) {
          final usuarioNuevo = element.data();
          usuarioNuevo.id = element.id;
          usuarios.add(usuarioNuevo);
        });

        return usuarios;
      } catch (e) {
        print(e);
        if(e.toString().contains("Quota exceeded"))
        {
          exit(0);
          throw "La base de datos se ha saturado";
        }
      }
    }

    // Metodo que te devuelve todos los profesores de la base de datos
    consultarTodosProfesores() async {
      try {
        var usuarios = [];

        final ref = db.collection("usuarios").withConverter(
            fromFirestore: Usuario.fromFirestore,
            toFirestore: (Usuario user, _) => user.toFirestore());

        final consulta = await ref.where("rol", isNotEqualTo: "Rol.alumno").get();

        monitorizarPeticionesLectura("consultarTodosProfesores");


        consulta.docs.forEach((element) {
          final usuarioNuevo = element.data();
          usuarioNuevo.id = element.id;
          usuarios.add(usuarioNuevo);
        });

        return usuarios;
      } catch (e) {
        print(e);
        if(e.toString().contains("Quota exceeded"))
        {
          throw "La base de datos se ha saturado";
        }
      }
    }

    //endregion

    //region Edicion

  /*
  @deprecated
  editarUsuario(usuario, foto, usuarioPerfil) async {
    try {
      final ref = db.collection("usuarios");
      //Se encripta la contaseña
      var nuevaPassword = usuario.password;
      var nombrehaseao =
      encriptacionSha256(usuario.apellidos + usuario.fechanacimiento);

      if (usuario.foto is String) {
        if (usuario.foto.startsWith("http")) {
          foto = usuario.foto;
        }
      } else {
        var fotoPath =
            "Imágenes/perfiles/${usuario.nombre + usuario.apellidos + nombrehaseao}";

        //se introduce la imágen dentro del storage y cuando se comrpueba que se ha cargado entronces se incrementa 'i' para que se pueda salir del bucle de espera
        return await storageRef
            .child(fotoPath)
            .putFile(usuario.foto)
            .then((d0) async {
          await leerImagen(fotoPath).then((value) {
            log(value);
            foto = value;
            log("Se añadio la imagen al array");
          });
          log("Se leido lo de await leerImagen");
        });
      }

      var user = <String, dynamic>{
        "nombre": usuario.nombre,
        "apellidos": usuario.apellidos,
        "password": nuevaPassword,
        "fechanacimiento": usuario.fechanacimiento,
        "rol": usuario.rol,
        "foto": foto,
        "metodoLogeo": usuario.metodoLogeo
      };
      ref.doc(usuarioPerfil.id).update(user);
      log(user.toString());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
  */

  editarFotoUsuario(idUsuario,nuevaFoto) async{
      try{

        if(nuevaFoto is String)
        {
          countPeticionesEscritura++;
          return db.collection("usuario").doc(idUsuario).update({"foto":nuevaFoto});

        }
        else
        {
          var url =  await subirArchivo(nuevaFoto,"Imágenes/perfiles/"+idUsuario.toString()+".jpg");
          await db.collection("usuarios").doc(idUsuario).update({"foto":url});
          countPeticionesEscritura++;
          return url;

        }

      }catch(e)
      {
        print(e);
        return false;
      }
    }

    editarApellidosUsuario(idUsuario,apellidos) async{
      try{

        countPeticionesEscritura++;
        await db.collection("usuarios").doc(idUsuario).update({"apellidos":apellidos}).then(
                (e){

              return true;
            }
        );

      }catch(e)
      {
        print(e);
        return false;
      }
    }

    editarNombreUsuario(idUsuario,nombre) async{
      try{

        countPeticionesEscritura++;
        return await db.collection("usuarios").doc(idUsuario).update({"nombre":nombre});

      }catch(e)
      {
        print(e);
        return false;
      }
    }

    editarNacimientoUsuario(idUsuario,fecha) async{
      try{

        countPeticionesEscritura++;
        await db.collection("usuarios").doc(idUsuario).update({"fechanacimiento":fecha}).then((e){
          return true;
        });

      }catch(e)
      {
        print(e);
        return false;
      }
    }

  addFeedbackTarea(tarea,idUsuario, retroalimentacion) async {
    try {
      final ref = db.collection("usuarioTieneTareas");

      //Solo se añade al historial si la tarea se ha completado satisfactoriamente
      if(tarea.estado == "completada")
        {
          final ref2 = db.collection("historial");

          var tareaHistorial = <String, dynamic>{
            "idUsuario":idUsuario,
            "nombre":tarea.nombre,
            "retroalimentacion":retroalimentacion
          };
          ref2.add(tareaHistorial);
          countPeticionesEscritura++;
        }

      countPeticionesEscritura++;
      return await ref
          .doc(tarea.idRelacion)
          .update({"retroalimentacion": retroalimentacion, "estado":"finalizada"});





    } catch (e) {
      log(e.toString());
      return false;
    }
  }
    //endregion

    //region Eliminacion

  Future eliminarAlumno(id) async {
    try {
      if (Sesion.alumnos != null) {
        await db.collection("usuarios").doc(id).delete().then((e) async {

          monitorizarPeticionesLectura("eliminarAlumno");

          await db.collection('chats').where('idUsuarios',  arrayContains: id ).get().then((value) {
            value.docs.forEach((element) {
              element.reference.delete();
            });
          });



          await db
              .collection("usuarioTieneTareas")
              .where("idUsuario", isEqualTo: id)
              .get()
              .then((e) {
            for (int i = 0; i < e.docs.length; i++) {
              countPeticionesEliminacion++;
              db.collection("usuarioTieneTareas").doc(e.docs[i].id).delete();
            }

            return true;
          });
        });
      }
    } catch (e) {
      return false;
      print(e);
    }
  }

  Future eliminarProfesor(id) async {
    try {
      if (Sesion.profesores != null&& Sesion.profesores != []) {
        countPeticionesEliminacion++;
        await db.collection("usuarios").doc(id).delete();
        await db.collection('chats').where('idUsuarios',  arrayContains: id ).get().then((value) {
          value.docs.forEach((element) {
            element.reference.delete();
          });
          return true;
        });

      }
    } catch (e) {
      return false;
      print(e);
    }
  }

  //endregion

  //endregion

  //region Tareas

  //region Creacion
  // Metodo para crear una tarea
  crearTarea(tarea) async {
    try {
      //Se encripta la contaseña

      var videos = [];
      var url = "";

      if(!(tarea.imagen is String))
        {
          var fotoPath = "Imágenes/pictogramas/" +
              encriptacionSha256(tarea.imagen.path);
          tarea.imagen = await subirArchivo(tarea.imagen, fotoPath); // se sube el archivo y se obtiene la url
        }

      // se sube el video
      if(tarea.videos.length == 1)
        {
          var videoPath = "Vídeos/" + encriptacionSha256(tarea.videos[0].path);
          url = await subirArchivo(tarea.videos[0], videoPath); // se sube el archivo
          videos.add(url); // se añade el url a la base de datos
        }


      //Cuando se han cargado todas las imágenes y vídeos entonces se sube a la base de datos
      //la nueva tarea con todas las urls de las imágenes y vídeos

      log("Todos los futures se han completado");

      var nuevaTarea = <String, dynamic>{
        "nombre": tarea.nombre,
        "descripcion" : tarea.descripcion,
        "imagen" : tarea.imagen,
        "textos": tarea.textos,
        "imagenes": tarea.imagenes,
        "videos": videos,
        "formularios": tarea.formularios,
      };

      countPeticionesEscritura++;
      await db.collection("Tareas").add(nuevaTarea);

      return true;

    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  //endregion

  //region Consultas
  // Metodo que te devuelve todas las tareas del usuario
  consultarTodasLasTareas() async {
    try {
      final ref = db.collection("Tareas").withConverter(
          fromFirestore: Tarea.fromFirestore,
          toFirestore: (Tarea tarea, _) => tarea.toFirestore());


      monitorizarPeticionesLectura("consultarTareasCompletas");

      final consulta = await ref.get();

      var lista = [];

      consulta.docs.forEach((element) {
        var nuevaTarea = element.data();
        nuevaTarea.id = element.id;
        lista.add(nuevaTarea);
      });

      return lista;
    } catch (e) {
      print(e);
    }
  }

  consultarTareasCompletas(id) async {
    try {
      final ref = db.collection("historial").where("idUsuario",isEqualTo: id);

      monitorizarPeticionesLectura("consultarTareasCompletas");

      final consulta = await ref.get();

      var lista = [];

      consulta.docs.forEach((element) {
        var nuevahisto = Historial(element.id,element.get("nombre"),element.get("retroalimentacion"),element.get("idUsuario"));
        lista.add(nuevahisto);
      });

      return lista;
    } catch (e) {
      print(e);
    }
  }

  // Metodo que te devuelve la tarea segun el id de esta
  consultarIDTarea(id) async {
    try {
      final ref = db.collection("Tareas");

      final consulta = ref.doc(id).withConverter(
          fromFirestore: Tarea.fromFirestore,
          toFirestore: (Tarea tarea, _) => tarea.toFirestore());

      monitorizarPeticionesLectura("consultarIDTarea");

      final docSnap = await consulta.get();

      var tarea = null;
      if (docSnap != null) {
        tarea = docSnap.data();
        tarea?.id = docSnap.id;
      }

      return tarea;
    } catch (e) {
      print(e);
    }
  }

  // Metodo para consultar las tareas asignadas a un usuario según el id pasado por parametro y te devuelve las tareas que tiene insertandolas en la
  // sesion

  consultarTareasAsignadasAlumno(id, completa) async {
    try {
      //Se accede a la relación de las tareas de un usuario
      final ref = db.collection("usuarioTieneTareas");

      _subscripcion = await ref
          .where("idUsuario", isEqualTo: id)
          .orderBy(
          "fechainicio") // consulta todas las tareas de un usuario ordenadas por fecha de asignación
          .snapshots()
          .listen((e) async

          {
          monitorizarPeticionesLectura("consultarTareasAsignadasAlumno");

        //Escucha los cambios en el servidor
        var nuevasTareas = [];

        // se recorren todas las tareas asignadas
        for (int i = 0; i < e.docs.length; i++) {

          var idTarea = e.docs[i].get("idTarea"); // cada tarea tiene una id

          try {
            // esa id se usa para consultar la información de la tarea
              var nuevaTarea = await consultarIDTarea(idTarea);

              // necesito saber que estado tiene por que igual esa tarea no tiene que verla el alumno
              nuevaTarea.estado = e.docs[i].get("estado");

              // SI la tarea está finalizada, solo la puede ver el profesor. La tarea finaliza cuando el profesor manda la retroalimentación
              //el alumno verá la retroalimentación en el historial
              if((nuevaTarea.estado != "finalizada" && Sesion.rol == Rol.alumno.toString()) || Sesion.rol != Rol.alumno.toString()) {

                //meto en la nueva tarea toda la información que necesito
                nuevaTarea.idRelacion = e.docs[i].id;
                nuevaTarea.fechafinal = e.docs[i].get("fechafinal");
                nuevaTarea.respuesta = e.docs[i].get("respuesta");
                try {
                  nuevaTarea.fotoRespuesta = e.docs[i].get("fotoURL");
                } catch (e) {
                  nuevaTarea.fotoRespuesta = "";
                }
                nuevaTarea.retroalimentacion =
                    e.docs[i].get("retroalimentacion");

                if (nuevaTarea.estado != "sinFinalizar") {
                  nuevaTarea.fechaentrega =
                      (DateTime
                          .now()
                          .millisecondsSinceEpoch -
                          e.docs[i].get("fechaentrega")) /
                          (1000 * 60);

                  if (nuevaTarea.formularios !=
                      [
                      ]) // si en la tarea no se han actualizado los datos del formulario entonces debemos sobreescribir
                    //el que viene por defecto
                    nuevaTarea.formularios = e.docs[i].get("formularios");
                }
                nuevasTareas.add(nuevaTarea);
              }

          } catch (e) {
            print(e);
          }
        }

        Sesion.tareas = nuevasTareas;

        //Aquí se cargan los videos si se ha requerido
        if (completa) {
          try {
            for (int k = 0; k < Sesion.tareas.length; k++) {
              var array = [];

              for (int j = 0; j < Sesion.tareas[k].videos.length; j++) {
                /*var nuevoControlador = VideoPlayerController.network(
                                Sesion.tareas[k].videos[j]);*/
                Sesion.tareas[k].controladoresVideo.add(0); /// Se añade un cero porque si se inicializará el video entonces se cargaría de internet
                /// y podría haber descargas inncesarias que el usuario no va a ver.
                /*Sesion.tareas[k].controladoresVideo.last.initialize();*/

              }

              //Se cargan los formularios (Mas feo esto que pegarle a un pae la verdad)
              if (Sesion.tareas[k].formularios != []) {
                for (int l = 0;
                l < Sesion.tareas[k].formularios.length;
                l = l +
                    2 +
                    (Sesion.tareas[k].formularios[l + 1] as int) *
                        3) {
                  for (int j = 0;
                  j < (Sesion.tareas[k].formularios[l + 1] as int);
                  j++) {
                    Sesion.tareas[k].controladoresComandas
                        .add(TextEditingController());
                  }
                }
              }
            }
          } catch (e) {
            print(e);
          }
          ;
        }

        if (e.docs.length == 0) Sesion.tareas = [];

        Sesion.paginaActual.actualizar();

      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //endregion

  //region Edicion
  editarTarea(tarea,nuevaImagen,nuevoVideo) async {
    try {
      //Se encripta la contaseña
      final ref = db.collection("Tareas");

      if(nuevaImagen)
        {
          if (!(tarea.imagen is String)) {
            var fotoPath = "Imágenes/pictogramas/" +
                encriptacionSha256(tarea.imagen.path);

            var url = await subirArchivo(tarea.imagen, fotoPath);
            tarea.imagen = url;
          };
        }

      if(nuevoVideo)
        {
          if (tarea.videos.length > 0) {
            // se espera a que se introduzca el video correctamente en el storage para después salir del bucle de espera
            var url = tarea.videos[0];
            if (!(tarea.videos[0] is String)) {
              var videoPath = "Vídeos/" +
                  encriptacionSha256(tarea.videos[0].path);

               url = await subirArchivo(tarea.videos[0], videoPath);
            }
            tarea.videos = [url];
          }
        }


      //Cuando se han cargado todas las imágenes y vídeos entonces se sube a la base de datos
      //la nueva tarea con todas las urls de las imágenes y vídeos

      log("Todos los futures se han completado");

      var nuevaTarea = <String, dynamic>{
        "nombre": tarea.nombre.toString(),
        "descripcion": tarea.descripcion,
        "imagen" : tarea.imagen,
        "textos": tarea.textos,
        "imagenes": tarea.imagenes,
        "videos": tarea.videos,
        "formularios": tarea.formularios,
      };
      ref.doc(tarea.id).update(nuevaTarea);

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Metodo para añadir una tarea con el id de tarea a un usuario en especifico con id de usuario
  addTareaAlumno(idUsuario, idTarea, fechafinal) async {
    try {
      var tar = <String, dynamic>{
        "idUsuario": idUsuario,
        "idTarea": idTarea,
        "fechainicio": DateTime.now().millisecondsSinceEpoch,
        "fechafinal": fechafinal,
        "estado": "sinFinalizar",
        "fechaentrega": 0,
        "respuesta": "",
        "retroalimentacion": "",
        "formularios": []
      };

      await db.collection("usuarioTieneTareas").add(tar).then((value) {
        return true;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }

  completarTarea(idTareaAsignada) async {
    try {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({
        "estado": "completada",
        "fechaentrega": DateTime.now().millisecondsSinceEpoch
      });
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  resetTarea(idTareaAsignada) async {
    try {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({
        "estado": "sinFinalizar",
        "fechaentrega": 0,
        "respuesta": "",
        "retroalimentacion": "",
        "fotoURL": "",
        "fotopath": ""
      });
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  fallarTarea(idTareaAsignada) async {
    try {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({
        "estado": "cancelada",
        "fechaentrega": DateTime.now().millisecondsSinceEpoch
      });
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  addRespuestaTarea(idTareaAsignada, comentario, foto) async {
    try {
      final ref = db.collection("usuarioTieneTareas");
      var fotoURL = "";
      var fotoPath = "";

      if (foto != null) {
        fotoPath = "Imágenes/comentarios/" + idTareaAsignada;
        /*storageRef.child(fotoPath).putFile(foto).then((p0) async {
          await leerImagen(fotoPath).then((url) async {
            fotoURL = url;
            return await ref.doc(idTareaAsignada).update({
              "respuesta": comentario,
              'fotopath': fotoPath,
              'fotoURL': fotoURL
            });
          });
        });*/
        var url = await subirArchivo(foto,fotoPath);
        fotoURL = url;
        return await ref.doc(idTareaAsignada).update({
          "respuesta": comentario,
          'fotopath': fotoPath,
          'fotoURL': fotoURL
        });

      } else {
        return await ref
            .doc(idTareaAsignada)
            .update({"respuesta": comentario, 'fotopath': "", 'fotoURL': ""});
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  updateComanda(idTareaAsignada, formulario) async {
    try {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({"formularios": formulario});
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
  //endregion

  //region Eliminacion
  // Metodo para eliminar una tarea de un usuario pasandole el id de la relacion entre el usuario y la tarea
  Future eliminarTareaAlumno(id) async {
    try {
      if (Sesion.tareas != null && Sesion.tareas != []) {
        await db.collection("usuarioTieneTareas").doc(id).delete();
        return true;
      }
    } catch (e) {
      return false;
      print(e);
    }
  }

  Future eliminarTarea(id) async {
    try {
      if (Sesion.tareas != null && Sesion.tareas != []) {
        await db.collection("Tareas").doc(id).delete().then((e) async {

          monitorizarPeticionesLectura("eliminarTarea");

          await db
              .collection("usuarioTieneTareas")
              .where("idTarea", isEqualTo: id)
              .get()
              .then((e) {
            for (int i = 0; i < e.docs.length; i++) {
              db.collection("usuarioTieneTareas").doc(e.docs[i].id).delete();
            }

            return true;
          });
        });
      }
    } catch (e) {
      return false;
      print(e);
    }
  }

  //endregion

  //endregion

  //region Gestión de archivos
  subirArchivo(archivo,path) async
  {
    try {
      await storageRef.child(path).putFile(archivo); // espera hasta subir el archivo en la base de datos
      var url = await leerArchivo(path);// espera a obtener la url para acceder a dicho archivo y comprobar que existe
      return url; // devuelve la url del archivo
    }
    catch(e)
    {
      print(e);
      return "error al subir archivo";
    }
  }

  // Metodo que te devuelve la URL según el PATH que tenga un archivo en el servidor
  leerArchivo(path) async {
    final archivo = storageRef.child(path);

    print("intentando cargar imagen");
    try {
      const oneMegabyte = 1024 * 1024;
      final String? data = await archivo.getDownloadURL();
      return data;
      // Data for "images/island.jpg" is returned, use this as needed.
    } on FirebaseException catch (e) {
      print("ERROR:" + e.toString());
      // Handle any errors.
    }
  }

//endregion

  //region Geolocalizacion

  cambiarPosicion(idUsuario, latitud, longitud) async {
    try {
      final ref = db.collection("usuarios");
      return await ref
          .doc(idUsuario)
          .update({"latitud": latitud, "longitud": longitud});
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  obtenerPosicion(idUsuario) async {
    try {
      final ref = db.collection("usuarios").doc(idUsuario);
      _subscripcionLoc =
          await ref // consulta todas las tareas de un usuario ordenadas por fecha de asignación
              .snapshots()
              .listen((e) async {
            monitorizarPeticionesLectura("obtenerPosicion");

        if (Sesion.argumentos.length == 0) {
          Sesion.argumentos.add(0.0);
          Sesion.argumentos.add(0.0);
        }
        Sesion.argumentos[0] = e.get("latitud");
        Sesion.argumentos[1] = e.get("longitud");
        Sesion.paginaActual.actualizar();
      });
    } catch (e) {
      print(e);
    }
  }

  //endregion

  //region Tablon de comunicacion
  crearTablon(tablon) async {
    try {
      final ref = db.collection("tablero");
      var nuevoTablero = <String, dynamic>{
        "nombre": tablon.nombres,
        "imagene": tablon.imagenes,
        "tipo": tablon.tipos,
      };
      ref.add(nuevoTablero);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  editarTablon(tablon, tablonPerfil) async {
    try {
      //Se encripta la contaseña
      final ref = db.collection("tablero");
      var imagenes;

      if (tablon.imagenes is String) {
        if (tablon.imagenes.startsWith("http")) {
          imagenes = tablon.imagenes;
        }
      } else {
        var fotoPath =
            "Imágenes/pictogramas/" + encriptacionSha256(tablon.imagenes.path);

        //se introduce la imágen dentro del storage y cuando se comrpueba que se ha cargado entronces se incrementa 'i' para que se pueda salir del bucle de espera
        /*await storageRef
            .child(fotoPath)
            .putFile(tablon.imagenes)
            .then((d0) async {
          await leerImagen(fotoPath).then((value) {
            log(value);
            imagenes = value;
            log("Se añadio la imagen al array");
          });
          log("Se leido lo de await leerImagen");
        });*/
        await subirArchivo(tablon.imagenes, fotoPath).then((value){
          imagenes = value;
        });
      }
      //Cuando se han cargado todas las imágenes y vídeos entonces se sube a la base de datos
      //la nueva tarea con todas las urls de las imágenes y vídeos

      log("Todos los futures se han completado");

      var nuevaTablon = <String, dynamic>{
        "nombre": tablon.nombres.toString(),
        "imagene": imagenes,
        "tipo": tablon.tipos
      };
      log(nuevaTablon.toString());
      ref.doc(tablonPerfil.id).update(nuevaTablon);

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Metodo que te devuelve todos los usuarios de la base de datos
  consultarTodosTablon() async {
    try {
      var tablon = [];

      final ref = db.collection("tablero").withConverter(
          fromFirestore: Tablon.fromFirestore,
          toFirestore: (Tablon tab, _) => tab.toFirestore());

      monitorizarPeticionesLectura("consultarTodosTablon");

      final consulta = await ref.get();

      consulta.docs.forEach((element) {
        final tableroNuevo = element.data();
        tableroNuevo.id = element.id;
        tablon.add(tableroNuevo);
      });
      return tablon;
    } catch (e) {
      print(e);
    }
  }

  Future eliminarTablon(id) async {
    try {
      if (Sesion.tablon != null && Sesion.tablon != []) {
        await db.collection("tablero").doc(id).delete();
        return true;
      }
    } catch (e) {
      return false;
      print(e);
    }
  }

  consultarIDTablon(id) async {
    try {
      final ref = db.collection("tablero");

      final consulta = ref.doc(id).withConverter(
          fromFirestore: Tablon.fromFirestore,
          toFirestore: (Tablon tablon, _) => tablon.toFirestore());


      monitorizarPeticionesLectura("consultarIDTablon");

      final docSnap = await consulta.get();

      var tablon = null;
      if (docSnap != null) {
        tablon = docSnap.data();
        tablon?.id = docSnap.id;
      }

      return tablon;
    } catch (e) {
      print(e);
    }
  }

  //endregion

  obtenerChats(id) async{
    try {
          _subscripcionListaChat1 = await db
          .collection('chats')
          .where('idUsuarios',  arrayContains: id )
          .orderBy('fechaUltimoMensaje',descending: true)
          .snapshots().listen((event) async{

            monitorizarPeticionesLectura("obtenerChats");
            var listaChats = [];

            for(int i = event.docs.length - 1; i>=0;i--){


              var index = (await event.docs[i].get("idUsuarios").indexOf(id)) == 0 ? 1: 0;

              var snapshot2 = await Sesion.db.consultarIDusuario(event.docs[i].get("idUsuarios")[index]);

              bool sinLeer = index==0? (await event.docs[i].get("sinLeer2")):(await event.docs[i].get("sinLeer1"));

              var foto = await snapshot2.foto;
              var nombre = await snapshot2.nombre;

              Chat nuevo = Chat(event.docs[i].id,Sesion.id,snapshot2.id,nombre,foto,sinLeer,event.docs[i].get("fechaUltimoMensaje"));
              listaChats.add(nuevo);
            }

            Sesion.chats = listaChats;

            if(Sesion.paginaActual==Sesion.paginaChats){
              Sesion.paginaChats.actualizarChats();
            }
          });


    } catch (e) {
      print(e);
    }
  }

  obtenerMensajes(idChat) async{
    try {

      _subscripcionChat = await db
          .collection('mensajes')
          .where('idChat',  isEqualTo: idChat).orderBy("fechaEnvio")
          .snapshots().listen((event) async{

        monitorizarPeticionesLectura("obtenerMensajes (1)");

            print(idChat);

          var listaMensajes = [];

            for(int i = 0; i<event.docs.length;i++){
              Mensaje nuevo = Mensaje(event.docs[i].get('idChat'),event.docs[i].get('idUsuarioEmisor'),event.docs[i].get('idUsuarioReceptor'),
                event.docs[i].get('tipo'),event.docs[i].get('contenido'),event.docs[i].get('fechaEnvio'));
              listaMensajes.add(nuevo);
            }

            if(Sesion.paginaActual==Sesion.paginaChat) {
              Sesion.paginaActual.actualizarMensajes(listaMensajes);
            }

            //marco como leido el chat para este usuario
            if(listaMensajes.length>0){

              monitorizarPeticionesLectura("obtenerMensajes (2)");

              var snapshot = await db.collection('chats').doc(idChat).get();
              var sinLeer = event.docs.last.get('idUsuarioEmisor')==Sesion.id?'sinLeer1':'sinLeer2';

              db.collection('chats').doc(idChat).update({
                'idUsuarios': [event.docs.last.get('idUsuarioEmisor'), event.docs.last.get('idUsuarioReceptor')],
                sinLeer:false,
                'fechaUltimoMensaje' : event.docs.last.get('fechaEnvio')});
              }

          });
    } catch (e) {
      print(e);
    }
  }

  addMensaje(Mensaje mensaje) async{
    try {

      //Si el id es vacio, creamos un nuevo chat
      if(mensaje.idChat==''){
        Map<String,dynamic> chat = {
          'idUsuarios': [mensaje.idUsuarioEmisor, mensaje.idUsuarioReceptor],
          'sinLeer1' : false,
          'sinLeer2' : true,
          'fechaUltimoMensaje' : mensaje.fechaEnvio,
        };

        countPeticionesEscritura++;
        await db.collection('chats').add(chat);

        mensaje.idChat = await buscarIdChat(mensaje.idUsuarioEmisor, mensaje.idUsuarioReceptor);
      }else{
        //Marco sin leer el chat
        db.collection('chats').doc(mensaje.idChat).update({
          'idUsuarios': [mensaje.idUsuarioEmisor, mensaje.idUsuarioReceptor],
          'sinLeer1':true,
          'sinLeer2':true,
          'fechaUltimoMensaje' : mensaje.fechaEnvio});
      }

      Map<String,dynamic> msg = {
        'idChat': mensaje.idChat,
        'idUsuarioEmisor': mensaje.idUsuarioEmisor,
        'idUsuarioReceptor': mensaje.idUsuarioReceptor,
        'fechaEnvio': mensaje.fechaEnvio,
        'tipo': mensaje.tipo,
        'contenido': mensaje.contenido,
      };


      print(msg.toString());
      db.collection('mensajes').add(msg);

    } catch (e) {
      print(e);
    }
  }

  eliminarTodosLosMensajes() {
    try{
      monitorizarPeticionesLectura("eliminarTodosLosMensajes");

        db.collection("mensajes").get().then((res) {

          res.docs.forEach((element) {
            countPeticionesEliminacion++;
            element.reference.delete();
          });
        }
        );
    }
    catch(e){print(e);};
  }

  buscarIdChat(id1, id2) async{
    try{
      monitorizarPeticionesLectura("buscarIdChat");

      var id = '';
      var snapshot = await db.collection("chats")
          .where('idUsuarios',  arrayContains: id1 )
          .get();

      for(int i = 0; i < snapshot.docs.length;i++)
      {

        if(snapshot.docs[i].get("idUsuarios").contains(id2))
          {
            return snapshot.docs[i].id;
          }
      }


      return '';

    }
    catch(e){print(e);};
  }

  monitorizarPeticionesLectura(funcion)
  {
    countPeticionesLectura++;
    print("Las peticiones de lectura: " + countPeticionesLectura.toString() + "  en ${funcion}");

      if(countPeticionesLectura >= 1000)
        {
          print("peticiones escritura : " + countPeticionesEscritura.toString() + " peticiones eliminacion " + countPeticionesEliminacion.toString() );

          print( "PETICIONES DE LECTURA EXCEDIDAS, EL MÁXIMO SON 300\n última peticion en + ${funcion}");

          exit(0);
        }
  }
}

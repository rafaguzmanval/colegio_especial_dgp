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

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/tablon.dart';
import 'package:colegio_especial_dgp/Dart/tarea.dart';

import 'package:colegio_especial_dgp/Dart/usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';
import 'notificacion.dart';

String encriptacionSha256(String password) {
  var data = utf8.encode(password);
  var hashvalue = sha256.convert(data);

  return hashvalue.toString();
}

class AccesoBD {
  var db = FirebaseFirestore.instance;
  var storageRef = FirebaseStorage.instance.ref();
  var _subscripcion;
  var _subscripcionLoc;

  var fotoDesconocido =
      "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fperfiles%2Fdesconocido.png?alt=media&token=98ba72ac-776e-4f83-9aaa-57761589c974";

  desactivarSubscripcion() {
    if (_subscripcion != null) _subscripcion.cancel();
  }

  desactivarSubscripcionUbicacion() {
    if (_subscripcionLoc != null) _subscripcionLoc.cancel();
  }

  // Metodo para registrar usuario
  registrarUsuario(usuario, foto) async {
    try {
      //Se encripta la contaseña
      var nuevaPassword = encriptacionSha256(usuario.password);
      var nombrehaseao =
          encriptacionSha256(usuario.apellidos + usuario.fechanacimiento);

      var fotoPath = null;
      if (foto != null) {
        fotoPath =
            "Imágenes/perfiles/${usuario.nombre + usuario.apellidos + nombrehaseao}";

        return await storageRef.child(fotoPath).putFile(foto).then((p0) async {
          var fotoURL = await leerImagen(fotoPath);

          var user = <String, dynamic>{
            "nombre": usuario.nombre,
            "apellidos": usuario.apellidos,
            "password": nuevaPassword,
            "fechanacimiento": usuario.fechanacimiento,
            "rol": usuario.rol,
            "foto": fotoURL,
            "metodoLogeo": usuario.metodoLogeo
          };
          db.collection("usuarios").add(user);

          return true;
        });
      } else {
        var user = <String, dynamic>{
          "nombre": usuario.nombre,
          "apellidos": usuario.apellidos,
          "password": nuevaPassword,
          "fechanacimiento": usuario.fechanacimiento,
          "rol": usuario.rol,
          "foto": fotoDesconocido,
          "metodoLogeo": usuario.metodoLogeo
        };
        db.collection("usuarios").add(user);

        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  /*
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
  }*/

  // Metodo para crear una tarea
  crearTarea(tarea) async {
    try {
      //Se encripta la contaseña


      var imagenes = [];
      var videos = [];


      int i = 0;

      for( int j= 0; j < tarea.imagenes.length ; j++) {
        if (tarea.imagenes[j] is String) {
          if (tarea.imagenes[j].startsWith("http")) {
            imagenes.add(tarea.imagenes[j]);
            i++;
          }
        } else {
          var fotoPath = "Imágenes/pictogramas/" +
              encriptacionSha256(tarea.imagenes[j].path);

          //se introduce la imágen dentro del storage y cuando se comrpueba que se ha cargado entronces se incrementa 'i' para que se pueda salir del bucle de espera
          await storageRef
              .child(fotoPath)
              .putFile(tarea.imagenes[j])
              .then((d0) async {
            await leerImagen(fotoPath).then((value) {
              log(value);
              imagenes.add(value);
              log("Se añadio la imagen al array");
              i++;
            });
            log("Se leido lo de await leerImagen");
          });
        }
      }

      for (int j = 0; j < tarea.videos.length ; j++) {
        var videoPath = "Vídeos/" + encriptacionSha256(tarea.videos[j].path);

        // se espera a que se introduzca el video correctamente en el storage para después salir del bucle de espera
        await storageRef
            .child(videoPath)
            .putFile(tarea.videos[j])
            .then((p0) async {
          await leerVideo(videoPath).then((value) {
            videos.add(value);
            i++;
          });
        });
      }

      //bucle de espera  para que las imágenes y los vídeos estén cargados
      while (i != tarea.imagenes.length + tarea.videos.length) {}
      ;

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

      db.collection("Tareas").add(nuevaTarea);

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Metodo al que le pasas por parametro la id del usuario, comprueba si existe y te devuelve el objeto usuario
  consultarIDusuario(id) async {
    try {
      final ref = db.collection("usuarios");

      final consulta = ref.doc(id).withConverter(
          fromFirestore: Usuario.fromFirestore,
          toFirestore: (Usuario user, _) => user.toFirestore());

      final docSnap = await consulta.get();

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

  // Metodo para consultar las tareas asignadas a un usuario según el id pasado por parametro y te devuelve las tareas que tiene insertandolas en la
  // sesion
  @deprecated
  consultarTareasAsignadasAlumno(id, completa) async {
    try {
      //Se accede a la relación de las tareas de un usuario
      final ref = db.collection("usuarioTieneTareas");

      _subscripcion = await ref
          .where("idUsuario", isEqualTo: id)
          .orderBy(
              "fechainicio") // consulta todas las tareas de un usuario ordenadas por fecha de asignación
          .snapshots()
          .listen((e) async {
        //Escucha los cambios en el servidor
        var nuevasTareas = [];
        for (int i = 0; i < e.docs.length; i++) {
          // itera sobre los elementos de la colección
          var idTarea = e.docs[i].get("idTarea"); // cada tarea tiene una id

          try {
            await consultarIDTarea(idTarea).then((nuevaTarea) {
              // sobre esa id accedemos a la colección tarea donde se encuentra la información de la tarea
              nuevaTarea.idRelacion = e.docs[i].id;
              nuevaTarea.estado = e.docs[i].get("estado");
              if((nuevaTarea.estado != "finalizada" && Sesion.rol == Rol.alumno.toString()) || Sesion.rol != Rol.alumno.toString()) {
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

              if (nuevasTareas.length == e.docs.length) {
                Sesion.tareas = nuevasTareas;
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
              }
            });
          } catch (e) {
            print(e);
          }
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
        storageRef.child(fotoPath).putFile(foto).then((p0) async {
          await leerImagen(fotoPath).then((url) async {
            fotoURL = url;
            return await ref.doc(idTareaAsignada).update({
              "respuesta": comentario,
              'fotopath': fotoPath,
              'fotoURL': fotoURL
            });
          });
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

  subirArchivo(archivo,path) async
  {
    try {
      return await storageRef
          .child(path)
          .putFile(archivo);
    }
    catch(e)
    {
      print(e);
      return "error al subir archivo";
    }
  }

  subirImagen(archivo,path) async{
    try {
      return await storageRef // espera hasta subir el archivo en la base de datos
          .child(path)
          .putFile(archivo).then((e) async {
        return await leerImagen( // espera a obtener la url para acceder a dicho archivo y comprobar que existe
            path).then((value) {
          return value; // devuelve la url del archivo
        });
      });
    }
    catch(e)
    {
      print(e);
      return "error al subir archivo";
    }
  }

  editarFotoUsuario(idUsuario,nuevaFoto) async{
    try{

      if(nuevaFoto is String)
        {
          return db.collection("usuario").doc(idUsuario).update({"foto":nuevaFoto});
        }
      else
        {
          /*return await subirArchivo(nuevaFoto,"Imágenes/perfiles/"+idUsuario.toString()+".jpg").then((e) async{

                     return await leerImagen("Imágenes/perfiles/"+idUsuario.toString()+".jpg").then((value) {
                      print(value);
                       db.collection("usuarios").doc(idUsuario).update({"foto":value});
                       return value;
                    });*/
          return await subirImagen(nuevaFoto,"Imágenes/perfiles/"+idUsuario.toString()+".jpg").then((value) async{
            return await db.collection("usuarios").doc(idUsuario).update({"foto":value});
          });

        }

    }catch(e)
    {
      print(e);
      return false;
    }
  }

  editarApellidosUsuario(idUsuario,apellidos) async{
    try{

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

      return await db.collection("usuarios").doc(idUsuario).update({"nombre":nombre});

    }catch(e)
    {
      print(e);
      return false;
    }
  }

  editarNacimientoUsuario(idUsuario,fecha) async{
    try{

       await db.collection("usuarios").doc(idUsuario).update({"fechanacimiento":fecha}).then((e){
         return true;
       });

    }catch(e)
    {
      print(e);
      return false;
    }
  }


  editarTarea(tarea) async {
    try {
      //Se encripta la contaseña
      final ref = db.collection("Tareas");

      int i = 0;

        if (tarea.imagen is String) {
          if (tarea.imagen.startsWith("http")) {
            i++;
          }
        } else {
          var fotoPath = "Imágenes/pictogramas/" +
              encriptacionSha256(tarea.imagen.path);

          //se introduce la imágen dentro del storage y cuando se comrpueba que se ha cargado entronces se incrementa 'i' para que se pueda salir del bucle de espera
          await storageRef
              .child(fotoPath)
              .putFile(tarea.imagen)
              .then((d0) async {
            await leerImagen(fotoPath).then((value) {
              tarea.imagen = value;
              i++;
            });
          });
        }

      if (tarea.videos.length > 0) {
        // se espera a que se introduzca el video correctamente en el storage para después salir del bucle de espera
        if (!(tarea.videos[0] is String)) {
          var videoPath = "Vídeos/" + encriptacionSha256(tarea.videos[0].path);
          await storageRef
              .child(videoPath)
              .putFile(tarea.videos[0])
              .then((p0) async {
            await leerVideo(videoPath).then((value) {
              tarea.videos = [value];
              i++;
            });
          });
        } else {
          i++;
        }
      }

      //bucle de espera  para que las imágenes y los vídeos estén cargados
      while (i != 1 + tarea.videos.length) {}
      ;

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



  addFeedbackTarea(tarea,idUsuario, retroalimentacion) async {
    try {
      final ref = db.collection("usuarioTieneTareas");
      final ref2 = db.collection("historial");

      var tareaHistorial = <String, dynamic>{
        "idUsuario":idUsuario,
        "nombre":tarea.nombre,
        "retroalimentacion":retroalimentacion
      };
      ref2.add(tareaHistorial);

      return await ref
          .doc(tarea.idRelacion)
          .update({"retroalimentacion": retroalimentacion, "estado":"finalizada"});




    } catch (e) {
      log(e.toString());
      return false;
    }
  }

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

  Future eliminarAlumno(id) async {
    try {
      if (Sesion.alumnos != null) {
        await db.collection("usuarios").doc(id).delete().then((e) async {
          await db
              .collection("usuarioTieneTareas")
              .where("idUsuario", isEqualTo: id)
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

  Future eliminarProfesor(id) async {
    try {
      if (Sesion.profesores != null&& Sesion.profesores != []) {
        await db.collection("usuarios").doc(id).delete();
        return true;
      }
    } catch (e) {
      return false;
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

      consulta.docs.forEach((element) {
        final usuarioNuevo = element.data();
        usuarioNuevo.id = element.id;
        usuarios.add(usuarioNuevo);
      });

      return usuarios;
    } catch (e) {
      print(e);
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

      consulta.docs.forEach((element) {
        final usuarioNuevo = element.data();
        usuarioNuevo.id = element.id;
        usuarios.add(usuarioNuevo);
      });

      return usuarios;
    } catch (e) {
      print(e);
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

      consulta.docs.forEach((element) {
        final usuarioNuevo = element.data();
        usuarioNuevo.id = element.id;
        usuarios.add(usuarioNuevo);
      });

      return usuarios;
    } catch (e) {
      print(e);
    }
  }

  // Metodo que te devuelve todas las tareas del usuario
  consultarTodasLasTareas() async {
    try {
      final ref = db.collection("Tareas").withConverter(
          fromFirestore: Tarea.fromFirestore,
          toFirestore: (Tarea tarea, _) => tarea.toFirestore());

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

  updateComanda(idTareaAsignada, formulario) async {
    try {
      final ref = db.collection("usuarioTieneTareas");
      return await ref.doc(idTareaAsignada).update({"formularios": formulario});
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Metodo que te devuelve la tarea segun el id de esta
  consultarIDTarea(id) async {
    try {
      final ref = db.collection("Tareas");

      final consulta = ref.doc(id).withConverter(
          fromFirestore: Tarea.fromFirestore,
          toFirestore: (Tarea tarea, _) => tarea.toFirestore());

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

  // Metodo que comprueba la contraseña introducida con la guardada en la base de datos
  checkearPassword(id, password) async {
    try {
      var resultado = await consultarIDusuario(id);

      var PassEncriptada = encriptacionSha256(password);

      if (PassEncriptada == resultado.password) {
        return true;
      } else
        return false;
    } catch (e) {
      print(e);
    }
  }

  // Metodo que te devuelve la URL según el PATH que tenga la imagen en el servidor
  leerImagen(path) async {
    final imagen = storageRef.child(path);

    print("intentando cargar imagen");
    try {
      const oneMegabyte = 1024 * 1024;
      final String? data = await imagen.getDownloadURL();
      return data;
      // Data for "images/island.jpg" is returned, use this as needed.
    } on FirebaseException catch (e) {
      print("ERROR:" + e.toString());
      // Handle any errors.
    }
  }

  // Metodo que te devuelve la URL según el PATH que tenga el video en el servidor
  leerVideo(path) async {
    final video = storageRef.child(path);

    print("intentando cargar video");
    try {
      const oneMegabyte = 1024 * 1024;
      final String? data = await video.getDownloadURL();
      print("video cargado");
      return data;
      // Data for "images/island.jpg" is returned, use this as needed.
    } on FirebaseException catch (e) {
      print("ERROR:" + e.toString());
      // Handle any errors.
    }
  }

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
        await storageRef
            .child(fotoPath)
            .putFile(tablon.imagenes)
            .then((d0) async {
          await leerImagen(fotoPath).then((value) {
            log(value);
            imagenes = value;
            log("Se añadio la imagen al array");
          });
          log("Se leido lo de await leerImagen");
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
}

/*
*   Archivo: crear_tarea.dart
*
*   Descripción:
*   Formulario para crear una tarea para el usuario
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   video_player.dart : Necesario para cargar los videos del storage y cargarlos en el controlador de los reproductores de video.
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   image_picker.dart : Libreria para acceder a la cámara y a la galería de imagenes del dispositivo.
*   tarea.dart: Se utiliza para construir el objeto tarea y enviarlo a la base de datos
* */

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/arasaac.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/tipo_tablon.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import "package:image_picker/image_picker.dart";
import '../Dart/tarea.dart';
import '../Dart/tablon.dart';

enum SeleccionImagen { camara, galeria, video }

class GestionTablon extends StatefulWidget {
  @override
  GestionTablonState createState() => GestionTablonState();
}

// Clase para crear tarea
class GestionTablonState extends State<GestionTablon> {
  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();
  var tipoElegido = "NINGÚN TIPO ELEGIDO";
  var tipo;
  var controladorVideo;
  var fotoTomada;
  var videoTomado;
  ImagePicker capturador = new ImagePicker();

  var creando = false;

  final controladorNombre = TextEditingController();
  final controladorTexto = TextEditingController();

  var busqueda = "";
  var busquedaPrevia = "";

  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose() {
    super.dispose();
    if (controladorNombre != null) controladorNombre.dispose();
  }

  @override
  void initState() {
    super.initState();
    //Notificacion.showBigTextNotification(title: "Vaya vaya", body: "¿Que dices? ¿creando tu primera tarea?", fln: flutterLocalNotificationsPlugin);

    /*
    controladorStream.stream.listen((event) async{



    });*/

    Sesion.paginaActual = this;
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('CREA UN NUEVO BOTÓN PARA EL TABLÓN'),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          child: Column(
            children: [
              if (Sesion.rol == Rol.alumno.toString()) ...[
                VistaAlumno(),
              ] else if (Sesion.rol == Rol.profesor.toString()) ...[
                VistaProfesor()
              ] else if (Sesion.rol == Rol.administrador.toString()) ...[
                VistaAdministrador()
              ]
            ],
          )),
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    Navigator.pop(context);
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    Navigator.pop(context);
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              style: TextStyle(fontSize: 30.0),
              obscureText: false,
              maxLength: 40,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'INTRODUCE EL NOMBRE DEL PICTOGRAMA *',
              ),
              controller: controladorNombre,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          const Text(
            "ELIGE EL TIPO PARA EL BOTÓN: *",
            style: TextStyle(fontSize: 30.0, height: 2.0, color: Colors.black),
          ),
          SizedBox(
            height: 10,
          ),
          DropdownButton(
            value: tipoElegido,
            items: [
              Tipo.sustantivo.toString(),
              Tipo.adjetivo.toString(),
              Tipo.verbo.toString(),
              "NINGÚN TIPO ELEGIDO"
            ].map((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value,style: TextStyle(fontSize: 30.0)),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                tipoElegido = value!;
              });
            },
          ),
          SizedBox(
            height: 10,
          ),
          const Text(
            "ELIGE UN PICTOGRAMA PARA EL BOTÓN: *",
            style: TextStyle(fontSize: 30.0, height: 2.0, color: Colors.black),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
              child: Text('ELIGE UN PICTOGRAMA DESDE LA WEB DE ARASAAC',style: TextStyle(fontSize: 30.0)),
              onPressed: () async {
                fotoTomada = await buscadorArasaac(context: context);
                actualizar();
              }),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(width: 2)),
            height: 150,
            width: 230,
            child: fotoTomada == null
                ? Center(child: Text('NINGÚN PICTOGRAMA ELEGIDO ****',textAlign: TextAlign.center,))
                : Center(
                    child: fotoTomada.startsWith("http")
                        ? Image.network(fotoTomada)
                        : Image.file(File(fotoTomada.path))),
          ),
          SizedBox(
            height: 10,
          ),
          Visibility(
              visible: !creando,
              child: Container(
                  margin: EdgeInsets.only(top: 0),
                  child: ElevatedButton(
                    child: Text(
                      "CREAR NUEVO BOTÓN TABLÓN",
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      crearTablon();
                    },
                  ))),
          SizedBox(
            height: 10,
          ),
          Visibility(visible: creando, child: new CircularProgressIndicator()),
        ],
      ),
    );
  }

  //Método para crear tarea
  crearTablon() async {
    if (controladorNombre.text.isNotEmpty) {
      creando = true;
      actualizar();

      var nombre = "" + controladorNombre.text;

      var imagenes = "";
      if (fotoTomada != null) {
        if (fotoTomada is String) {
          if (fotoTomada.startsWith("http")) {
            imagenes = fotoTomada;
          }
        }
      }

      if (tipoElegido == "Tipo.sustantivo") {
        tipo = "sustantivo";
      } else if (tipoElegido == "Tipo.verbo") {
        tipo = "verbo";
      } else if (tipoElegido == "Tipo.adjetivo") tipo = "adjetivo";

      Tablon tablon = Tablon();
      tablon.setTablon(nombre, imagenes, tipo);
      await base.crearTablon(tablon).then((value) {
        creando = false;
        if (value) {
          controladorNombre.text = "";
          fotoTomada = null;
          displayMensajeValidacion(
              "TAREA CREADA CORRECTAMENTE\nPUEDES VOLVER A CREAR OTRA TAREA:",
              false);
        } else {
          displayMensajeValidacion(
              "FALLO AL CREAR TAREA, INTÉNTELO DE NUEVO", true);
        }

        actualizar();
      });
    } else {
      displayMensajeValidacion("ES NECESARIO RELLENAR TODOS LOS CAMPOS", true);
      actualizar();
    }
  }

  displayMensajeValidacion(mensajeDeValidacion, error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          duration: Duration(seconds: 2),
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: BoxDecoration(
              color: Color(error ? 0xFFC72C41 : 0xFF6BFF67),
              borderRadius: BorderRadius.all(Radius.circular(29)),
            ),
            child: Center(
                child: Text(mensajeDeValidacion, selectionColor: Colors.black)),
          )),
    );
  }

  // Actualizar las páginas
  void actualizar() async {
    setState(() {});
  }
}

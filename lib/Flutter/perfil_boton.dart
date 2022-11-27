/*
*   Archivo: perfil_profesor.dart
*
*   Descripción:
*   Pagina para ver el perfil del profesor
*
*   Includes:
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
* */

import 'dart:async';
import 'dart:io';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';
import "package:image_picker/image_picker.dart";
import 'package:video_player/video_player.dart';
import 'package:colegio_especial_dgp/Dart/arasaac.dart';
import 'package:colegio_especial_dgp/Flutter/reproductor_video.dart';
import '../Dart/tarea.dart';
import 'dart:developer';
import '../Dart/tablon.dart';
import 'package:colegio_especial_dgp/Dart/tipo_tablon.dart';

class Perfilboton extends StatefulWidget {
  @override
  PerfilbotonState createState() => PerfilbotonState();
}

class PerfilbotonState extends State<Perfilboton> {
  var botonPerfil;
  final controladorNombre = TextEditingController();
  var fotoTomada;
  var creando = false;
  var vez = 0;
  var tipoElegido = "";
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;
    cargarBoton();
    actualizar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Center(child: Text(
            'Editar boton: ${Sesion.seleccion.nombres}'
                ''
                .toUpperCase(),textAlign: TextAlign.center,
            style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 30),
          )),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  cargando(),
                ],
              )),
        ));
  }

  // Carga el perfil del profesor
  Widget VistaProfesor() {
    return perfilBoton();
  }

  Widget VistaAlumno() {
    Navigator.pop(context);
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  // Carga el perfil del profesor
  Widget VistaAdministrador() {
    return perfilBoton();
  }

  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  /// Carga el perfil del profesor
  Widget perfilBoton() {
    if (vez == 0) {
      controladorNombre.text = botonPerfil.nombres.toUpperCase();
      fotoTomada = botonPerfil.imagenes;
      tipoElegido = botonPerfil.tipos.toUpperCase();
      vez++;
    }

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
              style: TextStyle(fontSize: 30.0,color: GuardadoLocal.colores[0]),
              obscureText: false,
              maxLength: 40,
              decoration: InputDecoration(
                  enabledBorder:  OutlineInputBorder(
                    borderSide:  BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'INTRODUCE EL NOMBRE DEL PICTOGRAMA *',
                  hintStyle: TextStyle(color: GuardadoLocal.colores[0])
              ),
              controller: controladorNombre,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "ELIGE EL TIPO PARA EL BOTÓN: *",
            style: TextStyle(fontSize: 30.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),
          SizedBox(
            height: 10,
          ),
          DropdownButton(
            style: TextStyle(color: GuardadoLocal.colores[0]),
            value: tipoElegido,
            items: [
              "adjetivo".toUpperCase(),
              "verbo".toUpperCase(),
              "sustantivo".toUpperCase(),
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
          Text(
            "ELIGE UN PICTOGRAMA PARA EL BOTÓN: *",
            style: TextStyle(fontSize: 30.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
              child: Text('ELIGE UN PICTOGRAMA DESDE LA WEB DE ARASAAC',style: TextStyle(fontSize: 30.0,color: GuardadoLocal.colores[2])),
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
            decoration: BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[0])),
            height: 150,
            width: 230,
            child: fotoTomada == null
                ? Center(child: Text('NINGÚN PICTOGRAMA ELEGIDO ****',textAlign: TextAlign.center,))
                :  Stack(
              children: [
                Center(
                    child: fotoTomada is String
                        ? Image.network(fotoTomada)
                        : Image.network(fotoTomada)),
                Container(
                  child: ElevatedButton(
                      onPressed: () {
                        fotoTomada = null;
                        actualizar();
                      },
                      child: Icon(Icons.remove,color: GuardadoLocal.colores[2],)),
                  alignment: Alignment.topLeft,
                )
              ],
            ),
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
                      "EDITAR BOTÓN TABLÓN",
                      style: TextStyle(
                        fontSize: 30.0,
                        color: GuardadoLocal.colores[2],
                      ),
                    ),
                    onPressed: () {
                      editarTablon();
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

  /// Carga el usuario del profesor
  cargarBoton() async // EN sesion seleccion estara el id del usuario que se ha elegido
      {
    botonPerfil = await Sesion.db.consultarIDTablon(Sesion.seleccion.id);
    actualizar();
  }

  editarTablon() async {
    if (controladorNombre.text.isNotEmpty) {
      creando = true;
      actualizar();

      var nombre = "" + controladorNombre.text;

      var imagenes;
      if (fotoTomada != null) {
        if (fotoTomada is String) {
          if (fotoTomada.startsWith("http")) {
            imagenes = fotoTomada;
          }
        } else {
          imagenes = File(fotoTomada.path);
          log(imagenes.toString());
        }
      }

      var tipos = tipoElegido.toLowerCase();

      Tablon tablon = Tablon();
      tablon.setTablon(nombre, imagenes, tipos);

      await Sesion.db.editarTablon(tablon, botonPerfil).then((value) {
        creando = false;

        if (value) {
          /*
          controladorNombre.text = "";
          controladorTexto.text = "";
          fotoTomada = null;
          videoTomado = null;
          */


          displayMensajeValidacion(
              "Tablon editadO correctamente\nPuedes volver a crear otra tarea:"
                  .toUpperCase(),
              false);
          Navigator.pop(context);

        } else {
          displayMensajeValidacion(
              "Fallo al editar tablon, inténtelo de nuevo".toUpperCase(), true);
        }

        actualizar();
      });
    } else {
      displayMensajeValidacion(
          "Es necesario rellenar todos los campos".toUpperCase(), true);
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

  Widget cargando() {
    if (botonPerfil == null)
      return Center(
        child: Text(
          '\nCARGANDO EL BOTON',
          textAlign: TextAlign.center,
        ),
      );
    else {
      return vista();
    }
  }

  vista() {
    if (Sesion.rol == Rol.alumno.toString()) {
      return VistaAlumno();
    } else if (Sesion.rol == Rol.profesor.toString()) {
      return VistaProfesor();
    } else if (Sesion.rol == Rol.administrador.toString()) {
      return VistaAdministrador();
    } else if (Sesion.rol == Rol.programador.toString()) {
      return VistaProgramador();
    }
  }

  /// Actualiza la pagina
  void actualizar() {
    setState(() {});
  }
}

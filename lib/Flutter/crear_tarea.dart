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

import 'dart:async';
import 'dart:io';

import 'package:colegio_especial_dgp/Dart/arasaac.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Flutter/reproductor_video.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import "package:image_picker/image_picker.dart";
import '../Dart/tarea.dart';

enum SeleccionImagen { camara, galeria, video }

class CrearTarea extends StatefulWidget {
  @override
  CrearTareaState createState() => CrearTareaState();
}

// Clase para crear tarea
class CrearTareaState extends State<CrearTarea> {
  Tarea nuevaTarea = new Tarea();

  var fotoDescripcion;
  var video;
  var controladorVideo;
  var formularios = [];
  var textos = [];
  var imagenes = [];
  ImagePicker capturador = new ImagePicker();

  var creando = false;

  final controladorNombre = TextEditingController();
  final controladorTexto = TextEditingController();

  var busqueda = "";

  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose() {
    super.dispose();
    if (controladorVideo != null) controladorVideo.dispose();

    if (controladorNombre != null) controladorNombre.dispose();

    if (controladorTexto != null) controladorTexto.dispose();
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

  ///introduce en el atributo @fototomada la imagen, @seleccion nos indica si el método va a ser desde la cámara o de galería
  seleccionarImagen(seleccion) async {
    try {
      if (seleccion == SeleccionImagen.camara) {
        print("Se va a abrir la cámara de fotos");
        fotoDescripcion = await capturador.pickImage(
          source: ImageSource.camera,
          imageQuality: 15,
        );
      } else if (seleccion == SeleccionImagen.galeria) {
        print("Se va a coger una foto de la galería");
        fotoDescripcion = await capturador.pickImage(
            source: ImageSource.gallery, imageQuality: 5);
      } else {
        print("Hacer un video");
        await capturador
            .pickVideo(
                source: ImageSource.camera, maxDuration: Duration(seconds: 10))
            .then((value) async {
          video = value;
          controladorVideo =
              await VideoPlayerController.file(File(value?.path as String));
          await controladorVideo.initialize();
          actualizar();

          print(controladorVideo.value.duration.toString());
        });
      }
    } catch (e) {
      print(e);
    }
    actualizar();
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Center(
            child: Text('Crea una nueva tarea'.toUpperCase(),
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: GuardadoLocal.colores[2], fontSize: 30)),
          )),
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
              style: TextStyle(color: GuardadoLocal.colores[0]),
              obscureText: false,
              maxLength: 40,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'Título *'.toUpperCase(),
                  hintStyle:
                      TextStyle(color: GuardadoLocal.colores[0], fontSize: 25)),
              controller: controladorNombre,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              style: TextStyle(color: GuardadoLocal.colores[0]),
              obscureText: false,
              maxLength: 500,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'Descripción *'.toUpperCase(),
                  hintStyle:
                      TextStyle(color: GuardadoLocal.colores[0], fontSize: 25)),
              controller: controladorTexto,
            ),
          ),
          Text(
            "ELIGE UNA FOTO O PICTOGRAMA: *",
            style: TextStyle(
                fontSize: 25.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
              child: ElevatedButton(
                  child: Image.asset(
                    'assets/camara.png',
                    width: 140,
                    height: 100,
                  ),
                  onPressed: () {
                    seleccionarImagen(SeleccionImagen.camara);
                  }),
            ),
            Container(
                margin: EdgeInsets.only(right: 20, left: 20),
                child: Flexible(
                  child: ElevatedButton(
                      child: Image.asset(
                        'assets/galeria.png',
                        width: 140,
                        height: 100,
                      ),
                      onPressed: () {
                        seleccionarImagen(SeleccionImagen.galeria);
                      }),
                )),
            Flexible(
              child: ElevatedButton(
                  child: Image.asset(
                    'assets/logo-arasaac.png',
                    width: 140,
                    height: 100,
                  ),
                  onPressed: () async {
                    fotoDescripcion = await buscadorArasaac(context: context);
                    actualizar();
                  }),
            )
          ]),
          Text(
            "HAZ UN VIDEOTUTORIAL : ",
            style: TextStyle(
                fontSize: 25.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              child: Image.asset(
                'assets/vieja-camara.png',
                width: 140,
                height: 100,
              ),
              onPressed: () {
                seleccionarImagen(SeleccionImagen.video);
              }),
          SizedBox(
            height: 15,
          ),
          /*Text(
            "CREA UN FORMULARIO: ",
            style: TextStyle(fontSize: 25.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),*/
          ElevatedButton(
              child: Column(children: [
                Text(
                    (formularios.isEmpty)
                        ? 'Crea un formulario'.toUpperCase()
                        : "Edita el formulario".toUpperCase(),
                    style: TextStyle(
                        color: GuardadoLocal.colores[2], fontSize: 25)),
                Image.asset(
                  'assets/formulario.png',
                  width: 140,
                  height: 100,
                ),
                SizedBox(
                  height: 10,
                ),
              ]),
              onPressed: () async {
                dialogFormulario();
              }),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
              child: Column(children: [
                Text(
                    (textos.isEmpty && imagenes.isEmpty)
                        ? 'Crea unos pasos'.toUpperCase()
                        : "Edita los pasos".toUpperCase(),
                    style: TextStyle(
                        color: GuardadoLocal.colores[2], fontSize: 25)),
                Image.asset(
                  'assets/lista.png',
                  width: 140,
                  height: 100,
                ),
                SizedBox(
                  height: 10,
                ),
              ]),
              onPressed: () async {
                dialogPasos();
              }),
          SizedBox(
            height: 20,
          ),
          /*
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: GuardadoLocal.colores[0])),
            height: 150,
            width: 210,
            child: fotoTomada == null
                ? Center(
                    child: Text(
                    'Ninguna foto tomada ****'.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ))
                : Stack(
                    children: [
                      Center(
                          child: fotoTomada is String
                              ? Image.network(fotoTomada)
                              : Image.file(File(fotoTomada.path))),
                      Container(
                        child: ElevatedButton(
                            onPressed: () {
                              fotoTomada = null;
                              actualizar();
                            },
                            child: Icon(
                              Icons.remove,
                              color: GuardadoLocal.colores[0],
                            )),
                        alignment: Alignment.topLeft,
                      )
                    ],
                  ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: GuardadoLocal.colores[0])),
            margin: EdgeInsets.only(right: 70, left: 70, top: 20, bottom: 20),
            child: videoTomado == null
                ? Container(
                    child: Text(
                      'Ningun video tomado ****'.toUpperCase(),
                      style: TextStyle(fontSize: 25),
                    ),
                    padding: EdgeInsets.only(
                        top: 100, bottom: 100, right: 10, left: 10),
                  )
                : Stack(children: [
                    Container(
                      child: ElevatedButton(
                          onPressed: () {
                            ventanaVideo(controladorVideo, context);
                          },
                          child: Text(
                            "ver video".toUpperCase(),
                            style: TextStyle(
                                color: GuardadoLocal.colores[2], fontSize: 25),
                          )),
                      alignment: Alignment.center,
                    ),
                    Container(
                      child: ElevatedButton(
                          onPressed: () {
                            videoTomado = null;
                            actualizar();
                          },
                          child: Icon(
                            Icons.remove,
                            color: GuardadoLocal.colores[0],
                          )),
                      alignment: Alignment.centerLeft,
                    )
                  ]
                    /*padding: EdgeInsets.only(
                        top: 10, bottom: 10, right: 10, left: 10),*/
                    ),
          ),
          */

          Visibility(
              visible: !creando,
              child: Container(
                  alignment: Alignment.bottomRight,
                  margin: EdgeInsets.only(top: 0),
                  child: ElevatedButton(
                    child: Image.asset(
                      'assets/disquete.png',
                      width: 140,
                      height: 100,
                    ),
                    onPressed: () {
                      crearTarea();
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
  crearTarea() async {
    if (controladorNombre.text.isNotEmpty) {
      creando = true;
      actualizar();

      var nombre = "" + controladorNombre.text;
      var descripcion = "" + controladorTexto.text;
      var imagen = null;

      if (fotoDescripcion != null) {
        if (fotoDescripcion is String) {
          if (fotoDescripcion.startsWith("http")) {
            imagen = fotoDescripcion;
            //imagenes.add(fotoTomada);
          }
        } else {
          imagen = File(fotoDescripcion.path);
        }
      }

      var videos = [];
      if (video != null) {
        videos.add(File(video.path));
      }

      Tarea tarea = Tarea();
      tarea.setTarea(
          nombre, descripcion, imagen, textos, imagenes, videos, formularios);

      await Sesion.db.crearTarea(tarea).then((value) {
        creando = false;

        if (value) {
          controladorNombre.text = "";
          controladorTexto.text = "";
          fotoDescripcion = null;
          video = null;

          displayMensajeValidacion(
              "Tarea creada correctamente\nPuedes volver a crear otra tarea:"
                  .toUpperCase(),
              false);
        } else {
          displayMensajeValidacion(
              "Fallo al crear tarea, inténtelo de nuevo".toUpperCase(), true);
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
                child: Text(mensajeDeValidacion,
                    style: TextStyle(
                        color: GuardadoLocal.colores[2], fontSize: 25))),
          )),
    );
  }

  dialogPasos() {
    var controladorStream = StreamController();
    showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder(
              stream: controladorStream.stream,
              initialData: "",
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print("actualizacion");
                return Dialog(
                  backgroundColor: GuardadoLocal.colores[1],
                  child: SingleChildScrollView(
                      child: Column(children: [
                    Text(
                      "\nCrea unos pasos".toUpperCase(),
                      style: TextStyle(fontSize: 40),
                    ),

                    ///Previsualizacion de los pasos
                    for (int i = 0; i < textos.length; i++)
                      Container(
                        margin: EdgeInsets.only(top: 15, bottom: 10),
                        child: Column(children: [
                          Text("Paso " + (i + 1).toString()),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                  child: Container(
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: GuardadoLocal.colores[0])),

                                ///DESCRIPCION DEL PASO
                                child: TextButton(
                                    child: Text(
                                      textos[i],
                                      style: TextStyle(
                                          fontSize: 40,
                                          color: GuardadoLocal.colores[0]),
                                    ),
                                    onPressed: () async {
                                      await dialogNombre(textos[i]).then((e) {
                                        if (e != null) {
                                          textos[i] = e;
                                          controladorStream.add("");
                                        }
                                      });
                                    }),
                              )),

                              Flexible(
                                child: Container(
                                    /*margin: EdgeInsets.only(
                                            right: 20,
                                            left: 20,
                                            top: 10,
                                            bottom: 10),*/
                                    child: Image.network(
                                  imagenes[i],
                                  fit: BoxFit.fill,
                                )),
                              ),

                              ///ELIMINACION
                              Flexible(
                                flex: 30,
                                child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: FloatingActionButton(
                                        heroTag: "boton" + i.toString(),
                                        onPressed: () {
                                          textos.removeAt(i);
                                          imagenes.removeAt(i);
                                          controladorStream.add("");
                                        },
                                        child: Icon(
                                          Icons.remove,
                                          color: GuardadoLocal.colores[2],
                                        ))),
                              ),

                            ],
                          ),
                        ]),
                      ),

                    Container(
                        margin: EdgeInsets.only(top: 15, bottom: 10),
                        child: FloatingActionButton(
                            onPressed: () async {
                              await dialogAddPaso();
                              controladorStream.add("");
                            },
                            child: Icon(
                              Icons.add,
                              color: GuardadoLocal.colores[2],
                            ))),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            margin: EdgeInsets.all(0),
                            child: ElevatedButton(
                                onPressed: () {
                                  formularios = [];
                                  Navigator.pop(context);
                                },
                                child: Column(children: [
                                  Text(
                                    '\nCancelar'.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: GuardadoLocal.colores[2]),
                                  ),
                                  Image.asset(
                                    "assets/cerrar.png",
                                    height: 100,
                                    width: 100,
                                  )
                                ]))),
                        Container(
                          margin: EdgeInsets.all(0),
                          child: ElevatedButton(
                              onPressed: () {
                                actualizar();

                                Navigator.pop(context);
                              },
                              child: Column(children: [
                                Text('\n Crear'.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: GuardadoLocal.colores[2])),
                                Image.asset(
                                  "assets/enviarunemail.png",
                                  height: 100,
                                  width: 100,
                                )
                              ])),
                        )
                      ],
                    )
                  ])),
                );
              });
        });
  }

  dialogFormulario() {
    var controladorStream = StreamController();
    showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder(
              stream: controladorStream.stream,
              initialData: "",
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Dialog(
                  backgroundColor: GuardadoLocal.colores[1],
                  child: SingleChildScrollView(
                      child: Column(children: [
                    Text(
                      "\nCrea un nuevo formulario".toUpperCase(),
                      style: TextStyle(fontSize: 40),
                    ),

                    for (int i = 0;
                        i < formularios.length;
                        i = i + 2 + (formularios[i + 1] as int) * 3)
                      Container(
                        margin: EdgeInsets.only(top: 15, bottom: 10),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                  flex: 90,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: GuardadoLocal.colores[0])),
                                    child: TextButton(
                                        child: Text(
                                          formularios[i],
                                          style: TextStyle(
                                              fontSize: 40,
                                              color: GuardadoLocal.colores[0]),
                                        ),
                                        onPressed: () async {
                                          await dialogNombre(formularios[i])
                                              .then((e) {
                                            if (e != null) {
                                              formularios[i] = e;
                                              controladorStream.add("");
                                            }
                                          });
                                        }),
                                  )),
                              Flexible(
                                flex: 30,
                                child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: FloatingActionButton(
                                        heroTag: "boton" + i.toString(),
                                        onPressed: () {
                                          formularios.removeRange(
                                              i,
                                              i +
                                                  2 +
                                                  (formularios[i + 1] as int) *
                                                      3);
                                          controladorStream.add("");
                                        },
                                        child: Icon(
                                          Icons.remove,
                                          color: GuardadoLocal.colores[2],
                                        ))),
                              ),
                              Flexible(
                                flex: 30,
                                child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: FloatingActionButton(
                                        heroTag: "boton" + i.toString(),
                                        onPressed: () {
                                          for (int m = i;
                                              m <
                                                  i +
                                                      2 +
                                                      formularios[i + 1] * 3;
                                              m++)
                                            formularios.add(formularios[m]);

                                          controladorStream.add("");
                                        },
                                        child: Icon(
                                          Icons.queue_outlined,
                                          color: GuardadoLocal.colores[2],
                                        ))),
                              ),
                            ],
                          ),

                          for (int j = i + 2;
                              j < i + 2 + (formularios[i + 1] as int) * 3;
                              j = j + 3)
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2,
                                        color: GuardadoLocal.colores[0])),
                                margin: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                          margin: EdgeInsets.only(right: 20),
                                          child: TextButton(
                                              child: Text(
                                                  formularios[j].toUpperCase(),
                                                  style: TextStyle(
                                                      fontSize: 30,
                                                      color: GuardadoLocal
                                                          .colores[0])),
                                              onPressed: () async {
                                                await dialogNombre(
                                                        formularios[j])
                                                    .then((e) {
                                                  if (e != null) {
                                                    formularios[j] = e;
                                                    controladorStream.add("");
                                                  }
                                                });
                                              })),
                                    ),
                                    if (formularios[j + 1] != "") ...[
                                      Flexible(
                                        child: Container(
                                            margin: EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                                top: 10,
                                                bottom: 10),
                                            child: Image.network(
                                              formularios[j + 1],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.fill,
                                            )),
                                      ),
                                    ],
                                    Flexible(
                                      child: Container(
                                          margin: EdgeInsets.only(left: 30),
                                          child: FloatingActionButton(
                                              heroTag: "boton" +
                                                  i.toString() +
                                                  j.toString(),
                                              onPressed: () {
                                                print(
                                                    formularios[j].toString() +
                                                        " " +
                                                        formularios[j + 1]
                                                            .toString() +
                                                        "  " +
                                                        formularios[j + 2]
                                                            .toString());
                                                formularios.removeRange(
                                                    j, j + 3);
                                                formularios[i + 1]--;

                                                controladorStream.add("");
                                              },
                                              child: Icon(
                                                Icons.remove,
                                                color: GuardadoLocal.colores[2],
                                              ))),
                                    ),
                                  ],
                                )),

                          /// ELEMENTO NUEVO
                          Container(
                              margin: EdgeInsets.only(top: 15),
                              child: ElevatedButton(
                                  onPressed: () async {
                                    await dialogElemento(i);
                                    controladorStream.add("");
                                  },
                                  child: Text(
                                    "Crea un elemento".toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: GuardadoLocal.colores[2]),
                                  ))),
                        ]),
                      ),

                    ///

                    Text(
                      "\n Crea una agrupación".toUpperCase(),
                      style: TextStyle(
                          fontSize: 25, color: GuardadoLocal.colores[0]),
                    ),

                    Container(
                        margin: EdgeInsets.only(top: 15, bottom: 10),
                        child: FloatingActionButton(
                            onPressed: () async {
                              await dialogNombre("").then((e) {
                                if (e != null) {
                                  formularios.add(e);
                                  formularios.add(0);
                                  controladorStream.add("");
                                }
                              });
                            },
                            child: Icon(
                              Icons.add,
                              color: GuardadoLocal.colores[2],
                            ))),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            margin: EdgeInsets.all(0),
                            child: ElevatedButton(
                                onPressed: () {
                                  formularios = [];
                                  Navigator.pop(context);
                                },
                                child: Column(children: [
                                  Text(
                                    '\nCancelar'.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: GuardadoLocal.colores[2]),
                                  ),
                                  Image.asset(
                                    "assets/cerrar.png",
                                    height: 100,
                                    width: 100,
                                  )
                                ]))),
                        Container(
                          margin: EdgeInsets.all(0),
                          child: ElevatedButton(
                              onPressed: () {
                                actualizar();

                                Navigator.pop(context);
                              },
                              child: Column(children: [
                                Text('\n Crear'.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: GuardadoLocal.colores[2])),
                                Image.asset(
                                  "assets/enviarunemail.png",
                                  height: 100,
                                  width: 100,
                                )
                              ])),
                        )
                      ],
                    )
                  ])),
                );
              });
        });
  }

  dialogNombre(texto) {
    var controlador = TextEditingController();
    controlador.text = texto.toUpperCase();
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              backgroundColor: GuardadoLocal.colores[1],
              child: Column(
                children: [
                  TextField(
                    controller: controlador,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 35, color: GuardadoLocal.colores[0]),
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: GuardadoLocal.colores[0], width: 0.0),
                    )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          margin: EdgeInsets.all(15),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Column(children: [
                                Text(
                                  'No'.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 40,
                                      color: GuardadoLocal.colores[2]),
                                ),
                              ]))),
                      Container(
                          margin: EdgeInsets.all(15),
                          child: ElevatedButton(
                            onPressed: () {
                              if (controlador.text != "") {
                                Navigator.pop(context, controlador.text);
                              }
                            },
                            child: Text(
                              'Ok'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 40,
                                  color: GuardadoLocal.colores[2]),
                            ),
                          ))
                    ],
                  )
                ],
              ));
        });
  }

  dialogElemento(i) {
    var imagenEscogida = "";
    var controlador = TextEditingController();
    var controladorStream = StreamController();

    return showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder(
              stream: controladorStream.stream,
              initialData: "",
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Dialog(
                    backgroundColor: GuardadoLocal.colores[1],
                    child: Column(children: [
                      Flexible(
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30, color: GuardadoLocal.colores[0]),
                          controller: controlador,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: GuardadoLocal.colores[0],
                                    width: 0.0),
                              ),
                              hintText: "Nombre Elemento:".toUpperCase(),
                              hintStyle:
                                  TextStyle(color: GuardadoLocal.colores[0])),
                        ),
                      ),
                      Flexible(
                          child: Container(
                              margin: EdgeInsets.all(10),
                              child: ElevatedButton(
                                  child: Text(
                                      'Pictograma desde la web de ARASAAC'
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: GuardadoLocal.colores[2])),
                                  onPressed: () async {
                                    imagenEscogida =
                                        await buscadorArasaac(context: context);
                                    controladorStream.add("");
                                  }))),
                      if (imagenEscogida != "") ...[
                        Flexible(
                            child: Image.network(imagenEscogida,
                                width: 150, height: 150)),
                      ] else ...[
                        Flexible(
                            child: Container(
                          width: 150,
                          height: 150,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2, color: GuardadoLocal.colores[0])),
                          child: Center(
                              child: Text("NADA ESCOGIDO**",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: GuardadoLocal.colores[0]))),
                        ))
                      ],
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: FloatingActionButton(
                              onPressed: () {
                                if (imagenEscogida == null) {
                                  imagenEscogida = "";
                                }
                                formularios.insert(
                                    i + 2 + formularios[i + 1] * 3,
                                    controlador.text);
                                formularios.insert(
                                    i + 2 + formularios[i + 1] * 3 + 1,
                                    imagenEscogida);
                                formularios.insert(
                                    i + 2 + formularios[i + 1] * 3 + 2, 0);
                                formularios[i + 1]++;

                                controlador.text = "";
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.add,
                                color: GuardadoLocal.colores[2],
                              ))),
                    ]));
              });
        });
  }

  dialogAddPaso() {
    var imagenEscogida = "";
    var controlador = TextEditingController();
    var controladorStream = StreamController();

    return showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder(
              stream: controladorStream.stream,
              initialData: "",
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Dialog(
                    backgroundColor: GuardadoLocal.colores[1],
                    child: Column(children: [
                      Flexible(
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30, color: GuardadoLocal.colores[0]),
                          controller: controlador,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: GuardadoLocal.colores[0],
                                    width: 0.0),
                              ),
                              hintText: "Descripcion Paso:".toUpperCase(),
                              hintStyle:
                                  TextStyle(color: GuardadoLocal.colores[0])),
                        ),
                      ),
                      Flexible(
                          child: Container(
                              margin: EdgeInsets.all(10),
                              child: ElevatedButton(
                                  child: Text(
                                      'Pictograma desde la web de ARASAAC'
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: GuardadoLocal.colores[2])),
                                  onPressed: () async {
                                    imagenEscogida =
                                        await buscadorArasaac(context: context);
                                    controladorStream.add("");
                                  }))),
                      if (imagenEscogida != "") ...[
                        Flexible(
                            child: Image.network(imagenEscogida,
                                width: 150, height: 150)),
                      ] else ...[
                        Flexible(
                            child: Container(
                          width: 150,
                          height: 150,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2, color: GuardadoLocal.colores[0])),
                          child: Center(
                              child: Text("NADA ESCOGIDO**",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: GuardadoLocal.colores[0]))),
                        ))
                      ],
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          child: FloatingActionButton(
                              onPressed: () {
                                if (imagenEscogida == null) {
                                  imagenEscogida = "";
                                }

                                textos.add(controlador.text);
                                imagenes.add(imagenEscogida);

                                controlador.text = "";
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.add,
                                color: GuardadoLocal.colores[2],
                              ))),
                    ]));
              });
        });
  }

  // Actualizar las páginas
  void actualizar() async {
    setState(() {});
  }
}

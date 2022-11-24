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

enum SeleccionImagen { camara, galeria, video }

class PerfilTarea extends StatefulWidget {
  @override
  PerfilTareaState createState() => PerfilTareaState();
}

class PerfilTareaState extends State<PerfilTarea> {
  var tareaPerfil;
  final controladorNombre = TextEditingController();
  final controladorTexto = TextEditingController();
  var imagenPerfil;
  var fotoTomada;
  var videoTomado;
  ImagePicker capturador = new ImagePicker();
  var creando = false;
  var controladorVideo;
  var formularios = [];
  var vez = 0;
  var vez2 = 0;
  AccesoBD base = new AccesoBD();

  //Todas las tareas que el profesor selecciona para asignar al alumno
  var tareas = [];
  var nombresTareas = ["NADA SELECCIONADO"];
  var tareaElegida = "NADA SELECCIONADO";
  var idTareaElegida = null;

  bool esNuevaTareaCargando = false;
  bool esTareaEliminandose = false;

  int tareaEliminandose = 0;

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
    cargarTarea();
    actualizar();
  }

  seleccionarImagen(seleccion) async {
    try {
      if (seleccion == SeleccionImagen.camara) {
        print("Se va a abrir la cámara de fotos");
        fotoTomada = await capturador.pickImage(
          source: ImageSource.camera,
          imageQuality: 15,
        );
      } else if (seleccion == SeleccionImagen.galeria) {
        print("Se va a coger una foto de la galería");
        fotoTomada = await capturador.pickImage(
            source: ImageSource.gallery, imageQuality: 5);
      } else {
        print("Hacer un video");
        await capturador
            .pickVideo(
                source: ImageSource.camera, maxDuration: Duration(seconds: 10))
            .then((value) async {
          videoTomado = value;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            'Editar tarea: ${Sesion.seleccion.nombre}'
                    ''
                .toUpperCase(),
            style: TextStyle(color: GuardadoLocal.colores[2]),
          ),
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
    return perfilProfesor();
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
    return perfilProfesor();
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
  Widget perfilProfesor() {
    if (vez == 0) {
      controladorNombre.text = tareaPerfil.nombre.toUpperCase();
      controladorTexto.text = tareaPerfil.textos[0].toUpperCase();
      fotoTomada = tareaPerfil.imagenes[0];
      formularios = tareaPerfil.formularios;
      vez++;
    }
    if (vez2 == 0) {
      if (!tareaPerfil.videos.isEmpty) {
        videoTomado = tareaPerfil.videos[0];
        controladorVideo = VideoPlayerController.network(
            videoTomado);
         controladorVideo.initialize();
      }
      vez2++;
    }

    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              obscureText: false,
              maxLength: 40,
              style: TextStyle(fontSize: 25,color: GuardadoLocal.colores[0]),
              decoration: InputDecoration(
                enabledBorder:  OutlineInputBorder(
                  borderSide:  BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                )),
              controller: controladorNombre,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              obscureText: false,
              style: TextStyle(fontSize: 25,color: GuardadoLocal.colores[0]),
              maxLength: 500,
              decoration: InputDecoration(
                  enabledBorder:  OutlineInputBorder(
                    borderSide:  BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                  )),
              controller: controladorTexto,
            ),
          ),
          Text(
            "ELIGE UNA FOTO PARA LA TAREA: *",
            style: TextStyle(fontSize: 25.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              child: Text(
                'Haz una foto'.toUpperCase(),
                style: TextStyle(fontSize: 25,color: GuardadoLocal.colores[2]),
              ),
              onPressed: () {
                seleccionarImagen(SeleccionImagen.camara);
              }),
          Text(
            "ELIGE UN PICTOGRAMA PARA LA TAREA: *",
            style: TextStyle(fontSize: 25.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              child: Text(
                'Elige un pictograma de tu galería'.toUpperCase(),
                style: TextStyle(fontSize: 25,color: GuardadoLocal.colores[2]),
              ),
              onPressed: () {
                seleccionarImagen(SeleccionImagen.galeria);
              }),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              child: Text(
                'Elige un pictograma desde la web de ARASAAC'.toUpperCase(),
                style: TextStyle(fontSize: 25,color: GuardadoLocal.colores[2]),
              ),
              onPressed: () async {
                fotoTomada = await buscadorArasaac(context: context);
                actualizar();
              }),
          Text(
            "ELIGE UN VIDEOTUTORIAL PARA LA TAREA: ",
            style: TextStyle(fontSize: 25.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              child: Text(
                'Haz un videOtutorial'.toUpperCase(),
                style: TextStyle(fontSize: 25,color: GuardadoLocal.colores[2]),
              ),
              onPressed: () {
                seleccionarImagen(SeleccionImagen.video);
              }),
          Text(
            "CREA UN FORMULARIO: ",
            style: TextStyle(fontSize: 25.0, height: 2.0, color: GuardadoLocal.colores[0]),
          ),
          ElevatedButton(
              child: Text(
                (formularios == [])
                    ? 'Crea un formulario'.toUpperCase()
                    : "Edita el formulario".toUpperCase(),
                style: TextStyle(fontSize: 25,color: GuardadoLocal.colores[2]),
              ),
              onPressed: () async {
                dialogFormulario();
              }),
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[0])),
            height: 150,
            width: 210,
            child: fotoTomada == null
                ? Center(
                    child: Text(
                    'Ninguna foto tomada ****'.toUpperCase(),
                    textAlign: TextAlign.center,
                  ))
                : Stack(
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
          Container(
            decoration: BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[0])),
            margin: EdgeInsets.only(right: 70, left: 70, top: 20, bottom: 20),
            child: videoTomado == null
                ? Container(
                    child: Text('Ningun video tomado ****'.toUpperCase()),
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
                            style: TextStyle(fontSize: 25),
                          )),
                      alignment: Alignment.center,
                    ),
                    Container(
                      child: ElevatedButton(
                          onPressed: () {
                            videoTomado = null;
                            actualizar();
                          },
                          child: Icon(Icons.remove)),
                      alignment: Alignment.centerLeft,
                    )
                  ]),
          ),
          Visibility(
              visible: !creando,
              child: Container(
                  margin: EdgeInsets.only(top: 0),
                  child: ElevatedButton(
                    child: Text(
                      "Editar tarea".toUpperCase(),
                      style: TextStyle(
                        color: GuardadoLocal.colores[2],
                        fontSize: 25,
                      ),
                    ),
                    onPressed: () {
                      editarTarea();
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
  cargarTarea() async // EN sesion seleccion estara el id del usuario que se ha elegido
  {
    tareaPerfil = await Sesion.db.consultarIDTarea(Sesion.seleccion.id);
    actualizar();
  }

  dialogFormulario() {
    var controlador = TextEditingController();
    var controladorStream = StreamController();
    var imagenEscogida = "";
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
                                            border: Border.all(width: 1,color: GuardadoLocal.colores[0])),
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
                                            child: Icon(Icons.remove,color: GuardadoLocal.colores[2],))),
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
                                            child: Icon(Icons.queue_outlined,color: GuardadoLocal.colores[2],))),
                                  ),
                                ],
                              ),

                              for (int j = i + 2;
                              j < i + 2 + (formularios[i + 1] as int) * 3;
                              j = j + 3)
                                Container(
                                    decoration:
                                    BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[0])),
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
                                                  child: Icon(Icons.remove,color: GuardadoLocal.colores[2],))),
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
                                child: Icon(Icons.add,color: GuardadoLocal.colores[2],))),

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
                    style: TextStyle(fontSize: 35, color: GuardadoLocal.colores[0]),
                    decoration: InputDecoration(
                        enabledBorder:  OutlineInputBorder(
                          borderSide:  BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
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
                                  fontSize: 40, color: GuardadoLocal.colores[2]),
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
                              enabledBorder:  OutlineInputBorder(
                                borderSide:  BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                              ),
                              hintText: "Nombre Elemento:".toUpperCase(),
                              hintStyle: TextStyle(color: GuardadoLocal.colores[0])),
                        ),
                      ),
                      Flexible(
                          child: Container(
                              margin: EdgeInsets.all(10),
                              child: ElevatedButton(
                                  child: Text(
                                      'Elige un pictograma desde la web de ARASAAC'
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
                              decoration: BoxDecoration(border: Border.all(width: 2,color: GuardadoLocal.colores[0])),
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
                                formularios.insert(i + 2 + formularios[i + 1] * 3,
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
                              child: Icon(Icons.add,color: GuardadoLocal.colores[2],))),
                    ]));
              });
        });
  }

  editarTarea() async {
    if (controladorNombre.text.isNotEmpty) {
      creando = true;
      actualizar();

      var nombre = "" + controladorNombre.text;
      var texto = "" + controladorTexto.text;

      var orden = [];

      var textos = [];
      if (texto != "") {
        textos.add(texto);
        orden.add("T");
      }
      var imagenes = [];
      if (fotoTomada != null) {
        if (fotoTomada is String) {
          if (fotoTomada.startsWith("http")) {
            imagenes.add(fotoTomada);
          }
        } else {
          imagenes.add(File(fotoTomada.path));
          log(imagenes.toString());
        }

        orden.add("I");
      }

      var videos = [];
      if (videoTomado != null) {
        if (videoTomado is String) {
          if (videoTomado.startsWith("http")) {
            videos.add(videoTomado);
          }
        } else {
          log(videos.toString());
          videos.add(File(videoTomado.path));
          log(videos.toString());
        }

        orden.add("V");
      }

      Tarea tarea = Tarea();
      tarea.setTarea(nombre, textos, imagenes, videos, formularios, orden);

      await base.EditarTarea(tarea, tareaPerfil).then((value) {
        creando = false;

        if (value) {
          controladorNombre.text = "";
          controladorTexto.text = "";
          fotoTomada = null;
          videoTomado = null;

          displayMensajeValidacion(
              "Tarea editada correctamente\nPuedes volver a crear otra tarea:"
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
                child: Text(mensajeDeValidacion, selectionColor: Colors.black)),
          )),
    );
  }

  Widget cargando() {
    if (tareaPerfil == null)
      return Center(
        child: Text(
          '\nCARGANDO LAS TAREAS',
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

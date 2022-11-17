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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/arasaac.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
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
  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();

  var controladorVideo;
  var fotoTomada;
  var videoTomado;
  var formularios = [];
  var indiceAgrupacion = 1;
  var numCampos = 0;
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
    if(controladorVideo != null)
    controladorVideo.dispose();

    if(controladorNombre != null)
    controladorNombre.dispose();

    if(controladorTexto != null)
    controladorTexto.dispose();

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
        fotoTomada = await capturador.pickImage(
          source: ImageSource.camera,
          imageQuality: 15,
        );
      } else if (seleccion == SeleccionImagen.galeria) {
        print("Se va a coger una foto de la galería");
        fotoTomada = await capturador.pickImage(
            source: ImageSource.gallery, imageQuality: 15);
      } else {
        print("Hacer un video");
        await capturador
            .pickVideo(
          source: ImageSource.camera,
        )
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

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Crea una nueva tarea'),
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
              obscureText: false,
              maxLength: 40,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Introduce el título *',
              ),
              controller: controladorNombre,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              obscureText: false,
              maxLength: 500,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Introduce una descripción *',
              ),
              controller: controladorTexto,
            ),
          ),
          const Text(
            "Elige una foto para la tarea: *",
            style: TextStyle(fontSize: 20.0, height: 2.0, color: Colors.black),
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              child: Text('Haz una foto'),
              onPressed: () {
                seleccionarImagen(SeleccionImagen.camara);
              }),
          const Text(
            "Elige un pictograma para la tarea: *",
            style: TextStyle(fontSize: 20.0, height: 2.0, color: Colors.black),
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              child: Text('Elige un pictograma de tu galería'),
              onPressed: () {
                seleccionarImagen(SeleccionImagen.galeria);
              }),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
              child: Text('Elige un pictograma desde la web de ARASAAC'),
              onPressed: () async {
                    fotoTomada =  await buscadorArasaac(context: context);
                    actualizar();
            }

              ),


          const Text(
            "Elige un videotutorial para la tarea: ",
            style: TextStyle(fontSize: 20.0, height: 2.0, color: Colors.black),
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              child: Text('Haz un videotutorial'),
              onPressed: () {
                seleccionarImagen(SeleccionImagen.video);
              }),

          const Text(
            "Crea un formulario: ",
            style: TextStyle(fontSize: 20.0, height: 2.0, color: Colors.black),
          ),
          ElevatedButton(
              child: Text('Crea un formulario'),
              onPressed: () async {
                  dialogFormulario();

              }

          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(width: 2)),
            height: 120,
            width: 190,
            child: fotoTomada == null
                ? Center(child: Text('Ninguna foto tomada ****'))
                : Center(child: fotoTomada.startsWith("http") ? Image.network(fotoTomada): Image.file(File(fotoTomada.path)) ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(width: 2)),
            margin: EdgeInsets.only(right: 70, left: 70, top: 20, bottom: 20),
            child: videoTomado == null
                ? Container(
                    child: Text('Ningun video tomado ****'),
                    padding: EdgeInsets.only(
                        top: 100, bottom: 100, right: 10, left: 10),
                  )
                : Container(
                    child: ReproductorVideo(controladorVideo),
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, right: 10, left: 10),
                  ),
          ),
          Visibility(
              visible: !creando,
              child: Container(
                  margin: EdgeInsets.only(top: 0),
                  child: ElevatedButton(
                    child: Text(
                      "Crear nueva tarea",
                      style: TextStyle(
                        color: Colors.white,
                      ),
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
      var texto = "" + controladorTexto.text;

      var orden = [];

      var textos = [];
      if(texto != "")
        {
          textos.add(texto);
          orden.add("T");
        }
      var imagenes = [];
      if(fotoTomada != null)
        {
          if(fotoTomada is String)
            {
              if(fotoTomada.startsWith("http"))
                {
                  imagenes.add(fotoTomada);
                }
            }
          else
            {
              imagenes.add(File(fotoTomada.path));
            }

          orden.add("I");
        }

      var videos = [];
      if(videoTomado != null)
        {
          videos.add(File(videoTomado.path));
          orden.add("V");
        }


      Tarea tarea = Tarea();
      tarea.setTarea(nombre, textos, imagenes, videos, formularios,orden);

      await base.crearTarea(tarea).then((value) {
        creando = false;

        if (value) {
          controladorNombre.text = "";
          controladorTexto.text = "";
          fotoTomada = null;
          videoTomado = null;

          displayMensajeValidacion("Tarea creada correctamente\nPuedes volver a crear otra tarea:",false);
        } else {
          displayMensajeValidacion("Fallo al crear tarea, inténtelo de nuevo",true);
        }

        actualizar();
      });
    } else {
      displayMensajeValidacion("Es necesario rellenar todos los campos",true);
      actualizar();
    }
  }

  displayMensajeValidacion(mensajeDeValidacion,error)
  {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          duration: Duration(seconds: 2),
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration:  BoxDecoration(
              color: Color(error?0xFFC72C41:0xFF6BFF67),
              borderRadius: BorderRadius.all(Radius.circular(29)),
            ),
            child: Center(child:Text(mensajeDeValidacion, selectionColor: Colors.black)),
          )),
    );
  }

  // Widget para insertar el reproductor de video
  Widget ReproductorVideo(controlador) {
    return Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child: Column(children: [
      ElevatedButton(
        onPressed: () {
          if (controlador.value.isPlaying) {
            controlador.pause();
          } else {
            controlador.play();
          }
          setState(() {});
        },
        child: AspectRatio(
            aspectRatio: controlador.value.aspectRatio,
            child: VideoPlayer(controlador)),
      ),
      Icon(
        controlador.value.isPlaying ? Icons.pause : Icons.play_arrow,
        size: 20,
        semanticLabel: controlador.value.isPlaying ? "Pausa" : "Reanudar",
      ),
      Container(
        //duration of video
        child: Text("Total Duration: " + controlador.value.duration.toString()),
      ),

    ]));
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
              builder: (BuildContext context, AsyncSnapshot snapshot)
          {
            return Dialog(
                child:SingleChildScrollView(
                child: Column(children: [
                  Text("\nCrea un nuevo formulario"),

                  for (int i = 0; i < formularios.length;
                  i = i + 2 + (formularios[i + 1] as int) * 3)
                    Container(
                        child: Column(
                            children: [
                              Text(formularios[i]),
                              for (int j = i + 2; j <
                                  i + 2 + (formularios[i + 1] as int) * 3;
                              j = j + 3)
                                Container(
                                    decoration: BoxDecoration(border: Border
                                        .all(width: 2)),
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Flexible(
                                          child: Text(formularios[j]),
                                        ),
                                        Flexible(
                                          child: Container(
                                              margin: EdgeInsets.only(
                                                  right: 20, left: 10),
                                              child: Image.network(
                                                formularios[j + 1],
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                      ],
                                    )),
                            ])),


                  Text("\n Crea una agrupación"),

                  TextField(
                    controller: controlador,
                  ),

                  IconButton(onPressed:
                      () {
                          formularios.add(controlador.text);
                          formularios.add(0);
                          indiceAgrupacion = formularios.length - 1;
                          numCampos = 0;
                          controlador.text = "";

                          controladorStream.add("");

                      },
                      icon: Icon(Icons.add)),

                  Text("\n Crea un elemento"),

                  Row(children:[
                    Flexible(child:
                    TextField(
                      controller: controlador,
                    ),
                    ),

                    Flexible(child:
                    ElevatedButton(
                        child: Text('Elige un pictograma desde la web de ARASAAC'),
                        onPressed: () async {
                          imagenEscogida =  await buscadorArasaac(context: context);
                          actualizar();
                        }

                    )
                    ),
                    if(imagenEscogida != "")...[
                      Flexible(child:
                        Image.network(imagenEscogida)

                      ),
                    ]
                    else...
                      [
                        Flexible(child:
                        Container())
                      ],
                  ]

                    ),

                  IconButton(onPressed:
                      () {

                    numCampos ++;
                    formularios[indiceAgrupacion] = numCampos;
                    formularios.add(controlador.text);
                    formularios.add(imagenEscogida);
                    formularios.add(0);

                    controlador.text = "";
                    controladorStream.add("");


                  },
                      icon: Icon(Icons.add)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          margin: EdgeInsets.all(10),
                          child: ElevatedButton(
                              onPressed: () {
                                formularios = [];
                                Navigator.pop(context);
                              },
                              child: Column(children: [
                                Text('\nCancelar'),
                                Image.asset(
                                  "assets/cerrar.png",
                                  height: 100,
                                  width: 100,
                                )
                              ]))),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: ElevatedButton(
                            onPressed: () {
                              if (controlador.text != null) {

                              }

                              actualizar();

                              Navigator.pop(context);
                            },
                            child: Column(children: [
                              Text('\n Crear'),
                              Image.asset(
                                "assets/enviarunemail.png",
                                height: 100,
                                width: 100,
                              )
                            ])),
                      )
                    ],
                  )
                ]
                )
            ),
            );
          }
          );
          }
        );
  }

  // Actualizar las páginas
  void actualizar() async {
    setState(() {});
  }
}

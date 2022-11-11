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
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import "package:image_picker/image_picker.dart";
import '../Dart/tarea.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  ImagePicker capturador = new ImagePicker();

  var creando = false;

  final controladorNombre = TextEditingController();
  final controladorTexto = TextEditingController();

  var busqueda = "";
  var busquedaPrevia = "";

  StreamController<String> controladorStream = StreamController<String>.broadcast();


  var controladorBusqueda = TextEditingController();




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

    if(controladorBusqueda != null)
      controladorBusqueda.dispose();

  }

  @override
  void initState() {
    super.initState();
    //Notificacion.showBigTextNotification(title: "Vaya vaya", body: "¿Que dices? ¿creando tu primera tarea?", fln: flutterLocalNotificationsPlugin);

    /*
    controladorStream.stream.listen((event) async{



    });*/

    controladorBusqueda.addListener(() async{

      if(controladorBusqueda.text.isNotEmpty)
        {
          await http.get(Uri.parse("https://api.arasaac.org/api/pictograms/es/search/" + controladorBusqueda.text)).then((r){
            controladorStream.add(r.body);
          });
        }
      else
        {
          controladorStream.add("");
        }



    });

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


  ///Dialogo con el buscador de imagenes online de ARASAAC
  buscadorArasaac(){
    return Dialog(
      child:SingleChildScrollView(
        child: StreamBuilder(
            stream: controladorStream.stream,
            initialData: "",
            builder: (BuildContext context,
                AsyncSnapshot snapshot) {


                  var msg = snapshot.data.toString() != "" ? json.decode(snapshot.data.toString()) : "";
                  var longitud = msg.length;

                  return Column(children: [
                    TextField(controller: controladorBusqueda
                      ,decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Buscar ...',
                      ),),
                    if(snapshot.data.toString() != "")...[

                      for (int i = 0; i < longitud && i < 20; i=i+2)

                        Container(child:

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for(int j = i; j < i+2 && j < longitud; j++)
                          if(!msg[i]["sex"] && !msg[i]["violence"])...[
                            Flexible(flex: 50,
                                child:
                            buscarARASAAC(msg, j))

                          ]
                        ],)
                       )


                      ]
                  ]);



            }
        )
      )

    );

}

buscarARASAAC(mensaje,i){

  return Container(
      child: 
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
            ),
              onPressed: (){
                fotoTomada = "https://api.arasaac.org/api/pictograms/" +
                    mensaje[i]["_id"].toString();
                actualizar();
                Navigator.pop(context, false);
              },
              child:
                  Column(
                    children:[
                      Center(child:Text(mensaje[i]["keywords"][0]["keyword"],style: TextStyle(color: Colors.black),)),
                      Image.network(
                          "https://api.arasaac.org/api/pictograms/" +
                              mensaje[i]["_id"].toString()),
                    ]
                  )

              
          )
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
              maxLength: 60,
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
          ElevatedButton(
              child: Text('Elige un pictograma desde la web de ARASAAC'),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context)
                      {
                      return buscadorArasaac();
                      }
                    );
            }

              ),


          const Text(
            "Elige un videotutorial para la tarea: *",
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
      tarea.setTarea(nombre, textos, imagenes, videos, orden);

      await base.crearTarea(tarea).then((value) {
        creando = false;

        if (value) {
          controladorNombre.text = "";
          controladorTexto.text = "";
          fotoTomada = null;
          videoTomado = null;

          displayMensajeValidacion("Tarea creada correctamente\nPuedes volver a crear otra tarea:");
        } else {
          displayMensajeValidacion("Fallo al crear tarea, inténtelo de nuevo");
        }

        actualizar();
      });
    } else {
      displayMensajeValidacion("Es necesario rellenar todos los campos");
      actualizar();
    }
  }

  displayMensajeValidacion(mensajeDeValidacion)
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
            decoration: const BoxDecoration(
              color: Color(0xFF6BFF67),
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

      /*
                Container(
                    child: VideoProgressIndicator(
                        controlador,
                        allowScrubbing: true,
                        colors:VideoProgressColors(
                          backgroundColor: Colors.black,
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                        )
                    )
                ),*/
    ]));
  }

  // Actualizar las páginas
  void actualizar() async {
    setState(() {});
  }
}

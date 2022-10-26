import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';


import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

import "package:flutter_tts/flutter_tts.dart";

import '../Dart/main.dart';
import '../Dart/notificacion.dart';
import '../Dart/tarea.dart';

enum SeleccionImagen{
  camara,
  galeria,
  video
}


class CrearTarea extends StatefulWidget{

  @override
  CrearTareaState createState() => CrearTareaState();

}

class CrearTareaState extends State<CrearTarea>{

  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();

  var controladorVideo;
  var fotoTomada;
  var videoTomado;
  ImagePicker capturador = new ImagePicker();

  var creando = false;
  var mensajeDeValidacion = "";



  final controladorNombre = TextEditingController();
  final controladorTexto = TextEditingController();



  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose(){

    super.dispose();
    controladorVideo.dispose();
    controladorNombre.dispose();
    controladorTexto.dispose();
  }



  @override
  void initState(){
    super.initState();
    //Notificacion.showBigTextNotification(title: "Vaya vaya", body: "¿Que dices? ¿creando tu primera tarea?", fln: flutterLocalNotificationsPlugin);

    Sesion.paginaActual = this;

  }

  ///introduce en el atributo @fototomada la imagen, @seleccion nos indica si el método va a ser desde la cámara o de galería
  seleccionarImagen(seleccion) async{

    try {
      if(seleccion == SeleccionImagen.camara)
        {
      print("Se va a abrir la cámara de fotos");
        fotoTomada =  await capturador.pickImage(
            source: ImageSource.camera,
            imageQuality: 15,

        );}
    else if(seleccion == SeleccionImagen.galeria)
      {
        print("Se coger una foto de la galería");
        fotoTomada =  await capturador.pickImage(
            source: ImageSource.gallery,
            imageQuality: 15);
      }
    else {
        print("Hacer un video");
        await capturador.pickVideo(
          source: ImageSource.camera,
        ).then((value) async{
          videoTomado = value;
          controladorVideo = await VideoPlayerController.file(File(value?.path as String));
          await controladorVideo.initialize();
          actualizar();

          print(controladorVideo.value.duration.toString());
        });




      }

    }
    catch(e){
      print(e);
    }
    actualizar();
  }


  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context){
    
    return

      new Scaffold(

        appBar:AppBar(

          title: Text('Crea una nueva tarea'),
        ),
        body: Sesion.rol == Rol.administrador.toString()
              ?VistaAdministrador()
              :VistaProfesor()

      );


  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor()
  {
    Navigator.pop(context);
    return
      Container(
      );
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno()
  {
    Navigator.pop(context);
    return
      Container(
      );
  }


  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador()
  {
    return
      SingleChildScrollView(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children: <Widget>[


            Text("\nRegistra un nuevo usuario:"),

            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border:OutlineInputBorder(),
                hintText: 'Introduce nombre',
              ),
              controller: controladorNombre,
            ),

            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border:OutlineInputBorder(),
                hintText: 'Introduce texto',
              ),
              controller: controladorTexto,
            ),


            ElevatedButton(
                child: Text('Haz una foto'),
                onPressed: (){seleccionarImagen(SeleccionImagen.camara);}
            ),
            ElevatedButton(
                child: Text('Elige un pictograma de tu galería'),
                onPressed: (){seleccionarImagen(SeleccionImagen.galeria);}
            ),

            ElevatedButton(
                child: Text('Haz un videotutorial'),
                onPressed: (){seleccionarImagen(SeleccionImagen.video);}
            ),


            Container(
              height: 100,
              width: 100,
                child: fotoTomada == null
                  ? Center()
                  : Center(child: Image.file(File(fotoTomada.path))),
            ),


            



            SizedBox(
              height: 200,
              width: 200,
              child: videoTomado == null
                  ? Center(child: Text('Ningun video tomado'))
                  : Center(child:ReproductorVideo(controladorVideo)),
            ),


            Text(mensajeDeValidacion),


            Visibility(
                visible: !creando,
                child:

            TextButton(
              child: Text("Crear nueva tarea",
                style: TextStyle(
                    color: Colors.cyan,
                    decorationColor: Colors.lightBlueAccent
                ),
              ),
              onPressed: () {
                crearTarea();
              },

            )
            ),


            Visibility(
                visible: creando,
                child: new CircularProgressIndicator()

            ),

          ],
        ),
      );
  }

  //Método para registrar usuario
  crearTarea() async
  {

    if(controladorNombre.text.isNotEmpty && videoTomado != null && fotoTomada != null)
    {
      creando = true;
      actualizar();

      var nombre = "" + controladorNombre.text;
      var texto = "" + controladorTexto.text;

      var textos = [];
      textos.add(texto);
      var imagenes = [];
      imagenes.add(File(fotoTomada.path));

      var videos = [];
      videos.add(File(videoTomado.path));

      var orden = ["T","I","V"];


      Tarea tarea = Tarea();
      tarea.setTarea(
          nombre,textos,imagenes,videos,orden);


      await base.crearTarea(tarea).then((value) {
        creando = false;

        if (value) {
          controladorNombre.text = "";
          controladorTexto.text = "";
          fotoTomada = null;
          videoTomado = null;

          mensajeDeValidacion =
          "Tarea creada correctamente\nPuedes volver a crear otra tarea:";
        }
        else {
          mensajeDeValidacion = "Fallo al crear tarea, inténtelo de nuevo";
        }

        actualizar();
      });
    }
    else
      {
        mensajeDeValidacion = "Es necesario rellenar todos los campos";
        actualizar();
      }
  }



  Widget ReproductorVideo(controlador)
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child:Column(
              children:[

                ElevatedButton(

                  onPressed: (){
                              if(controlador.value.isPlaying){
                              controlador.pause();
                              }else{
                              controlador.play();
                              }
                              setState(() {
                              });
                      },
                    child: AspectRatio(
                        aspectRatio: controlador.value.aspectRatio ,
                        child: VideoPlayer(controlador)
                    ),
                ),

                Icon(
                    controlador.value.isPlaying?Icons.pause:Icons.play_arrow,
                  size: 20,
                  semanticLabel: controlador.value.isPlaying?"Pausa":"Reanudar",
                ),



                Container( //duration of video
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

              ]
          )

      );
  }


  void actualizar() async
  {
    setState((){});
  }

}









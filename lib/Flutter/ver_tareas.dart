import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/myhomepage.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/clase.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

import "package:flutter_tts/flutter_tts.dart";


class VerTareas extends StatefulWidget{

  @override
  VerTareasState createState() => VerTareasState();

}

class VerTareasState extends State<VerTareas>{


  var msg = "null";
  var imagen = null;
  var video = null;
  var alumnos = [];
  var fotoTomada;
  ImagePicker capturador = new ImagePicker();

  var registrando = false;
  var mensajeDeRegistro = "";

  var indiceTextos = 0;
  var indiceImagenes = 0;
  var indiceVideos = 0;

  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();

  var controladoresVideo = [];

  var lenguajes;

  FlutterTts tts = new FlutterTts();


  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose(){

    for(int i = 0; i < Sesion.controladoresVideo.length;i++)
      {
        Sesion.controladoresVideo[i].dispose();
      }

    Sesion.controladoresVideo.clear();

    super.dispose();
  }



  @override
  void initState(){
    super.initState();

    Sesion.paginaActual = this;

    Sesion.seleccion = "";
    Sesion.tareas = [];
    Sesion.controladoresVideo = [];


    if(Sesion.rol == Rol.alumno.toString())
    {
      print("Cargando tareas");
      cargarTareas();
    }


  }


  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context){
    
    return

       new Scaffold(

        appBar:AppBar(

          title: Text('Tareas'),
        ),
        body: Container(

            padding: EdgeInsets.symmetric(vertical: 0, horizontal:  0),
            child: Column(
              children: [


                if(Sesion.rol == Rol.alumno.toString())...[
                  VistaAlumno(),
                ]
                else if(Sesion.rol == Rol.profesor.toString())...[
                  VistaProfesor()
                ]
                else if(Sesion.rol == Rol.administrador.toString())...[
                    VistaAdministrador()
                  ]
                  else if(Sesion.rol == Rol.programador.toString())...[
                      VistaProgramador()
                    ]
              ],
            )




        ),
      );


  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor()
  {
    return
      Container(
      );
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno()
  {
    return
    Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      alignment: Alignment.center,
      child:Column(
        children:[
          Text("Eres un alumno"),


          if(Sesion.tareas != null)...[
            for(int i = 0; i < Sesion.tareas.length; i++)
            //TAREA
              Container(
                constraints: BoxConstraints(maxWidth: 200,minWidth: 200),
                width: 50,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(20)),
                alignment: Alignment.center,
                child: Column(children: [


                  Text(Sesion.tareas[i].nombre,
                    style: TextStyle(
                      color: Colors.white,

                    ),
                  ),

                  resetIndicesTarea(),
                  for(int j = 0; j < Sesion.tareas[i].orden.length; j++)
                    LecturaTarea(Sesion.tareas[i].orden[j],i)


                ]

                ),
              ),
            resetIndicesVideos()
          ],


        ],
      ),
    );
  }


  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador()
  {
    return
      Container(
        );
  }


  /*
  *
  * */
  Widget LecturaTarea(String valor, i){

    if(valor == "T")
      {
        String pathTexto = Sesion.tareas[i].textos[indiceTextos];
        incIndiceTextos();
        return
        Text(pathTexto
          ,style: TextStyle(
          color: Colors.white,
          )
        );
      }
    else if(valor == "I")
      {
        String pathImagen = Sesion.tareas[i].imagenes[indiceImagenes];
        incIndiceImagenes();
        return
          Image.network(pathImagen);
      }
    else if(valor == "V" && Sesion.controladoresVideo.length > 0 )
      {
        return  ReproductorVideo(Sesion.controladoresVideo[indiceVideos++]);
      }

    else return
        Container();
  }

  Widget VistaProgramador()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un programador")

          ],
        ),
      );
  }


  Widget ReproductorVideo(controlador)
  {
    return
          Column(
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
                  child: Column(
                    children: [
                      AspectRatio(
                          aspectRatio: controlador.value.aspectRatio ,
                          child: VideoPlayer(controlador)
                      ),
                      Icon(
                        controlador.value.isPlaying?Icons.pause:Icons.play_arrow,
                        size: 20,
                        semanticLabel: controlador.value.isPlaying?"Pausa":"Reanudar",
                      ),


                      Container( //duration of video
                        child: Text("Total Duration: " + controlador.value.duration.toString()),
                      ),

                    ]


                  )
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


      );
  }


  cargarTareas() async {
    await base.consultarTareasAsignadasAlumno(Sesion.id,true);
  }


  Widget resetIndicesTarea(){
    indiceImagenes = 0;
    indiceTextos = 0;


    return Container();
  }

  Widget resetIndicesVideos(){
    indiceVideos = 0;

    return Container();
  }
  
  void incIndiceImagenes(){
    indiceImagenes++;
  }


  void incIndiceTextos(){
    indiceTextos++;
  }

  void incIndiceVideos(){
    indiceVideos++;
  }

 void actualizar() async
  {
    setState((){});
  }

  void _speak(text) async{
    await tts.speak(text);
  }

}









import 'dart:html';
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
  int tareaActual = 0;

  double offSetActual = 0;
  ScrollController homeController = new ScrollController();
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
          leading: IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Tareas'),
        ),
        body: Container(

            padding: EdgeInsets.symmetric(vertical: 0, horizontal:  0),
            child: Stack(
              children: [

                if(Sesion.rol == Rol.alumno.toString())...[
                  //BotonIzq(),
                  //BotonDer(),
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
          /*Container(
            constraints: BoxConstraints(maxWidth: 200,minWidth: 200),
            width: 50,
            margin: EdgeInsets.all(100),
            decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent)
            ),
            alignment: FractionalOffset(0.5,0.5),

            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Sesion.tareas[TareaActual].nombre,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  resetIndicesTarea(),
                  for(int j = 0; j < Sesion.tareas[TareaActual].orden.length; j++)
                    LecturaTarea(Sesion.tareas[TareaActual].orden[j],TareaActual)
                ]

            ),
          );*/

       ListView(
          children: <Widget>[
      if(Sesion.tareas != null)...[
        Wrap(
          //ROW 2
          alignment: WrapAlignment.end,
          //spacing: 800,
          children: [

            Container(
              child:
              Text("${Sesion.nombre}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
    Row(
    //ROW 2
    mainAxisAlignment: MainAxisAlignment.spaceBetween,

    children: [
      Container(
          margin: EdgeInsets.only(top: 100.0),
          child: FloatingActionButton(
              onPressed: (){

                if(tareaActual > 0){
                  tareaActual--;
                  resetIndicesTarea();
                  actualizar();
                }
                print(tareaActual);
              },
              child: const Icon(Icons.arrow_left)
          ),
      ),

      Container(
        width: 500.0,
        height: 500.0,
        decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent)
        ),
        margin: EdgeInsets.only(top: 50.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(Sesion.tareas[tareaActual].nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30.0,
              ),
            ),

            SizedBox(height: 50),

            Text("AQUI VA EL VIDEO",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 100),
            Text("AQUI VA LA LISTA DE PASOS PARA COMPLETAR LA TAREA",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ]

      ),
      ),

      Container(
      margin: EdgeInsets.only(top: 100.0),
      child:FloatingActionButton(
          onPressed: (){

            if(tareaActual < Sesion.tareas.length -1){
              tareaActual++;
              resetIndicesTarea();
              actualizar();
            }
            print(tareaActual);
          },
          child: const Icon(Icons.arrow_right)
      ),
      ),
    ],
  ),
    ]
      ]
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

  buildLandscape()
  {
    return
      SingleChildScrollView(
        controller: homeController,
        child: VistaTareas(),
      );
  }


  buildPortrait()
  {
    return
      SingleChildScrollView(
        controller: homeController,
        child: VistaTareas(),
      );

  }

  VistaTareas()
  {
            if(Sesion.rol == Rol.alumno.toString()) {
              return VistaAlumno();
             }
            else if(Sesion.rol == Rol.profesor.toString()) {
              return VistaProfesor();
            }
            else if(Sesion.rol == Rol.administrador.toString()) {
              return VistaAdministrador();
            }
              else if(Sesion.rol == Rol.programador.toString()) {
              return VistaProgramador();
            }

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









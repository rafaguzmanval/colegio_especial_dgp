
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

  bool verFlechaIzquierda = false;
  bool verFlechaDerecha = true;



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

       Column(
              children: <Widget>[

            Wrap(
              //ROW 2
              alignment: WrapAlignment.end,
              //spacing: 800,
              children: [

                Container(
                  child:
                  Text("${Sesion.nombre}",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
            if(Sesion.tareas.length > 0)...[

              Row(
              //ROW 2
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Visibility(child:
                  Container(
                      margin: EdgeInsets.only(top: 100.0),
                      child: FloatingActionButton(
                          onPressed: (){

                            if(tareaActual > 0){
                              tareaActual--;
                              verFlechaDerecha = true;

                            }
                            verFlechaIzquierda = tareaActual != 0;


                            actualizar();

                          },
                          child: const Icon(Icons.arrow_left)
                      ),
                  ),
                  visible: verFlechaIzquierda,
                ),





                Container(

                    color: Color.fromRGBO(143, 125, 178,1),
                  child: Column(
                    children: [
                      Text(Sesion.tareas[tareaActual].nombre,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),

                      resetIndicesTarea(),
                      for(int j = 0; j < Sesion.tareas[tareaActual].orden.length; j++)
                        LecturaTarea(Sesion.tareas[tareaActual].orden[j],tareaActual)
                    ]

                    ),
                  ),

                      Visibility(child:
                      Container(
                        margin: EdgeInsets.only(top: 100.0),
                        child:FloatingActionButton(
                            onPressed: (){

                              if(tareaActual < Sesion.tareas.length ){
                                tareaActual++;
                                verFlechaIzquierda = true;

                              }

                              verFlechaDerecha = tareaActual != Sesion.tareas.length - 1;

                              actualizar();
                            },
                            child: const Icon(Icons.arrow_right)
                        ),
                      ),
                        visible: verFlechaDerecha,
                      )
                    ]



                ),








              ],

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

    if(valor == "T" && Sesion.tareas[i].textos.length > indiceTextos)
      {
        String pathTexto = Sesion.tareas[i].textos[indiceTextos];
        indiceTextos++;
        return
        Text(pathTexto
          ,style: TextStyle(
          color: Colors.white,
          )
        );
      }
    else if(valor == "I" && Sesion.tareas[i].imagenes.length > indiceImagenes)
      {

        String pathImagen = Sesion.tareas[i].imagenes[indiceImagenes];
        indiceImagenes++;

        return
          Image.network(pathImagen, width: 200, height: 200);
      }
    else if(valor == "V" && Sesion.tareas[i].controladoresVideo.length > 0 )
      {
        return Container( width: 200,height: 200, child:ReproductorVideo(Sesion.tareas[i].controladoresVideo[indiceVideos++]));
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
                          aspectRatio: 16.0/9.0 ,
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
    indiceVideos = 0;

    return Container();
  }



 void actualizar() async
  {
    setState((){});
  }


}









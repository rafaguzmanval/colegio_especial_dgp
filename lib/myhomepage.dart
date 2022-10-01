
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Sesion.dart';
import 'package:colegio_especial_dgp/discapacidad.dart';
import 'package:colegio_especial_dgp/perfilalumno.dart';
import 'package:colegio_especial_dgp/rol.dart';
import 'clase.dart';
import 'usuario.dart';

import 'package:colegio_especial_dgp/AccesoBD.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';






class MyHomePage extends StatefulWidget{

  @override
  MyHomePageState createState() => MyHomePageState();

}

class MyHomePageState extends State<MyHomePage>{

  late VideoPlayerController controller;

  var msg = "null";
  var imagen = null;
  var video = null;
  var alumnos = [];

  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();
  

  @override
  void initState(){
    super.initState();
   /* var alumno1 = Alumno("Pepito","Perez","MierdaDeContraseña","2/5/1998",Discapacidad.sindromeDown,Clase("",[],[]));
    var profesor1 = Profesor("Pepa", "Castro", "OtraMierdaContraseña", "3/7/1976", []);
    base.registrarUsuario(alumno1);
    base.registrarUsuario(profesor1);*/
    //lecturaDatos("usuarios");
    //lecturaImagen("AppStorage/ugr.png");
    //lecturaVideo("Vídeos/video.mp4");

    Sesion.paginaActual = this;

    if(Sesion.rol == Rol.profesor.toString())
    {
      cargarAlumnos();
    }

    if(Sesion.rol == Rol.alumno.toString())
    {
      print("Cargando tareas");
      cargarTareas();
    }


  }

  @override
  Widget build(BuildContext context){


    return Scaffold(
      appBar:AppBar(
        title: Text('Hola ${Sesion.nombre}'),
            automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal:  200),
        child: Column(
          children: [


            if(Sesion.rol == Rol.alumno.toString())...[
              VistaAlumno()
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


  Widget VistaProfesor()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un profesor"),

            for(int i = 0; i < alumnos.length; i++)
              Container(
                  constraints: BoxConstraints(maxWidth: 70,minWidth: 30),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  child: FlatButton(
                    child: Text(alumnos[i].nombre,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Sesion.seleccion = alumnos[i].id;
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => perfilAlumno()));
                    },


                  )

              )

          ],
        ),
      );
  }


  Widget VistaAlumno()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child:Column(
              children:[
                        Text("Eres un alumno"),


                        for(int i = 0; i < Sesion.misTareas.length; i++)
                          Container(
                              constraints: BoxConstraints(maxWidth: 70,minWidth: 30),
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.cyan,
                                  borderRadius: BorderRadius.circular(20)),
                              alignment: Alignment.center,
                                child: Text(Sesion.misTareas[i],
                                  style: TextStyle(
                                    color: Colors.white,

                                ),


                              )

                          ),

                          FloatingActionButton(
                              onPressed: (){actualizar();} ,
                              child: const Icon(Icons.refresh),

                          )



                    ],
                  ),
      );
  }


  Widget VistaAdministrador()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un profesor")

          ],
        ),
      );
  }

  Widget VistaProgramador()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un profesor")

          ],
        ),
      );
  }


  Widget ReproductorVideo()
  {
    return
    Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child:Column(
        children:[
          
          AspectRatio(
            aspectRatio: controller.value.aspectRatio ,
            child: VideoPlayer(controller)
          ),

          Container( //duration of video
            child: Text("Total Duration: " + controller.value.duration.toString()),
          ),

          Container(
              child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors:VideoProgressColors(
                    backgroundColor: Colors.black,
                    playedColor: Colors.red,
                    bufferedColor: Colors.grey,
                  )
              )
          ),

          Container(
            child: Row(
              children: [
                IconButton(
                    onPressed: (){
                      if(controller.value.isPlaying){
                        controller.pause();
                      }else{
                        controller.play();
                      }

                      setState(() {

                      });
                    },
                    icon:Icon(controller.value.isPlaying?Icons.pause:Icons.play_arrow)
                ),

              ],
            ),
          )
        ]
      )

    );
  }

  cargarAlumnos() async{
    alumnos = await base.consultarTodosAlumnos();
    actualizar();
  }

  cargarTareas() async {
    await base.consultarTareas(Sesion.id);
    actualizar();
  }

  lecturaImagen(path)
  {
    var future = base.leerImagen(path);

    future.then((value){
      imagen = value;
      actualizar();

    });
  }

  lecturaVideo(path){

    var future = base.leerVideo(path);

    future.then((value){
      video = value;
      controller = VideoPlayerController.network(video);
      controller.initialize().then((value){
        setState(() {});
      });
      actualizar();
    });
  }

  lecturaDatos(path)
  {
    var future = base.leerDatos(path);

    future.then((value){
      msg = value;
      actualizar();

    });
  }



 void actualizar() async
  {
    //var reloj = 1;
    //await Future.delayed(Duration(seconds:reloj));
    setState(() {

    });
  }


  consultarTareas(id)
  {
    final ref = db.collection("usuarios");

    ref.doc(id).withConverter(
        fromFirestore: Usuario.fromFirestore,
        toFirestore: (Usuario user, _) => user.toFirestore()).snapshots().listen((event) {
      var usuario = event.data();
      Sesion.misTareas = usuario?.tareas;
      actualizar();
    });

  }

}









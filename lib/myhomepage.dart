
import 'package:colegio_especial_dgp/Sesion.dart';
import 'package:colegio_especial_dgp/discapacidad.dart';
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

  AccesoBD base = new AccesoBD();
  

  @override
  void initState(){
    super.initState();
   /* var alumno1 = Alumno("Pepito","Perez","MierdaDeContraseña","2/5/1998",Discapacidad.sindromeDown,Clase("",[],[]));
    var profesor1 = Profesor("Pepa", "Castro", "OtraMierdaContraseña", "3/7/1976", []);
    base.registrarUsuario(alumno1);
    base.registrarUsuario(profesor1);*/
    lecturaDatos("usuarios");
    lecturaImagen("AppStorage/ugr.png");
    lecturaVideo("Vídeos/video.mp4");
  }

  @override
  Widget build(BuildContext context){

    //base.escribirDatos();

    return Scaffold(
      appBar:AppBar(
        title: Text('Hola ${Sesion.nombre}'),
            automaticallyImplyLeading: false,
      ),
      body: Container(
        child: Column(
          children: [
            Text("ERES ${Sesion.rol}" ),
            if(imagen != null)...[
              Image.memory(imagen)
            ]else...[
              new CircularProgressIndicator(),
              Text("Cargando la imagen")
            ],
            if(video != null)...[
              ReproductorVideo()
            ]else...[
              new CircularProgressIndicator(),
              Text("Cargando el video ")
            ],
            //Text(msg),
          ],
        )


      ),
    );
  }


  Widget ReproductorVideo()
  {
    return
    Container(
      padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
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
                    backgroundColor: Colors.redAccent,
                    playedColor: Colors.green,
                    bufferedColor: Colors.purple,
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

                IconButton(
                    onPressed: (){
                      controller.seekTo(Duration(seconds: 0));

                      setState(() {

                      });
                    },
                    icon:Icon(Icons.stop)
                )
              ],
            ),
          )
        ]
      )

    );
  }

  lecturaImagen(path)
  {
    var future = base.leerImagen(path);

    future.then((value){
      imagen = value;
      _actualizar();

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
      _actualizar();
    });
  }

  lecturaDatos(path)
  {
    var future = base.leerDatos(path);

    future.then((value){
      msg = value;
      _actualizar();

    });
  }



  void _actualizar() async
  {
    //var reloj = 1;
    //await Future.delayed(Duration(seconds:reloj));
    setState(() {

    });
  }

}









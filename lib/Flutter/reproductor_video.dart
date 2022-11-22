
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';

String _duracionVideo(Duration duracion){
  String dosDigitos(int n) => n.toString().padLeft(2,'0');
  final horas = dosDigitos(duracion.inHours);
  final minutos = dosDigitos(duracion.inMinutes.remainder(60));
  final segundos = dosDigitos(duracion.inSeconds.remainder(60));

  return [
    if(duracion.inHours>0) horas,
    minutos,
    segundos
  ].join(':');
}

ventanaVideo(controlador,context){
  var controladorStream = StreamController();

  showDialog(context: context, builder: (context){

    return WillPopScope(child: Dialog(
        child: StreamBuilder(stream: controladorStream.stream,
            builder: (BuildContext context,AsyncSnapshot snapshot)
            {
              return Container(
                  color: GuardadoLocal.colores[0],
                  //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
                  child:
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Expanded(
                            flex: 12,
                            child:
                            ElevatedButton(
                                onPressed: () {
                                  if (controlador.value.isPlaying) {
                                    controlador.pause();
                                  } else {
                                    controlador.play();
                                  }
                                  controladorStream.add("");
                                },
                                child:
                                AspectRatio(
                                  aspectRatio: controlador.value.aspectRatio,
                                  child: VideoPlayer(controlador),))
                        ),
                        Expanded(child:
                        Row(
                            children:[
                              ValueListenableBuilder(valueListenable: controlador, builder: (context, VideoPlayerValue value, child){
                                return Text(
                                  _duracionVideo(value.position),
                                  style: TextStyle(
                                    color: GuardadoLocal.colores[2],
                                  ),
                                );
                              }),
                              Expanded(
                                  child:
                                  SizedBox(
                                      height: 40,
                                      child:
                                      VideoProgressIndicator(controlador, allowScrubbing: true,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0,
                                            horizontal: 12),))
                              ),
                              Text(
                                _duracionVideo(controlador.value.duration),
                                style: TextStyle(
                                  color: GuardadoLocal.colores[2],
                                ),)
                            ]
                        )
                        )
                      ]
                  )
              );
            }
        ),
        ),
        onWillPop: (){
          controlador.pause();
          return Future.value(true);
        });

  }

  );



}
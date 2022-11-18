
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

ventanaVideo(controlador,context){
  var controladorStream = StreamController();

  showDialog(context: context, builder: (context){

    return Dialog(
        child: StreamBuilder(stream: controladorStream.stream,
            builder: (BuildContext context,AsyncSnapshot snapshot)
            {
              return Container(
                //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
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
                  child: AspectRatio(
                    aspectRatio: controlador.value.aspectRatio,
                    child: /*Column(children: [*/
                    VideoPlayer(controlador),
                    /*Icon(
                            controlador.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 20,
                            semanticLabel: controlador.value.isPlaying ? "Pausa" : "Reanudar",
                          ),
                          Container(
                            //duration of video
                            child: Text("Duración del video: " +
                                (controlador.value.duration.inSeconds / 3600).toString() + " : "
                                + ((controlador.value.duration.inSeconds / 60) % 60 ).toString()  + " : "
                                + (controlador.value.duration.inSeconds % 60).toString()),
                          ),

                        ],)*/),
                ),


              );
            }
        )
    );

  }

  );

}
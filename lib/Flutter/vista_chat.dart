import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/lista_mensajes.dart';
import 'package:colegio_especial_dgp/Flutter/reproductor_video.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../Dart/arasaac.dart';
import '../Dart/mensaje.dart';
import '../Dart/guardado_local.dart';
import 'lista_mensajes.dart';

class VistaChat extends StatefulWidget {
  final chatId;
  final foto;
  final nombre;
  final idInterlocutor;

  const VistaChat(
      {Key? key,
        required this.chatId,
        required this.foto,
        required this.nombre,
        required this.idInterlocutor})
      : super(key: key);

  @override
  State<VistaChat> createState() => _VistaChatState();
}

class _VistaChatState extends State<VistaChat> {
  StreamController chatsController = new StreamController();
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  ImagePicker capturador = new ImagePicker();
  var idChat;
  var scrollDown = 0;

  var mensajes = [];

  tomarFoto() async {
    return await capturador.pickImage(
      source: ImageSource.camera,
      imageQuality: 15,
    );
  }

  grabarVideo() async {
    return await capturador.pickVideo(
      source: ImageSource.camera, maxDuration: Duration(seconds: 30));
  }

  galeriaFoto() async{
    return await capturador.pickImage(
        source: ImageSource.gallery, imageQuality: 5);
  }

  galeriaVideo() async{
    return await capturador.pickVideo(
        source: ImageSource.gallery);
  }

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;
    idChat = widget.chatId;

    if(widget.chatId!='')
      cargaMensajes();
  }

  @override
  void dispose(){
    Sesion.db.desactivarSubscripcionChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
            onPressed: () {
              Navigator.pop(context);

            }),
        title:  ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: GuardadoLocal.colores[2],
            backgroundImage: NetworkImage(
              widget.foto,
            ),
          ),
          title: Text(
            widget.nombre.toUpperCase(),
            style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          // chat messages here
          mensajesChat(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                color: GuardadoLocal.colores[0],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: GuardadoLocal.colores[2],
                      width: 1)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              child: Row(children: [
                GestureDetector(
                  onTap: () async{
                    return opcionesAdjunto();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: GuardadoLocal.colores[0],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                        child: Icon(
                          Icons.attach_file,
                          color: GuardadoLocal.colores[2],
                        )),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(child:Container(
                    padding: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: GuardadoLocal.colores[1],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      controller: messageController,
                      style: TextStyle(color: GuardadoLocal.colores[0]),
                      decoration: InputDecoration(
                        hintText: "Envia un mensaje...".toUpperCase(),
                        hintStyle: TextStyle(color: GuardadoLocal.colores[0], fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ))),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    enviarMensaje(null,'texto');
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: GuardadoLocal.colores[2],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                        child: Icon(
                          Icons.send,
                          color: GuardadoLocal.colores[0],
                        )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  mensajesChat() {
    return StreamBuilder(
      stream: chatsController.stream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData //snapshot.hasData
            ? Expanded(
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: mensajes.length,
                itemBuilder: (context, index) {
                  if(scrollDown<mensajes.length){
                    scrollDown++;
                    WidgetsBinding.instance.addPostFrameCallback((_){
                      if(_scrollController.hasClients){
                        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds:50), curve: Curves.easeOut);
                        }
                    });
                  }
                  return ListaMensajes(
                      mensaje: mensajes[index].contenido,
                      enviadoPorMi: mensajes[index].idUsuarioEmisor==Sesion.id,
                      fecha:mensajes[index].fechaEnvio,
                      tipo:mensajes[index].tipo);
                },
              ),
            )
            : Container();
      },
    );
  }

  enviarMensaje(multimedia,tipo) async{
    if (messageController.text.isNotEmpty || multimedia != null) {
      Mensaje msg;
      if(tipo == 'texto')
       msg = Mensaje(idChat, Sesion.id, widget.idInterlocutor, tipo, messageController.text.toUpperCase(), DateTime.now().millisecondsSinceEpoch);
      else
        msg = Mensaje(idChat, Sesion.id, widget.idInterlocutor, tipo, multimedia , DateTime.now().millisecondsSinceEpoch);

      await Sesion.db.addMensaje(msg);

      if(idChat == ''){
        idChat = await Sesion.db.buscarIdChat(Sesion.id, widget.idInterlocutor);
        cargaMensajes();
      }

      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds:50), curve: Curves.easeOut);
      setState(() {
        messageController.clear();
      });
    }
  }

  cargaMensajes() async{
    await Sesion.db.obtenerMensajes(idChat);
  }

  actualizarMensajes(listaMensajes){
    mensajes = listaMensajes;
    chatsController.add('');
    setState(() {});

    if(mounted)
      {
        mensajes = listaMensajes;
        chatsController.add('');
      }
  }

  opcionesAdjunto(){
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              alignment: Alignment.bottomCenter,
              backgroundColor: GuardadoLocal.colores[0],
              child: SingleChildScrollView(
                child: Column(children: [
                  Column(children: [
                    Container(
                        padding:EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                            color: GuardadoLocal.colores[1],
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: GuardadoLocal.colores[0])
                        ),

                        ///TOMAR UNA FOTO DE LA CÁMARA
                        child: GestureDetector(onTap: ()async{return opcionesCamara();},
                            child: Row(mainAxisAlignment: MainAxisAlignment.start,children:[
                              Icon(Icons.camera_alt,color: GuardadoLocal.colores[0],),
                              const SizedBox(
                                width: 2,
                              ),
                              Text('CÁMARA',style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 30),)
                            ])
                        )),

                    ///COGER UN ARCHIVO DESDE LA GALERÍA
                    Container(
                        padding:EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                            color: GuardadoLocal.colores[1],
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: GuardadoLocal.colores[0])
                        ),
                        child: GestureDetector(onTap: (){return opcionesGaleria();},
                            child: Row(mainAxisAlignment: MainAxisAlignment.start,children:[
                              Icon(Icons.photo,color: GuardadoLocal.colores[0],),
                              const SizedBox(
                                width: 2,
                              ),
                              Text('GALERÍA',style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 30),)
                            ])
                        )),
                  ],),
                  ///COGER UN ARCHIVO DESDE ARASAAC
                  Container(
                      padding:EdgeInsets.only(left: 1),
                      decoration: BoxDecoration(
                          color: GuardadoLocal.colores[1],
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: GuardadoLocal.colores[0])
                      ),
                      child: GestureDetector(
                          onTap: () async{
                            String fotoEnviada = await buscadorArasaac(context: context);
                            previsualizacionImagen(fotoEnviada,'arasaac');
                            },
                          child: Row(mainAxisAlignment: MainAxisAlignment.start,children:[
                            Icon(Icons.emoji_emotions,color: GuardadoLocal.colores[0],),
                            const SizedBox(
                              width: 2,
                            ),
                            Text('ARASAAC',style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 30),)
                          ])
                      )),
                  Container(
                      padding:EdgeInsets.all(5),
                      child: GestureDetector(onTap: (){Navigator.pop(context);},
                          child: Text('CANCELAR',textAlign: TextAlign.center,style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 35),)
                      )),
                ],),
              ));});
  }

  opcionesCamara(){
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              alignment: Alignment.bottomCenter,
              backgroundColor: GuardadoLocal.colores[0],
              child: SingleChildScrollView(
                child: Column(children: [
                  Column(children: [
                    Container(
                        padding:EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                            color: GuardadoLocal.colores[1],
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: GuardadoLocal.colores[0])
                        ),

                        ///TOMAR UNA FOTO DE LA CÁMARA
                        child: GestureDetector(onTap: ()async{

                          //Se toma la foto de la cámara
                          XFile fotoCapturada = await tomarFoto();

                          //Se sube la foto tomada en el storage de Firebase
                          var url = await Sesion.db.subirArchivo(File(fotoCapturada.path), "Imágenes/chats/${fotoCapturada.name}");

                          previsualizacionImagen(url, 'imagen');
                        },
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,children:[
                              Center(child:Text('FOTO',style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 30),))
                            ])
                        )),

                    ///TOMAR UN VIDEO DE LA CÁMARA
                    Container(
                        padding:EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                            color: GuardadoLocal.colores[1],
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: GuardadoLocal.colores[0])
                        ),
                        child: GestureDetector(onTap: () async{

                          //Se toma el video de la cámara
                          XFile videoCapturado = await grabarVideo();

                          //Se sube la foto tomada en el storage de Firebase
                          var url = await Sesion.db.subirArchivo(File(videoCapturado.path), "Vídeos/chats/${videoCapturado.name}");
                          var nuevoControlador = await VideoPlayerController.network(url);
                          nuevoControlador.initialize();

                          await previsualizacionVideo(nuevoControlador,context,idChat,Sesion.id,widget.idInterlocutor,url);

                          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds:50), curve: Curves.easeOut);
                          setState(() {
                            messageController.clear();
                          });
                        },
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,children:[
                              Center(child:Text('VIDEO',style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 30),))
                            ])
                        )),
                  ],),
                  Container(
                      padding:EdgeInsets.all(5),
                      child: GestureDetector(onTap: (){Navigator.pop(context);},
                          child: Text('ATRÁS',textAlign: TextAlign.center,style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 35),)
                      )),
                ],),
              ));});
  }

  opcionesGaleria(){
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              alignment: Alignment.bottomCenter,
              backgroundColor: GuardadoLocal.colores[0],
              child: SingleChildScrollView(
                child: Column(children: [
                  Column(children: [
                    Container(
                        padding:EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                            color: GuardadoLocal.colores[1],
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: GuardadoLocal.colores[0])
                        ),

                        ///TOMAR UNA FOTO DE LA GALERIA
                        child: GestureDetector(onTap: ()async{

                          //Se toma la foto de la galeria
                          XFile fotoCapturada = await galeriaFoto();

                          //Se sube la foto tomada en el storage de Firebase
                          var url = await Sesion.db.subirArchivo(File(fotoCapturada.path), "Imágenes/chats/${fotoCapturada.name}");

                          previsualizacionImagen(url, 'imagen');
                        },
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,children:[
                              Center(child:Text('FOTO',style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 30),))
                            ])
                        )),

                    ///TOMAR UN VIDEO DE LA GALERIA
                    Container(
                        padding:EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                            color: GuardadoLocal.colores[1],
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: GuardadoLocal.colores[0])
                        ),
                        child: GestureDetector(onTap: () async{

                          //Se toma el video de la galeria
                          XFile videoCapturado = await galeriaVideo();

                          //Se sube la foto tomada en el storage de Firebase
                          var url = await Sesion.db.subirArchivo(File(videoCapturado.path), "Vídeos/chats/${videoCapturado.name}");
                          var nuevoControlador = await VideoPlayerController.network(url);
                          nuevoControlador.initialize();

                          await previsualizacionVideo(nuevoControlador,context,idChat,Sesion.id,widget.idInterlocutor,url);

                          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds:50), curve: Curves.easeOut);
                          setState(() {
                            messageController.clear();
                          });
                        },
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,children:[
                              Center(child:Text('VIDEO',style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 30),))
                            ])
                        )),
                  ],),
                  Container(
                      padding:EdgeInsets.all(5),
                      child: GestureDetector(onTap: (){Navigator.pop(context);},
                          child: Text('ATRÁS',textAlign: TextAlign.center,style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 35),)
                      )),
                ],),
              ));});
  }

  previsualizacionImagen(url,tipo){
    showDialog(context: context, builder: (context)
    {
      return Dialog(
          backgroundColor: GuardadoLocal.colores[0],
          child: Column(children:[
            Row(mainAxisAlignment: MainAxisAlignment.start,children:[IconButton(
                onPressed: (){Navigator.pop(context);},
                icon: Icon(Icons.arrow_back),color: GuardadoLocal.colores[2])]),
            Expanded(child: Image.network(
              url,)),
            Row(mainAxisAlignment: MainAxisAlignment.end,children:[GestureDetector(
                onTap: () {
                  enviarMensaje(url,tipo);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: GuardadoLocal.colores[2],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                        child: Icon(
                          Icons.send,
                          color: GuardadoLocal.colores[0],
                        ))))]),
          ]));});
  }
}
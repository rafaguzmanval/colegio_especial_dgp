import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/lista_mensajes.dart';
import 'package:flutter/material.dart';

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
  var mensajes = [];

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;

    cargaMensajes();
    /*
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if(i%2==0)
        mensajes.add(Mensaje(Sesion.id, widget.idInterlocutor, 'texto', 'Mensaje nuevo '+i.toString(), ''));
      else
        mensajes.add(Mensaje(widget.idInterlocutor, Sesion.id, 'texto', 'Mensaje nuevo '+i.toString(), ''));

      chatsController.add('');
      i++;});*/
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
      body: Stack(
        children: <Widget>[
          // chat messages here
          mensajesChat(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                color: GuardadoLocal.colores[1],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: GuardadoLocal.colores[0],
                      width: 1)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: TextStyle(color: GuardadoLocal.colores[0]),
                      decoration: InputDecoration(
                        hintText: "Envia un mensaje...".toUpperCase(),
                        hintStyle: TextStyle(color: GuardadoLocal.colores[0], fontSize: 16),
                        border: InputBorder.none,
                      ),
                    )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    enviarMensaje();
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
                          Icons.send,
                          color: GuardadoLocal.colores[2],
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
            ? ListView.builder(
          itemCount: mensajes.length,//snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return ListaMensajes(
                mensaje: mensajes[index].contenido,//snapshot.data.docs[index]['message'],
                enviadoPorMi: mensajes[index].idUsuarioEmisor==Sesion.id);//widget.userName == snapshot.data.docs[index]['sender']);
          },
        )
            : Container();
      },
    );
  }

  enviarMensaje() {
    if (messageController.text.isNotEmpty) {

      Mensaje msg = Mensaje(widget.chatId, Sesion.id, widget.idInterlocutor, 'texto', messageController.text, DateTime.now().millisecondsSinceEpoch);

      Sesion.db.addMensaje(msg);
      setState(() {
        messageController.clear();
      });
    }
  }

  cargaMensajes() async{
    await Sesion.db.obtenerMensajes(widget.chatId);
  }

  actualizarMensajes(listaMensajes){

    mensajes = listaMensajes;
    print("numero de mensajes ${mensajes.length}" );
    chatsController.add('');
  }
}
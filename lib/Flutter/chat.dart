import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Flutter/lista_mensajes.dart';
import 'package:flutter/material.dart';

import '../Dart/guardado_local.dart';
import 'lista_mensajes.dart';

class Chat extends StatefulWidget {
  final String chatId;
  final String nombre;
  final String foto;
  const Chat(
      {Key? key,
        required this.chatId,
        required this.nombre,
        required this.foto})
      : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return !snapshot.hasData //snapshot.hasData
            ? ListView.builder(
          itemCount: 2,//snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return ListaMensajes(
                mensaje: 'Prueba',//snapshot.data.docs[index]['message'],
                enviadoPorMi: index<1?false:true);//widget.userName == snapshot.data.docs[index]['sender']);
          },
        )
            : Container();
      },
    );
  }

  enviarMensaje() {
    if (messageController.text.isNotEmpty) {/*
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);*/
      setState(() {
        messageController.clear();
      });
    }
  }
}
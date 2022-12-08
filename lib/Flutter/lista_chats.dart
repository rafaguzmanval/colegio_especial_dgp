import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class ListaChats extends StatefulWidget {
  final String chatId;
  final String nombre;
  final String foto;
  const ListaChats(
      {Key? key,
        required this.chatId,
        required this.nombre,
        required this.foto})
      : super(key: key);

  @override
  State<ListaChats> createState() => _ListaChatsState();
}

class _ListaChatsState extends State<ListaChats> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                  chatId: widget.chatId,
                  nombre: widget.nombre,
                  foto: widget.foto,
                )));
      },
      child: Container(
        decoration: BoxDecoration(
          color: GuardadoLocal.colores[1],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: GuardadoLocal.colores[0],
              width: 1)
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: GuardadoLocal.colores[0],
            backgroundImage: NetworkImage(
                widget.foto,
              ),
            child: Container(alignment: FractionalOffset(0.98, 0.98),
              child:Stack(children: [
                Icon(Icons.new_releases,color: GuardadoLocal.colores[1],),
                Icon(Icons.new_releases_outlined,color: GuardadoLocal.colores[0],),
              ],),)
            ),
          title: Text(
            widget.nombre.toUpperCase(),
            style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
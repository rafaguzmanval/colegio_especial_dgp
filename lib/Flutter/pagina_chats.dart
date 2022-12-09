/*
*   Archivo: lista_chats.dart
*
*   Descripción:
*   Pagina para consultar la lista de chats y acceder a ellos
* */

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:colegio_especial_dgp/Flutter/search_chat.dart';
import 'package:colegio_especial_dgp/Flutter/vista_chat.dart';
import 'package:flutter/material.dart';

import 'lista_chats.dart';


class PaginaChats extends StatefulWidget {
  @override
  PaginaChatsState createState() => PaginaChatsState();
}

class PaginaChatsState extends State<PaginaChats> {
  StreamController chatsController = new StreamController();
  double offSetActual = 0;
  ScrollController homeController = new ScrollController();

  @override
  void initState() {
    super.initState();

    cargarAlumnos();
    Sesion.paginaActual = this;
    Sesion.paginaChats = this;

    cargarChats();
  }

  @override
  void dispose() {
    Sesion.db.desactivarSubscripcionListaChat();
    Sesion.paginaChats = null;
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            IconButton(
              onPressed: () async{
                await showSearch(context: context, delegate: CustomSearchDelegate(),);
                setState(() {});
              },
              icon: Icon(Icons.search,color: GuardadoLocal.colores[2],),
            ),
          ],
          title: Center(
            child: Text(
              'CHATS  peti. ${Sesion.db.countPeticiones}',
              textAlign: TextAlign.center,
              style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 30, fontWeight: FontWeight.bold),
            ),
          )),
      body: Stack(children: [
        OrientationBuilder(
          builder: (context, orientation) => orientation == Orientation.portrait
              ? buildPortrait()
              : buildLandscape(),
        ),
        Container(
          alignment: FractionalOffset(0.98, 0.01),
          child: FloatingActionButton(
              heroTag: "botonUp",
              child: Icon(
                Icons.arrow_upward,
                color: GuardadoLocal.colores[2],
              ),
              elevation: 1.0,
              onPressed: () {
                offSetActual -= 100.0;
                if (offSetActual < homeController.position.minScrollExtent)
                  offSetActual = homeController.position.minScrollExtent;

                homeController.animateTo(
                  offSetActual, // change 0.0 {double offset} to corresponding widget position
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              }),
        ),
        Container(
          alignment: FractionalOffset(0.98, 0.99),
          child: FloatingActionButton(
              heroTag: "botonDown",
              child: Icon(
                Icons.arrow_downward,
                color: GuardadoLocal.colores[2],
              ),
              elevation: 1.0,
              onPressed: () {
                offSetActual += 100;

                if (offSetActual > homeController.position.maxScrollExtent)
                  offSetActual = homeController.position.maxScrollExtent;

                homeController.animateTo(
                  offSetActual, // change 0.0 {double offset} to corresponding widget position
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              }),
        ),
      ]),
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return _listaChats();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    return _listaChats();
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return _listaChats();
  }



  buildLandscape() {
    return SingleChildScrollView(
      controller: homeController,
      child: lista(),
    );
  }

  buildPortrait() {
    return SingleChildScrollView(
      controller: homeController,
      child: lista(),
    );
  }

  lista() {
    if (Sesion.rol == Rol.alumno.toString()) {
      return VistaAlumno();
    } else if (Sesion.rol == Rol.profesor.toString()) {
      return VistaProfesor();
    } else if (Sesion.rol == Rol.administrador.toString()) {
      return VistaAdministrador();
    }
  }

  // Obtiene la lista de alumnos y actualiza la pagina
  cargarAlumnos() async {
    Sesion.alumnos = await Sesion.db.consultarTodosAlumnos();
    actualizar();
  }

  Widget _listaChats() {
    return StreamBuilder(
        stream: chatsController.stream,
        builder: (context, AsyncSnapshot snapshot){

          if(snapshot.hasData){ //snapshot.hasData
            if(Sesion.chats.length!=0){//snapshot.data['chats']!=null
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: Sesion.chats.length, //snapshot.data['chats'].length
                  itemBuilder: (context, index) {

                    int reverseIndex = Sesion.chats.length - index - 1; // int reverseIndex = snapshot.data['chats'].length - index - 1
                    var idInterlocutor = Sesion.chats[reverseIndex].idUsuario1==Sesion.id?Sesion.chats[reverseIndex].idUsuario2:Sesion.chats[reverseIndex].idUsuario1;

                    return _listachatAux(Sesion.chats[reverseIndex].id, Sesion.chats[reverseIndex].nombre, Sesion.chats[reverseIndex].foto, idInterlocutor);
                    /*ListaChats(
                      chatId: Sesion.chats[reverseIndex].id,
                      nombre:Sesion.chats[reverseIndex].nombre,
                      foto: Sesion.chats[reverseIndex].foto,
                      idInterlocutor: Sesion.chats[reverseIndex].idUsuario1==Sesion.id?Sesion.chats[reverseIndex].idUsuario2:Sesion.chats[reverseIndex].idUsuario1,);*/
                  },
              );
            }else{
              return noChatsWidget();
            }
          }
          else{
            return Center(child: CircularProgressIndicator(color: GuardadoLocal.colores[0],),);
          }
        }
    );
  }

  _listachatAux(chatId,nombre,foto,idInterlocutor)
  {
    return GestureDetector(
      onTap: () async {
        Sesion.db.desactivarSubscripcionListaChat();
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VistaChat(
                  chatId: chatId,
                  nombre: nombre,
                  foto: foto,
                  idInterlocutor: idInterlocutor,
                )));
        Sesion.paginaActual = this;
        cargarChats();

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
                foto,
              ),
              child: Container(alignment: FractionalOffset(0.98, 0.98),
                child:Stack(children: [
                  Icon(Icons.new_releases,color: GuardadoLocal.colores[1],),
                  Icon(Icons.new_releases_outlined,color: GuardadoLocal.colores[0],),
                ],),)
          ),
          title: Text(
            nombre.toUpperCase(),
            style: TextStyle(color: GuardadoLocal.colores[0], fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  noChatsWidget(){

    return Center(child:Text('Sin chats creados.\nBusca en la lupa para crear un nuevo chat.'.toUpperCase(),));

  }

  // Obtiene la lista de alumnos y actualiza la pagina
  cargarChats() async {
    await Sesion.db.obtenerChats(Sesion.id);
  }

  void actualizarChats() async {
    chatsController.add('');
    actualizar();
  }

  void actualizar(){
    setState(() {});
  }
}
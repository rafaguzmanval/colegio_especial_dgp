/*
*   Archivo: lista_chats.dart
*
*   Descripción:
*   Pagina para consultar la lista de chats y acceder a ellos
* */

import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:colegio_especial_dgp/Flutter/search_chat.dart';
import 'package:flutter/material.dart';

import 'lista_chats.dart';

class PaginaChats extends StatefulWidget {
  @override
  PaginaChatsState createState() => PaginaChatsState();
}

class PaginaChatsState extends State<PaginaChats> {
  Stream? chats;
  double offSetActual = 0;
  ScrollController homeController = new ScrollController();

  @override
  void initState() {
    super.initState();

    cargarAlumnos();
    Sesion.paginaActual = this;
    AccesoBD.obtenerChats(Sesion.id);
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
              'CHATS',
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
        stream: chats,
        builder: (context, AsyncSnapshot snapshot){

          if(!snapshot.hasData){ //snapshot.hasData
            if(true){//snapshot.data['chats']!=null
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: Sesion.alumnos.length, //snapshot.data['chats'].length
                  itemBuilder: (context, index) {
                    int reverseIndex = Sesion.alumnos.length - index - 1; // int reverseIndex = snapshot.data['chats'].length - index - 1
                    return ListaChats(
                      chatId: 'id',
                      nombre:Sesion.alumnos[reverseIndex].nombre,
                      foto: Sesion.alumnos[reverseIndex].foto);
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

    /*Container(
      alignment: Alignment.center,
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(children: [
        for (int i = 0; i < Sesion.alumnos.length; i++) ...[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: 130,
                height: 150,
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Column(
                    children: [
                      Text(
                        Sesion.alumnos[i].nombre.toString().toUpperCase(),
                        style: TextStyle(
                          color: GuardadoLocal.colores[2],
                          fontSize: 25,
                        ),
                      ),
                      if(Sesion.alumnos[i].foto is String)...[
                        Image.network(
                          Sesion.alumnos[i].foto,
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                      ]
                    ],
                  ),
                  onPressed: () async {
                    Sesion.seleccion = Sesion.alumnos[i];
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PerfilAlumno()));
                  },
                )),
          ])
        ],
      ]),
    );*/
  }

  noChatsWidget(){

    return Center(child:Text('Sin chats creados.\nBusca en la lupa para crear un nuevo chat'.toUpperCase(),));
  }

  void actualizar() async {
    setState(() {});
  }
}
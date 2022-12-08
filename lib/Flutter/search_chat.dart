import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';

import 'vista_chat.dart';

class CustomSearchDelegate extends SearchDelegate {
// Demo list to show querying
  List<String> searchTerms = [];
  var vez = 0;

  crearLista() async{
    if(Sesion.rol == "Rol.alumno"){
      await cargarProfesores();
      for (var i = 0; i < Sesion.profesores.length; i++) {
        searchTerms.add(Sesion.profesores[i].nombre);
      }
    }
    else{
      await cargarAlumnos();
      for (var i = 0; i < Sesion.alumnos.length; i++) {
        searchTerms.add(Sesion.alumnos[i].nombre);
      }
    }
  }

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    if (vez == 0) {
      crearLista();
      vez++;
    }
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.cleaning_services),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    var pos = 0;
    for (var nombre in searchTerms) {
      if (nombre.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(nombre);
      }
    }
    return Sesion.rol == "Rol.alumno"?
    ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        for (int i = 0; i < Sesion.profesores.length; i++)
          if (result.toString().toUpperCase() ==
              Sesion.profesores[i].nombre.toUpperCase()) pos = i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            children: [
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
                            Sesion.profesores[pos].nombre.toString().toUpperCase(),
                            style: TextStyle(
                              color: GuardadoLocal.colores[2],
                              fontSize: 25,
                            ),
                          ),
                          Image.network(
                            Sesion.profesores[pos].foto,
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var profesores = [];
                        for(int i=0;i<Sesion.profesores.length;i++){
                          if(matchQuery.contains(Sesion.profesores[i].nombre.toString())){
                            profesores.add(Sesion.profesores[i]);
                          }
                        }
                        Sesion.seleccion = profesores[index];
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VistaChat(
                                  chatId: buscarIdChat(Sesion.nombre,profesores[index].nombre),
                                  nombre: profesores[index].nombre,
                                  foto: profesores[index].foto,
                                  idInterlocutor: profesores[index].id,
                                )));
                      },
                    )),
              ])
            ],
          ),
        );
      },
    )
    :ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        for (int i = 0; i < Sesion.alumnos.length; i++)
          if (result.toString().toUpperCase() ==
              Sesion.alumnos[i].nombre.toUpperCase()) pos = i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            children: [
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
                          Sesion.alumnos[pos].nombre.toString().toUpperCase(),
                          style: TextStyle(
                            color: GuardadoLocal.colores[2],
                            fontSize: 25,
                          ),
                        ),
                        Image.network(
                          Sesion.alumnos[pos].foto,
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                    onPressed: () async {
                      var alumnos = [];
                      for(int i=0;i<Sesion.alumnos.length;i++){
                        if(matchQuery.contains(Sesion.alumnos[i].nombre.toString())){
                          alumnos.add(Sesion.alumnos[i]);
                        }
                      }
                      Sesion.seleccion = alumnos[index];
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VistaChat(
                                  chatId: buscarIdChat(Sesion.nombre,alumnos[index].nombre),
                                  nombre: alumnos[index].nombre,
                                  foto: alumnos[index].foto,
                                  idInterlocutor: alumnos[index].id,
                                )));
                    },
                  )),
            ])
            ],
          ),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    var pos = 0;
    for (var nombre in searchTerms) {
      if (nombre.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(nombre);
      }
    }
    return Sesion.rol == "Rol.alumno"?
    ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        for (int i = 0; i < Sesion.profesores.length; i++)
          if (result.toString().toUpperCase() ==
              Sesion.profesores[i].nombre.toUpperCase()) pos = i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            children: [
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
                            Sesion.profesores[pos].nombre.toString().toUpperCase(),
                            style: TextStyle(
                              color: GuardadoLocal.colores[2],
                              fontSize: 25,
                            ),
                          ),
                          Image.network(
                            Sesion.profesores[pos].foto,
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var profesores = [];
                        for(int i=0;i<Sesion.profesores.length;i++){
                          if(matchQuery.contains(Sesion.profesores[i].nombre.toString())){
                            profesores.add(Sesion.profesores[i]);
                          }
                        }
                        Sesion.seleccion = profesores[index];
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VistaChat(
                                  chatId: buscarIdChat(Sesion.nombre,profesores[index].nombre),
                                  nombre: profesores[index].nombre,
                                  foto: profesores[index].foto,
                                  idInterlocutor: profesores[index].id,
                                )));
                      },
                    )),
              ])
            ],
          ),
        );
      },
    )
    :ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        for (int i = 0; i < Sesion.alumnos.length; i++)
          if (result.toString().toUpperCase() ==
              Sesion.alumnos[i].nombre.toUpperCase()) pos = i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            children: [
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
                            Sesion.alumnos[pos].nombre.toString().toUpperCase(),
                            style: TextStyle(
                              color: GuardadoLocal.colores[2],
                              fontSize: 25,
                            ),
                          ),
                          Image.network(
                            Sesion.alumnos[pos].foto,
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        var alumnos = [];
                        for(int i=0;i<Sesion.alumnos.length;i++){
                          if(matchQuery.contains(Sesion.alumnos[i].nombre.toString())){
                            alumnos.add(Sesion.alumnos[i]);
                          }
                        }
                        Sesion.seleccion = alumnos[index];
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VistaChat(
                                  chatId: buscarIdChat(Sesion.nombre,alumnos[index].nombre),
                                  nombre: alumnos[index].nombre,
                                  foto: alumnos[index].foto,
                                  idInterlocutor: alumnos[index].id,
                                )));
                      },
                    )),
              ])
            ],
          ),
        );
      },
    );
  }

  buscarIdChat(String miNombre, String nombreAlumno){
    //if(encuentro en la basde de datos) return id;
    //else(creo nuevo chat) return nuevoId;

    return "";
  }

  cargarProfesores() async {
    Sesion.profesores = await Sesion.db.consultarTodosProfesores();
    actualizar();
  }

  cargarAlumnos() async {
    Sesion.alumnos = await Sesion.db.consultarTodosAlumnos();
    actualizar();
  }

  // metodo para actualizar la pagina
  void actualizar() async {
    searchTerms.clear();
    crearLista();
  }
}

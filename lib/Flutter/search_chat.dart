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
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    assert(theme != null);
    return theme.copyWith(
      textTheme: TextTheme(subtitle1: TextStyle(fontFamily:'Escolar',fontSize: 20,color: GuardadoLocal.colores[0],fontWeight: FontWeight.bold),
          button: TextStyle(fontFamily:'Escolar',fontSize: 20,color: GuardadoLocal.colores[2],fontWeight: FontWeight.bold)),
      appBarTheme: AppBarTheme(
        brightness: colorScheme.brightness,
        backgroundColor: GuardadoLocal.colores[1],
      ),
      inputDecorationTheme: searchFieldDecorationTheme ??
          InputDecorationTheme(
            //fillColor: GuardadoLocal.colores[0],
            //filled: true,
              hintStyle: TextStyle(color: GuardadoLocal.colores[0]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: GuardadoLocal.colores[0], width: 0.0),
              )
          ),
    );
  }

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
        icon: Icon(Icons.cleaning_services,color: GuardadoLocal.colores[0]),
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
      icon: Icon(Icons.arrow_back,color: GuardadoLocal.colores[0]),
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
                        var id = await buscarIdChat(Sesion.id,profesores[index].id);
                        Navigator.pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VistaChat(
                                  chatId: id,
                                  nombre: profesores[index].nombre,
                                  foto: profesores[index].foto,
                                  idInterlocutor: profesores[index].id,
                                )));

                        Sesion.paginaChats.actualizarChats();
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
                      var id = await buscarIdChat(Sesion.id,alumnos[index].id);
                      Navigator.pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VistaChat(
                                  chatId: id,
                                  nombre: alumnos[index].nombre,
                                  foto: alumnos[index].foto,
                                  idInterlocutor: alumnos[index].id,
                                )));

                      Sesion.paginaChats.actualizarChats();

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
                        var id = await buscarIdChat(Sesion.id,profesores[index].id);
                        Navigator.pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VistaChat(
                                  chatId: id,
                                  nombre: profesores[index].nombre,
                                  foto: profesores[index].foto,
                                  idInterlocutor: profesores[index].id,
                                )));
                        Sesion.paginaChats.actualizarChats();
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
                        var id = await buscarIdChat(Sesion.id,alumnos[index].id);
                        Navigator.pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VistaChat(
                                  chatId: id,
                                  nombre: alumnos[index].nombre,
                                  foto: alumnos[index].foto,
                                  idInterlocutor: alumnos[index].id,
                                )));
                        Sesion.paginaChats.actualizarChats();
                      },
                    )),
              ])
            ],
          ),
        );
      },
    );
  }

  buscarIdChat(String miId, String idOtro) async{
    //if(encuentro en la basde de datos) return id;
    //else(creo nuevo chat) return nuevoId;
    var id = await Sesion.db.buscarIdChat(miId, idOtro);

    return id;
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

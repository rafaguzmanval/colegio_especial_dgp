import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_profesor.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';

class CustomSearchDelegate extends SearchDelegate {
// Demo list to show querying
  List<String> searchTerms = [];
  var vez = 0;
  bool esProfesorEliminandose = false;
  int profesorEliminandose = 0;

  crearLista() {
    for (var i = 0; i < Sesion.profesores.length; i++) {
      searchTerms.add(Sesion.profesores[i].nombre);
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
          cargarProfesores();
        },
        icon: Icon(Icons.update,color: GuardadoLocal.colores[0]),
      ),
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
    return ListView.builder(
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
                    width: 180,
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Container(width:170,child: ElevatedButton(
                      child: Column(
                        children: [
                          Text(
                            Sesion.profesores[pos].nombre
                                .toString()
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold,
                              color: GuardadoLocal.colores[2],
                              fontSize: 25,
                            ),
                          ),
                          Image.network(
                            Sesion.profesores[pos].foto,
                            width: 120,
                            height: 120,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(height: 10,)
                        ],
                      ),
                      onPressed: () async {
                        var profesores = [];
                        for (int i = 0; i < Sesion.profesores.length; i++) {
                          if (matchQuery.contains(Sesion.profesores[i].nombre.toString())) {
                            profesores.add(Sesion.profesores[i]);
                          }
                        }
                        Sesion.seleccion = profesores[index];
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PerfilProfesor()));
                        cargarProfesores();
                      },
                    ))),
                  if(matchQuery[index] != Sesion.nombre)...[IconButton(
                    onPressed: () async {
                      var profesores = [];
                      for (int i = 0; i < Sesion.profesores.length; i++) {
                        if (matchQuery.contains(Sesion.profesores[i].nombre.toString())) {
                          profesores.add(Sesion.profesores[i]);
                        }
                      }
                      await Sesion.db
                          .eliminarProfesor(profesores[index].id)
                          .then((e) async{
                        esProfesorEliminandose = true;
                        profesorEliminandose = pos;
                        await cargarProfesores();
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: GuardadoLocal.colores[0],
                    )),],
                if (esProfesorEliminandose && pos == profesorEliminandose) ...[
                  new CircularProgressIndicator(),
                ]
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
    return ListView.builder(
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
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Container(width:170,child: ElevatedButton(
                        child: Column(
                          children: [
                            Text(
                              Sesion.profesores[pos].nombre
                                  .toString()
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold,
                                color: GuardadoLocal.colores[2],
                                fontSize: 25,
                              ),
                            ),
                            Image.network(
                              Sesion.profesores[pos].foto,
                              width: 120,
                              height: 120,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(height: 10,)
                          ],
                        ),
                        onPressed: () async {
                          var profesores = [];
                          for (int i = 0; i < Sesion.profesores.length; i++) {
                            if (matchQuery.contains(Sesion.profesores[i].nombre.toString())) {
                              profesores.add(Sesion.profesores[i]);
                            }
                          }
                          Sesion.seleccion = profesores[index];
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PerfilProfesor()));
                          cargarProfesores();
                        }))),
                    if(matchQuery[index] != Sesion.nombre)...[IconButton(
                    onPressed: () async {
                      var profesores = [];
                      for (int i = 0; i < Sesion.profesores.length; i++) {
                        if (matchQuery.contains(Sesion.profesores[i].nombre.toString())) {
                          profesores.add(Sesion.profesores[i]);
                        }
                      }
                      await Sesion.db
                          .eliminarProfesor(profesores[index].id)
                          .then((e) async {
                        esProfesorEliminandose = true;
                        profesorEliminandose = pos;
                        await cargarProfesores();
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: GuardadoLocal.colores[0],
                    ))],
                if (esProfesorEliminandose && pos == profesorEliminandose) ...[
                  new CircularProgressIndicator(),
                ]
              ])
            ],
          ),
        );
      },
    );
  }

  cargarProfesores() async {
    Sesion.profesores = await Sesion.db.consultarTodosProfesores();
    await actualizar();
  }

  // metodo para actualizar la pagina
  actualizar() async {
      String aux = query;
      query='';
      query=aux;
      esProfesorEliminandose = false;
      searchTerms.clear();
      crearLista();
  }
}

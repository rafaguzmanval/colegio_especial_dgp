import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_boton.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';

/*
class CustomSearchDelegate extends SearchDelegate {
// Demo list to show querying
  List<String> searchTerms = [];
  var vez = 0;
  bool esBotonEliminandose = false;
  int botonEliminandose = 0;

  crearLista() {
    for (var i = 0; i < Sesion.tablon.length; i++) {
      searchTerms.add(Sesion.tablon[i].nombres);
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
          cargarTablon();
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
        for (int i = 0; i < Sesion.tablon.length; i++)
          if (result.toString().toUpperCase() ==
              Sesion.tablon[i].nombres.toUpperCase()) pos = i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                    width: 200,
                    height: 220,
                    margin: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: Column(
                        children: [
                          Text(
                            Sesion.tablon[pos].nombres.toString().toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: GuardadoLocal.colores[2],
                            ),
                          ),
                          if (!Sesion.tablon[pos].imagenes.isEmpty) ...[
                            Image.network(
                              Sesion.tablon[pos].imagenes,
                              width: 150,
                              height: 150,
                              fit: BoxFit.fill,
                            ),
                          ]
                        ],
                      ),
                      onPressed: () async {
                        var tablon = [];
                        for(int i=0;i<Sesion.tablon.length;i++){
                          if(matchQuery.contains(Sesion.tablon[i].nombres.toString())){
                            tablon.add(Sesion.tablon[i]);
                          }
                        }
                        Sesion.seleccion = tablon[index];
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Perfilboton()));
                          cargarTablon();
                      },
                    )),
                IconButton(
                    onPressed: () async {
                      var tablon = [];
                      for(int i=0;i<Sesion.tablon.length;i++){
                        if(matchQuery.contains(Sesion.tablon[i].nombres.toString())){
                          tablon.add(Sesion.tablon[i]);
                        }
                      }
                      await Sesion.db
                          .eliminarTablon(tablon[index].id)
                          .then((e) async{
                        esBotonEliminandose = true;
                        botonEliminandose = pos;
                        await cargarTablon();
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: GuardadoLocal.colores[0],
                    )),
                if (esBotonEliminandose && pos == botonEliminandose) ...[
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
        for (int i = 0; i < Sesion.tablon.length; i++)
          if (result.toString().toUpperCase() ==
              Sesion.tablon[i].nombres.toUpperCase()) pos = i;
        return Container(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                    width: 200,
                    height: 220,
                    margin: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                        child: Column(
                          children: [
                            Text(
                              Sesion.tablon[pos].nombres
                                  .toString()
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: GuardadoLocal.colores[2],
                              ),
                            ),
                            if (!Sesion.tablon[pos].imagenes.isEmpty) ...[
                              Image.network(
                                Sesion.tablon[pos].imagenes,
                                width: 150,
                                height: 150,
                                fit: BoxFit.fill,
                              ),
                            ]
                          ],
                        ),
                        onPressed: () async {
                          var tablon = [];
                          for(int i=0;i<Sesion.tablon.length;i++){
                            if(matchQuery.contains(Sesion.tablon[i].nombres.toString())){
                              tablon.add(Sesion.tablon[i]);
                            }
                          }
                          Sesion.seleccion = tablon[index];
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Perfilboton()));
                            cargarTablon();
                        })),
                IconButton(
                    onPressed: () async {
                      var tablon = [];
                      for(int i=0;i<Sesion.tablon.length;i++){
                        if(matchQuery.contains(Sesion.tablon[i].nombres.toString())){
                          tablon.add(Sesion.tablon[i]);
                        }
                      }
                        await Sesion.db
                            .eliminarTablon(tablon[index].id)
                            .then((e) async{
                          esBotonEliminandose = true;
                          botonEliminandose = pos;
                          await cargarTablon();
                        });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: GuardadoLocal.colores[0],
                    )),
                if (esBotonEliminandose && pos == botonEliminandose) ...[
                  new CircularProgressIndicator(),
                ]
              ])
            ],
          ),
        );
      },
    );
  }

  cargarTablon() async {
    Sesion.tablon = await Sesion.db.consultarTodosTablon();
    await actualizar();
  }

  // metodo para actualizar la pagina
  actualizar() async {
    String aux = query;
    query='';
    query=aux;
    esBotonEliminandose = false;
    searchTerms.clear();
    crearLista();
  }
}
*/

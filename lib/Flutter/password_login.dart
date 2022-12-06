/*
*   Archivo: password_login.dart
*
*   Descripción:
*   Pagina para iniciar sesion introduciendo una clave
*
*   Includes:
*   myhomepage.dart : Redirige al menu principal
*   passport_method.dart : Enumeracion de los metodos de acceso.
*   notificacion.dart : Clase para construir las notificaciones.
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
* */

import 'dart:async';
import 'package:colegio_especial_dgp/Dart/passport_method.dart';
import 'package:colegio_especial_dgp/Flutter/myhomepage.dart';
import '../Dart/sesion.dart';
import '../Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Dart/background.dart';


class PasswordLogin extends StatefulWidget {
  @override
  PasswordLoginState createState() => PasswordLoginState();
}

class PasswordLoginState extends State<PasswordLogin> {
  var concatenacionPin = "";
  var pulsaciones = 0;
  var errorLog = "";
  var temporizador;
  var pictogramasPin = [
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpin%2Fconejo.png?alt=media&token=b93aefd5-f2f8-4056-949d-863b6bbec317",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpin%2Fduende.png?alt=media&token=3fc18f70-ecce-4d23-8506-79a7bc048b87",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpin%2Fmariposa.png?alt=media&token=acb62a95-3373-4ec0-82e2-881fb5a8ab5e",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpin%2Fprincesa.png?alt=media&token=d890b321-1136-41e4-8317-0f7f2fb88689"
  ];

  @override
  void initState() {
    super.initState();


    Sesion.paginaActual = this;

  }

  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  // Metodo para que una vez se ha introducido el pin, tarda un tiempo en dar un mensaje de advertencia si está equivocado
  void temporizadorPin([int milliseconds = 3000]) {
    if (temporizador != null) temporizador.cancel();
    temporizador = Timer(Duration(milliseconds: milliseconds), advertencia);
  }

  // Crear el mensaje de advertencia
  void advertencia() {
    errorLog = "El pin no es correcto, pulsa el botón si te has equivocado".toUpperCase();
    _actualizar();
  }

  // Borrar el pin introducido si ha sido fallido
  void resetPin() {
    errorLog = "Vuelve a introducir".toUpperCase();
    concatenacionPin = "";
    pulsaciones = 0;
    _actualizar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst)),
          title: Center(child: Text('Hola ${Sesion.nombre}'.toUpperCase(),textAlign: TextAlign.center,style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 30),),

        )),
        body: Container(margin: EdgeInsets.all(5), child: vista()));
  }

  // Crear la vista dependiendo del metodo de clave que se quiere
  Widget vista() {

    if (Sesion.metodoLogin == Passportmethod.pin.toString()) {
      return vistaPin();
    } else {
      return vistaClave();
    }
  }

  // Vista para meter un clave pin
  Widget vistaClave() {
    return Container(
        //margin: EdgeInsets.all(200),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 500,
              child: TextField(
                style: TextStyle(color: GuardadoLocal.colores[0]),
                key: Key("campoContraseña"),
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder:  OutlineInputBorder(
                    borderSide:  BorderSide(color: GuardadoLocal.colores[0], width: 0.0),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'Introduce la clave'.toUpperCase(),
                  hintStyle: TextStyle(color: GuardadoLocal.colores[0],fontSize: 25),
                ),
                controller: myController,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              child: ElevatedButton(
                child: Text(
                  "Enviar".toUpperCase(),
                  style: TextStyle(
                    fontSize: 30,
                    color: GuardadoLocal.colores[2],
                  ),
                ),
                onPressed: () {
                  if (myController.text.length == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          content: Container(
                            padding: const EdgeInsets.all(16),
                            height: 90,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC72C41),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(29)),
                            ),
                            child: Text("La contraseña no puede estar vacia".toUpperCase()),
                          )),
                    );
                  } else {
                    ComprobarLogeo(Sesion.id, myController.text);
                  }
                },
              ),
            ),
            Text(errorLog)
          ],
        ));
  }

  // vista para crear una clave con imagenes
  Widget vistaPin() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            concatenarPin("conejo");
                          },
                          child: Image.network(pictogramasPin[0]))),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            concatenarPin("duende");
                          },
                          child: Image.network(pictogramasPin[1]))),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            concatenarPin("mariposa");
                          },
                          child: Image.network(pictogramasPin[2]))),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            concatenarPin("princesa");
                          },
                          child: Image.network(pictogramasPin[3]))),
                )
              ],
            ),
          ),
          Text(
            errorLog,
            selectionColor: Colors.black,
          ),
          ElevatedButton(
              onPressed: () {
                resetPin();
              },
              child: Text("Volver a introducir".toUpperCase(),style: TextStyle(fontSize: 25,color: GuardadoLocal.colores[2]),)),
        ]);
  }

  // Metodo para ir generando la clave al pulsar las imagenes o pin
  concatenarPin(nuevo) {
    pulsaciones++;
    concatenacionPin += nuevo;
    ComprobarPin(Sesion.id, concatenacionPin);

    if (pulsaciones > 2) {
      temporizadorPin();
    }
  }

  // Metodo para comprobar el pin introducido
  ComprobarPin(id, password) async {
    var resul = await Sesion.db.checkearPassword(id, password);

    print(resul);

    if (resul) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));
    } else {}
  }

  // Metodo para comprobar si la contraseña es correcta
  ComprobarLogeo(id, password) async {
    var resul = await Sesion.db.checkearPassword(id, password);

    print(resul);

    if (resul) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            duration: Duration(seconds: 2),
            elevation: 0,
            content: Container(
              padding: const EdgeInsets.all(16),
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFC72C41),
                borderRadius: BorderRadius.all(Radius.circular(29)),
              ),
              child: Text("CONTRASEÑA INCORRECTA"),
            )),
      );
    }
  }


  // Actualizar pagina
  void _actualizar() async {
    //var reloj = 1;
    //await Future.delayed(Duration(seconds:reloj));
    setState(() {});
  }
}

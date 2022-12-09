import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:flutter/material.dart';

class ListaMensajes extends StatefulWidget {
  final String mensaje;
  final bool enviadoPorMi;
  final fecha;

  const ListaMensajes(
      {Key? key,
        required this.mensaje,
        required this.enviadoPorMi,
        required this.fecha
      })
      : super(key: key);

  @override
  State<ListaMensajes> createState() => _ListaMensajesState();
}

class _ListaMensajesState extends State<ListaMensajes> {
  @override
  Widget build(BuildContext context) {
    var fecha = _obtenerFecha(widget.fecha);

    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.enviadoPorMi ? 0 : 24,
          right: widget.enviadoPorMi ? 24 : 0),
      alignment: widget.enviadoPorMi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.enviadoPorMi
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
        const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            border: widget.enviadoPorMi
                ?Border.all(
              color: GuardadoLocal.colores[0],
              width: 1):null,
            borderRadius: widget.enviadoPorMi
                ? const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            )
                : const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: widget.enviadoPorMi
                ? GuardadoLocal.colores[1]
                : GuardadoLocal.colores[0]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 8,
            ),
            Text(widget.mensaje.toUpperCase(),
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight:FontWeight.bold,fontSize: 16, color: widget.enviadoPorMi?GuardadoLocal.colores[0]:GuardadoLocal.colores[2]),),
            Text(fecha,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 10, color: widget.enviadoPorMi?GuardadoLocal.colores[0]:GuardadoLocal.colores[2]))
          ],
        ),
      ),
    );
  }

  String _obtenerFecha(fechaUM){
    var fecha = DateTime.fromMicrosecondsSinceEpoch(fechaUM*1000);

    var hora = fecha.hour.toString().length==1?('0'+fecha.hour.toString()):fecha.hour.toString();
    var minuto = fecha.minute.toString().length==1?('0'+fecha.minute.toString()):fecha.minute.toString();
    var dia = fecha.day.toString().length==1?('0'+fecha.day.toString()):fecha.day.toString();
    var mes = fecha.month.toString().length==1?('0'+fecha.month.toString()):fecha.month.toString();
    var stringFecha = hora+':'+minuto;

    if(fecha.day!=DateTime.now().day) stringFecha += dia+'/'+mes+'/'+fecha.year.toString();
    return stringFecha;
  }
}
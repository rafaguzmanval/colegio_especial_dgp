import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:flutter/material.dart';

class ListaMensajes extends StatefulWidget {
  final String mensaje;
  final bool enviadoPorMi;

  const ListaMensajes(
      {Key? key,
        required this.mensaje,
        required this.enviadoPorMi})
      : super(key: key);

  @override
  State<ListaMensajes> createState() => _ListaMensajesState();
}

class _ListaMensajesState extends State<ListaMensajes> {
  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(fontSize: 16, color: widget.enviadoPorMi?GuardadoLocal.colores[0]:GuardadoLocal.colores[2]))
          ],
        ),
      ),
    );
  }
}
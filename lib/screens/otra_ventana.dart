import 'package:flutter/material.dart';

class OtraVentana extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Otra ventana')),
      body: Center(
        child: Text(
          '¡Hola desde otra ventana!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

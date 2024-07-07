import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  final Color backgroundColor; // Nuevo campo para el color de fondo

  const PinScreen({
    Key? key,
    this.backgroundColor = Colors.white, // Color de fondo por defecto
  }) : super(key: key);

  @override
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  String pin = '';
  List<String> validPins = ['1234', '5678', '9999']; // Lista de pines correctos

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Verifica si el PIN ingresado está en la lista de pines correctos
      if (validPins.contains(pin)) {
        Navigator.pushReplacementNamed(context, '/list');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PIN incorrecto')),
        );
        _pinController
            .clear(); // Limpia el campo de entrada después de un intento fallido
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose(); // Asegura la correcta disposición del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(238, 71, 36, 1),
        title: Image.asset(
          'assets/images/logo.png',
          width: 250,
          height: 50,
        ),
      ),
      backgroundColor: widget.backgroundColor, // Color de fondo de la pantalla
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ingrese PIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  hintText: 'Ingrese su PIN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el PIN';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    pin = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Ingresar'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromRGBO(238, 71, 36, 1),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

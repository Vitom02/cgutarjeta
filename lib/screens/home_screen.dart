import 'package:flutter/material.dart';
import 'tarjeta_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí irá la lógica de logout del Cubit
                // Por ahora solo navegamos al login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('CGU Tarjeta'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Espacio superior
                Spacer(flex: 2),
                
                // Logo CGU
                Image.asset(
                  'assets/sello-cgu.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                
                SizedBox(height: 40),
                
                // Nombre del sistema
                Text(
                  'CGU Tarjeta Digital',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 10),
                
                Text(
                  'Sistema de Registro de Scores',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 60),
                
                // Botón Torneo
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TarjetaScreen(isTorneo: true),
                        ),
                      );
                    },
                    icon: Icon(Icons.emoji_events, size: 28),
                    label: Text(
                      'TORNEO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Botón Práctica Libre
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TarjetaScreen(isTorneo: false),
                        ),
                      );
                    },
                    icon: Icon(Icons.sports_golf, size: 28),
                    label: Text(
                      'PRÁCTICA LIBRE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
                
                // Espacio inferior
                Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


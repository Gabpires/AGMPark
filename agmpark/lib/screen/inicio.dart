import 'package:flutter/material.dart';
import 'package:agmpark/screen/estacionamentos.dart';
import 'package:agmpark/screen/login.dart';
import 'package:agmpark/services/auth_service.dart';

class AgmPark extends StatelessWidget {
  const AgmPark({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'AGM Park',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    'Business',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Column(
                children: [
                  Image.asset(
                    'assets/images/logoagm.png',
                    width: 320,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Gerencie vagas, monitore reservas, acompanhe o fluxo e mantenha tudo rodando',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final autenticado = await ApiService.checkAuth();

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => autenticado
                            ? const EstacionamentosPage()
                            : const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF26B66B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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

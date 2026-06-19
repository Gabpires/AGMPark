import 'package:flutter/material.dart';
import 'package:agmpark/screen/estacionamentos.dart' deferred as estacionamentos;
import 'package:agmpark/screen/login.dart' deferred as login;
import 'package:agmpark/services/auth_service.dart' deferred as auth_service;

class AgmPark extends StatelessWidget {
  const AgmPark({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool carregando = false;

  Future<void> continuar() async {
    if (carregando) {
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      await auth_service.loadLibrary();
      final autenticado = await auth_service.ApiService.checkAuth();

      if (!mounted) {
        return;
      }

      if (autenticado) {
        await estacionamentos.loadLibrary();

        if (!mounted) {
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => estacionamentos.EstacionamentosPage(),
          ),
        );
      } else {
        await login.loadLibrary();

        if (!mounted) {
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => login.LoginPage()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

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
                    'assets/images/logoagm2.png',
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
                  onPressed: carregando ? null : continuar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF26B66B),
                    disabledBackgroundColor: Color(0xFF26B66B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: carregando
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
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

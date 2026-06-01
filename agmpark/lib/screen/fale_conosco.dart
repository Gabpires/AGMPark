import 'package:flutter/material.dart';

class FaleConoscoPage extends StatelessWidget {
  const FaleConoscoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        title: const Text('Fale Conosco', style: TextStyle(fontSize: 18)),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 110, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ContatoItem(
                icon: Icons.chat_bubble_outline,
                titulo: 'Whatsapp:',
                valor: 'XX X XXXX-XXXX',
              ),
              SizedBox(height: 18),
              _ContatoItem(
                icon: Icons.email_outlined,
                titulo: 'E-mail:',
                valor: 'contato@agmpark.com',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContatoItem extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;

  const _ContatoItem({
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 34, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(valor, style: const TextStyle(fontSize: 15, color: Colors.black)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});

  static const _verde = Color(0xFF21B573);

  @override
  Widget build(BuildContext context) {
    final notificacoes = [
      const _NotificacaoItem(
        icon: Icons.local_parking,
        titulo: 'Vaga ocupada',
        descricao: 'Uma nova estadia foi registrada no estacionamento.',
        horario: 'Agora',
      ),
      const _NotificacaoItem(
        icon: Icons.payments_outlined,
        titulo: 'Pagamento recebido',
        descricao: 'Um pagamento foi confirmado no hist\u00f3rico.',
        horario: 'Hoje',
      ),
      const _NotificacaoItem(
        icon: Icons.event_available_outlined,
        titulo: 'Reserva atualizada',
        descricao: 'A situa\u00e7\u00e3o de uma reserva foi alterada.',
        horario: 'Hoje',
      ),
      const _NotificacaoItem(
        icon: Icons.warning_amber_rounded,
        titulo: 'Aten\u00e7\u00e3o na estadia',
        descricao: 'Confira as estadias com tempo pr\u00f3ximo do fim.',
        horario: 'Ontem',
      ),
      const _NotificacaoItem(
        icon: Icons.analytics_outlined,
        titulo: 'Resumo dispon\u00edvel',
        descricao: 'Os dados do estacionamento foram atualizados.',
        horario: 'Ontem',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        shadowColor: Colors.black26,
        title: const Text(
          'Notifica\u00e7\u00f5es',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        itemCount: notificacoes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return _NotificacaoCard(item: notificacoes[index]);
        },
      ),
    );
  }
}

class _NotificacaoItem {
  final IconData icon;
  final String titulo;
  final String descricao;
  final String horario;

  const _NotificacaoItem({
    required this.icon,
    required this.titulo,
    required this.descricao,
    required this.horario,
  });
}

class _NotificacaoCard extends StatelessWidget {
  final _NotificacaoItem item;

  const _NotificacaoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: NotificacoesPage._verde.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: NotificacoesPage._verde,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.titulo,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.horario,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios,
                color: NotificacoesPage._verde,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

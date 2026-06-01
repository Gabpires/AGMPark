import 'package:agmpark/models/funcionario_estacionamento_model.dart';
import 'package:agmpark/screen/adicionar_funcionario.dart';
import 'package:agmpark/services/auth_service.dart';
import 'package:agmpark/services/funcionario_estacionamento_service.dart';
import 'package:agmpark/widgets/acesso_restrito.dart';
import 'package:flutter/material.dart';

class GerenciarFuncionariosPage extends StatefulWidget {
  final int idEstacionamento;

  const GerenciarFuncionariosPage({super.key, required this.idEstacionamento});

  @override
  State<GerenciarFuncionariosPage> createState() =>
      _GerenciarFuncionariosPageState();
}

class _GerenciarFuncionariosPageState extends State<GerenciarFuncionariosPage> {
  final _service = FuncionarioEstacionamentoService();
  final _buscaController = TextEditingController();

  List<FuncionarioEstacionamentoModel> funcionarios = [];
  bool carregando = true;
  String? erro;
  int? removendoId;
  bool? podeAcessar;

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() => setState(() {}));
    inicializar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> inicializar() async {
    final permitido = await ApiService.possuiAcessoProprietario();

    if (!mounted) {
      return;
    }

    setState(() {
      podeAcessar = permitido;
    });

    if (permitido) {
      carregarFuncionarios();
    } else {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> carregarFuncionarios() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      funcionarios = await _service.listar(widget.idEstacionamento);
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  Future<void> abrirCadastro() async {
    final cadastrou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdicionarFuncionarioPage(idEstacionamento: widget.idEstacionamento),
      ),
    );

    if (cadastrou == true) {
      carregarFuncionarios();
    }
  }

  Future<void> remover(FuncionarioEstacionamentoModel funcionario) async {
    setState(() {
      removendoId = funcionario.idVinculo;
    });

    try {
      await _service.remover(funcionario.idVinculo);
      funcionarios.removeWhere(
        (item) => item.idVinculo == funcionario.idVinculo,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          removendoId = null;
        });
      }
    }
  }

  List<FuncionarioEstacionamentoModel> get funcionariosFiltrados {
    final termo = _buscaController.text.trim().toLowerCase();

    if (termo.isEmpty) {
      return funcionarios;
    }

    return funcionarios.where((funcionario) {
      return funcionario.nome.toLowerCase().contains(termo) ||
          funcionario.email.toLowerCase().contains(termo) ||
          funcionario.cpfCnpj.toLowerCase().contains(termo);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        title: const Text(
          'Gerenciar Funcionários',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: podeAcessar == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF21B573)),
            )
          : podeAcessar == false
          ? const AcessoRestrito(
              mensagem: 'Somente proprietarios podem gerenciar funcionarios.',
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF21B573),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: abrirCadastro,
                        child: const Text(
                          'Cadastrar Funcionário',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _buscaController,
                        decoration: InputDecoration(
                          hintText: 'Procurar funcionário',
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(child: _buildLista()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLista() {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF21B573)),
      );
    }

    if (erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(erro!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF21B573),
              ),
              onPressed: carregarFuncionarios,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    final lista = funcionariosFiltrados;

    if (lista.isEmpty) {
      return const Center(child: Text('Nenhum funcionário encontrado'));
    }

    return RefreshIndicator(
      color: const Color(0xFF21B573),
      onRefresh: carregarFuncionarios,
      child: ListView.builder(
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final funcionario = lista[index];

          return _FuncionarioCard(
            funcionario: funcionario,
            removendo: removendoId == funcionario.idVinculo,
            onRemover: () => remover(funcionario),
          );
        },
      ),
    );
  }
}

class _FuncionarioCard extends StatelessWidget {
  final FuncionarioEstacionamentoModel funcionario;
  final bool removendo;
  final VoidCallback onRemover;

  const _FuncionarioCard({
    required this.funcionario,
    required this.removendo,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFD5D5D5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.account_box_outlined, size: 54, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nome do Funcionário:',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  funcionario.nome.isEmpty ? '---' : funcionario.nome,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text('CPF:', style: TextStyle(fontSize: 12)),
                Text(
                  funcionario.cpfCnpj.isEmpty ? '---' : funcionario.cpfCnpj,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text('Email:', style: TextStyle(fontSize: 12)),
                Text(
                  funcionario.email.isEmpty ? '---' : funcionario.email,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF21B573),
                      disabledBackgroundColor: const Color(0xFF21B573),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: removendo ? null : onRemover,
                    child: removendo
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Remover Funcionário',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

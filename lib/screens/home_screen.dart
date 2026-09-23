import 'package:flutter/material.dart';
import 'package:projeto_flutter/models/produto_model.dart';
import 'package:projeto_flutter/services/produto_banco.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //============================================
  List<ProdutoModel> _listarProdutos = [];

  @override
  void initState() {
    super.initState();
    _carregarLista();
  }

  void _carregarLista() async {
    final produtos = await ProdutoBanco().listarProdutos();
    setState(() {
      _listarProdutos = produtos;
    });
  }

  void abrirFormulario(ProdutoModel? produto) {
    final nomeController = TextEditingController(text: produto?.nome ?? '');
    final descricaoController = TextEditingController(text: produto?.descricao ?? '');
    final categoriaController = TextEditingController(text: produto?.categoria ?? '');
    final valorController = TextEditingController(text: produto?.valor.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            produto?.id == null ? "Cadastro de produto" : "Edição produto",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(label: Text("Nome")),
              ),
              SizedBox(height: 20),
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(label: Text("Descrição")),
              ),
              SizedBox(height: 20),
              TextField(
                controller: categoriaController,
                decoration: InputDecoration(label: Text("Categoria")),
              ),
              SizedBox(height: 20),
              TextField(
                controller: valorController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(label: Text("Valor")),
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                // instancia produto e preenche com os dados digitados
                final dadosProduto = ProdutoModel(
                  id: produto?.id,
                  nome: nomeController.text,
                  descricao: descricaoController.text,
                  categoria: categoriaController.text,
                  // troca vírgula por ponto para converter o texto em double
                  valor: double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0
                );
                // chama função que salva os dados
                _salvarDados(dadosProduto);
              },
              child: Text("Salvar"),
            ),
          ],
        );
      },
    );
  } //fim da função abrir formulario

  void _salvarDados(ProdutoModel produto) async {
    bool modoCadastro = produto.id == null;
    bool salvou = false;
    if (modoCadastro) {
      salvou = await ProdutoBanco().inserirProduto(produto);
    } else {
      salvou = await ProdutoBanco().atualizarProduto(produto);
    }
    if (salvou) {
      //fecha modal formulario
      Navigator.of(context).pop();

      // carrega a lista novamente
      _carregarLista();

      //abre a modal de avisos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(modoCadastro ? "Produto salvo!" : "Produto atualizado!"),
        ),
      );
    }
  } //fim da função salvar dados

  void _abrirModalExclusao(ProdutoModel produto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Excluir produto"),
          content: Text("Deseja realmente excluir o produto ${produto.nome}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                deletarProduto(produto.id!);
                Navigator.pop(context);
              },
              child: Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  void deletarProduto(int id) async {
    bool deletou = await ProdutoBanco().deletarProduto(id);
    if (deletou) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Produto deletado com sucesso!")));
      _carregarLista();
    }
  }

  //============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de produtos"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: _listarProdutos.length, //conta numero de itens no array
        itemBuilder: (context, index) {
          final item = _listarProdutos[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(item.nome),
              subtitle: Text('${item.categoria} - ${item.descricao}\nR\$ ${item.valor.toStringAsFixed(2)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => abrirFormulario(item),
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => _abrirModalExclusao(item),
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
              leading: CircleAvatar(child: Icon(Icons.shopping_bag)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          abrirFormulario(null); // enviar nulo porque é um cadastro
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
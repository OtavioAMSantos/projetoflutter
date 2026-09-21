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
              leading: CircleAvatar(child: Icon(Icons.shopping_bag)),
            ),
          );
        },
      ),
    );
  }
}
import 'package:projeto_flutter/models/produto_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProdutoBanco {

  Future<Database> iniciarBanco() async {
    return await openDatabase(
      // /data/data/<package_name>/databases/"produtos.db"
      join(await getDatabasesPath(), 'produtos.db'),
      onCreate: (db, version) {
        return db.execute("""CREATE TABLE produtos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT,
          descricao TEXT,
          categoria TEXT,
          valor REAL
        )""");
      },
      version: 1
    );
  }
  Future<List<ProdutoModel>> listarProdutos() async {
    final db = await iniciarBanco();
    final List<Map<String, dynamic>> json = await db.query("produtos");
    return json.map((item) => ProdutoModel.fromJson(item)).toList();
  }

  Future<bool> inserirProduto(ProdutoModel dadosProduto) async {
    final db = await iniciarBanco(); 
    await db.insert("produtos", dadosProduto.toJson());
    return true;
  }

  Future<bool> atualizarProduto(ProdutoModel dadosProduto) async {
    final db = await iniciarBanco();
    await db.update(
      "produtos", 
      dadosProduto.toJson(),
      where: 'id = ?',
      whereArgs: [dadosProduto.id],
      conflictAlgorithm: ConflictAlgorithm.replace
    );
    return true;
  }

  Future<bool> deletarProduto(int id) async {
    final db = await iniciarBanco();
    await db.delete(
      "produtos",
      where: 'id = ?',
      whereArgs: [id]
    );
    return true;
  }

}
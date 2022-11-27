import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/product_bloc.dart';
import 'package:gerente_loja/validators/product_validator.dart';
import 'package:gerente_loja/widgets/images_widget.dart';
import 'package:gerente_loja/widgets/product_sizes.dart';

class ProductScreen extends StatefulWidget {

  final String? categoryId;
  final DocumentSnapshot? product;

  const ProductScreen({this.categoryId, this.product, Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with ProductValidator {

  late ProductBloc _productBloc;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _productBloc = ProductBloc(categoryId: widget.categoryId, product: widget.product);
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration _buildDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
      );
    }

    const fieldStyle = TextStyle(color: Colors.white, fontSize: 16);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        title: StreamBuilder<bool>(
          stream: _productBloc.outCreated,
          initialData: false,
          builder: (context, snapshot) {
            return Text(snapshot.data! ? "Editar Produto" : "Criar Produto");
          },
        ),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _productBloc.outCreated,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data!) {
                return StreamBuilder<bool>(
                  stream: _productBloc.outLoading,
                  initialData: false,
                  builder: (context, snapshot) {
                    return IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: snapshot.data!
                          ? null
                          : () {
                        _productBloc
                            .deleteProduct();
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),
          StreamBuilder<bool>(
            stream: _productBloc.outLoading,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: snapshot.data! ? null : saveProduct,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: StreamBuilder<Map>(
              stream: _productBloc.outData,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    const Text(
                      "Imagens",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    ImagesWidget(
                      context: context,
                      initialValue: snapshot.data!["images"],
                      onSaved: _productBloc.saveImages,
                      validator: validateImages,
                    ),
                    TextFormField(
                      initialValue: snapshot.data!["title"],
                      style: fieldStyle,
                      decoration: _buildDecoration("Título"),
                      onSaved: _productBloc.saveTitle,
                      validator: validateTitle,
                    ),
                    TextFormField(
                      initialValue: snapshot.data!["description"],
                      style: fieldStyle,
                      maxLines: 6,
                      decoration: _buildDecoration("Descrição"),
                      onSaved:
                      _productBloc.saveDescription,
                      validator: validateDescription,
                    ),
                    TextFormField(
                      initialValue: snapshot.data!["price"]?.toStringAsFixed(2),
                      style: fieldStyle,
                      decoration: _buildDecoration("Preço"),
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      onSaved: _productBloc.savePrice,
                      validator: validatePrice,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      "Tamanhos",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    ProductSizes(
                      context: context,
                      initialValue: snapshot.data!["sizes"],
                      onSaved: _productBloc.saveSizes,
                      validator: (s) {
                        if (s != null && s.isEmpty) {
                          return "";
                        }
                        return null;
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          StreamBuilder<bool>(
            stream: _productBloc.outLoading,
            initialData: false,
            builder: (context, snapshot) {
              return IgnorePointer(
                ignoring: !snapshot.data!,
                child: Container(
                  color: snapshot.data! ? Colors.black54 : Colors.transparent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Salvando produto...",
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(minutes: 1),
          backgroundColor: Colors.pinkAccent,
        ),
      );

      bool success = await _productBloc.saveProduct();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Produto salvo!" : "Erro ao salvar produto!",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.pinkAccent,
        ),
      );

      Navigator.of(context).pop();
    }
  }
}
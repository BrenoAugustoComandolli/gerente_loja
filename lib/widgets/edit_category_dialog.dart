import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/category_bloc.dart';
import 'package:gerente_loja/widgets/image_source_sheet.dart';

class EditCategoryDialog extends StatefulWidget {
  const EditCategoryDialog({this.category, Key? key}) : super(key: key);

  final DocumentSnapshot? category;

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late final CategoryBloc? _categoryBloc;
  late final TextEditingController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.category != null
        ? widget.category!.get("title") : "");

    _categoryBloc = CategoryBloc(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => ImageSourceSheet(
                      onImageSelected: (image) {
                        Navigator.of(context).pop();
                        _categoryBloc!.setImage(image);
                      },
                    ),
                  );
                },
                child: StreamBuilder(
                  stream: _categoryBloc!.outImage,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: snapshot.data is File
                            ? Image.file(
                                snapshot.data as File,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                snapshot.data as String,
                                fit: BoxFit.cover,
                              ),
                      );
                    } else {
                      return const Icon(Icons.image);
                    }
                  },
                ),
              ),
              title: StreamBuilder<String>(
                  stream: _categoryBloc!.outTitle,
                  builder: (context, snapshot) {
                    return TextField(
                      controller: _controller,
                      onChanged: _categoryBloc!.setTitle,
                      decoration: InputDecoration(
                        errorText:
                            snapshot.hasError ? snapshot.error as String : null,
                      ),
                    );
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StreamBuilder<bool>(
                  stream: _categoryBloc!.outDelete,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    return TextButton(
                      onPressed: snapshot.data!
                          ? () {
                              _categoryBloc!.delete();
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: const Text(
                        "Excluir",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
                StreamBuilder<bool>(
                  stream: _categoryBloc!.submitValid,
                  builder: (context, snapshot) {
                    return TextButton(
                      onPressed: snapshot.hasData
                          ? () async {
                              await _categoryBloc!.saveData();

                              if (!mounted) return;
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: const Text("Salvar"),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

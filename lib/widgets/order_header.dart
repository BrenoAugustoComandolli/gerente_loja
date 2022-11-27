import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/user_bloc.dart';

class OrderHeader extends StatelessWidget {
  final DocumentSnapshot? order;

  const OrderHeader({this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.getBloc<UserBloc>();

    final user = userBloc.getUser(order!.get("clientId"));

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("${user["name"]}"),
              Text("${user["address"]}")
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Produtos: R\$${order!.get("productsPrice").toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              "Total: R\$${order!.get("totalPrice").toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

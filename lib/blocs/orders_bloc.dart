import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

enum SortCriteria { readyFirst, readyLast }

class OrdersBloc extends BlocBase {
  final _ordersController = BehaviorSubject<List>();

  Stream<List> get outOrders => _ordersController.stream;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<DocumentSnapshot> _orders = [];

  SortCriteria _criteria = SortCriteria.readyFirst;

  OrdersBloc() {
    _addOrdersListener();
  }

  void _addOrdersListener() {
    _firestore.collection("orders").snapshots().listen(
      (snapshot) {
        for (var change in snapshot.docChanges) {
          String oid = change.doc.id;

          switch (change.type) {
            case DocumentChangeType.added:
              _orders.add(change.doc);
              break;
            case DocumentChangeType.modified:
              _orders.removeWhere((order) => order.id == oid);
              _orders.add(change.doc);
              break;
            case DocumentChangeType.removed:
              _orders.removeWhere((order) => order.id == oid);
              break;
          }
        }
        _sort();
      },
    );
  }

  void setOrderCriteria(SortCriteria criteria) {
    _criteria = criteria;

    _sort();
  }

  void _sort() {
    switch (_criteria) {
      case SortCriteria.readyFirst:
        _orders.sort(
          (a, b) {
            int sa = a.get("status");
            int sb = b.get("status");

            if (sa < sb) {
              return 1;
            } else if (sa > sb) {
              return -1;
            } else {
              return 0;
            }
          },
        );
        break;
      case SortCriteria.readyLast:
        _orders.sort(
          (a, b) {
            int sa = a.get("status");
            int sb = b.get("status");

            if (sa > sb) {
              return 1;
            } else if (sa < sb) {
              return -1;
            } else {
              return 0;
            }
          },
        );
        break;
    }

    _ordersController.add(_orders);
  }

  @override
  void dispose() {
    super.dispose();
    _ordersController.close();
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> _ordersRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data() ?? {},
          toFirestore: (data, _) => data,
        );
  }

  Future<String> createOrder(OrderModel order) async {
    if (_uid.isEmpty) {
      throw Exception('Usuário não autenticado.');
    }

    final doc = await _ordersRef(_uid).add(order.toMap());
    return doc.id;
  }

  Stream<List<OrderModel>> streamUserOrders() {
    if (_uid.isEmpty) return Stream.value(const []);

    return _ordersRef(_uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _productsRef => _firestore.collection('products');

  String get _currentUid => _auth.currentUser?.uid ?? '';

  Future<void> createProduct(Product product) async {
    if (_currentUid.isEmpty) throw Exception('Usuário não autenticado');

    final querySnapshot = await _productsRef
        .where('sku', isEqualTo: product.sku.toUpperCase())
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw Exception('SKU já cadastrado. Use um código único.');
    }

    await _productsRef.add(product.toMap());
  }

  Stream<List<Product>> getProducts({
    String? category,
    bool onlyActive = true,
    String? searchQuery,
    String sortField = 'createdAt',
    bool sortDescending = true,
  }) {
    Query query = _productsRef;

    if (onlyActive) {
      query = query.where('ativo', isEqualTo: true);
    }

    if (category != null && category.isNotEmpty) {
      query = query.where('categoria', isEqualTo: category);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      query = query
          .where('nome', isGreaterThanOrEqualTo: lowerQuery)
          .where('nome', isLessThanOrEqualTo: '$lowerQuery\uf8ff');
    }

    query = query.orderBy(sortField, descending: sortDescending);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Product>> getAllProducts() {
    return _productsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _productsRef.doc(id).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateProduct(Product product) async {
    if (_currentUid.isEmpty) throw Exception('Usuário não autenticado');

    final querySnapshot = await _productsRef
        .where('sku', isEqualTo: product.sku.toUpperCase())
        .limit(1)
        .get();

    for (final doc in querySnapshot.docs) {
      if (doc.id != product.id) {
        throw Exception('SKU já cadastrado para outro produto.');
      }
    }

    await _productsRef.doc(product.id).update(product.toUpdateMap());
  }

  Future<void> deleteProduct(String id) async {
    if (_currentUid.isEmpty) throw Exception('Usuário não autenticado');
    await _productsRef.doc(id).delete();
  }

  Future<void> toggleStatus(String id, bool active) async {
    if (_currentUid.isEmpty) throw Exception('Usuário não autenticado');
    await _productsRef.doc(id).update({
      'ativo': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> checkSkuExists(String sku, {String? excludeId}) async {
    final querySnapshot = await _productsRef
        .where('sku', isEqualTo: sku.toUpperCase())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return false;

    if (excludeId != null) {
      return querySnapshot.docs.any((doc) => doc.id != excludeId);
    }
    return true;
  }
}
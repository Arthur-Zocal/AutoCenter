import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products').withConverter<Map<String, dynamic>>(
            fromFirestore: (snapshot, _) => snapshot.data() ?? {},
            toFirestore: (data, _) => data,
          );

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
    String? searchQuery,
    String sortField = 'createdAt',
    bool sortDescending = true,
  }) {
    Query<Map<String, dynamic>> query = _productsRef;

    // Always order by createdAt to avoid composite index requirements
    // Other filters (category, search) applied in-memory
    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      var products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      // In-memory filter by category
      if (category != null && category.isNotEmpty) {
        products = products.where((p) => p.categoria == category).toList();
      }

      // In-memory search by nome, marca, or sku
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        products = products.where((p) {
          return p.nome.toLowerCase().contains(lowerQuery) ||
              p.marca.toLowerCase().contains(lowerQuery) ||
              p.sku.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      // In-memory sort (if not createdAt desc which is already sorted)
      if (sortField != 'createdAt' || !sortDescending) {
        products.sort((a, b) {
          int comparison = 0;
          switch (sortField) {
            case 'nome':
              comparison = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
              break;
            case 'preco':
              comparison = a.preco.compareTo(b.preco);
              break;
            case 'estoque':
              comparison = a.estoque.compareTo(b.estoque);
              break;
            case 'createdAt':
            default:
              comparison = a.createdAt.compareTo(b.createdAt);
              break;
          }
          return sortDescending ? -comparison : comparison;
        });
      }

      return products;
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
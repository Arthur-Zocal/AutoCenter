import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/product_model.dart';
import '../models/adesivo_envelopamento_model.dart';
import 'adesivo_envelopamento_service.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AdesivoEnvelopamentoService _adesivoService = AdesivoEnvelopamentoService();

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products').withConverter<Map<String, dynamic>>(
            fromFirestore: (snapshot, _) => snapshot.data() ?? {},
            toFirestore: (data, _) => data,
          );

  String get _currentUid => _auth.currentUser?.uid ?? '';

  static const String _adesivoCategoryLabel = 'Adesivo/Envelopamento';

  bool _isAdesivoCategory(String categoria) => categoria == _adesivoCategoryLabel;

  Product _adesivoToProduct(AdesivoEnvelopamento adesivo) {
    return Product(
      id: adesivo.id,
      nome: adesivo.nome,
      preco: adesivo.preco,
      descricao: adesivo.descricao,
      categoria: _adesivoCategoryLabel,
      estoque: adesivo.estoque,
      marca: adesivo.marca,
      sku: adesivo.sku,
      ativo: adesivo.ativo,
      imagemUrl: adesivo.imagemUrl,
      createdAt: adesivo.createdAt,
      updatedAt: adesivo.updatedAt,
    );
  }

  List<Product> _adesivosToProducts(List<AdesivoEnvelopamento> adesivos) {
    return adesivos.map(_adesivoToProduct).toList();
  }

  AdesivoEnvelopamento _productToAdesivo(Product product) {
    return AdesivoEnvelopamento(
      id: product.id,
      nome: product.nome,
      preco: product.preco,
      descricao: product.descricao,
      categoria: _adesivoCategoryLabel,
      estoque: product.estoque,
      marca: product.marca,
      sku: product.sku,
      ativo: product.ativo,
      imagemUrl: product.imagemUrl,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Future<void> createProduct(Product product) async {
    if (_isAdesivoCategory(product.categoria)) {
      await _adesivoService.cadastrar(_productToAdesivo(product));
    } else {
      if (_currentUid.isEmpty) throw Exception('Usuário não autenticado');

      final firebaseSkuExists = await _checkSkuInFirebase(product.sku);
      final adesivoSkuExists = await _adesivoService.checkSkuExists(product.sku);

      if (firebaseSkuExists || adesivoSkuExists) {
        throw Exception('SKU já cadastrado. Use um código único.');
      }

      await _productsRef.add(product.toMap());
    }
  }

  Stream<List<Product>> getProducts({
    String? category,
    String? searchQuery,
    String sortField = 'createdAt',
    bool sortDescending = true,
    bool onlyActive = true,
    bool onlyInactive = false,
  }) {
    final isAdesivoCategory = category != null && _isAdesivoCategory(category);
    final isAllCategories = category == null || category.isEmpty;

    if (isAdesivoCategory) {
      return _adesivoService
          .getAdesivosStream(
            searchQuery: searchQuery,
            sortField: sortField,
            sortDescending: sortDescending,
            onlyActive: onlyActive,
            onlyInactive: onlyInactive,
          )
          .map(_adesivosToProducts);
    }

    if (isAllCategories) {
      return _getMergedProductsStream(
        searchQuery: searchQuery,
        sortField: sortField,
        sortDescending: sortDescending,
        onlyActive: onlyActive,
        onlyInactive: onlyInactive,
      );
    }

    Query<Map<String, dynamic>> query = _productsRef;
    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      var products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      if (onlyActive) {
        products = products.where((p) => p.ativo).toList();
      } else if (onlyInactive) {
        products = products.where((p) => !p.ativo).toList();
      }

      if (category != null && category.isNotEmpty) {
        products = products.where((p) => p.categoria == category).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        products = products.where((p) {
          return p.nome.toLowerCase().contains(lowerQuery) ||
              p.marca.toLowerCase().contains(lowerQuery) ||
              p.sku.toLowerCase().contains(lowerQuery);
        }).toList();
      }

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

  Stream<List<Product>> _getMergedProductsStream({
    String? searchQuery,
    String sortField = 'createdAt',
    bool sortDescending = true,
    bool onlyActive = true,
    bool onlyInactive = false,
  }) {
    final controller = StreamController<List<Product>>();

    List<Product> firebaseProducts = [];
    List<Product> adesivoProducts = [];
    bool firebaseLoaded = false;
    bool adesivoLoaded = false;

    void mergeAndEmit() {
      if (!firebaseLoaded || !adesivoLoaded) return;

      var products = [...firebaseProducts, ...adesivoProducts];

      if (onlyActive) {
        products = products.where((p) => p.ativo).toList();
      } else if (onlyInactive) {
        products = products.where((p) => !p.ativo).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        products = products.where((p) {
          return p.nome.toLowerCase().contains(lowerQuery) ||
              p.marca.toLowerCase().contains(lowerQuery) ||
              p.sku.toLowerCase().contains(lowerQuery);
        }).toList();
      }

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

      if (!controller.isClosed) {
        controller.add(products);
      }
    }

    final firebaseSub = _productsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            firebaseProducts =
                snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
            firebaseLoaded = true;
            mergeAndEmit();
          },
          onError: (error) {
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
        );

    _adesivoService
        .getAdesivosStream(
          searchQuery: null,
          sortField: sortField,
          sortDescending: sortDescending,
          onlyActive: onlyActive,
          onlyInactive: onlyInactive,
        )
        .listen(
          (adesivos) {
            adesivoProducts = _adesivosToProducts(adesivos);
            adesivoLoaded = true;
            mergeAndEmit();
          },
          onError: (error) {
            adesivoLoaded = true;
            mergeAndEmit();
          },
        );

    controller.onCancel = () {
      firebaseSub.cancel();
    };

    return controller.stream;
  }

  Stream<List<Product>> getAllProducts() {
    return getProducts();
  }

  Future<Product?> getProductById(String id) async {
    final firebaseProduct = await _getFromFirebaseById(id);
    if (firebaseProduct != null) return firebaseProduct;

    final adesivo = await _adesivoService.consultarPorId(id);
    if (adesivo != null) return _adesivoToProduct(adesivo);

    return null;
  }

  Future<Product?> _getFromFirebaseById(String id) async {
    final doc = await _productsRef.doc(id).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateProduct(Product product) async {
    if (_isAdesivoCategory(product.categoria)) {
      await _adesivoService.atualizar(_productToAdesivo(product));
    } else {
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
  }

  Future<void> deleteProduct(String id) async {
    final product = await getProductById(id);
    if (product == null) {
      throw Exception('Produto não encontrado.');
    }

    if (_isAdesivoCategory(product.categoria)) {
      await _adesivoService.excluir(id);
    } else {
      if (_currentUid.isEmpty) throw Exception('Usuário não autenticado');
      await _productsRef.doc(id).delete();
    }
  }

  Future<void> toggleStatus(String id, bool active) async {
    final product = await getProductById(id);
    if (product == null) {
      throw Exception('Produto não encontrado.');
    }

    if (_isAdesivoCategory(product.categoria)) {
      final adesivo = await _adesivoService.consultarPorId(id);
      if (adesivo != null) {
        final updatedAdesivo = adesivo.copyWith(ativo: active);
        await _adesivoService.atualizar(updatedAdesivo);
      }
    } else {
      if (_currentUid.isEmpty) throw Exception('Usuário não autenticado');
      await _productsRef.doc(id).update({
        'ativo': active,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<bool> checkSkuExists(String sku, {String? excludeId}) async {
    final firebaseExists = await _checkSkuInFirebase(sku, excludeId: excludeId);
    if (firebaseExists) return true;

    return await _adesivoService.checkSkuExists(sku, excludeId: excludeId);
  }

  Future<bool> _checkSkuInFirebase(String sku, {String? excludeId}) async {
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
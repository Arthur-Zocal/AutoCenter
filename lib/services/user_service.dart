import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestore.collection('users');

  Future<void> createUser({
    required UserModel user,
    required String password,
  }) async {
    print('[UserService] Criando usuário no Auth: ${user.email}');
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );

    String? uid = credential.user?.uid;
    print('[UserService] Usuário criado no Auth com UID: $uid');

    if (uid != null) {
      print('[UserService] Salvando no Firestore...');
      await _usersRef.doc(uid).set(user.toMap());
      print('[UserService] Salvo no Firestore com sucesso!');
    }
  }

  Future<UserModel?> getCurrentUserProfile() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    DocumentSnapshot doc = await _usersRef.doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Stream<UserModel?> streamUserProfile() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  Future<void> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    String? uid = _auth.currentUser?.uid;
    print('[UserService] updateUserProfile - UID: $uid');
    if (uid == null) throw Exception("Usuário não autenticado");

    print('[UserService] Atualizando Firestore...');
    await _usersRef.doc(uid).update({
      'name': name,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('[UserService] Firestore atualizado com sucesso!');
  }

  Future<void> deleteAccount() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _usersRef.doc(currentUser.uid).delete();
    await currentUser.delete();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

class FirestoreUserProfileDataSource {
  FirestoreUserProfileDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<UserProfileModel?> getUserProfile(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return null;
    }

    return UserProfileModel.fromFirestore(id: snapshot.id, data: data);
  }
}

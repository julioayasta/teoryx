import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/data/firestore/firestore_collection_paths.dart';
import '../../../../core/theme/school_theme_config.dart';
import '../../domain/repositories/school_theme_repository.dart';
import '../models/firestore_school_theme_model.dart';

class FirestoreSchoolThemeRepository implements SchoolThemeRepository {
  FirestoreSchoolThemeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<SchoolThemeConfig?> getSchoolThemeConfig(String schoolId) async {
    final snapshot = await _firestore
        .doc(FirestoreCollectionPaths.school(schoolId))
        .get();
    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return SchoolThemeConfig.k2s();
    }

    final status = data['status'] as String?;
    if (status != null && status != 'active') {
      return SchoolThemeConfig.k2s();
    }

    return FirestoreSchoolThemeModel.fromFirestore(data).toEntity();
  }
}

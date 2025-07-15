// lib/core/di.dart

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:merinocizgi/data/repository/series_repository_impl.dart';

import '../data/services/firestore_service.dart';
import '../data/services/storage_service.dart';
import '../domain/repositories.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // 1) Firebase SDK’ları
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  // 2) Data Services
  getIt.registerLazySingleton<FirestoreService>(
    () => FirestoreService(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<FirebaseStorage>()),
  );

  // 3) Repository Implementations
  getIt.registerLazySingleton<SeriesRepository>(
    () => SeriesRepositoryImpl(
      firestore: getIt<FirestoreService>(),
      storage: getIt<StorageService>(),
    ),
  );

  // Eğer ihtiyacın varsa daha fazla use‐case veya repo ekle…
}

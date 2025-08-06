import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
abstract class Post with _$Post {
  const Post._(); // custom methodlar için

  const factory Post({
    required String id,
    required String userId,
    required String userName,
    String? userPhoto,
    required String text,
    String? imageUrl,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    required DateTime createdAt,
  }) = _Post;

  /// Firestore'dan gelen veriyi modele çevir
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  /// Firestore'a veri yazarken kullanılacak
  Map<String, dynamic> toFirestore() {
    return toJson()
      ..['createdAt'] = FieldValue.serverTimestamp(); // set ederken kullan
  }

  /// Firestore'dan gelen Timestamp'i dönüştür
  factory Post.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'],
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

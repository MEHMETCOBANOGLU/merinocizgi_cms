import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id, // Firestore doc.id
    required String contentType, // "series" | "books" | "episodes"
    required String contentId, // hedef içerik ID
    String? parentId, // null => üst yorum
    required String userId,
    @Default('Kullanıcı') String userName,
    String? userPhoto,
    required String text,
    @Default(0) int likeCount,
    required DateTime createdAt,
  }) = _Comment;

  /// Json için (opsiyonel – REST vb. için)
  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  /// Firestore doc'tan entity üretimi
  factory Comment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    final ts = d['createdAt'];
    final createdAt = ts is Timestamp ? ts.toDate() : DateTime.now();

    return Comment(
      id: doc.id,
      contentType: d['contentType'] as String? ?? '',
      contentId: d['contentId'] as String? ?? '',
      parentId: d['parentId'] as String?,
      userId: d['userId'] as String? ?? '',
      userName: d['userName'] as String? ?? 'Kullanıcı',
      userPhoto: d['userPhoto'] as String?,
      text: d['text'] as String? ?? '',
      likeCount: (d['likeCount'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
    );
  }
}

/// Firestore’a yazarken kullanabileceğiniz yardımcı
extension CommentFirestoreX on Comment {
  Map<String, dynamic> toFirestore() {
    return {
      'contentType': contentType,
      'contentId': contentId,
      'parentId': parentId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'text': text,
      'likeCount': likeCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(), // isterseniz
    };
  }
}

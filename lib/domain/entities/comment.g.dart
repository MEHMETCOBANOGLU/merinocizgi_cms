// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
      id: json['id'] as String,
      contentType: json['contentType'] as String,
      contentId: json['contentId'] as String,
      parentId: json['parentId'] as String?,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'Kullanıcı',
      userPhoto: json['userPhoto'] as String?,
      text: json['text'] as String,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
      'id': instance.id,
      'contentType': instance.contentType,
      'contentId': instance.contentId,
      'parentId': instance.parentId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPhoto': instance.userPhoto,
      'text': instance.text,
      'likeCount': instance.likeCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };

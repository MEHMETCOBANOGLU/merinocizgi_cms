// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhoto: json['userPhoto'] as String?,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPhoto': instance.userPhoto,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };

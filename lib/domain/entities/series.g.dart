// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Series _$SeriesFromJson(Map<String, dynamic> json) => _Series(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      squareThumbUrl: json['squareThumbUrl'] as String?,
      verticalThumbUrl: json['verticalThumbUrl'] as String?,
      category1: json['category1'] as String?,
      category2: json['category2'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SeriesToJson(_Series instance) => <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'title': instance.title,
      'summary': instance.summary,
      'squareThumbUrl': instance.squareThumbUrl,
      'verticalThumbUrl': instance.verticalThumbUrl,
      'category1': instance.category1,
      'category2': instance.category2,
      'createdAt': instance.createdAt.toIso8601String(),
    };

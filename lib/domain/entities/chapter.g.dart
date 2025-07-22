// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Chapter _$ChapterFromJson(Map<String, dynamic> json) => _Chapter(
      chapterId: json['chapterId'] as String?,
      chapterNumber: (json['chapterNumber'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      status: json['status'] as String? ?? 'draft',
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ChapterToJson(_Chapter instance) => <String, dynamic>{
      if (instance.chapterId case final value?) 'chapterId': value,
      'chapterNumber': instance.chapterNumber,
      'title': instance.title,
      'content': instance.content,
      'status': instance.status,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'wordCount': instance.wordCount,
    };

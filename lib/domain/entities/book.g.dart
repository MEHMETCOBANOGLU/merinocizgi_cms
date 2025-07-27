// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Book _$BookFromJson(Map<String, dynamic> json) => _Book(
      bookId: json['bookId'] as String?,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      category: json['category'] as String,
      copyright: json['copyright'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      status: json['status'] as String? ?? 'ongoing',
      createdAt: _dateTimeFromTimestamp(json['createdAt'] as Timestamp?),
      lastUpdatedAt:
          _dateTimeFromTimestamp(json['lastUpdatedAt'] as Timestamp?),
      hasPublishedEpisodes: json['hasPublishedEpisodes'] as bool? ?? true,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      chapterCount: (json['chapterCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BookToJson(_Book instance) => <String, dynamic>{
      if (instance.bookId case final value?) 'bookId': value,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'title': instance.title,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'category': instance.category,
      'copyright': instance.copyright,
      'tags': instance.tags,
      'status': instance.status,
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'lastUpdatedAt': _dateTimeToTimestamp(instance.lastUpdatedAt),
      'hasPublishedEpisodes': instance.hasPublishedEpisodes,
      'viewCount': instance.viewCount,
      'voteCount': instance.voteCount,
      'chapterCount': instance.chapterCount,
    };

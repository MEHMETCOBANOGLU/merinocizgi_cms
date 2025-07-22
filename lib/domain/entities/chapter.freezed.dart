// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Chapter {
  @JsonKey(includeIfNull: false)
  String? get chapterId;
  int get chapterNumber;
  String get title;
  String get content;
  String get status; // Varsayılan olarak 'taslak'
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime? get publishedAt;
  int get wordCount;

  /// Create a copy of Chapter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChapterCopyWith<Chapter> get copyWith =>
      _$ChapterCopyWithImpl<Chapter>(this as Chapter, _$identity);

  /// Serializes this Chapter to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Chapter &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.chapterNumber, chapterNumber) ||
                other.chapterNumber == chapterNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.wordCount, wordCount) ||
                other.wordCount == wordCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, chapterId, chapterNumber, title,
      content, status, publishedAt, wordCount);

  @override
  String toString() {
    return 'Chapter(chapterId: $chapterId, chapterNumber: $chapterNumber, title: $title, content: $content, status: $status, publishedAt: $publishedAt, wordCount: $wordCount)';
  }
}

/// @nodoc
abstract mixin class $ChapterCopyWith<$Res> {
  factory $ChapterCopyWith(Chapter value, $Res Function(Chapter) _then) =
      _$ChapterCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(includeIfNull: false) String? chapterId,
      int chapterNumber,
      String title,
      String content,
      String status,
      @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
      DateTime? publishedAt,
      int wordCount});
}

/// @nodoc
class _$ChapterCopyWithImpl<$Res> implements $ChapterCopyWith<$Res> {
  _$ChapterCopyWithImpl(this._self, this._then);

  final Chapter _self;
  final $Res Function(Chapter) _then;

  /// Create a copy of Chapter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapterId = freezed,
    Object? chapterNumber = null,
    Object? title = null,
    Object? content = null,
    Object? status = null,
    Object? publishedAt = freezed,
    Object? wordCount = null,
  }) {
    return _then(_self.copyWith(
      chapterId: freezed == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as String?,
      chapterNumber: null == chapterNumber
          ? _self.chapterNumber
          : chapterNumber // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      wordCount: null == wordCount
          ? _self.wordCount
          : wordCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Chapter implements Chapter {
  const _Chapter(
      {@JsonKey(includeIfNull: false) this.chapterId,
      required this.chapterNumber,
      required this.title,
      required this.content,
      this.status = 'draft',
      @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
      this.publishedAt,
      this.wordCount = 0});
  factory _Chapter.fromJson(Map<String, dynamic> json) =>
      _$ChapterFromJson(json);

  @override
  @JsonKey(includeIfNull: false)
  final String? chapterId;
  @override
  final int chapterNumber;
  @override
  final String title;
  @override
  final String content;
  @override
  @JsonKey()
  final String status;
// Varsayılan olarak 'taslak'
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime? publishedAt;
  @override
  @JsonKey()
  final int wordCount;

  /// Create a copy of Chapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChapterCopyWith<_Chapter> get copyWith =>
      __$ChapterCopyWithImpl<_Chapter>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChapterToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Chapter &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.chapterNumber, chapterNumber) ||
                other.chapterNumber == chapterNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.wordCount, wordCount) ||
                other.wordCount == wordCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, chapterId, chapterNumber, title,
      content, status, publishedAt, wordCount);

  @override
  String toString() {
    return 'Chapter(chapterId: $chapterId, chapterNumber: $chapterNumber, title: $title, content: $content, status: $status, publishedAt: $publishedAt, wordCount: $wordCount)';
  }
}

/// @nodoc
abstract mixin class _$ChapterCopyWith<$Res> implements $ChapterCopyWith<$Res> {
  factory _$ChapterCopyWith(_Chapter value, $Res Function(_Chapter) _then) =
      __$ChapterCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(includeIfNull: false) String? chapterId,
      int chapterNumber,
      String title,
      String content,
      String status,
      @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
      DateTime? publishedAt,
      int wordCount});
}

/// @nodoc
class __$ChapterCopyWithImpl<$Res> implements _$ChapterCopyWith<$Res> {
  __$ChapterCopyWithImpl(this._self, this._then);

  final _Chapter _self;
  final $Res Function(_Chapter) _then;

  /// Create a copy of Chapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chapterId = freezed,
    Object? chapterNumber = null,
    Object? title = null,
    Object? content = null,
    Object? status = null,
    Object? publishedAt = freezed,
    Object? wordCount = null,
  }) {
    return _then(_Chapter(
      chapterId: freezed == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as String?,
      chapterNumber: null == chapterNumber
          ? _self.chapterNumber
          : chapterNumber // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      wordCount: null == wordCount
          ? _self.wordCount
          : wordCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on

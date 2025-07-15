// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'series.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Series {
  String get id;
  String get authorId;
  String get title;
  String? get summary;
  String? get squareThumbUrl;
  String? get verticalThumbUrl;
  String? get category1;
  String? get category2;

  /// İçerik puanlarını tek bir JSONB/Map olarak saklıyoruz
  DateTime get createdAt;

  /// Create a copy of Series
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SeriesCopyWith<Series> get copyWith =>
      _$SeriesCopyWithImpl<Series>(this as Series, _$identity);

  /// Serializes this Series to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Series &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.squareThumbUrl, squareThumbUrl) ||
                other.squareThumbUrl == squareThumbUrl) &&
            (identical(other.verticalThumbUrl, verticalThumbUrl) ||
                other.verticalThumbUrl == verticalThumbUrl) &&
            (identical(other.category1, category1) ||
                other.category1 == category1) &&
            (identical(other.category2, category2) ||
                other.category2 == category2) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, authorId, title, summary,
      squareThumbUrl, verticalThumbUrl, category1, category2, createdAt);

  @override
  String toString() {
    return 'Series(id: $id, authorId: $authorId, title: $title, summary: $summary, squareThumbUrl: $squareThumbUrl, verticalThumbUrl: $verticalThumbUrl, category1: $category1, category2: $category2, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $SeriesCopyWith<$Res> {
  factory $SeriesCopyWith(Series value, $Res Function(Series) _then) =
      _$SeriesCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String authorId,
      String title,
      String? summary,
      String? squareThumbUrl,
      String? verticalThumbUrl,
      String? category1,
      String? category2,
      DateTime createdAt});
}

/// @nodoc
class _$SeriesCopyWithImpl<$Res> implements $SeriesCopyWith<$Res> {
  _$SeriesCopyWithImpl(this._self, this._then);

  final Series _self;
  final $Res Function(Series) _then;

  /// Create a copy of Series
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? title = null,
    Object? summary = freezed,
    Object? squareThumbUrl = freezed,
    Object? verticalThumbUrl = freezed,
    Object? category1 = freezed,
    Object? category2 = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      summary: freezed == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      squareThumbUrl: freezed == squareThumbUrl
          ? _self.squareThumbUrl
          : squareThumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      verticalThumbUrl: freezed == verticalThumbUrl
          ? _self.verticalThumbUrl
          : verticalThumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category1: freezed == category1
          ? _self.category1
          : category1 // ignore: cast_nullable_to_non_nullable
              as String?,
      category2: freezed == category2
          ? _self.category2
          : category2 // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Series extends Series {
  _Series(
      {required this.id,
      required this.authorId,
      required this.title,
      this.summary,
      this.squareThumbUrl,
      this.verticalThumbUrl,
      this.category1,
      this.category2,
      required this.createdAt})
      : super._();
  factory _Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);

  @override
  final String id;
  @override
  final String authorId;
  @override
  final String title;
  @override
  final String? summary;
  @override
  final String? squareThumbUrl;
  @override
  final String? verticalThumbUrl;
  @override
  final String? category1;
  @override
  final String? category2;

  /// İçerik puanlarını tek bir JSONB/Map olarak saklıyoruz
  @override
  final DateTime createdAt;

  /// Create a copy of Series
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SeriesCopyWith<_Series> get copyWith =>
      __$SeriesCopyWithImpl<_Series>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SeriesToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Series &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.squareThumbUrl, squareThumbUrl) ||
                other.squareThumbUrl == squareThumbUrl) &&
            (identical(other.verticalThumbUrl, verticalThumbUrl) ||
                other.verticalThumbUrl == verticalThumbUrl) &&
            (identical(other.category1, category1) ||
                other.category1 == category1) &&
            (identical(other.category2, category2) ||
                other.category2 == category2) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, authorId, title, summary,
      squareThumbUrl, verticalThumbUrl, category1, category2, createdAt);

  @override
  String toString() {
    return 'Series(id: $id, authorId: $authorId, title: $title, summary: $summary, squareThumbUrl: $squareThumbUrl, verticalThumbUrl: $verticalThumbUrl, category1: $category1, category2: $category2, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$SeriesCopyWith<$Res> implements $SeriesCopyWith<$Res> {
  factory _$SeriesCopyWith(_Series value, $Res Function(_Series) _then) =
      __$SeriesCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String authorId,
      String title,
      String? summary,
      String? squareThumbUrl,
      String? verticalThumbUrl,
      String? category1,
      String? category2,
      DateTime createdAt});
}

/// @nodoc
class __$SeriesCopyWithImpl<$Res> implements _$SeriesCopyWith<$Res> {
  __$SeriesCopyWithImpl(this._self, this._then);

  final _Series _self;
  final $Res Function(_Series) _then;

  /// Create a copy of Series
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? title = null,
    Object? summary = freezed,
    Object? squareThumbUrl = freezed,
    Object? verticalThumbUrl = freezed,
    Object? category1 = freezed,
    Object? category2 = freezed,
    Object? createdAt = null,
  }) {
    return _then(_Series(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      summary: freezed == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      squareThumbUrl: freezed == squareThumbUrl
          ? _self.squareThumbUrl
          : squareThumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      verticalThumbUrl: freezed == verticalThumbUrl
          ? _self.verticalThumbUrl
          : verticalThumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category1: freezed == category1
          ? _self.category1
          : category1 // ignore: cast_nullable_to_non_nullable
              as String?,
      category2: freezed == category2
          ? _self.category2
          : category2 // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on

// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Book {
// @JsonKey(includeIfNull: false) bu, Firestore'a yazarken alan null ise onu eklemez.
  @JsonKey(includeIfNull: false)
  String? get bookId;
  String get authorId;
  String get authorName;
  String get title;
  String get description;
  String? get coverImageUrl;
  String get category;
  String
      get copyright; // Etiketler için varsayılan olarak boş bir liste atayalım.
  List<String> get tags;
  String
      get status; // Tarih alanları için özel dönüştürücülerimizi kullanıyoruz.
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime? get createdAt;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime? get lastUpdatedAt;
  bool get hasPublishedEpisodes; // Sayaçlar
  int get viewCount;
  int get voteCount;
  int get chapterCount;

  /// Create a copy of Book
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BookCopyWith<Book> get copyWith =>
      _$BookCopyWithImpl<Book>(this as Book, _$identity);

  /// Serializes this Book to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Book &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.copyright, copyright) ||
                other.copyright == copyright) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt) &&
            (identical(other.hasPublishedEpisodes, hasPublishedEpisodes) ||
                other.hasPublishedEpisodes == hasPublishedEpisodes) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.chapterCount, chapterCount) ||
                other.chapterCount == chapterCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bookId,
      authorId,
      authorName,
      title,
      description,
      coverImageUrl,
      category,
      copyright,
      const DeepCollectionEquality().hash(tags),
      status,
      createdAt,
      lastUpdatedAt,
      hasPublishedEpisodes,
      viewCount,
      voteCount,
      chapterCount);

  @override
  String toString() {
    return 'Book(bookId: $bookId, authorId: $authorId, authorName: $authorName, title: $title, description: $description, coverImageUrl: $coverImageUrl, category: $category, copyright: $copyright, tags: $tags, status: $status, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, hasPublishedEpisodes: $hasPublishedEpisodes, viewCount: $viewCount, voteCount: $voteCount, chapterCount: $chapterCount)';
  }
}

/// @nodoc
abstract mixin class $BookCopyWith<$Res> {
  factory $BookCopyWith(Book value, $Res Function(Book) _then) =
      _$BookCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(includeIfNull: false) String? bookId,
      String authorId,
      String authorName,
      String title,
      String description,
      String? coverImageUrl,
      String category,
      String copyright,
      List<String> tags,
      String status,
      @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
      DateTime? createdAt,
      @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
      DateTime? lastUpdatedAt,
      bool hasPublishedEpisodes,
      int viewCount,
      int voteCount,
      int chapterCount});
}

/// @nodoc
class _$BookCopyWithImpl<$Res> implements $BookCopyWith<$Res> {
  _$BookCopyWithImpl(this._self, this._then);

  final Book _self;
  final $Res Function(Book) _then;

  /// Create a copy of Book
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = freezed,
    Object? authorId = null,
    Object? authorName = null,
    Object? title = null,
    Object? description = null,
    Object? coverImageUrl = freezed,
    Object? category = null,
    Object? copyright = null,
    Object? tags = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? lastUpdatedAt = freezed,
    Object? hasPublishedEpisodes = null,
    Object? viewCount = null,
    Object? voteCount = null,
    Object? chapterCount = null,
  }) {
    return _then(_self.copyWith(
      bookId: freezed == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as String?,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _self.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      copyright: null == copyright
          ? _self.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _self.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasPublishedEpisodes: null == hasPublishedEpisodes
          ? _self.hasPublishedEpisodes
          : hasPublishedEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _self.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      voteCount: null == voteCount
          ? _self.voteCount
          : voteCount // ignore: cast_nullable_to_non_nullable
              as int,
      chapterCount: null == chapterCount
          ? _self.chapterCount
          : chapterCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Book implements Book {
  const _Book(
      {@JsonKey(includeIfNull: false) this.bookId,
      required this.authorId,
      required this.authorName,
      required this.title,
      required this.description,
      this.coverImageUrl,
      required this.category,
      required this.copyright,
      final List<String> tags = const [],
      this.status = 'ongoing',
      @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
      this.createdAt,
      @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
      this.lastUpdatedAt,
      this.hasPublishedEpisodes = true,
      this.viewCount = 0,
      this.voteCount = 0,
      this.chapterCount = 0})
      : _tags = tags;
  factory _Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

// @JsonKey(includeIfNull: false) bu, Firestore'a yazarken alan null ise onu eklemez.
  @override
  @JsonKey(includeIfNull: false)
  final String? bookId;
  @override
  final String authorId;
  @override
  final String authorName;
  @override
  final String title;
  @override
  final String description;
  @override
  final String? coverImageUrl;
  @override
  final String category;
  @override
  final String copyright;
// Etiketler için varsayılan olarak boş bir liste atayalım.
  final List<String> _tags;
// Etiketler için varsayılan olarak boş bir liste atayalım.
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String status;
// Tarih alanları için özel dönüştürücülerimizi kullanıyoruz.
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime? createdAt;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime? lastUpdatedAt;
  @override
  @JsonKey()
  final bool hasPublishedEpisodes;
// Sayaçlar
  @override
  @JsonKey()
  final int viewCount;
  @override
  @JsonKey()
  final int voteCount;
  @override
  @JsonKey()
  final int chapterCount;

  /// Create a copy of Book
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BookCopyWith<_Book> get copyWith =>
      __$BookCopyWithImpl<_Book>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BookToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Book &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.copyright, copyright) ||
                other.copyright == copyright) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt) &&
            (identical(other.hasPublishedEpisodes, hasPublishedEpisodes) ||
                other.hasPublishedEpisodes == hasPublishedEpisodes) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.chapterCount, chapterCount) ||
                other.chapterCount == chapterCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bookId,
      authorId,
      authorName,
      title,
      description,
      coverImageUrl,
      category,
      copyright,
      const DeepCollectionEquality().hash(_tags),
      status,
      createdAt,
      lastUpdatedAt,
      hasPublishedEpisodes,
      viewCount,
      voteCount,
      chapterCount);

  @override
  String toString() {
    return 'Book(bookId: $bookId, authorId: $authorId, authorName: $authorName, title: $title, description: $description, coverImageUrl: $coverImageUrl, category: $category, copyright: $copyright, tags: $tags, status: $status, createdAt: $createdAt, lastUpdatedAt: $lastUpdatedAt, hasPublishedEpisodes: $hasPublishedEpisodes, viewCount: $viewCount, voteCount: $voteCount, chapterCount: $chapterCount)';
  }
}

/// @nodoc
abstract mixin class _$BookCopyWith<$Res> implements $BookCopyWith<$Res> {
  factory _$BookCopyWith(_Book value, $Res Function(_Book) _then) =
      __$BookCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(includeIfNull: false) String? bookId,
      String authorId,
      String authorName,
      String title,
      String description,
      String? coverImageUrl,
      String category,
      String copyright,
      List<String> tags,
      String status,
      @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
      DateTime? createdAt,
      @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
      DateTime? lastUpdatedAt,
      bool hasPublishedEpisodes,
      int viewCount,
      int voteCount,
      int chapterCount});
}

/// @nodoc
class __$BookCopyWithImpl<$Res> implements _$BookCopyWith<$Res> {
  __$BookCopyWithImpl(this._self, this._then);

  final _Book _self;
  final $Res Function(_Book) _then;

  /// Create a copy of Book
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bookId = freezed,
    Object? authorId = null,
    Object? authorName = null,
    Object? title = null,
    Object? description = null,
    Object? coverImageUrl = freezed,
    Object? category = null,
    Object? copyright = null,
    Object? tags = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? lastUpdatedAt = freezed,
    Object? hasPublishedEpisodes = null,
    Object? viewCount = null,
    Object? voteCount = null,
    Object? chapterCount = null,
  }) {
    return _then(_Book(
      bookId: freezed == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as String?,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _self.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      copyright: null == copyright
          ? _self.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _self.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasPublishedEpisodes: null == hasPublishedEpisodes
          ? _self.hasPublishedEpisodes
          : hasPublishedEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _self.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      voteCount: null == voteCount
          ? _self.voteCount
          : voteCount // ignore: cast_nullable_to_non_nullable
              as int,
      chapterCount: null == chapterCount
          ? _self.chapterCount
          : chapterCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on

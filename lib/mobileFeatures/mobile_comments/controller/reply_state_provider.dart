// reply_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplyTarget {
  final String commentId;
  final String userName;
  final String? preview; // ilk 40 karakter gibi
  ReplyTarget({required this.commentId, required this.userName, this.preview});
}

class ReplyState extends StateNotifier<ReplyTarget?> {
  ReplyState() : super(null);
  void set(ReplyTarget? t) => state = t;
  void clear() => state = null;
}

// replyStateProvider: Şu an kime yanıt veriyoruz bilgisini tutar.
final replyStateProvider =
    StateNotifierProvider<ReplyState, ReplyTarget?>((ref) => ReplyState());


// CommentComposer: Altta sabit inline composer. Yanıt modunda üstünde “Yanıtladığın: @kisi ❌” barı çıkar. Otomatik fokus/temizleme yapar.

// CommentTile: Ana ve reply yorumlar aynı bileşen; isReply/depth ile kompakt görünüm.

// CommentList: Üst yorumları ve yanıtlarını listeler (indentli). “Yanıtla” tıklanınca replyState setlenir, composer fokuslanır.
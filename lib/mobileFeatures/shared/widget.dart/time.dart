String timeAgoTr(DateTime dateTime, {DateTime? now}) {
  final current = now ?? DateTime.now();
  var diff = current.difference(dateTime);

  // Gelecek tarih güvenliği (negatifse 0 yap)
  if (diff.isNegative) diff = Duration.zero;

  final seconds = diff.inSeconds;
  final minutes = diff.inMinutes;
  final hours = diff.inHours;
  final days = diff.inDays;

  if (seconds < 60) return 'şimdi';
  if (minutes < 60) return '$minutes dk';
  if (hours < 24) return '$hours saat';
  if (days < 7) return '$days gün';

  // Haftayı istersen açabilirsin:
  final weeks = (days / 7).floor();
  if (weeks < 5) return '$weeks hf';

  // Ay/yıl kabaca (takvim ayı gerekirse paket kullan)
  final months = (days / 30).floor();
  if (months < 12) return '$months ay';

  final years = (days / 365).floor();
  return '$years yıl';
}

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Model: Her kelime için ekranda belirme zamanını tutar.
class WordStamp {
  final String word;
  final Duration start;
  WordStamp(this.word, this.start);
}

/// KaraokePage: Ses kaydıyla eş zamanlı metin gösterimi.
class KaraokePage extends StatefulWidget {
  const KaraokePage({Key? key}) : super(key: key);

  @override
  _KaraokePageState createState() => _KaraokePageState();
}

class _KaraokePageState extends State<KaraokePage> {
  final AudioPlayer _player = AudioPlayer();
  Duration _position = Duration.zero;

  // 1) Tüm metni buraya yazın
  static const String _fullText = '''
ordan kırmızı bimin oradan yeşil ışık yanıyordu bimin ordan karşı yoldan geçtim bu yola geçtim adam bene çarptı!!! zavadak dedi!! bende o heyecanla şeyle vardım gittim köye doğru şorda durdum aktım teker de yok arabada ama tamam ben belki alkollü olabilirim de.. o arkadaş neyin ECELİNDE korono virüsten mi kaçıyor? kimden kaçıyor dayeşil ışıkta kırmızı ışıkta durmadı da bene çarptı bene yanaşıpta ya derdi ney yani derdi ney derdi hay tamam ben zarhoşum ben hadi geçebilirim ben suçluyum da şu anda kanunen o suçlu o suçlu yani devletin ışıklarından faydalanmayan devletin ışıklarına uymayan o benim suçum ne?
''';

  // 2) Metni kelimelere böler ve her kelimeye 600ms aralıkla zaman damgası atar.
  late final List<WordStamp> _transcript = () {
    final words = _fullText.trim().split(RegExp(r'\s+'));
    return List.generate(
      words.length,
      (i) => WordStamp(words[i], Duration(milliseconds: i * 600)),
    );
  }();

  @override
  void initState() {
    super.initState();
    // Assets klasörünüzde 'audio/my_recording.mp3' olduğundan emin olun
    _player.setSource(AssetSource('audio/my_recording.mp3'));
    _player.onPositionChanged.listen((pos) {
      setState(() {
        _position = pos;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// O ana kadar gösterilmesi gereken kelimeler
  List<String> get _visibleWords => _transcript
      .where((ws) => ws.start <= _position)
      .map((ws) => ws.word)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Oynat'),
            onPressed: () => _player.resume(),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                _visibleWords.join(' '),
                style: const TextStyle(fontSize: 20, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../data/models/word_model.dart';

class WordDetailPage extends StatelessWidget {
  final Word word;

  const WordDetailPage({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(word.word)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word.word,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              word.phonetic,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text('释义:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...word.meaning.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('${m.pos} ${m.definitions.join('、')}'),
                )),
            const SizedBox(height: 16),
            const Text('例句:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...word.example.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(e),
                )),
          ],
        ),
      ),
    );
  }
}

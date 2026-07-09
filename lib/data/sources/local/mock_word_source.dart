import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../models/word_model.dart';

abstract class WordDataSource {
  Future<List<Word>> getWords(String wordBookId);
}

@Injectable(as: WordDataSource)
class MockWordSource implements WordDataSource {
  @override
  Future<List<Word>> getWords(String wordBookId) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/cet-6.json');
      final jsonList = json.decode(jsonString) as List<dynamic>;
      final words = jsonList.map((e) => Word.fromJson(e)).toList();
      return words.where((word) => word.wordBookId == wordBookId).toList();
    } catch (e) {
      throw Exception('Failed to load words: $e');
    }
  }
}

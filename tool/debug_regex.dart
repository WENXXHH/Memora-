import 'dart:io';

void main() {
  final docColon = RegExp(r'[（(]\s*(?:doc|Bug|bug)[^：:）)]*[：:]\s*([^）)]*)[）)]');
  final docBare = RegExp(r'[（(]\s*(?:doc|Bug|bug)[^）)]*[）)]');
  final samples = [
    '/// 当前词库选择状态（doc 6）。',
    '/// 选择顺序（doc 55 / Bug 9 防御）：验证 → 去重 → 先持久化 →',
    '/// （doc 27：不能写在 build）',
    '/// 听音辨词控制器（doc 26 / 27 / 28 / 29 / 30 / 31）。',
  ];
  for (final s in samples) {
    var r = s.replaceAllMapped(docColon, (m) => '（${(m[1] ?? '').trim()}）');
    r = r.replaceAll(docBare, '');
    print('IN : $s');
    print('OUT: $r');
    print('---');
  }

  // 检查文件读取
  final f = File(r'lib\features\word_book_selection\state\current_word_book_state.dart');
  print('exists: ${f.existsSync()}');
  if (f.existsSync()) {
    final line = f.readAsLinesSync()[0];
    print('line0: [$line]');
  }
}

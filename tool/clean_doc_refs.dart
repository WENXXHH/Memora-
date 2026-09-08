// 一次性清理脚本：删除 Dart 注释/测试描述中带小括号的（doc xx）/（Bug xx）引用痕迹。
// 规则：
// 1. 整组删除带小括号且含 doc/Bug/bug 标记的括号内容（（说明，doc N）、（Bug N 防御）等）。
// 2. 删除后整行只剩注释标记（/// 或 //）的注释行一并删除。
// 3. 覆盖 lib/ 与 test/ 下全部 .dart（含 freezed/g 生成文件；源模型注释已是干净的，
//    重新 build 也不会把引用带回来）。
// 4. 跨行括号组（（与 ）不在同一行）不处理，由人工修改。
// 运行后删除本文件。
import 'dart:io';

void main() {
  final dirs = [Directory('lib'), Directory('test')];
  final docRef = RegExp(r'（[^（）]*?\b(?:doc|Bug|bug)\b[^（）]*?）');
  final emptyComment = RegExp(r'^\s*///?\s*$');

  var fileCount = 0;
  var lineCount = 0;

  for (final dir in dirs) {
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final lines = entity.readAsLinesSync();
      final out = <String>[];
      var changed = false;
      for (final line in lines) {
        final newLine = line.replaceAll(docRef, '');
        if (newLine != line) {
          changed = true;
          lineCount++;
          if (emptyComment.hasMatch(newLine)) continue; // 整行被删空 → 删除该行
        }
        out.add(newLine);
      }
      if (changed) {
        entity.writeAsStringSync('${out.join('\n')}\n');
        fileCount++;
        print('cleaned: ${entity.path}');
      }
    }
  }
  print('files=$fileCount lines=$lineCount');
}

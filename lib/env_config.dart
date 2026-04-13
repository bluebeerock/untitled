import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

class EnvConfig {
  /// LAN A のインターフェース名
  static String lanA = 'eth0';

  /// LAN B のインターフェース名
  static String lanB = 'eth1';

  /// リスト形式での取得
  static List<String> get interfaces => [lanA, lanB];

  /// 実行時に config.json から設定を読み込む
  static Future<void> load() async {
    try {
      // 実行ファイルのディレクトリを取得してパスを結合する
      final exePath = Platform.resolvedExecutable;
      final Directory exeDir = File(exePath).parent;
      
      // まず実行ファイルの隣を探し、なければカレントディレクトリ（開発用）を探す
      File file = File('${exeDir.path}/config.json');
      if (!(await file.exists())) {
        file = File('config.json'); 
      }

      debugPrint('Searching for config at: ${file.absolute.path}');

      if (await file.exists()) {
        final String content = await file.readAsString();
        final Map<String, dynamic> config = jsonDecode(content);
        if (config['LAN_A'] != null) {
          lanA = config['LAN_A'];
          debugPrint('Loaded LAN_A: $lanA');
        }
        if (config['LAN_B'] != null) {
          lanB = config['LAN_B'];
          debugPrint('Loaded LAN_B: $lanB');
        }
      } else {
        debugPrint('config.json not found. Using default values.');
      }
    } catch (e) {
      // ファイルがない場合や形式エラー時はデフォルト値を維持
      stderr.writeln('Config load error: $e');
    }
  }
}
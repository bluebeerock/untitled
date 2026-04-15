//
//import 'dart:math';

import 'package:flutter/material.dart' hide Size;
import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'my_bandwidth.dart';
import 'my_delay.dart';
import 'my_init.dart';
import 'env_config.dart';

Future<void> executeProcess(String cmd) async {
  var shell = Shell();
  final results = await shell.run(cmd);
  // 実行結果にエラーがないか確認するためのデバッグ出力
  for (var result in results) {
    if (result.exitCode != 0) {
      debugPrint('Command failed: ${result.stderr}');
      throw Exception(result.stderr);
    }
  }
}

const Color myDefaultBg = Colors.cyanAccent;

void main() async {
  // 非同期処理（ファイル読み込み）を行うために必要
  WidgetsFlutterBinding.ensureInitialized();
  // 実行時に設定ファイルを読み込む
  await EnvConfig.load();
  runApp(MaterialApp(home: LanSettingsScreen()));
}

class LanSettingsScreen extends StatefulWidget {
  const LanSettingsScreen({super.key});

  @override
  State<LanSettingsScreen> createState() => _LanSettingsScreenState();
}

class _LanSettingsScreenState extends State<LanSettingsScreen> {
  double get myWidth1 => 150;
  static double get myWidth => 550;
  static double get myHeight1 => 120;
  static double get myHeight => 70;

  @override
  void initState() {
    super.initState();
    // 起動時にネットワーク設定を初期化
    _resetNetworkSettings();
  }

  /// 各インターフェースの tc 設定を削除する共通メソッド
  Future<void> _resetNetworkSettings() async {
    for (var interface in EnvConfig.interfaces) {
      try {
        await executeProcess('sudo tc qdisc del dev $interface root');
        debugPrint('Success: Reset qdisc on $interface');
      } catch (e) {
        // 設定が既に存在しない場合はエラーが出るが、初期化なので無視する
        debugPrint('Notice: No qdisc to delete on $interface');
      }
    }
  }

  final List<String> _executedCommands = [];

  // 共通の装飾スタイル
  BoxDecoration _cellDecoration({Color? color, bool hasBottomBorder = true}) {
    return BoxDecoration(
      color: color,
      border: hasBottomBorder ? const Border(bottom: BorderSide()) : null,
    );
  }

  Widget _buildLabelColumn() {
    final labels = [
      ('', myHeight),
      ('帯域', myHeight),
      ('遅延', myHeight1),
      ('損失', myHeight),
    ];
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: labels.map((label) => Container(
          width: myWidth1,
          height: label.$2,
          decoration: _cellDecoration(color: Colors.blue),
          child: Center(
            child: Text(
              label.$1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildDataColumn(int index) {
    final title = index == 0 ? "LAN A → LAN B" : "LAN B → LAN A";
    return Container(
      padding: const EdgeInsets.all(2.0),
      width: myWidth,
      child: Column(
        children: [
          _buildDataCell(Center(child: Text(title, style: const TextStyle(fontSize: 20)))),
          _buildDataCell(MyBandwidth(myno1: index)),
          _buildDataCell(
            MyDelay(myno3: index * 2, myno4: index * 2 + 1, myno5: index),
            height: myHeight1,
          ),
          _buildDataCell(_buildLossInput(index)),
        ],
      ),
    );
  }

  Widget _buildDataCell(Widget child, {double? height}) {
    return Container(
      width: myWidth,
      height: height ?? myHeight,
      decoration: _cellDecoration(color: myDefaultBg),
      child: child,
    );
  }

  Widget _buildLossInput(int index) {
    return Row(
      children: [
        const SizedBox(width: 100),
        SizedBox(
          height: 30,
          width: 140,
          child: TextFormField(
            controller: controllermyLoValue[index],
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: myLoValue[index]),
          ),
        ),
        const SizedBox(width: 100, child: Text(' %')),
      ],
    );
  }

  Future<void> _handleExecute() async {
    setState(() {
      _executedCommands.clear();
    });
    for (int i = 0; i < 2; i++) {
      final unit = myBwSelect[i];
      final double multiplier = switch (unit) {
        'Gbps' => 1e9,
        'Mbps' => 1e6,
        'Kbps' => 1e3,
        _ => 1.0,
      };

      final double bwVal = double.tryParse(controllermyBwValue[i].text) ?? 1.0;
      final int rateInKbit = (bwVal * multiplier / 1000).toInt();
      
      // バーストとリミットの計算（最低値を保証してエラーを防ぐ）
      double calcBurst = (bwVal * multiplier) / myHziConfig / 8;
      if (calcBurst < 1600) calcBurst = 1600; // 最小1600バイト
      final double calcLimit = calcBurst * 10;

      // 遅延設定の組み立て (myDlSelect[i] が 1:Constant, 2:Uniform, 3:Normal)
      String delayPart = 'delay ${controllermyDlValue[i * 2].text.isEmpty ? "0" : controllermyDlValue[i * 2].text}ms';
      if (myDlSelect[i] != '1') {
        final String jitter = controllermyDlValue[i * 2 + 1].text.isEmpty ? "0" : controllermyDlValue[i * 2 + 1].text;
        delayPart += ' ${jitter}ms';
        if (myDlSelect[i] == '3') {
          delayPart += ' distribution normal';
        }
      }

      final String lossText = controllermyLoValue[i].text.isEmpty ? "0" : controllermyLoValue[i].text;

      // コマンド生成
      final String cmdNetem = 'sudo tc qdisc add dev ${EnvConfig.interfaces[i]} root handle 1: netem $delayPart loss $lossText%';
      final String cmdTbf = 'sudo tc qdisc add dev ${EnvConfig.interfaces[i]} parent 1: tbf rate ${rateInKbit}kbit burst ${calcBurst.toInt()} limit ${calcLimit.toInt()}';
      
      setState(() {
        _executedCommands.add(cmdNetem);
        _executedCommands.add(cmdTbf);
        // 表示用にコマンドを保持
        myCmd[i] = '$cmdNetem && $cmdTbf';
      });
      
      try {
        // 設定を適用する前に一度削除（既存設定によるエラー回避）
        await executeProcess('sudo tc qdisc del dev ${EnvConfig.interfaces[i]} root').catchError((_){});
        await executeProcess(cmdNetem);
        await executeProcess(cmdTbf);
      } catch (e) {
        setState(() {
          _executedCommands.add('Error: $e');
        });
      }
    }
    await executeProcess('echo Processes Executed');
  }

  /// 現在の tc 設定を取得して表示するメソッド
  Future<void> _handleCheckStatus() async {
    setState(() {
      _executedCommands.clear();
      _executedCommands.add('--- Current TC Status ---');
    });

    for (var interface in EnvConfig.interfaces) {
      try {
        var shell = Shell();
        final results = await shell.run('tc qdisc show dev $interface');
        setState(() {
          for (var result in results) {
            _executedCommands.add('[$interface]\n${result.stdout.toString().trim()}');
          }
        });
      } catch (e) {
        debugPrint('Error checking status: $e');
      }
    }
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: myWidth,
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton('初期化', () async {
              setState(() {
                myInit();
                _executedCommands.clear();
              });
              await _resetNetworkSettings();
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton('状態確認', _handleCheckStatus),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton('決定', _handleExecute),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LAN Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildLabelColumn(),
                _buildDataColumn(0),
                Container(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [
                      _buildDataColumn(1),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
            if (_executedCommands.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '実行コマンド',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20, color: Colors.blueGrey),
                            tooltip: 'クリップボードにコピー',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _executedCommands.join('\n')));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('クリップボードにコピーしました')),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      SelectableText(
                        _executedCommands.join('\n'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 20)),
    );
  }
}

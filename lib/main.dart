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
  runApp(
    MaterialApp(
      home: const LanSettingsScreen(),
      theme: ThemeData(
        // アプリ全体のInputDecorationのデフォルトスタイルを定義
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // デフォルトの背景色
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black26, width: 1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.blueAccent,
              width: 3.0,
            ), // フォーカス時の太い枠線
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
  );
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
  static double get myHeightStatus =>
      35; // New: Height for interface status row

  // FocusNodes for all inputs and buttons (4 per side * 2 + 3 buttons = 11)
  final List<FocusNode> _focusNodes = List.generate(11, (_) => FocusNode());

  String _lanAStatus = 'Unknown';
  String _lanBStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    // 起動時にネットワーク設定を初期化
    _resetNetworkSettings();
    // インターフェースの状態をロード
    _loadInterfaceStatuses();
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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

  /// インターフェースのUP/DOWN状態を取得する
  Future<String> _getInterfaceStatus(String interfaceName) async {
    try {
      final results = await Shell().run('ip link show $interfaceName');
      if (results.isNotEmpty && results.first.exitCode == 0) {
        final output = results.first.stdout;

        // 1. 明示的な 'state UP' をチェック
        if (output.contains('state UP')) {
          return 'up';
        }

        // 2. フラグ内の 'UP' をチェック (管理状態で判断)
        // 例: <BROADCAST,MULTICAST,UP,LOWER_UP>
        final match = RegExp(r'<(.*)>').firstMatch(output);
        if (match != null) {
          final flags = match.group(1)?.split(',') ?? [];
          if (flags.contains('UP')) {
            return 'up';
          }
        }

        if (output.contains('state DOWN') || output.contains('NO-CARRIER')) {
          return 'down';
        }
      }
    } catch (e) {
      return 'error';
    }
    return 'unknown';
  }

  /// インターフェースの状態をロードしてUIを更新する
  Future<void> _loadInterfaceStatuses() async {
    final statusA = await _getInterfaceStatus(EnvConfig.lanA);
    final statusB = await _getInterfaceStatus(EnvConfig.lanB);
    setState(() {
      _lanAStatus = statusA;
      _lanBStatus = statusB;
    });
  }

  // 共通の装飾スタイル
  BoxDecoration _cellDecoration({Color? color, bool hasBottomBorder = true}) {
    return BoxDecoration(
      color: color,
      border: hasBottomBorder
          ? Border(bottom: BorderSide(color: Colors.grey[300]!)) // 境界線の色を調整
          : null,
    );
  }

  Widget _buildLabelColumn() {
    final labels = [
      ('状態', myHeightStatus), // インターフェース状態表示用のラベル
      ('', myHeight),
      ('帯域', myHeight),
      ('遅延', myHeight1),
      ('損失', myHeight),
    ];
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: labels
            .map(
              (label) => Container(
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
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDataColumn(int index) {
    final title = index == 0 ? "LAN A →" : "LAN B →";
    return Container(
      padding: const EdgeInsets.all(2.0),
      width: myWidth,
      child: Column(
        children: [
          // インターフェース名と状態を表示
          _buildDataCell(
            _buildInterfaceStatus(
              index == 0 ? EnvConfig.lanA : EnvConfig.lanB,
              index == 0 ? _lanAStatus : _lanBStatus,
            ),
            height: myHeightStatus,
          ),
          _buildDataCell(
            Center(child: Text(title, style: const TextStyle(fontSize: 20))),
          ),
          _buildDataCell(
            MyBandwidth(myno1: index, focusNode: _focusNodes[index * 4]),
          ),
          _buildDataCell(
            MyDelay(
              myno3: index * 2,
              myno4: index * 2 + 1,
              myno5: index,
              focusNode1: _focusNodes[index * 4 + 1],
              focusNode2: _focusNodes[index * 4 + 2],
            ),
            height: myHeight1,
          ),
          _buildDataCell(_buildLossInput(index, _focusNodes[index * 4 + 3])),
        ],
      ),
    );
  }

  /// インターフェース名と状態を表示するウィジェット
  Widget _buildInterfaceStatus(String interfaceName, String status) {
    Color statusColor = Colors.grey;
    if (status.toLowerCase() == 'up') {
      statusColor = Colors.green[700]!;
    } else if (status.toLowerCase() == 'down') {
      statusColor = Colors.red[700]!;
    }

    return Container(
      width: myWidth,
      height: myHeightStatus,
      decoration: _cellDecoration(color: Colors.blueGrey[100]),
      child: Center(
        child: Text(
          '$interfaceName: ${status.toUpperCase()}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
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

  Widget _buildLossInput(int index, FocusNode focusNode) {
    return Row(
      children: [
        const SizedBox(width: 100),
        SizedBox(
          height: 45, // 高さを少し広げて入力しやすく
          width: 140,
          child: Focus(
            onFocusChange: (hasFocus) => setState(() {}),
            child: TextFormField(
              controller: controllermyLoValue[index],
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                hintText: myLoValue[index],
                fillColor: focusNode.hasFocus
                    ? Colors.yellow[50]
                    : Colors.white,
              ),
              focusNode: focusNode,
            ),
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
      final double bwVal = double.tryParse(controllermyBwValue[i].text) ?? 0.0;
      if (bwVal <= 0) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${i == 0 ? "LAN A →" : "LAN B →"} は帯域が0のため設定をスキップしました',
            ),
          ),
        );
        continue; // 0の場合はこのインターフェースの設定をスキップして次へ
      }

      final unit = myBwSelect[i];
      final double multiplier = switch (unit) {
        'Gbps' => 1e9,
        'Mbps' => 1e6,
        'Kbps' => 1e3,
        _ => 1.0,
      };

      // 小数点入力時に意図せず 0 に切り捨てられないよう round() を使用
      // また、tcコマンドのエラーを防ぐため最低 1kbit を確保
      int rateInKbit = (bwVal * multiplier / 1000).round();
      if (rateInKbit < 1) rateInKbit = 1;

      // バーストとリミットの計算（最低値を保証してエラーを防ぐ）
      double calcBurst = (bwVal * multiplier) / myHziConfig / 8;
      if (calcBurst < 32000) {
        calcBurst = 32000; // 瞬間的な通信の余裕を確保するため、最小値を 32KB に引き上げ
      }

      // 遅延設定の組み立て (myDlSelect[i] が 1:Constant, 2:Uniform, 3:Normal)
      String delayPart =
          'delay ${controllermyDlValue[i * 2].text.isEmpty ? "0" : controllermyDlValue[i * 2].text}ms';
      if (myDlSelect[i] != '1') {
        final String jitter = controllermyDlValue[i * 2 + 1].text.isEmpty
            ? "0"
            : controllermyDlValue[i * 2 + 1].text;
        delayPart += ' ${jitter}ms';
        if (myDlSelect[i] == '3') {
          delayPart += ' distribution normal';
        }
      }

      final String lossText = controllermyLoValue[i].text.isEmpty
          ? "0"
          : controllermyLoValue[i].text;

      // コマンド生成
      final String cmdNetem =
          'sudo tc qdisc replace dev ${EnvConfig.interfaces[i]} root handle 1: netem $delayPart loss $lossText% limit 100000';
      final String cmdTbf =
          'sudo tc qdisc add dev ${EnvConfig.interfaces[i]} parent 1: tbf rate ${rateInKbit}kbit burst ${calcBurst.toInt()} latency 1000ms';

      setState(() {
        _executedCommands.add(cmdNetem);
        _executedCommands.add(cmdTbf);
        // 表示用にコマンドを保持
        myCmd[i] = '$cmdNetem && $cmdTbf';
      });

      try {
        // 設定を適用する前に一度削除（既存設定によるエラー回避）
        await executeProcess(
          'sudo tc qdisc del dev ${EnvConfig.interfaces[i]} root',
        ).catchError((_) {});
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
    // 上部のインターフェース状態表示も最新にする
    await _loadInterfaceStatuses();

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
            _executedCommands.add(
              '[$interface]\n${result.stdout.toString().trim()}',
            );
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
            child: _buildActionButton('初期化', _focusNodes[8], () async {
              setState(() {
                myInit();
                _executedCommands.clear();
              });
              await _resetNetworkSettings();
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              '状態確認',
              _focusNodes[9],
              _handleCheckStatus,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton('決定', _focusNodes[10], _handleExecute),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LAN Settings',
          style: TextStyle(color: Colors.white),
        ),
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
                Column(
                  children: [
                    _buildDataColumn(1),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
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
                            icon: const Icon(
                              Icons.copy,
                              size: 20,
                              color: Colors.blueGrey,
                            ),
                            tooltip: 'クリップボードにコピー',
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: _executedCommands.join('\n'),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('クリップボードにコピーしました'),
                                ),
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

  Widget _buildActionButton(
    String label,
    FocusNode focusNode,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      focusNode: focusNode,
      onPressed: onPressed,
      style:
          ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.focused)) {
                return Colors.yellow[700]; // フォーカス時は黄色
              }
              return Colors.blue; // 通常時は青
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.focused)) {
                return Colors.black; // 黄色背景に合わせて文字色を黒に
              }
              return Colors.white;
            }),
            side: WidgetStateProperty.resolveWith<BorderSide>((states) {
              if (states.contains(WidgetState.focused)) {
                return const BorderSide(
                  color: Colors.blueAccent,
                  width: 4.0,
                ); // フォーカス時に太い枠線
              }
              return BorderSide.none;
            }),
          ),
      child: Text(label, style: const TextStyle(fontSize: 20)),
    );
  }
}

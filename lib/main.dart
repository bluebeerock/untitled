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
  await shell.run(cmd);
}

const Color myDefaultBg = Colors.cyanAccent;

void main() {
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

  final List<String> _executedCommands = [];

  // 共通の装飾スタイル
  BoxDecoration _cellDecoration({Color? color, bool hasBottomBorder = true}) {
    return BoxDecoration(
      color: color,
      border: hasBottomBorder ? const Border(bottom: BorderSide()) : null,
    );
  }

  Widget _buildLabelCell(String text, {double? height}) {
    return Container(
      width: myWidth1,
      height: height ?? myHeight,
      decoration: _cellDecoration(color: Colors.blue),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDataColumn({
    required String title,
    required Color bgColor,
    required int bwIndex,
    required int delayIndexStart,
    required int delayIndexEnd,
    required int delaySelectIndex,
    required int lossIndex,
  }) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      width: myWidth,
      child: Column(
        children: [
          Container(
            width: myWidth,
            height: myHeight,
            decoration: _cellDecoration(color: bgColor),
            child: Center(
              child: Text(title, style: const TextStyle(fontSize: 20)),
            ),
          ),
          Container(
            width: myWidth,
            height: myHeight,
            decoration: _cellDecoration(color: bgColor),
            child: MyBandwidth(myno1: bwIndex),
          ),
          Container(
            height: myHeight1,
            decoration: _cellDecoration(color: bgColor),
            child: MyDelay(
              myno3: delayIndexStart,
              myno4: delayIndexEnd,
              myno5: delaySelectIndex,
            ),
          ),
          Container(
            width: myWidth,
            height: myHeight,
            decoration: _cellDecoration(color: bgColor),
            child: _buildLossInput(lossIndex),
          ),
        ],
      ),
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

  void _handleExecute() {
    setState(() {
      _executedCommands.clear();
      for (int i = 0; i < 2; i++) {
        final unit = myBwSelect[i];
        final double multiplier = switch (unit) {
          'Gbps' => 1e9,
          'Mbps' => 1e6,
          'Kbps' => 1e3,
          _ => 1.0,
        };

        final rateStr = unit.toLowerCase().replaceAll('bps', 'bit');
        final double bwVal = double.tryParse(controllermyBwValue[i].text) ?? 0;
        final double burst = (bwVal * multiplier) / myHziConfig / 8;
        final double limit = burst * 10;

        final String tbf = 'tbf rate $bwVal$rateStr burst $burst limit $limit';
        final String loss = 'netem loss ${controllermyLoValue[i].text}';

        // 環境設定ファイルからインターフェース名を取得
        myCmd[i] = '${myCmdHead[i]} ${EnvConfig.interfaces[i]} root $tbf $loss';
        _executedCommands.add(myCmd[i]);
        debugPrint(myCmd[i]);
      }
    });
    executeProcess('echo Processes Executed');
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
                // Left Column (Labels)
                Container(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [
                      _buildLabelCell(""),
                      _buildLabelCell("帯域"),
                      _buildLabelCell("遅延", height: myHeight1),
                      _buildLabelCell("損失"),
                    ],
                  ),
                ),
                // Center Column (LAN A -> LAN B)
                _buildDataColumn(
                  title: "LAN A → LAN B",
                  bgColor: myDefaultBg,
                  bwIndex: 0,
                  delayIndexStart: 0,
                  delayIndexEnd: 1,
                  delaySelectIndex: 0,
                  lossIndex: 0,
                ),
                // Right Column (LAN B -> LAN A)
                Container(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [
                      _buildDataColumn(
                        title: "LAN B → LAN A",
                        bgColor: myDefaultBg,
                        bwIndex: 1,
                        delayIndexStart: 2,
                        delayIndexEnd: 3,
                        delaySelectIndex: 1,
                        lossIndex: 1,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: myWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildActionButton('初期化', () {
                              setState(() {
                                myInit();
                                _executedCommands.clear();
                              });
                            }),
                            const SizedBox(width: 10),
                            _buildActionButton('決定', _handleExecute),
                          ],
                        ),
                      ),
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
                      const Text(
                        '実行コマンド',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const Divider(),
                      ..._executedCommands
                          .map((cmd) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  cmd,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ))
                          ,
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
      ),
      child: Text(label, style: const TextStyle(fontSize: 20)),
    );
  }
}

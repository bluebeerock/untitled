//
//import 'dart:math';

import 'package:flutter/material.dart' hide Size;
import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'my_bandwidth.dart';
import 'my_delay.dart';
import 'my_init.dart';

Future<void> executeProcess(String cmd) async {
  var shell = Shell();
  await shell.run(cmd);
}

Color get myColor1 => Colors.cyanAccent;
Color get myColor2 => Colors.cyanAccent;

void main() {
  runApp(MaterialApp(home: LanSettingsScreen()));
}

class LanSettingsScreen extends StatelessWidget {
  const LanSettingsScreen({super.key});

  static double get myWidth1 => 150;
  static double get myWidth => 550;
  static double get myHeight1 => 120;
  static double get myHeight => 70;
  
  //static Color get myColor1 => Colors.cyanAccent;
  //static Color get myColor2 => Colors.cyanAccent;
  //static const Color myColor2 = Colors.green; // predefined color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
        const Text('LAN Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,

      ),
      body: Row(
        children: <Widget>[
          ///////////////////////////////////////////////////////////
          Container(
            //Left
            padding: const EdgeInsets.all(2.0),
            // width: myWidth,
            //height: myHeight,
            decoration: BoxDecoration(
              //color: Colors.blue,
              //border: Border.all(color: Colors.black),
              //borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(  // L1
                  width: myWidth1,
                  height: myHeight,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide()),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      "",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Container(  // L2
                  width: myWidth1,
                  height: myHeight,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide()),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      "帯域",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
                Container(  // L3
                  width: myWidth1,
                  height: myHeight1,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: Center(
                    child: Text(
                      "遅延",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                      ),  
                    ),
                  ),
                ),
                Container(  // L4
                  width: myWidth1,
                  height: myHeight,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: Center(
                    child: Text(
                      "損失",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          ///////////////////////////////////////////////////////////
          Container(
            //Center
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(),
            child: Column(
              children: [
                Container(  // M1
                  width: myWidth,
                  height: myHeight,
                  decoration: BoxDecoration(
                    color: myColor1,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: Center(
                    child: Text(
                      "LAN A → LAN B",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                Container(  // M2 帯域
                  width: myWidth,
                  height: myHeight,
                  //color: myColor1,
                  decoration: BoxDecoration(
                    color: myColor1,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: MyBandwidth(myno1: 0),
                ),

                Container(  // M3 遅延
                  width: myWidth,
                  height: myHeight1,
                  //color: Colors.cyanAccent,
                  decoration: BoxDecoration(
                    color: myColor1,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: MyDelay(myno3: 0, myno4: 1, myno5: 0,),
                ),

                Container(  // M4 損失
                  width: myWidth,
                  height: myHeight,
                  //color: myColor1,
                  decoration: BoxDecoration(
                    color: myColor1,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: Row(
                    children: [ 
                      SizedBox(height:30,width: 100,),
                      SizedBox(
                        height: 30,
                        width: 140,
                        child: TextFormField(
                          controller: controllermyLoValue[0],
                          textAlign: TextAlign.right,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            //myLoValue[0] = value;
                          },
                          decoration: InputDecoration(
                            hintText: myDlValue[0],
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20 ,
                      width: 100,
                        child: Text(
                          ' %',
                      ),
                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          ///////////////////////////////////////////////////////////
          Container( 
            //Right
            padding: const EdgeInsets.all(2.0),
            width: myWidth,
            decoration: BoxDecoration(),
            child: Column(
              children: [
                Container(  // R1 表題
                  width: myWidth,
                  height: myHeight,
                  //color: myColor2,
                  decoration: BoxDecoration(
                    color: myColor2,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: Center(
                    child: Text(
                      "LAN B → LAN A",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                Container(  // R2 帯域
                  width: myWidth,
                  height: myHeight,
                  //color: myColor2,
                  decoration: BoxDecoration(
                    color: myColor2,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: MyBandwidth(myno1: 1),
                ),

                Container(  // R3 遅延
                  width: myWidth,
                  height: myHeight1,
                  //color: myColor2,
                  decoration: BoxDecoration(
                    color: myColor2,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: MyDelay( myno3: 2, myno4: 3, myno5: 1,),
                ),

                Container(  // R4 損失
                  width: myWidth,
                  height: myHeight,
                  //color: myColor2,
                  decoration: BoxDecoration(
                    color: myColor2,
                    border: Border(bottom: BorderSide()),
                  ),
                  child: Row(
                    children: [ 
                      SizedBox(height:30,width: 100,),
                      SizedBox(
                        height: 30 ,
                        width: 140,
                        child: TextFormField(
                          controller: controllermyLoValue[1],
                          textAlign: TextAlign.right,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            //myLoValue[1] = value;
                          },
                          decoration: InputDecoration(
                            hintText: myDlValue[1],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20 ,
                        width: 100,
                          child: Text( ' %',),
                      ),
                    ],
                  ),
                ),

                Text(''),


                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    ElevatedButton(
                      //onPressed: () => Navigator.pop(context),
                      onPressed: myInit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // ボタンの背景色を青にする
                        foregroundColor: Colors.white, // テキストの色を白にする
                        //shape: RoundedRectangleBorder(
                        //  borderRadius: BorderRadius.circular(10.0), // ボタンの角を丸くする
                        //),
                      ),
                      child: const Text('初期化', style: TextStyle(fontSize: 20)),
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        debugPrint("BandWidth");
                        debugPrint(controllermyBwValue[0].value.text);
                        debugPrint(myBwSelect[0]);
                                        
                        debugPrint(controllermyBwValue[1].value.text);
                        debugPrint(myBwSelect[1]);
                                        
                        debugPrint('Dely');
                        debugPrint(myDlSelect[0]);
                        debugPrint(controllermyDlValue[0].value.text);
                        debugPrint(controllermyDlValue[1].value.text);
                                        
                        debugPrint(myDlSelect[1]);
                        debugPrint(controllermyDlValue[2].value.text);
                        debugPrint(controllermyDlValue[3].value.text);
                                        
                        debugPrint('Lost');
                        debugPrint(controllermyLoValue[0].value.text);
                        debugPrint(controllermyLoValue[1].value.text);

                        // 帯域 
                        var myRate = '';
                        double myBurst = 1;
                        double myBrustLimit = 1;
                        double myLocalNum = 1;
                        var myTbf = '';

                        for (int i = 0; i < 2; i++) {
                          switch(myBwSelect[i]) {
                            case 'Gbps': 
                              myRate = '${myBwValue[i]}gbit';
                              myLocalNum = 1000000000; 
                            break;
                            case 'Mbps': 
                              myRate = '${myBwValue[i]}mbit';
                              myLocalNum = 1000000; 
                            break;
                            case 'Kbps': 
                              myRate = '${myBwValue[i]}kbit';
                              myLocalNum = 1000; 
                            break;
                          }
                          myBurst = double.parse(myBwValue[i])*myLocalNum/myHziConfig/8;
                          myBrustLimit = myBurst * 10;
                          myTbf = 'tbf rate $myRate burst $myBurst limit $myBrustLimit';
                          myCmd[i] = '${myCmdHead[i]} ${myLanNo[i]} root $myTbf';
                          debugPrint(myCmd[i]);
                        }

                        // 損失
                        for (int i = 0; i < 2; i++) {
                          myTbf = 'netem loss ${myLoValue[i]}';
                          myCmd[i] = '${myCmdHead[i]} ${myLanNo[i]} root $myTbf';
                          debugPrint(myCmd[i]);
                        }

                        executeProcess('echo Hello,World');

                      },
                                        
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // ボタンの背景色を青にする
                        foregroundColor: Colors.white, // テキストの色を白にする
                        //shape: RoundedRectangleBorder(
                        //  borderRadius: BorderRadius.circular(10.0), // ボタンの角を丸くする
                        //),
                      ),
                      child: const Text('決定', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  
}



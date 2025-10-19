import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'my_init.dart';

// ignore: must_be_immutable
class MyDelay extends StatefulWidget {
  final int myno3;
  final int myno4;
  final int myno5;
  const MyDelay({super.key,  required this.myno3, required this.myno4, required this.myno5});

  @override
  State<MyDelay> createState() => _MyDelay();
}

class _MyDelay extends State<MyDelay> {

  int _radioValue = 1;
  bool isConst = false; //true false
  var  isForm = ' min';
  var  isTo = ' max';
  int  isMax = 0;
  int  isMin = 0;
  
  void _onRadioSelected(int? value) {
    setState(() {
      if (value == 1) {
        isConst = false; 
        isForm = '';
        isTo   = '';
      }
      else {
        isConst = true; 
        isForm = ' min';
        isTo   = ' max';
      }
      _radioValue = value!;
      myDlSelect[widget.myno5] = _radioValue.toString();
    });
  }
  // ボタンを押したら呼ばれる関数
  /*
  void _xxxx() {
    debugPrint( myDlSelect.toString() );
    debugPrint( myDlValue.toString()  );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.cyanAccent,
        child: Column(
          children: [
            Row(
              children: <Widget>[
            
                // 1つめのボタン
                SizedBox(
                  height: 25 ,
                  width: 160,
                  child: RadioListTile(
                    title: Text('Costant'),
                    value: 1,
                    groupValue: _radioValue,
                    onChanged: (int? value) =>  _onRadioSelected(value),
                  ),
                ),
            
                // 2つ目のボタン
                SizedBox(
                  height: 25 ,
                  width: 160,
                  child: RadioListTile(
                    title: Text('Uniform'),
                    value: 2,
                    groupValue: _radioValue,
                    onChanged: (int? value) => _onRadioSelected(value),
                  ),
                ),
            
                // 3つ目のボタン
                SizedBox(
                  height: 25 ,
                  width: 160,
                  child: RadioListTile(
                    title: Text('Normal'),
                    value: 3,
                    groupValue: _radioValue,
                    onChanged: (int? value) => _onRadioSelected(value),
                  ),
                ),
              ],
            ),
        
            const Text(''),
        
            Row(
              children: <Widget>[
                const SizedBox(width:20),
                SizedBox(
                  height: 30 ,
                  width: 240,
                  child: Text(
                    isForm,
                  ),
                ),
                const SizedBox(width:20),
                SizedBox(
                  height: 30 ,
                  width: 240,
                  child: Text(
                    isTo,
                  ),
                ),
              ]
            ),
        
            Row(
              children: <Widget>[
                SizedBox(width:20),
                SizedBox(
                  height: 30 ,
                  width: 140,
                  child: TextFormField(
                    controller: controllermyDlValue[widget.myno3],
                    textAlign: TextAlign.right,
                    enabled: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      //myDlValue[widget.myno3] = value;
                    },
                    decoration: InputDecoration(
                      hintText: myDlValue[widget.myno3],
                    ),
                  ),
                ),
        
                const SizedBox(
                  height: 20 ,
                  width: 100,
                  child: Text(
                    ' ms',
                  ),
                ),
        
                const SizedBox(width:20),
                SizedBox(
                  height: 30 ,
                  width: 140,
                  child: TextFormField(
                    controller: controllermyDlValue[widget.myno4],
                    textAlign: TextAlign.right,
                    enabled: isConst,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      //myDlValue[widget.myno4] = value;
                    },
                    decoration: InputDecoration(
                      //border: OutlineInputBorder(),
                      hintText: myDlValue[widget.myno4],
                    ),
                  ),
                ),
        
                const SizedBox(
                  height: 20 ,
                  width: 100,
                  child: Text(
                    ' ms',
                  ),
                ),
        
              ],
            ),
            //const Text(''),
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _xxxx(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // ボタンの背景色を青にする
                    foregroundColor: Colors.white, // テキストの色を白にする
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // ボタンの角を丸くする
                    ),
                  ),
                  child: const Text('設定'),
                ),
              ],
            ),
            */
        
          ],
        ),
      ),
    );
  }

}




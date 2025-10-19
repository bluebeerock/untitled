import 'package:flutter/material.dart' hide Size;
import 'package:flutter/services.dart';
import 'dropdown_button_menu.dart';
import 'my_init.dart';

class MyBandwidth extends StatefulWidget {
  final int myno1;
  const MyBandwidth({super.key, required this.myno1});

  @override
  State<MyBandwidth> createState() => _MyBandwidthState();
}

class _MyBandwidthState extends State<MyBandwidth> {
  @override
  Widget build(BuildContext context) {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 適宜調整
      children: <Widget>[
        //SizedBox(width: 20,),
        SizedBox(
          height:  30,
          width:  120,
          child: TextFormField(
            controller: controllermyBwValue[widget.myno1],
            textAlign: TextAlign.right,
            enabled: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              //myBwValue[widget.myno1] = value;
            },
            decoration: InputDecoration(
              hintText: myBwValue[widget.myno1]
            ),
          ),
        ),
        SizedBox(width: 100,
          child: DropdownButtonMenu(myno2: widget.myno1)
        ),
      ],
    ));
  }
}

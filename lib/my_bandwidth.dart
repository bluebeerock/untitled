import 'package:flutter/material.dart' hide Size;
import 'package:flutter/services.dart';
import 'dropdown_button_menu.dart';
import 'my_init.dart';

class MyBandwidth extends StatefulWidget {
  final int myno1;
  final FocusNode? focusNode;
  const MyBandwidth({super.key, required this.myno1, this.focusNode});

  @override
  State<MyBandwidth> createState() => _MyBandwidthState();
}

class _MyBandwidthState extends State<MyBandwidth> {
  @override
  Widget build(BuildContext context) {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          height: 45,
          width: 120,
          child: Focus(
            onFocusChange: (hasFocus) => setState(() {}),
            child: TextFormField(
              controller: controllermyBwValue[widget.myno1],
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                hintText: myBwValue[widget.myno1],
                fillColor: (widget.focusNode?.hasFocus ?? false)
                    ? Colors.yellow[50]
                    : Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 110,
          height: 45,
          child: DropdownButtonMenu(myno2: widget.myno1),
        ),
      ],
    ));
  }
}

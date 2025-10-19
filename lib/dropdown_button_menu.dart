import 'package:flutter/material.dart' hide Size;
import 'my_init.dart';

class DropdownButtonMenu extends StatefulWidget {
  final int myno2;
  const DropdownButtonMenu({super.key, required this.myno2});

  @override
  State<DropdownButtonMenu> createState() => _DropdownButtonMenuState();
}

class _DropdownButtonMenuState extends State<DropdownButtonMenu> {
  //String isSelectedValue = 'Gbps';

  @override
  Widget build(BuildContext context) {
    return (DropdownButton(
      items: const [
        DropdownMenuItem(value: 'Gbps', child: Text('Gbps')),
        DropdownMenuItem(value: 'Mbps', child: Text('Mbps')),
        DropdownMenuItem(value: 'Kbps', child: Text('Kbps')),
      ],
      value: isSelectedValue[widget.myno2],
      onChanged: (String? value) {
        setState(() {
          isSelectedValue[widget.myno2] = value!;
          myBwSelect[widget.myno2] = isSelectedValue[widget.myno2];
          debugPrint(isSelectedValue[widget.myno2]);
        });
      },
    ));
  }
}

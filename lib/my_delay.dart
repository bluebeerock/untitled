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
  void _onRadioSelected(int? value) {
    setState(() {
      myDlSelect[widget.myno5] = (value ?? 1).toString();
    });
  }

  Widget _buildRadio(String title, int value, int groupValue) {
    return SizedBox(
      height: 25,
      width: 160,
      child: RadioListTile<int>(
        title: Text(title),
        value: value,
        groupValue: groupValue,
        onChanged: _onRadioSelected,
      ),
    );
  }

  Widget _buildTimeField(int index, {required bool enabled}) {
    return Row(
      children: [
        SizedBox(
          height: 30,
          width: 140,
          child: TextFormField(
            controller: controllermyDlValue[index],
            textAlign: TextAlign.right,
            enabled: enabled,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: myDlValue[index]),
          ),
        ),
        const SizedBox(height: 20, width: 100, child: Text(' ms')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentRadioValue = int.tryParse(myDlSelect[widget.myno5]) ?? 1;
    final bool isNotConstant = currentRadioValue != 1;
    final String formLabel = isNotConstant ? ' min' : '';
    final String toLabel = isNotConstant ? ' max' : '';

    return Container(
      color: Colors.cyanAccent,
      child: Column(
        children: [
          Row(
            children: [
              _buildRadio('Constant', 1, currentRadioValue),
              _buildRadio('Uniform', 2, currentRadioValue),
              _buildRadio('Normal', 3, currentRadioValue),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const SizedBox(width: 20),
              SizedBox(width: 240, height: 20, child: Text(formLabel)),
              const SizedBox(width: 20),
              SizedBox(width: 240, height: 20, child: Text(toLabel)),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              _buildTimeField(widget.myno3, enabled: true),
              const SizedBox(width: 20),
              _buildTimeField(widget.myno4, enabled: isNotConstant),
            ],
          ),
        ],
      ),
    );
  }
}

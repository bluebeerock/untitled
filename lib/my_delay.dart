import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'my_init.dart';

// ignore: must_be_immutable
class MyDelay extends StatefulWidget {
  final int myno3;
  final int myno4;
  final int myno5;
  final FocusNode? focusNode1;
  final FocusNode? focusNode2;
  const MyDelay({
    super.key,
    required this.myno3,
    required this.myno4,
    required this.myno5,
    this.focusNode1,
    this.focusNode2,
  });

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
        // ignore: deprecated_member_use
        groupValue: groupValue,
        // ignore: deprecated_member_use
        onChanged: _onRadioSelected,
        focusNode: FocusNode(canRequestFocus: false), // ラジオボタンをTab順序から除外
      ),
    );
  }

  Widget _buildTimeField(
    int index, {
    required bool enabled,
    FocusNode? focusNode,
  }) {
    return Row(
      children: [
        SizedBox(
          height: 45,
          width: 140,
          child: Focus(
            onFocusChange: (hasFocus) => setState(() {}),
            child: TextFormField(
              controller: controllermyDlValue[index],
              textAlign: TextAlign.right,
              enabled: enabled,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              focusNode: focusNode,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: myDlValue[index],
                fillColor: enabled
                    ? ((focusNode?.hasFocus ?? false)
                          ? Colors.yellow[50]
                          : Colors.white)
                    : Colors.grey[200],
              ),
            ),
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
    final String formLabel = isNotConstant ? ' 基準値' : '';
    final String toLabel = isNotConstant ? ' ゆらぎ' : '';

    return Container(
      color: Colors.cyanAccent,
      child: Column(
        children: [
          Row(
            children: [
              _buildRadio('固定', 1, currentRadioValue),
              _buildRadio('正規分布', 2, currentRadioValue),
              _buildRadio('標準偏差', 3, currentRadioValue),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // const SizedBox(width: 156), // 帯域の中央揃えに合わせた左余白 - 左揃えのため削除
              SizedBox(width: 240, height: 20, child: Text(formLabel)),
              const SizedBox(width: 7), // 20pxから7pxに短縮
              SizedBox(width: 240, height: 20, child: Text(toLabel)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // const SizedBox(width: 156), // 帯域の中央揃えに合わせた左余白 - 左揃えのため削除
              _buildTimeField(
                widget.myno3,
                enabled: true,
                focusNode: widget.focusNode1,
              ),
              const SizedBox(width: 7), // 20pxから7pxに短縮
              _buildTimeField(
                widget.myno4,
                enabled: isNotConstant,
                focusNode: widget.focusNode2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

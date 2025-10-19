import 'package:flutter/material.dart';

List<String> myBwSelect = ['Gbps', 'Gbps'];
List<String> isSelectedValue = ['Gbps','Gbps'];
List<String> myBwValue = ['1', '1'];
List<String> myDlSelect = ['1', '1' ];
List<String> myDlValue = ['0', '0' , '0' ,'0'];
List<String> myLoValue = ['0','0'];

List<String> myLanNo = ['eth0','eth1'];
List<String> myCmdHead = ['tc qdisc add dev','tc qdisc add dev'];
List<String> myCmd = ['',''];

double myHziConfig = 1000;

List<TextEditingController> controllermyBwValue = List.generate(2, (i) => TextEditingController());
List<TextEditingController> controllermyDlValue = List.generate(4, (i) => TextEditingController());
List<TextEditingController> controllermyLoValue = List.generate(2, (i) => TextEditingController());

void myInit(){
  debugPrint('myInit');
  myBwSelect = ['Gbps', 'Gbps'];
  isSelectedValue = ['Gbps','Gbps'];
  myBwValue = ['1', '1'];
  myDlSelect = ['1', '1' ];
  myDlValue = ['0', '0' , '0' ,'0'];
  myLoValue = ['0','0'];
  controllermyBwValue[0].text = '0';
  controllermyBwValue[1].text = '0';
  controllermyDlValue[0].text = '0';
  controllermyDlValue[1].text = '0';
  controllermyDlValue[2].text = '0';
  controllermyDlValue[3].text = '0';
  controllermyLoValue[0].text = '0';
  controllermyLoValue[1].text = '0';
}


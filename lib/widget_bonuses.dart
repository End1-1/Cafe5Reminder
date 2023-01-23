import 'dart:typed_data';

import 'package:cafe5_reminder/base_widget.dart';
import 'package:cafe5_reminder/class_outlinedbutton.dart';
import 'package:cafe5_reminder/config.dart';
import 'package:cafe5_reminder/socket_message.dart';
import 'package:cafe5_reminder/translator.dart';
import 'package:flutter/material.dart';

class WidgetBonusPage extends StatefulWidget {
  WidgetBonusPage({super.key}) {}

  @override
  State<StatefulWidget> createState() {
    return WidgetBonusPageState();
  }
}

class WidgetBonusPageState extends BaseWidgetState with TickerProviderStateMixin {
  int _bonus = 0;

  @override
  void handler(Uint8List data) async {
    SocketMessage m = SocketMessage(messageId: 0, command: 0);
    m.setBuffer(data);
    if (!checkSocketMessage(m)) {
      return;
    }
    print("command ${m.command}");
    if (m.command == SocketMessage.c_dllplugin) {
      int op = m.getInt();
      int dllok = m.getByte();
      if (dllok == 0) {
        sd(tr(m.getString()));
        return;
      }
      switch (op) {
        case SocketMessage.op_check_bonus:
          setState((){
            _bonus = m.getInt();
          });
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SocketMessage m = SocketMessage.dllplugin(SocketMessage.op_check_bonus);
      sendSocketMessage(m);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            minimum: const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 35),
            child: Stack(children: [
              Container(color: Colors.white),
              Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      ClassOutlinedButton.createImage(() {
                        Navigator.pop(context);
                      }, "images/back.png"),
                      Expanded(child: Container()),
                      Text(Config.getString(key_fullname), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Container()),

                    ]),
                    Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "${tr("Bonuses")}: $_bonus",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ))),
                  ])
            ])));
  }
}

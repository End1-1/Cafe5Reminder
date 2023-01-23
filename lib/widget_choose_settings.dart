import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cafe5_reminder/translator.dart';
import 'package:cafe5_reminder/config.dart';
import 'package:cafe5_reminder/base_widget.dart';
import 'package:cafe5_reminder/socket_message.dart';
import 'package:cafe5_reminder/home_page.dart';

import 'client_socket.dart';

class WidgetChooseSettings extends StatefulWidget {
  const WidgetChooseSettings({super.key});
  @override
  State<StatefulWidget> createState() {
    return WidgetChooseSettingsState();
  }
}

class WidgetChooseSettingsState extends BaseWidgetState<WidgetChooseSettings> {

  @override
  void handler(Uint8List data) {
    SocketMessage m = SocketMessage(messageId: 0, command: 0);
    m.setBuffer(data);
    if (!checkSocketMessage(m)) {
      return;
    }
    print("command ${m.command}");
    switch (m.command) {
      case SocketMessage.c_hello:
        m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_auth);
        m.addString(Config.getString(key_server_username));
        m.addString(Config.getString(key_server_password));
        sendSocketMessage(m);
        break;
      case SocketMessage.c_auth:
        int userid = m.getInt();
        if (userid > 0) {
          ClientSocket.setSocketState(2);
        }
        break;
    }
  }

  @override
  void connected(){
    print("WidgetChooseSettings.connected()");
    SocketMessage.resetPacketCounter();
    SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_hello);
    sendSocketMessage(m);
  }

  @override
  void authenticate() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => WidgetHome()), (route) => false);
    //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => WidgetHome()));
  }

  @override
  void disconnected() {
    setState((){});
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Image(image: AssetImage(ClientSocket.imageConnectionState()),)
              ),
            ]
        )
    );
  }
}
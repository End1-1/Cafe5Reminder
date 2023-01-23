import 'dart:typed_data';

import 'package:cafe5_reminder/base_widget.dart';
import 'package:cafe5_reminder/class_outlinedbutton.dart';
import 'package:cafe5_reminder/config.dart';
import 'package:cafe5_reminder/socket_message.dart';
import 'package:cafe5_reminder/translator.dart';
import 'package:cafe5_reminder/widget_main_page.dart';
import 'package:flutter/material.dart';

class WidgetHome extends StatefulWidget {
  WidgetHome({super.key}) {
    print("Create WidgetHome");
  }

  @override
  State<StatefulWidget> createState() {
    return WidgetHomeState();
  }
}

class WidgetHomeState extends BaseWidgetState with TickerProviderStateMixin {
  bool _dataLoading = false;
  bool _showPin = false;
  String _progressString = "";
  late AnimationController animationController;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (Config.getString(key_session_id).isNotEmpty) {
        SocketMessage m = SocketMessage.dllplugin(SocketMessage.op_login_pashhash);
        m.addString(Config.getString(key_session_id));
        m.addString(Config.getString(key_firebase_token));
        sendSocketMessage(m);
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void handler(Uint8List data) async {
    _dataLoading = false;
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
        case SocketMessage.op_login:
          Config.setString(key_session_id, m.getString());
          Config.setString(key_fullname, m.getString());
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => WidgetMainPage()), (route) => false);
          break;
        case SocketMessage.op_login_pashhash:
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => WidgetMainPage()), (route) => false);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Align(
              alignment: Alignment.center,
              child: Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    tr("Sign in"),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ))),
          Visibility(
              visible: false,
              child: Column(children: [
                Align(
                    alignment: Alignment.center,
                    child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 252,
                        decoration: BoxDecoration(border: Border.all(color: Colors.black38)),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset(
                              "images/user.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: 200,
                            child: TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: tr("Username"),
                                hintStyle: const TextStyle(color: Colors.black12),
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        ]))),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 252,
                        decoration: BoxDecoration(border: Border.all(color: Colors.black38)),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset(
                              "images/lock.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: 200,
                            child: TextFormField(
                              obscureText: true,
                              controller: _passwordController,
                              style: const TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: tr("********"),
                                hintStyle: const TextStyle(color: Colors.black12),
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        ]))),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 252,
                        height: 50,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                              backgroundColor: Colors.blueGrey,
                              side: const BorderSide(
                                width: 1.0,
                                color: Colors.black38,
                                style: BorderStyle.solid,
                              ),
                            ),
                            onPressed: _login,
                            child: Text(tr("Login"), style: const TextStyle(color: Colors.white))))),
              ])),
          Align(
              child: SizedBox(
                  width: 72 * 3,
                  child: TextFormField(
                    obscureText: !_showPin,
                    controller: _pinController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    decoration: InputDecoration(
                        suffixIcon: ClassOutlinedButton.createImage(() {
                      setState(() {
                        _showPin = !_showPin;
                      });
                    }, _showPin ? "images/hidden.png" : "images/view.png")),
                  ))),
          Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClassOutlinedButton.create(() {
                            _pin("7");
                          }, "7", h: 72, w: 72),
                          ClassOutlinedButton.create(() {
                            _pin("8");
                          }, "8", h: 72, w: 72),
                          ClassOutlinedButton.create(() {
                            _pin("9");
                          }, "9", h: 72, w: 72),
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClassOutlinedButton.create(() {
                            _pin("4");
                          }, "4", h: 72, w: 72),
                          ClassOutlinedButton.create(() {
                            _pin("5");
                          }, "5", h: 72, w: 72),
                          ClassOutlinedButton.create(() {
                            _pin("6");
                          }, "6", h: 72, w: 72),
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClassOutlinedButton.create(() {
                            _pin("1");
                          }, "1", h: 72, w: 72),
                          ClassOutlinedButton.create(() {
                            _pin("2");
                          }, "2", h: 72, w: 72),
                          ClassOutlinedButton.create(() {
                            _pin("3");
                          }, "3", h: 72, w: 72),
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClassOutlinedButton.createImage(() {
                            _loginPin();
                          }, "images/user.png", h: 72, w: 72),
                          ClassOutlinedButton.create(() {
                            _pin("0");
                          }, "0", h: 72, w: 72),
                          ClassOutlinedButton.createImage(() {
                            _pinController.clear();
                          }, "images/cancel.png", h: 72, w: 72),
                        ],
                      ))
                ],
              )),
          Align(
              child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Visibility(
                      visible: _dataLoading,
                      child: CircularProgressIndicator(
                        value: animationController.value,
                      )))),
          Align(
            child: Container(margin: const EdgeInsets.only(top: 5), child: Visibility(visible: _progressString.isNotEmpty, child: Text(_progressString))),
          )
        ])));
  }

  void _login() {
    if (_dataLoading) {
      return;
    }
    setState(() {
      _dataLoading = true;
      _progressString = "";
    });
    SocketMessage m = SocketMessage.dllplugin(SocketMessage.op_login);
    m.addString(_usernameController.text);
    m.addString(_passwordController.text);
    sendSocketMessage(m);
  }

  void _loginPin() {
    if (_dataLoading) {
      return;
    }
    setState(() {
      _dataLoading = true;
      _progressString = "";
    });
    SocketMessage m = SocketMessage.dllplugin(SocketMessage.op_login);
    m.addString(_pinController.text);
    m.addString(Config.getString(key_firebase_token));
    sendSocketMessage(m);
  }

  void _pin(String t) {
    _pinController.text += t;
  }
}

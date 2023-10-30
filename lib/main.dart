import 'package:flutter/material.dart';
import 'package:spin_wheel_game_flutter/game.dart';
import 'package:spin_wheel_game_flutter/utils/constant.dart';
import 'package:spin_wheel_game_flutter/utils/utils.dart';

void main(){
  runApp(const MyGameApp());
}

class MyGameApp extends StatelessWidget {
  const MyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constant.title,
      theme: ThemeData(
        fontFamily: Utils.fontFamily,
        primarySwatch: Colors.blue,
      ),
      home: const Game(),
    );
  }
}

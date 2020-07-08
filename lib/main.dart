import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_unit_mac/views/app/bloc_wrapper.dart';
import 'views/app/flutter_app.dart';
import 'package:window_size/window_size.dart' as window_size;

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  // 获取窗口信息，然后设置窗口信息
  window_size.getWindowInfo().then((window) {
    if (window.screen != null) {
      final screenFrame = window.screen.visibleFrame;
      final width = max((screenFrame.width / 2).roundToDouble(),1100.0);
      final height = max((screenFrame.height / 2).roundToDouble(), 850.0);
      final left = ((screenFrame.width - width) / 2).roundToDouble();
      final top = ((screenFrame.height - height) / 3).roundToDouble();
      final frame = Rect.fromLTWH(left, top, width, height);
      //设置窗口信息
      window_size.setWindowFrame(frame);
      //设置窗口顶部标题
      window_size
          .setWindowTitle('Flutter Unit Windows');

      if (Platform.isMacOS) {
        window_size.setWindowMinSize(Size(800, 600));
        window_size.setWindowMaxSize(Size(1600, 1200));
      }
    }
  });
  runApp(BlocWrapper(child: FlutterApp()));
}

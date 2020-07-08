
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_unit_mac/app/res/cons.dart';
import 'package:flutter_unit_mac/app/res/sp.dart';
import 'package:flutter_unit_mac/blocs/global/global_state.dart';
import 'package:moor_ffi/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
/// create by 张风捷特烈 on 2020-03-04
/// contact me by email 1981462002@qq.com
/// 说明:

class AppStorage {
//  SharedPreferences _sp;
  Database _database;

//  Future<SharedPreferences> get sp async {
//    _sp = _sp ?? await SharedPreferences.getInstance();
//    return _sp;
//  }

  Future<Database> get db async {
    _database = _database ?? await initDb();
    return _database;
  }

  // 初始化 App 固化的配置数据
  Future<GlobalState> initApp() async {
//    var prefs = await sp;
    _database = await initDb();
//    var showBg = prefs.getBool(SP.showBackground) ?? true;
//    var themeIndex = prefs.getInt(SP.themeColorIndex) ?? 4;
//    var fontIndex = prefs.getInt(SP.fontFamily) ?? 1;
//    var codeIndex = prefs.getInt(SP.codeStyleIndex) ?? 0;
//    var itemStyleIndex = prefs.getInt(SP.itemStyleIndex) ?? 0;
    var showBg =true;
    var themeIndex = 4;
    var fontIndex =  1;
    var codeIndex = 0;
    var itemStyleIndex = 0;

    return GlobalState(
        showBackGround: showBg,
        themeColor: Cons.themeColorSupport.keys.toList()[themeIndex],
        fontFamily: Cons.fontFamilySupport[fontIndex],
        itemStyleIndex: itemStyleIndex,
        codeStyleIndex: codeIndex);
  }

  // 初始化数据库
  Future<Database> initDb() async {
    Directory appDir = await getApplicationSupportDirectory();
    var dbPath = path.join(appDir.path, "flutter.db");
    var file =File(dbPath);
    if (!file.existsSync()) {
      //特别注意: `window加载assets文件，这里不要用path.join。 这个就是assets/XXX`
      ByteData data = await rootBundle.load("assets/flutter.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await file.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      print("========= assets ======拷贝完成====");
    } else {
      print("========= 数据库 ======已存在====");
    }
    _database = await Database.open(path.join(appDir.path,'flutter.db'));
    return _database;
  }
}

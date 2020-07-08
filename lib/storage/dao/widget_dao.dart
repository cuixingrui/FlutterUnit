import 'package:flutter_unit_mac/storage/app_storage.dart';
import 'package:flutter_unit_mac/app/enums.dart';

import '../po/widget_po.dart';


class WidgetDao {

 final  AppStorage storage;


 WidgetDao(this.storage);

 Future<int> insert(WidgetPo widget) async {
    //插入方法
    final db = await storage.db;
    String addSql = //插入数据
        "INSERT INTO "
        "widget(id,name,nameCN,collected,family,lever,image,linkWidget,info) "
        "VALUES (?,?,?,?,?,?,?,?,?);";

    db.prepare(addSql).execute([
      widget.id,
      widget.name,
      widget.nameCN,
      widget.collected,
      widget.family,
      widget.lever,
      widget.image,
      widget.linkWidget,
      widget.info
    ]);
    return 1;
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await storage.db;
    return await db.prepare("SELECT * "
        "FROM widget").select().toList();
  }

  Future<List<Map<String, dynamic>>> queryByFamily(WidgetFamily family) async {
    final db = await storage.db;
    return await db.prepare(
        "SELECT * "
        "FROM widget WHERE family = ? ORDER BY lever DESC",
        ).select([family.index]).toList();
  }

  Future<List<Map<String, dynamic>>> queryByIds(List<int> ids) async {
    if (ids.length == 0) {
      return [];
    }

    final db = await storage.db;

    var sql = "SELECT * "
        "FROM widget WHERE id in (${'?,' * (ids.length - 1)}?) ";

    return await db.prepare(sql).select([...ids]).toList();
  }

  Future<List<Map<String, dynamic>>> search(SearchArgs arguments) async {
    final db = await storage.db;
    return await db.prepare(
        "SELECT * "
        "FROM widget WHERE name like ? AND lever IN(?,?,?,?,?) ORDER BY lever DESC",
        ).select(["%${arguments.name}%", ...arguments.stars]).toList();
  }

  Future<List<Map<String, dynamic>>> toggleCollect(int id) async {
    final db = await storage.db;
    var data = await db.prepare('SELECT collected FROM widget WHERE id = ?').select([id]);
    var collected = data.toList()[0]['collected']==1;
    return await db.prepare(
        "UPDATE widget SET collected = ? "
        "WHERE id = ?").select([collected ? 0 : 1, id]).toList();
  }

  Future<List<Map<String, dynamic>>> queryCollect() async {
    final db = await storage.db;
    return await db.prepare("SELECT * "
        "FROM widget WHERE collected = 1 ORDER BY family,lever DESC").select().toList();
  }

 Future<bool> collected(int id) async {
   final db = await storage.db;
   var data = await db.prepare("SELECT collected "
       "FROM widget WHERE id = ?").select([id]).toList();

   if(data.length>0){
     return data[0]['collected'] == 1;
   }
   return false;
 }

}

class SearchArgs {
  final String name;
  final List<int> stars;

  const SearchArgs({this.name = '', this.stars = const [-1, -1, -1, -1, -1]});
}

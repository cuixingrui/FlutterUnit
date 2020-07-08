import 'package:moor_ffi/database.dart';

import '../app_storage.dart';
import '../po/category_po.dart';

//"""
// CREATE TABLE IF NOT EXISTS category(
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     name VARCHAR(64) NOT NULL,
//     color VARCHAR(9) DEFAULT '#FF2196F3',
//     info VARCHAR(256) DEFAULT '这里什么都没有...',
//     created DATETIME NOT NULL,
//     updated DATETIME NOT NULL,
//     priority INTEGER DEFAULT 0,
//     image VARCHAR(128) NULL image DEFAULT ''
//     );
//""";

class CategoryDao {
  final AppStorage storage;

  CategoryDao(this.storage);

  Future<Database> get _db async => await storage.db;

  Future<int> insert(CategoryPo widget) async {
    //插入方法
    final db = await _db;
    String addSql = //插入数据
        "INSERT INTO "
        "category(name,color,info,priority,image,created,updated) "
        "VALUES (?,?,?,?,?,?,?);";

    db.prepare(addSql).execute([
      widget.name,
      widget.color,
      widget.info,
      widget.priority,
      widget.image,
      widget.created.toIso8601String(),
      widget.updated.toIso8601String(),
    ]);
    return 1;
  }

  Future<int> update(CategoryPo widget) async {
    //插入方法
    final db = await _db;
    String updateSql = //插入数据
        "UPDATE category SET name=? , color=? ,info=?, priority=?,image=?,updated=? "
        "WHERE id = ?";
    db.prepare(updateSql).execute([
      widget.name,
      widget.color,
      widget.info,
      widget.priority,
      widget.image,
      widget.updated.toIso8601String(),
      widget.id,
    ]);
    return 1;
  }

  Future<int> addWidget(
    int categoryId,
    int widgetId,
  ) async {
    final db = await _db;
    String addSql = //插入数据
        "INSERT INTO "
        "category_widget(widgetId,categoryId) "
        "VALUES (?,?);";
    db.prepare(addSql).execute([
      widgetId,
      categoryId,
    ]);
    return 1;
  }

  Future<bool> existByName(String name) async {
    final db = await _db;
    String sql = //插入数据
        "SELECT COUNT(name) as count FROM category "
        "WHERE name = ?";
    var rawData = db.prepare(sql).select([name]).toList();
    if (rawData.length > 0) {
      return rawData[0]['count'] > 0;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await _db;
    var querySql =
        "SELECT c.id,c.name,c.info,c.color,c.image,c.created,c.updated,c.priority,COUNT(cw.categoryId) as `count`"
        "FROM category AS c "
        "LEFT JOIN category_widget AS cw "
        "ON c.id = cw.categoryId GROUP BY c.id "
        "ORDER BY priority DESC,created DESC";
    var rawData = db.prepare(querySql).select().toList();
    return rawData;
  }

  Future<List<int>> categoryWidgetIds(int id) async {
    final db = await _db;
    var data = await db.prepare(
        "SELECT categoryId FROM category_widget "
        "WHERE widgetId = ?").select([id]);
    return data.toList().map<int>((e) => e["categoryId"]).toList();
  }

  Future<void> deleteCollect(int id) async {
    final db = await _db;
    await db.prepare(
        "DELETE FROM category_widget "
        "WHERE categoryId = ?",
        ).execute([id]);
    await db.prepare(
        "DELETE FROM category "
        "WHERE id = ?",
       ).execute( [id]);
    return 0;
  }

  Future<int> removeWidget(int categoryId, int widgetId) async {
    //插入方法
    final db = await _db;
    String deleteSql = //插入数据
        "DELETE FROM "
        "category_widget WHERE categoryId = ? AND widgetId = ? ";
     await db.prepare(deleteSql).execute( [
      categoryId,
      widgetId,
    ]);
      return 1;
  }

  Future<bool> existWidgetInCollect(int categoryId, int widgetId) async {
    final db = await _db;
    String sql = //插入数据
        "SELECT COUNT(id) as count FROM category_widget "
        "WHERE categoryId = ? AND widgetId = ?";
    var rawData = await db.prepare(sql).select( [categoryId, widgetId]).toList();
    if (rawData.length > 0) {
      return rawData[0]['count'] > 0;
    }
    return false;
  }

  Future<void> toggleCollect(int categoryId, int widgetId) async {
    if (await existWidgetInCollect(categoryId, widgetId)) {
      //已存在: 移除
      await removeWidget(categoryId, widgetId);
    } else {
      await addWidget(categoryId, widgetId);
    }
  }

  Future<void> toggleCollectDefault(int widgetId) async {
    await toggleCollect(1, widgetId);
  }

  Future<List<Map<String, dynamic>>> loadCollectWidgets(int categoryId) async {
    String querySql = //插入数据
        "SELECT * FROM widget "
        "WHERE id IN (SELECT widgetId FROM category_widget WHERE categoryId = ?) "
        "ORDER BY lever DESC";

    final db = await _db;
    return await db.prepare(querySql).select( [categoryId]).toList();
  }
}

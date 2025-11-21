import 'package:hive_flutter/hive_flutter.dart';
import '../../models/shopping_list_model.dart';
import '../../models/shopping_item_model.dart';
import 'local_data_source.dart';

class HiveLocalDataSource implements LocalDataSource {
  static const String _boxName = 'shopping_lists';
  late Box<Map> _box;
  
  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }
  
  @override
  Future<List<ShoppingListModel>> getAllLists() async {
    final lists = <ShoppingListModel>[];
    for (var key in _box.keys) {
      final data = _box.get(key) as Map<String, dynamic>?;
      if (data != null) {
        lists.add(ShoppingListModel.fromJson(data));
      }
    }
    return lists;
  }
  
  @override
  Future<ShoppingListModel?> getListById(String id) async {
    final data = _box.get(id) as Map<String, dynamic>?;
    if (data != null) {
      return ShoppingListModel.fromJson(data);
    }
    return null;
  }
  
  @override
  Future<ShoppingListModel> saveList(ShoppingListModel list) async {
    await _box.put(list.id, list.toJson());
    return list;
  }
  
  @override
  Future<void> deleteList(String id) async {
    await _box.delete(id);
  }
  
  @override
  Future<void> clearAll() async {
    await _box.clear();
  }
}


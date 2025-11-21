import 'package:aik_buy_it/data/models/shopping_list_model.dart';

abstract class LocalDataSource {
  Future<List<ShoppingListModel>> getAllLists();
  Future<ShoppingListModel?> getListById(String id);
  Future<ShoppingListModel> saveList(ShoppingListModel list);
  Future<void> deleteList(String id);
  Future<void> clearAll();
}


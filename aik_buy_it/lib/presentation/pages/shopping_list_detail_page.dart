import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../cubits/shopping_list_detail_cubit.dart';
import '../widgets/shopping_list_item_widget.dart';
import '../widgets/list_header_widget.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/shopping_repository.dart';

class ShoppingListDetailPage extends StatelessWidget {
  final String listId;
  final ShoppingRepository repository;
  
  const ShoppingListDetailPage({
    super.key,
    required this.listId,
    required this.repository,
  });
  
  @override
  Widget build(BuildContext context) {
    final cubit = ShoppingListDetailCubit(repository);
    
    return BlocProvider(
      create: (_) => cubit..watchList(listId),
      child: Scaffold(
        body: BlocBuilder<ShoppingListDetailCubit, ShoppingListDetailState>(
          builder: (context, state) {
            if (state is ShoppingListDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ShoppingListDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ошибка: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ShoppingListDetailCubit>().loadList(listId);
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is ShoppingListDetailLoaded) {
              final list = state.list;
              final sortedItems = _sortItems(list.items);
              
              return Column(
                children: [
                  ListHeaderWidget(list: list),
                  Expanded(
                    child: sortedItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Список пуст',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Добавьте товары в список',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: sortedItems.length,
                            itemBuilder: (context, index) {
                              final item = sortedItems[index];
                              return ShoppingListItemWidget(
                                key: ValueKey(item.id),
                                item: item,
                                onTap: () {
                                  context
                                      .read<ShoppingListDetailCubit>()
                                      .toggleItem(listId, item.id);
                                },
                                onDelete: () {
                                  context
                                      .read<ShoppingListDetailCubit>()
                                      .deleteItem(listId, item.id);
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
          builder: (builderContext) => FloatingActionButton(
            onPressed: () => _showAddItemDialog(builderContext, listId),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
  
  List<ShoppingItem> _sortItems(List<ShoppingItem> items) {
    final completed = items.where((item) => item.isCompleted).toList();
    final notCompleted = items.where((item) => !item.isCompleted).toList();
    
    completed.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notCompleted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return [...notCompleted, ...completed];
  }
  
  void _showAddItemDialog(BuildContext context, String listId) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final categoryController = TextEditingController();
    
    // Получаем cubit из контекста, который имеет доступ к BlocProvider
    final cubit = context.read<ShoppingListDetailCubit>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: const Text('Добавить товар'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название товара',
                    hintText: 'Например: Молоко',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Количество',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Категория (необязательно)',
                    hintText: 'Например: Молочные продукты',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final quantity = int.tryParse(quantityController.text) ?? 1;
                  final category = categoryController.text.trim().isEmpty
                      ? null
                      : categoryController.text.trim();
                  
                  final item = ShoppingItem(
                    id: const Uuid().v4(),
                    name: name,
                    quantity: quantity,
                    category: category,
                    isCompleted: false,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  
                  repository
                      .addItem(listId, item)
                      .then((_) {
                    cubit.loadList(listId);
                  });
                  
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}


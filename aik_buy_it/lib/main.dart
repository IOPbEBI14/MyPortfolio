import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/cubits/shopping_list_cubit.dart';
import 'presentation/pages/home_page.dart';
import 'domain/usecases/get_all_lists.dart';
import 'domain/usecases/create_shopping_list.dart';
import 'domain/usecases/add_item_to_list.dart';
import 'domain/usecases/toggle_item_completion.dart';
import 'domain/usecases/delete_item.dart';
import 'domain/usecases/delete_list.dart';
import 'domain/usecases/send_invite.dart';
import 'data/repositories/shopping_repository_impl.dart';
import 'data/datasources/local/hive_local_data_source.dart';
import 'data/datasources/remote/mock_remote_data_source.dart';
import 'core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Hive
  await Hive.initFlutter();
  
  // Инициализация локального хранилища
  final localDataSource = HiveLocalDataSource();
  await localDataSource.init();
  
  // Инициализация удаленного хранилища (Mock для разработки)
  final remoteDataSource = MockRemoteDataSource();
  
  // Инициализация NetworkInfo
  final connectivity = Connectivity();
  final networkInfo = NetworkInfoImpl(connectivity);
  
  // Создание репозитория с синхронизацией
  final repository = ShoppingRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
  
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ShoppingRepositoryImpl repository;
  
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Купил-бы',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => ShoppingListCubit(
          getAllLists: GetAllLists(repository),
          createShoppingList: CreateShoppingList(repository),
          addItemToList: AddItemToList(repository),
          toggleItemCompletion: ToggleItemCompletion(repository),
          deleteItem: DeleteItem(repository),
          deleteList: DeleteList(repository),
          sendInvite: SendInvite(repository),
          repository: repository,
        )..watchLists(),
        child: const HomePage(),
      ),
    );
  }
}

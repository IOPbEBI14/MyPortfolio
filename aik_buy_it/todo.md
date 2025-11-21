"Купил-бы" (Buy-It) — Клон популярного приложения для списков покупок
Идея: Приложение для совместных покупок, где можно делиться списками с семьей/друзьями.

Концепция:

Создание нескольких списков ("Продукты", "Хозтовары").

Реалистичный UI/UX: Отмечаешь купленное — оно зачеркивается и уезжает вниз списка.

Совместный доступ: Отправка инвайта по email/ссылке для редактирования списка одним из членов семьи.

История покупок: Чтобы быстро добавлять часто покупаемые товары.

Что прокачаешь:

Работа с реальным API (или эмуляция через Firebase Functions/MockAPI).

Сложная структура данных (вложенные коллекции).

Оффлайн-работа и синхронизация при появлении сети.

Практика StreamBuilder для живых обновлений списка.


## 🗺️ План разработки "Купил-бы"

### Этап 1: Фундамент (Неделя 1)
**Цель**: Работающий оффлайн-список
```dart
// Архитектура: Clean Architecture + BLoC/Cubit
lib/
├── data/
│   ├── models/ (ShoppingItem, ShoppingList)
│   ├── repositories/ (локальная база - Hive/SharedPreferences)
│   └── datasources/ (локальное хранилище)
├── domain/
│   ├── entities/ 
│   ├── repositories/ 
│   └── usecases/ (добавить, удалить, отметить купленным)
└── presentation/
    ├── widgets/ (ShoppingListItem, ListHeader)
    ├── cubits/ (shopping_list_cubit.dart)
    └── pages/ (home_page.dart)
```

**Задачи**:
- [ ] Модели данных (List > List<Items>)
- [ ] Локальное хранилище
- [ ] BLoC для управления состоянием
- [ ] UI: создание списков, добавление/удаление позиций
- [ ] Анимация зачеркивания и перемещения вниз

### Этап 2: Совместный доступ (Неделя 2-3)
**Цель**: Реальные API и совместная работа
```dart
// Добавляем в data/
├── data/
│   ├── repositories_impl/ (ShoppingRepositoryImpl)
│   └── datasources/
│       ├── local/ (HiveLocalDataSource)
│       └── remote/ (FirebaseRemoteDataSource) // или MockAPI
```

**Задачи**:
- [ ] Настройка Firebase/MockAPI
- [ ] Репозиторий с оффлайн-синхронизацией
- [ ] Приглашения по email/ссылке
- [ ] StreamBuilder для live-обновлений
- [ ] Разрешения (только чтение / редактирование)

### Этап 3: Продвинутые фичи (Неделя 4)
**Цель**: История и умные функции
```dart
// Новые usecases в domain/
├── domain/
│   └── usecases/
│       ├── get_shopping_history.dart
│       ├── add_from_history.dart
│       └── sync_pending_changes.dart
```

**Задачи**:
- [ ] История покупок (отдельная таблица)
- [ ] Быстрое добавление из истории
- [ ] Конфликт-менеджмент при синхронизации
- [ ] Уведомления об изменениях

### Этап 4: Полировка (Неделя 5)
**Задачи**:
- [ ] Тесты (unit, widget, integration)
- [ ] Обработка ошибок (нет сети, невалидные инвайты)
- [ ] Performance optimization
- [ ] Публикация в Store

## 🛠️ Технический стек:
- **State Management**: BLoC/Cubit
- **Локальная БД**: Hive (быстрая) или SQLite
- **Бэкенд**: Firebase (Firestore, Auth, Functions) или собственный API
- **Оффлайн**: connectivity_plus + queue для отложенных запросов

## 💡 Что конкретно прокачаешь:

1. **StreamBuilder** - живые обновления при совместной работе
2. **Complex data relations** - пользователи → списки → товары
3. **Offline-first** - стратегии синхронизации
4. **API integration** - REST/GraphQL с Firebase
5. **Conflict resolution** - что делать при одновременном редактировании

Отлично! Начнем с самого фундамента - моделей данных. Это критически важно для всего приложения.

## 🗃️ Проектируем модели данных для "Купил-бы"

### 1. Базовая модель (абстрактный класс)
```dart
abstract class BaseModel {
  String id;
  DateTime createdAt;
  DateTime updatedAt;
  
  BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson();
}
```

### 2. Модель пользователя (User)
```dart
class User extends BaseModel {
  final String email;
  final String displayName;
  final String? photoUrl;
  
  User({
    required String id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

### 3. Модель элемента списка (ShoppingItem)
```dart
class ShoppingItem extends BaseModel {
  final String name;
  final int quantity;
  final String? category;
  final bool isCompleted;
  final String? notes;
  final String? addedByUserId; // Кто добавил товар
  
  ShoppingItem({
    required String id,
    required this.name,
    this.quantity = 1,
    this.category,
    this.isCompleted = false,
    this.notes,
    this.addedByUserId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);
  
  // Копирующий конструктор с изменениями
  ShoppingItem copyWith({
    String? name,
    int? quantity,
    String? category,
    bool? isCompleted,
    String? notes,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      addedByUserId: addedByUserId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'] ?? 1,
      category: json['category'],
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
      addedByUserId: json['addedByUserId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'isCompleted': isCompleted,
      'notes': notes,
      'addedByUserId': addedByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

### 4. Модель списка покупок (ShoppingList)
```dart
class ShoppingList extends BaseModel {
  final String name;
  final String? description;
  final String ownerId; // Владелец списка
  final List<String> memberIds; // ID участников
  final List<ShoppingItem> items;
  final List<ShoppingListInvite> pendingInvites;
  
  ShoppingList({
    required String id,
    required this.name,
    this.description,
    required this.ownerId,
    List<String>? memberIds,
    List<ShoppingItem>? items,
    List<ShoppingListInvite>? pendingInvites,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : memberIds = memberIds ?? [],
        items = items ?? [],
        pendingInvites = pendingInvites ?? [],
        super(id: id, createdAt: createdAt, updatedAt: updatedAt);
  
  // Геттер для общего количества товаров
  int get totalItems => items.length;
  
  // Геттер для количества купленных товаров
  int get completedItems => items.where((item) => item.isCompleted).length;
  
  // Геттер для проверки, пустой ли список
  bool get isEmpty => items.isEmpty;
  
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['ownerId'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ShoppingItem.fromJson(item))
          .toList() ?? [],
      pendingInvites: (json['pendingInvites'] as List<dynamic>?)
          ?.map((invite) => ShoppingListInvite.fromJson(invite))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'items': items.map((item) => item.toJson()).toList(),
      'pendingInvites': pendingInvites.map((invite) => invite.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

### 5. Модель приглашения (ShoppingListInvite)
```dart
class ShoppingListInvite extends BaseModel {
  final String listId;
  final String invitedEmail;
  final String invitedByUserId;
  final InviteStatus status;
  final String? token; // Для верификации по ссылке
  
  ShoppingListInvite({
    required String id,
    required this.listId,
    required this.invitedEmail,
    required this.invitedByUserId,
    this.status = InviteStatus.pending,
    this.token,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);
  
  factory ShoppingListInvite.fromJson(Map<String, dynamic> json) {
    return ShoppingListInvite(
      id: json['id'],
      listId: json['listId'],
      invitedEmail: json['invitedEmail'],
      invitedByUserId: json['invitedByUserId'],
      status: InviteStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InviteStatus.pending,
      ),
      token: json['token'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'invitedEmail': invitedEmail,
      'invitedByUserId': invitedByUserId,
      'status': status.name,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum InviteStatus {
  pending,
  accepted,
  rejected,
  expired,
}
```

### 6. Модель для истории покупок (PurchaseHistory)
```dart
class PurchaseHistory extends BaseModel {
  final String itemName;
  final String? category;
  final int quantity;
  final DateTime purchasedAt;
  final String listId;
  final String purchasedByUserId;
  
  PurchaseHistory({
    required String id,
    required this.itemName,
    this.category,
    required this.quantity,
    required this.purchasedAt,
    required this.listId,
    required this.purchasedByUserId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);
  
  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      id: json['id'],
      itemName: json['itemName'],
      category: json['category'],
      quantity: json['quantity'],
      purchasedAt: DateTime.parse(json['purchasedAt']),
      listId: json['listId'],
      purchasedByUserId: json['purchasedByUserId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'category': category,
      'quantity': quantity,
      'purchasedAt': purchasedAt.toIso8601String(),
      'listId': listId,
      'purchasedByUserId': purchasedByUserId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

## 🎯 Ключевые моменты архитектуры:

1. **Наследование от BaseModel** - единообразие всех моделей
2. **copyWith() методы** - для иммутабельных обновлений (важно для BLoC)
3. **Вложенные коллекции** - списки содержат элементы, есть связи между моделями
4. **Статусы приглашений** - гибкая система управления доступом
5. **Поддержка оффлайн-работы** - все модели сериализуемы

Что думаешь о такой структуре? Есть ли что-то, что хочешь изменить или добавить? 


import 'dart:convert';
import 'dart:io';
import 'models.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  Database._internal();

  final String _dataPath = 'data';
  final Map<String, User> _users = {};
  final Map<String, Order> _orders = {};

  Future<void> initialize() async {
    final dir = Directory(_dataPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await _loadData<User>(_users, 'users.json', User.fromJson);
    await _loadData<Order>(_orders, 'orders.json', Order.fromJson);
  }

  // CORRECTED: A robust, generic function to load data safely.
  Future<void> _loadData<T>(
    Map<String, dynamic> map,
    String fileName,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final file = File('$_dataPath/$fileName');
      if (!await file.exists()) return;

      final content = await file.readAsString();
      if (content.trim().isEmpty) return;

      final dynamic data = jsonDecode(content);
      if (data is List) {
        for (var jsonObj in data) {
          final item = fromJson(jsonObj);
          if (item is User) map[item.id] = item;
          if (item is Order) map[item.id] = item;
        }
      }
    } catch (e) {
      print('Error loading $fileName: $e');
    }
  }

  Future<void> _saveUsers() async {
    final file = File('$_dataPath/users.json');
    final data = _users.values.map((u) => u.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> _saveOrders() async {
    final file = File('$_dataPath/orders.json');
    final data = _orders.values.map((o) => o.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> clearAllOrders() async {
    _orders.clear();
    await _saveOrders();
  }

  Future<User> createUser(User user) async {
    _users[user.id] = user;
    await _saveUsers();
    return user;
  }

  User? getUserByUsername(String username) {
    try {
      return _users.values.firstWhere((user) => user.username == username) as User?;
    } catch (e) {
      return null;
    }
  }

  Future<Order> createOrder(Order order) async {
    _orders[order.id] = order;
    await _saveOrders();
    return order;
  }

  Future<Order> updateOrder(Order order) async {
    _orders[order.id] = order;
    await _saveOrders();
    return order;
  }

  Order? getOrderByRfidUid(String rfidUid) {
    try {
      return _orders.values.firstWhere((order) => order.rfidUid == rfidUid) as Order?;
    } catch (e) {
      return null;
    }
  }

  List<Order> getAllOrders() {
    return List<Order>.from(_orders.values)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

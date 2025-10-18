import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import '../lib/database.dart';
import '../lib/models.dart';
import '../lib/auth.dart';

final _clients = <WebSocketChannel>[];
final _db = Database();
final _uuid = Uuid();

void main() async {
  await _db.initialize();
  print('Database initialized');

  final router = Router();

  router.post('/login', _loginHandler);
  router.post('/signup', _signupHandler);
  router.get('/orders', _getOrdersHandler);
  router.post('/orders', _createOrderHandler);
  router.post('/updateStatus', _updateStatusHandler);

  // Updated callback with second parameter 'protocol'
  final wsHandler = webSocketHandler((WebSocketChannel webSocket, String? protocol) {
    _clients.add(webSocket);
    print('WebSocket client connected. Total clients: ${_clients.length}');

    webSocket.stream.listen(
      (message) {
        print('Received message: $message');
      },
      onDone: () {
        _clients.remove(webSocket);
        print('WebSocket client disconnected. Total clients: ${_clients.length}');
      },
      onError: (error) {
        print('WebSocket error: $error');
        _clients.remove(webSocket);
      },
    );
  });

  router.get('/ws', wsHandler);

  final handler = Pipeline()
      .addMiddleware(_corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(router);

  final server = await shelf_io.serve(
    handler,
    '0.0.0.0',
    8080,
  );

  print('Server running on http://${server.address.host}:${server.port}');
  print('WebSocket endpoint: ws://${server.address.host}:${server.port}/ws');
}

Middleware _corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }

      final response = await handler(request);
      return response.change(headers: _corsHeaders);
    };
  };
}

final _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

Future<Response> _loginHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final username = data['username'];
    final password = data['password'];

    final user = _db.getUserByUsername(username);

    if (user == null || !AuthService.verifyPassword(password, user.passwordHash)) {
      return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
    }

    final token = AuthService.generateToken(user.id, user.username, user.department);

    return Response.ok(
      jsonEncode({
        'user': user.toJson(),
        'token': token,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Login error: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Login failed'}),
    );
  }
}

Future<Response> _signupHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    final user = User(
      id: _uuid.v4(),
      username: data['username'],
      email: data['email'],
      passwordHash: AuthService.hashPassword(data['password']),
      department: data['department'],
      createdAt: DateTime.now(),
    );

    await _db.createUser(user);

    final token = AuthService.generateToken(user.id, user.username, user.department);

    return Response(
      201,
      body: jsonEncode({
        'user': user.toJson(),
        'token': token,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Signup error: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Signup failed'}),
    );
  }
}

Future<Response> _getOrdersHandler(Request request) async {
  try {
    final authHeader = request.headers['authorization'];
    if (authHeader == null) {
      return Response(401, body: jsonEncode({'error': 'Unauthorized'}));
    }

    final token = authHeader.replaceFirst('Bearer ', '');
    final payload = AuthService.verifyToken(token);

    if (payload == null) {
      return Response(401, body: jsonEncode({'error': 'Invalid token'}));
    }

    final orders = _db.getAllOrders();

    return Response.ok(
      jsonEncode(orders.map((o) => o.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Get orders error: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to fetch orders'}),
    );
  }
}

Future<Response> _createOrderHandler(Request request) async {
  try {
    final authHeader = request.headers['authorization'];
    if (authHeader == null) {
      return Response(401, body: jsonEncode({'error': 'Unauthorized'}));
    }

    final token = authHeader.replaceFirst('Bearer ', '');
    final payload = AuthService.verifyToken(token);

    if (payload == null) {
      return Response(401, body: jsonEncode({'error': 'Invalid token'}));
    }

    final body = await request.readAsString();
    final data = jsonDecode(body);

    final order = Order(
      id: _uuid.v4(),
      toyId: data['toy_id'],
      toyName: data['toy_name'],
      category: data['category'],
      rfidUid: data['rfid_uid'],
      assignedPerson: data['assigned_person'],
      status: 'PENDING',
      createdAt: DateTime.now(),
      department: data['department'],
      totalAmount: data['total_amount'].toDouble(),
    );

    await _db.createOrder(order);

    _broadcastToClients(order.toJson());

    return Response(
      201,
      body: jsonEncode(order.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Create order error: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to create order'}),
    );
  }
}

Future<Response> _updateStatusHandler(Request request) async {
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    final rfidUid = data['rfid_uid'];
    final category = data['category'];
    final status = data['status'];

    print('Update request - RFID: $rfidUid, Category: $category, Status: $status');

    final order = _db.getOrderByRfidUid(rfidUid);

    if (order == null) {
      return Response(404, body: jsonEncode({'error': 'Order not found'}));
    }

    if (order.category != category) {
      return Response(400, body: jsonEncode({'error': 'Category mismatch'}));
    }

    final updatedOrder = order.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    await _db.updateOrder(updatedOrder);

    _broadcastToClients(updatedOrder.toJson());

    return Response.ok(
      jsonEncode({
        'success': true,
        'order': updatedOrder.toJson(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('Update status error: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to update status'}),
    );
  }
}

void _broadcastToClients(Map<String, dynamic> data) {
  final message = jsonEncode(data);
  for (var client in List.from(_clients)) {
    try {
      client.sink.add(message);
    } catch (e) {
      print('Error broadcasting to client: $e');
      _clients.remove(client);
    }
  }
  print('Broadcasted to ${_clients.length} clients');
}

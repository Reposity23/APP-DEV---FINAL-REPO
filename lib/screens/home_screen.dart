import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'login_screen.dart';

// A model to represent a toy product
class Toy {
  final String id;
  final String name;
  final String category;
  final String rfidUid;
  final double price;
  final String imageUrl;

  Toy({
    required this.id,
    required this.name,
    required this.category,
    required this.rfidUid,
    required this.price,
    required this.imageUrl,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // A static list of available toys. In a real app, this would come from a database.
  static final List<Toy> _toys = [
    Toy(id: '1', name: 'Nerf Blaster', category: 'Toy Guns', rfidUid: 'A12B3C', price: 24.99, imageUrl: 'https://via.placeholder.com/150?text=Nerf+Blaster'),
    Toy(id: '2', name: 'Action Man', category: 'Action Figures', rfidUid: 'D44F8Z', price: 14.99, imageUrl: 'https://via.placeholder.com/150?text=Action+Man'),
    Toy(id: '3', name: 'Barbie Doll', category: 'Dolls', rfidUid: 'E77K9L', price: 19.99, imageUrl: 'https://via.placeholder.com/150?text=Barbie+Doll'),
    Toy(id: '4', name: '1000-Piece Puzzle', category: 'Puzzles', rfidUid: 'F23M1N', price: 12.99, imageUrl: 'https://via.placeholder.com/150?text=Puzzle'),
    Toy(id: '5', name: 'Monopoly', category: 'Board Games', rfidUid: 'G56P2Q', price: 29.99, imageUrl: 'https://via.placeholder.com/150?text=Monopoly'),
  ];

  Future<void> _handleLogout(BuildContext context) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showOrderConfirmation(BuildContext context, Toy toy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text('Do you want to buy the ${toy.name} for \$${toy.price}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Confirm'),
            onPressed: () {
              final provider = Provider.of<AppProvider>(context, listen: false);
              provider.createOrder(
                toyId: toy.id,
                toyName: toy.name,
                category: toy.category,
                rfidUid: toy.rfidUid,
                assignedPerson: provider.currentUser!.username,
                totalAmount: toy.price,
              );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Toy Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _toys.length,
        itemBuilder: (ctx, i) => _buildToyCard(context, _toys[i]),
      ),
    );
  }

  Widget _buildToyCard(BuildContext context, Toy toy) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              toy.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.toys, size: 80, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              toy.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '\$${toy.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showOrderConfirmation(context, toy),
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    );
  }
}

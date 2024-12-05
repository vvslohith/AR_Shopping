import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> cartItems = [];

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  final List<Map<String, dynamic>> items = [
    {
      'name': 'Sofa',
      'price': 199.99,
      'image': 'assets/sofa.png',
      'quantity': 1,
      'description': 'A comfortable leather sofa',
      'model': 'assets/sofaone.glb',
    },
    {
      'name': 'Soft Chair',
      'price': 99.99,
      'image': 'assets/sheenchair.png',
      'quantity': 1,
      'description': 'A modern wooden dining table',
      'model': 'assets/SheenChair.glb',
    },
    {
      'name': 'Air Conditioner',
      'price': 99.99,
      'image': 'assets/ac.png',
      'quantity': 1,
      'description': 'A modern camera',
      'model': 'assets/ac.glb',
    },
  ];

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      final existingItem = cartItems.indexWhere((cartItem) => cartItem['name'] == item['name']);
      if (existingItem != -1) {
        cartItems[existingItem]['quantity']++;
      } else {
        cartItems.add(Map.from(item));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item['name']} added to cart!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Furniture Store'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(cartItems: cartItems),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(items[index]['image']),
            title: Text(items[index]['name']),
            subtitle: Text('\$${items[index]['price']}'),
            trailing: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () => addToCart(items[index]),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(
                    item: items[index],
                    addToCart: () => addToCart(items[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: signOut,
        child: Icon(Icons.logout),
      ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function addToCart;

  ProductDetailsPage({required this.item, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['name']),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(item['image'], height: 250),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(item['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('\$${item['price']}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(item['description'], style: TextStyle(fontSize: 16)),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => addToCart(),
                  child: Text('Add to Cart'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ARViewPage(modelPath: item['model']),
                      ),
                    );
                  },
                  child: Text('View in AR'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ARViewPage extends StatelessWidget {
  final String modelPath;

  ARViewPage({required this.modelPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View in AR'),
      ),
      body: ModelViewer(
       // src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
        src: modelPath,
        alt: "A 3D model of ${modelPath.split('/').last}",
        ar: true,
        arModes: ["scene-viewer", "quick-look"],
        autoRotate: true,
        cameraControls: true,
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get totalPrice => widget.cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  void _removeItem(int index) {
    setState(() {
      if (widget.cartItems[index]['quantity'] > 1) {
        widget.cartItems[index]['quantity']--;
      } else {
        widget.cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: widget.cartItems.isEmpty
          ? Center(child: Text('No items in the cart'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return ListTile(
                  leading: Image.asset(item['image']),
                  title: Text(item['name']),
                  subtitle: Text('\$${item['price']} x${item['quantity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _removeItem(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            item['quantity']++;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderSummaryPage(totalPrice: totalPrice),
                  ),
                );
              },
              child: Text('Confirm Order (\$${totalPrice.toStringAsFixed(2)})'),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSummaryPage extends StatelessWidget {
  final double totalPrice;

  OrderSummaryPage({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
      ),
      body: Center(
        child: Text(
          'Thank you for your purchase!\nTotal Amount: \$${totalPrice.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

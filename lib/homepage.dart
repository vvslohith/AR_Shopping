// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class Homepage extends StatefulWidget {
//   const Homepage({super.key});
//
//   @override
//   State<Homepage> createState() => _HomepageState();
// }
//
// class _HomepageState extends State<Homepage> {
//
//   final user=FirebaseAuth.instance.currentUser;
//
//   signout()async{
//     await FirebaseAuth.instance.signOut();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Homepage"),),
//       body: Center(
//         child: Text('${user!.email}'),
//       ),
//       floatingActionButton: FloatingActionButton(
//           onPressed: (()=>signout()),
//           child: Icon(Icons.login_rounded),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> cartItems = [];

  final List<Map<String, dynamic>> items = [
    {
      'name': 'Sofa',
      'price': 199.99,
      'image': 'assets/sofa.jpg',
      'quantity': 1,
      'description': 'A comfortable leather sofa',
    },
    {
      'name': 'Table',
      'price': 99.99,
      'image': 'assets/table.jpg',
      'quantity': 1,
      'description': 'A modern wooden dining table',
    },
  ];

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
              onPressed: () {
                setState(() {
                  cartItems.add(items[index]);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to Cart')),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(
                    item: items[index],
                    addToCart: () {
                      setState(() {
                        cartItems.add(items[index]);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to Cart')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
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
            child: Image.asset(
              item['image'],
              height: 250.0,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              item['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('\$${item['price']}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              item['description'],
              style: TextStyle(fontSize: 16),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    addToCart();
                  },
                  child: Text('Add to Cart'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Open AR view logic here
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

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  CartPage({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('No items in the cart'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(cartItems[index]['image']),
            title: Text(cartItems[index]['name']),
            subtitle: Text('\$${cartItems[index]['price']}'),
            trailing: IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                // Handle removal from cart
              },
            ),
          );
        },
      ),
    );
  }
}

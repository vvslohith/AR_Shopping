import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buysellpage.dart';
import 'roomdimension.dart';
import 'package:flutter_braintree/flutter_braintree.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> cartItems = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void fetchUserName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      setState(() {
        userName = '${userDoc.data()?['name'] ?? 'Guest'}!!'; // Append "!!" to the username
      });
    } else {
      setState(() {
        userName = 'Guest!!'; // Fallback if no user document exists
      });
    }
  }
}

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
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
      'description': 'Stay cool in style with our high-performance Air Conditioner – designed for comfort, efficiency, and modern living.',
      'model': 'assets/ac.glb',
    },
    {
      'name': 'Bed',
      'price': 99.99,
      'image': 'assets/Bed.png',
      'quantity': 1,
      'description': 'Sink into luxurious rest with our elegantly crafted Bed – the perfect blend of comfort and style for your dream sleep.',
      'model': 'assets/Bed.glb',
    },
    {
      'name': 'Bean Bag',
      'price': 99.99,
      'image': 'assets/BeanBag.png',
      'quantity': 1,
      'description': 'Unwind effortlessly in our ultra-comfy Bean Bag – the perfect seat for casual lounging and laid-back vibes.',
      'model': 'assets/BeanBag.glb',
    },
    {
      'name': 'Stool',
      'price': 99.99,
      'image': 'assets/Stool.png',
      'quantity': 1,
      'description': 'Compact, stylish, and versatile – our Stool offers the perfect perch for any room or occasion.',
      'model': 'assets/Stool.glb',
    },
    {
      'name': 'Mirror',
      'price': 99.99,
      'image': 'assets/Mirror.png',
      'quantity': 1,
      'description': 'Reflect style and elegance with our chic Mirror – the perfect piece to brighten and expand any space.',
      'model': 'assets/Mirror.glb',
    },
    {
      'name': 'Bed Lamp',
      'price': 99.99,
      'image': 'assets/Lamp.png',
      'quantity': 1,
      'description': 'Enhance your nighttime routine with our Bed Lamp – a perfect blend of soft light and sleek design for cozy evenings.',
      'model': 'assets/Lamp.glb',
    },

    {
      'name': 'Arm Chair',
      'price': 99.99,
      'image': 'assets/ArmChair.png',
      'quantity': 1,
      'description': 'Relax in style with our plush Arm Chair – the perfect accent piece for comfort and charm in any room.',
      'model': 'assets/ArmChair.glb',
    },
    {
      'name': 'Bubble Sofa',
      'price': 99.99,
      'image': 'assets/BubbleSofa.png',
      'quantity': 1,
      'description': 'Experience cloud-like comfort with the stylish and ultra-cozy Bubble Sofa – where design meets relaxation.',
      'model': 'assets/BubbleSofa.glb',
    },
    {
      'name': 'Bench',
      'price': 99.99,
      'image': 'assets/Bench.png',
      'quantity': 1,
      'description': 'Add timeless charm and versatile seating with our sleek and sturdy Bench – perfect for any space indoors or out.',
      'model': 'assets/Bench.glb',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FurnishAR"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Hey ${userName ?? 'Guest'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Buy and Sell'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuySellPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.room_preferences),
              title: const Text('Room Planner'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoomDimensionPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                signOut();
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Image.asset(items[index]['image']),
              title: Text(
                items[index]['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('\$${items[index]['price']}'),
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(cartItems: cartItems),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.shopping_cart),
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
                      // Calculate the total amount
                      final totalAmount = widget.cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderSummaryPage(totalPrice: totalAmount, cartItems: widget.cartItems),
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

class OrderSummaryPage extends StatefulWidget {
  final double totalPrice;
  final List<Map<String, dynamic>> cartItems;

  OrderSummaryPage({required this.totalPrice, required this.cartItems});

  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  void _startBraintreePayment() async {
    final request = BraintreeDropInRequest(
      tokenizationKey: 'sandbox_47tt8mwn_nwxkkrdgh8mxmxnw', // Replace with your Braintree tokenization key
      collectDeviceData: true,
      paypalRequest: BraintreePayPalRequest(
        amount: widget.totalPrice.toStringAsFixed(2),
        currencyCode: 'USD',
      ),
      cardEnabled: true,
    );

    try {
      final result = await BraintreeDropIn.start(request);

      if (result != null) {
        _handlePaymentSuccess(result);
      } else {
        _handlePaymentError("Payment canceled by user.");
      }
    } catch (e) {
      _handlePaymentError("Error occurred during payment: $e");
    }
  }

  void _handlePaymentSuccess(BraintreeDropInResult result) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final formattedItems = widget.cartItems.map((item) {
          return '${item['name']} (\$${item['price']} x ${item['quantity']})';
        }).join('\n');

        final totalAmount = widget.cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));

        await FirebaseFirestore.instance.collection('orders').add({
          'username': user.email,
          'items': formattedItems,
          'totalAmount': totalAmount,
          'status': 'Pending',
          'timestamp': FieldValue.serverTimestamp(),
          'payment': 'success',
          'paymentMethod': result.paymentMethodNonce.description,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Successful! Order stored in Firebase.")),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in. Cannot store order.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error storing order: $e")),
      );
    }
  }

  void _handlePaymentError(String errorMessage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final formattedItems = widget.cartItems.map((item) {
          return '${item['name']} (\$${item['price']} x ${item['quantity']})';
        }).join('\n');

        final totalAmount = widget.cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));

        await FirebaseFirestore.instance.collection('orders').add({
          'username': user.email,
          'items': formattedItems,
          'totalAmount': totalAmount,
          'status': 'Failed',
          'timestamp': FieldValue.serverTimestamp(),
          'payment': 'failed',
          'errorMessage': errorMessage,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Failed! Order stored in Firebase with status 'failed'.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in. Cannot store failed order.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error storing failed order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Amount: \$${widget.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startBraintreePayment,
              child: Text('Proceed to Pay with PayPal'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(
          child: Text('You need to log in to view your orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('username', isEqualTo: user.email) // Filter by logged-in user's email
            .orderBy('timestamp', descending: true) // Order by most recent
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading orders: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order['items'];
              final paymentStatus = order['payment'];
              final totalAmount = order['totalAmount']; // Retrieve totalAmount
              final timestamp = (order['timestamp'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Items:\n$items',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Payment: ${paymentStatus == 'success' ? 'Successful' : 'Failed'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: paymentStatus == 'success' ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${timestamp.toLocal()}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
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

class ProfilePage extends StatelessWidget {
  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching user data: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }

          final userData = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  'Email: ${FirebaseAuth.instance.currentUser?.email ?? 'Guest'}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Name: ${userData['name'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                Text('Age: ${userData['age'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                Text('Phone: ${userData['phone'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                Text('Address: ${userData['address'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}

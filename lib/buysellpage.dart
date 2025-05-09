import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class BuySellPage extends StatefulWidget {
  @override
  _BuySellPageState createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buy & Sell',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Buy'),
            Tab(text: 'Sell'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BuySection(),
          SellSection(),
        ],
      ),
    );
  }
}

class BuySection extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('sellItems')
          .where('username', isNotEqualTo: _auth.currentUser?.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No items available for purchase.'));
        }

        final items = snapshot.data!.docs;

        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailsPage(item: item),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      item['images'][0],
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '\$${item['price']}',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ItemDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot item;

  ItemDetailsPage({required this.item});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> images = item['images']; // Get the list of images
    final String mobileNumber = item['mobile']; // Get the mobile number

    return Scaffold(
      appBar: AppBar(
        title: Text(item['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display all images in a horizontal scrollable list
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Show the full image in a dialog
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(
                                    images[index],
                                    fit: BoxFit.contain,
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Image.network(
                          images[index],
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Text('Name: ${item['name']}', style: TextStyle(fontSize: 18)),
              Text('Price: \$${item['price']}', style: TextStyle(fontSize: 18)),
              Text('Years Used: ${item['yearsUsed']}', style: TextStyle(fontSize: 18)),
              Text('Mobile: ${item['mobile']}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final Uri callUri = Uri(scheme: 'tel', path: mobileNumber);
                  if (await canLaunchUrl(callUri)) {
                    await launchUrl(callUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch call')),
                    );
                  }
                },
                icon: Icon(Icons.call),
                label: Text('Call Seller'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SellSection extends StatefulWidget {
  @override
  _SellSectionState createState() => _SellSectionState();
}

class _SellSectionState extends State<SellSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<QueryDocumentSnapshot> _cachedItems = []; // Cache for fetched items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('sellItems')
            .where('username', isEqualTo: _auth.currentUser?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _cachedItems.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            _cachedItems = snapshot.data!.docs; // Update cache with new data
            print('Fetched items: ${_cachedItems.length}'); // Debug log
          }

          if (_cachedItems.isEmpty) {
            return Center(child: Text('No items added yet.'));
          }

          return ListView.builder(
            itemCount: _cachedItems.length,
            itemBuilder: (context, index) {
              final item = _cachedItems[index];
              print('Item data: ${item.data()}'); // Debug log
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.network(
                      item['images'][0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Icon(Icons.broken_image);
                      },
                    ),
                  ),
                  title: Text(item['name']),
                  subtitle: Text('Price: \$${item['price']}\nUsed: ${item['yearsUsed']} years'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await _markItemAsSold(item);
                    },
                    child: Text('Sold'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _markItemAsSold(QueryDocumentSnapshot item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to mark this item as sold?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _firestore.collection('sellItems').doc(item.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item marked as sold and removed.')),
        );
      } catch (e) {
        print('Error deleting item: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
    }
  }

  void _showAddItemDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController yearsUsedController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();
    List<File> capturedImages = []; // List to store captured images

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Item'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter a price' : null,
                  ),
                  TextFormField(
                    controller: yearsUsedController,
                    decoration: InputDecoration(labelText: 'Years Used'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter years used' : null,
                  ),
                  TextFormField(
                    controller: mobileController,
                    decoration: InputDecoration(labelText: 'Mobile Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a mobile number';
                      } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (capturedImages.length >= 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('You can only add up to 4 images.')),
                        );
                        return;
                      }
                      final File? image = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CameraCaptureScreen()),
                      );
                      if (image != null && image.existsSync()) {
                        setState(() {
                          capturedImages.add(image);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to capture image.')),
                        );
                      }
                    },
                    child: Text('Take Pictures (${capturedImages.length}/4)'),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: capturedImages.map((image) {
                      return Stack(
                        children: [
                          Image.file(image, width: 80, height: 80, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  capturedImages.remove(image);
                                });
                              },
                              child: Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && capturedImages.isNotEmpty) {
                  try {
                    // Upload images to Supabase and get URLs
                    List<String> imageUrls = [];
                    for (var image in capturedImages) {
                      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
                      try {
                        // Upload the image to Supabase
                        final String uploadedPath = await Supabase.instance.client.storage
                            .from('sellitems')
                            .upload('images/$fileName.jpg', image);

                        // Extract the relative path (remove the bucket name if included)
                        final String relativePath = uploadedPath.replaceFirst('sellitems/', '');

                        // Generate the public URL using the relative path
                        final String publicUrl = Supabase.instance.client.storage
                            .from('sellitems')
                            .getPublicUrl(relativePath);

                        imageUrls.add(publicUrl);
                      } catch (e) {
                        throw Exception('Failed to upload image: $e');
                      }
                    }

                    // Save item details to Firestore
                    await FirebaseFirestore.instance.collection('sellItems').add({
                      'name': nameController.text,
                      'price': priceController.text,
                      'yearsUsed': yearsUsedController.text,
                      'mobile': mobileController.text,
                      'images': imageUrls,
                      'username': FirebaseAuth.instance.currentUser?.email,
                    }).then((value) => print('Item added with ID: ${value.id}'));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Item added successfully!')),
                    );
                    Navigator.pop(context); // Close the dialog
                  } catch (e) {
                    print('Error adding item: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding item: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields and add at least one image.')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// 🔥 NEW SCREEN FOR CAMERA
class CameraCaptureScreen extends StatefulWidget {
  @override
  _CameraCaptureScreenState createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() {
      _isReady = true;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (!_cameraController.value.isInitialized) return;
    try {
      final XFile imageFile = await _cameraController.takePicture();
      if (imageFile.path.isNotEmpty) {
        Navigator.pop(context, File(imageFile.path)); // Return the captured image
      } else {
        throw Exception('Image capture failed.');
      }
    } catch (e) {
      print('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) return Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: Text('Capture Image')),
      body: CameraPreview(_cameraController),
      floatingActionButton: FloatingActionButton(
        onPressed: _capture,
        child: Icon(Icons.camera),
      ),
    );
  }
}

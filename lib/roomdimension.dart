import 'package:flutter/material.dart';

class RoomDimensionPage extends StatefulWidget {
  @override
  _RoomDimensionPageState createState() => _RoomDimensionPageState();
}

class _RoomDimensionPageState extends State<RoomDimensionPage> {
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();

  double? roomLength;
  double? roomWidth;
  List<Map<String, dynamic>> furnitureList = [];

  // Generate furniture based on room area
  List<Map<String, dynamic>> generateFurniture(double length, double width) {
    double area = length * width;
    List<Map<String, dynamic>> furniture = [];

    if (area < 10) {
      furniture = [
        {'name': 'Small Sofa', 'x': 0.1, 'y': 0.1, 'width': 0.3, 'height': 0.2},
        {'name': 'Bookshelf', 'x': 0.6, 'y': 0.1, 'width': 0.2, 'height': 0.3},
      ];
    } else if (area < 20) {
      furniture = [
        {'name': 'Medium Sofa', 'x': 0.1, 'y': 0.1, 'width': 0.4, 'height': 0.2},
        {'name': 'Dining Table', 'x': 0.5, 'y': 0.5, 'width': 0.3, 'height': 0.3},
        {'name': 'TV Stand', 'x': 0.1, 'y': 0.7, 'width': 0.3, 'height': 0.2},
      ];
    } else {
      furniture = [
        {'name': 'King Bed', 'x': 0.1, 'y': 0.1, 'width': 0.5, 'height': 0.3},
        {'name': 'Wardrobe', 'x': 0.7, 'y': 0.1, 'width': 0.2, 'height': 0.5},
        {'name': 'Desk', 'x': 0.1, 'y': 0.6, 'width': 0.3, 'height': 0.2},
        {'name': 'Sofa', 'x': 0.6, 'y': 0.7, 'width': 0.3, 'height': 0.2},
      ];
    }

    return furniture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Planner'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _lengthController,
              decoration: InputDecoration(
                labelText: 'Room Length (meters)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.straighten),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _widthController,
              decoration: InputDecoration(
                labelText: 'Room Width (meters)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.straighten),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  double? length = double.tryParse(_lengthController.text);
                  double? width = double.tryParse(_widthController.text);
                  if (length != null && width != null && length > 0 && width > 0) {
                    setState(() {
                      roomLength = length;
                      roomWidth = width;
                      furnitureList = generateFurniture(length, width);
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid dimensions.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Show Layout',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (roomLength != null && roomWidth != null)
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: roomLength! / roomWidth!,
                    child: CustomPaint(
                      painter: RoomPainter(roomLength!, roomWidth!, furnitureList),
                      child: Container(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RoomPainter extends CustomPainter {
  final double roomLength;
  final double roomWidth;
  final List<Map<String, dynamic>> furnitureList;

  RoomPainter(this.roomLength, this.roomWidth, this.furnitureList);

  @override
  void paint(Canvas canvas, Size size) {
    final roomPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw room rectangle
    final roomRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(roomRect, roomPaint);
    canvas.drawRect(roomRect, borderPaint);

    final textPainter = (String text) => TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
          textDirection: TextDirection.ltr,
        );

    for (var item in furnitureList) {
      final dx = (item['x'] as double) * size.width;
      final dy = (item['y'] as double) * size.height;
      final furnitureWidth = (item['width'] as double) * size.width;
      final furnitureHeight = (item['height'] as double) * size.height;

      final furniturePaint = Paint()
        ..color = Colors.blue.shade200
        ..style = PaintingStyle.fill;

      final furnitureBorder = Paint()
        ..color = Colors.black
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      final furnitureRect = Rect.fromLTWH(dx, dy, furnitureWidth, furnitureHeight);

      canvas.drawRect(furnitureRect, furniturePaint);
      canvas.drawRect(furnitureRect, furnitureBorder);

      final tp = textPainter(item['name'] as String);
      tp.layout();
      tp.paint(canvas, Offset(dx + 4, dy + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
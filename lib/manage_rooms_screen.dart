import 'package:flutter/material.dart';
import 'models/room_model.dart';
import 'services/room_service.dart';

class ManageRoomsScreen extends StatefulWidget {
  const ManageRoomsScreen({super.key});

  @override
  State<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  final RoomService roomService = RoomService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController roomNumberController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    final room = Room(
      id: '',
      roomNumber: int.parse(roomNumberController.text),
      type: typeController.text,
      price: double.parse(priceController.text),
      status: 'available',
    );

    await roomService.createRoom(room);

    roomNumberController.clear();
    typeController.clear();
    priceController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Room created successfully")),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Rooms")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ExpansionTile(
                title: const Text("Add New Room", style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  TextFormField(
                    controller: roomNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Room Number"),
                    validator: (value) => value!.isEmpty ? "Enter room number" : null,
                  ),
                  TextFormField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: "Room Type"),
                    validator: (value) => value!.isEmpty ? "Enter room type" : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Price"),
                    validator: (value) => value!.isEmpty ? "Enter price" : null,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: createRoom,
                      child: const Text("Create Room"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          const Text("Room Status Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder<List<Room>>(
              stream: roomService.getRooms(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rooms = snapshot.data!;
                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text("Room ${room.roomNumber} - ${room.type}"),
                        subtitle: Text("Price: ₹ ${room.price}"),
                        trailing: DropdownButton<String>(
                          value: room.status,
                          underline: Container(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              roomService.updateStatus(room.id, newValue);
                            }
                          },
                          items: <String>['available', 'pending', 'confirmed']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value.toUpperCase(),
                                style: TextStyle(
                                  color: _statusColor(value),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        onLongPress: () {
                          // Existing delete logic
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'services/dormitory_service.dart';
import 'models/dormitory_model.dart';

class ManageDormitoryScreen extends StatefulWidget {
  const ManageDormitoryScreen({super.key});

  @override
  State<ManageDormitoryScreen> createState() => _ManageDormitoryScreenState();
}

class _ManageDormitoryScreenState extends State<ManageDormitoryScreen> {
  final DormitoryService dormitoryService = DormitoryService();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Dormitory Hall"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: "Hall Number"),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: "Type (e.g. AC, Non-AC)")),
              TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: "Capacity (Beds/Person)"),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price per Day"),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final dormitory = Dormitory(
                id: '',
                dormitoryNumber: int.parse(numberController.text),
                type: typeController.text,
                price: double.parse(priceController.text),
                capacity: int.parse(capacityController.text),
                description: descriptionController.text,
                status: 'available',
              );
              dormitoryService.addDormitory(dormitory);
              numberController.clear();
              typeController.clear();
              priceController.clear();
              capacityController.clear();
              descriptionController.clear();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
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
      case 'living':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Dormitory Halls")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Dormitory>>(
        stream: dormitoryService.getDormitories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final dorms = snapshot.data!;

          return ListView.builder(
            itemCount: dorms.length,
            itemBuilder: (context, index) {
              final dorm = dorms[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.apartment)),
                  title: Text("Dormitory Hall ${dorm.dormitoryNumber}"),
                  subtitle: Text("${dorm.type} - Capacity: ${dorm.capacity} - ₹${dorm.price}/day"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: dorm.status,
                        underline: Container(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            dormitoryService.updateStatus(dorm.id, newValue);
                          }
                        },
                        items: <String>['available', 'pending', 'confirmed', 'living']
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
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => dormitoryService.deleteDormitory(dorm.id),
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

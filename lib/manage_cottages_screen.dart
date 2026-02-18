import 'package:flutter/material.dart';
import 'services/cottage_service.dart';
import 'models/cottage_model.dart';

class ManageCottagesScreen extends StatefulWidget {
  const ManageCottagesScreen({super.key});

  @override
  State<ManageCottagesScreen> createState() => _ManageCottagesScreenState();
}

class _ManageCottagesScreenState extends State<ManageCottagesScreen> {
  final CottageService cottageService = CottageService();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Cottage"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: "Cottage Number"),
                keyboardType: TextInputType.number),
            TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Type (e.g. Luxury, Wooden)")),
            TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price per Night"),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final cottage = Cottage(
                id: '',
                cottageNumber: int.parse(numberController.text),
                type: typeController.text,
                price: double.parse(priceController.text),
                status: 'available',
              );
              cottageService.addCottage(cottage);
              numberController.clear();
              typeController.clear();
              priceController.clear();
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
      appBar: AppBar(title: const Text("Manage Cottages")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Cottage>>(
        stream: cottageService.getCottages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cottages = snapshot.data!;

          return ListView.builder(
            itemCount: cottages.length,
            itemBuilder: (context, index) {
              final cottage = cottages[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.home_work)),
                  title: Text("Cottage ${cottage.cottageNumber}"),
                  subtitle: Text("${cottage.type} - ₹${cottage.price}/night"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: cottage.status,
                        underline: Container(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            cottageService.updateStatus(cottage.id, newValue);
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
                        onPressed: () => cottageService.deleteCottage(cottage.id),
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

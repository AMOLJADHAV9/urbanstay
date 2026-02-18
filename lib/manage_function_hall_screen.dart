import 'package:flutter/material.dart';
import 'models/function_hall_model.dart';
import 'services/function_hall_service.dart';

class ManageFunctionHallScreen extends StatefulWidget {
  const ManageFunctionHallScreen({super.key});

  @override
  State<ManageFunctionHallScreen> createState() =>
      _ManageFunctionHallScreenState();
}

class _ManageFunctionHallScreenState
    extends State<ManageFunctionHallScreen> {
  final _formKey = GlobalKey<FormState>();
  final FunctionHallService hallService = FunctionHallService();

  final TextEditingController numberController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> createHall() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final hall = FunctionHall(
        id: '',
        hallNumber: int.parse(numberController.text.trim()),
        type: typeController.text.trim(),
        price: double.parse(priceController.text.trim()),
        capacity: int.parse(capacityController.text.trim()),
        description: descriptionController.text.trim(),
        status: 'available',
      );

      await hallService.createHall(hall);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Function Hall Created Successfully")),
      );

      numberController.clear();
      typeController.clear();
      priceController.clear();
      capacityController.clear();
      descriptionController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.blue;
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
      appBar: AppBar(title: const Text("Manage Function Halls")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ExpansionTile(
                title: const Text("Add New Function Hall", style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  TextFormField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Hall Number"),
                    validator: (value) => value!.isEmpty ? "Enter hall number" : null,
                  ),
                  TextFormField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: "Hall Type"),
                    validator: (value) => value!.isEmpty ? "Enter hall type" : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Price"),
                    validator: (value) => value!.isEmpty ? "Enter price" : null,
                  ),
                  TextFormField(
                    controller: capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Capacity"),
                    validator: (value) => value!.isEmpty ? "Enter capacity" : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    validator: (value) => value!.isEmpty ? "Enter description" : null,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: createHall,
                      child: const Text("Create Function Hall"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          const Text("Hall Status Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder<List<FunctionHall>>(
              stream: hallService.getHalls(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final halls = snapshot.data!;
                return ListView.builder(
                  itemCount: halls.length,
                  itemBuilder: (context, index) {
                    final hall = halls[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text("Hall ${hall.hallNumber} - ${hall.type}"),
                        subtitle: Text("Price: ₹ ${hall.price} | Capacity: ${hall.capacity}"),
                        trailing: DropdownButton<String>(
                          value: hall.status,
                          underline: Container(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              hallService.updateStatus(hall.id, newValue);
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

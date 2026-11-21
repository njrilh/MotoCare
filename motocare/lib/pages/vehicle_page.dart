
import 'package:flutter/material.dart';

import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  List<Vehicle> vehicles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    try {
      final result = await VehicleService.getVehicles();

      if (!mounted) return;

      setState(() {
        vehicles = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      showMessage(e.toString());
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> showVehicleForm({Vehicle? vehicle}) async {
    final merkController =
        TextEditingController(text: vehicle?.merk ?? '');
    final modelController =
        TextEditingController(text: vehicle?.model ?? '');
    final platController =
        TextEditingController(text: vehicle?.nomorPolisi ?? '');
    final tahunController =
        TextEditingController(text: vehicle?.tahun?.toString() ?? '');

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            vehicle == null ? 'Tambah Kendaraan' : 'Edit Kendaraan',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildField(merkController, 'Merek kendaraan'),
                  buildField(modelController, 'Model kendaraan'),
                  buildField(platController, 'Nomor polisi'),
                  buildField(
                    tahunController,
                    'Tahun kendaraan',
                    number: true,
                    requiredField: false,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  final tahun = tahunController.text.trim().isEmpty
                      ? null
                      : int.parse(tahunController.text.trim());

                  if (vehicle == null) {
                    await VehicleService.createVehicle(
                      merk: merkController.text.trim(),
                      model: modelController.text.trim(),
                      nomorPolisi: platController.text.trim(),
                      tahun: tahun,
                    );
                  } else {
                    await VehicleService.updateVehicle(
                      id: vehicle.idVehicle,
                      merk: merkController.text.trim(),
                      model: modelController.text.trim(),
                      nomorPolisi: platController.text.trim(),
                      tahun: tahun,
                    );
                  }

                  if (!mounted) return;

                  Navigator.pop(dialogContext);
                  await loadVehicles();
                  showMessage('Data kendaraan berhasil disimpan');
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    merkController.dispose();
    modelController.dispose();
    platController.dispose();
    tahunController.dispose();
  }

  Widget buildField(
    TextEditingController controller,
    String label, {
    bool number = false,
    bool requiredField = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return '$label wajib diisi';
          }

          if (number &&
              value != null &&
              value.trim().isNotEmpty &&
              int.tryParse(value.trim()) == null) {
            return 'Masukkan angka yang valid';
          }

          return null;
        },
      ),
    );
  }

  Future<void> confirmDelete(Vehicle vehicle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kendaraan'),
        content: Text(
          'Hapus ${vehicle.merk} ${vehicle.model}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await VehicleService.deleteVehicle(vehicle.idVehicle);
      await loadVehicles();
      showMessage('Kendaraan berhasil dihapus');
    } catch (e) {
      showMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan Saya'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showVehicleForm(),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadVehicles,
              child: vehicles.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Icon(Icons.motorcycle, size: 70),
                        Center(
                          child: Text('Belum ada kendaraan'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.motorcycle),
                            ),
                            title: Text(
                              '${vehicle.merk} ${vehicle.model}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${vehicle.nomorPolisi}\n'
                              'Tahun: ${vehicle.tahun ?? "-"}\n'
                              'Kilometer: ${vehicle.totalKm} km',
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showVehicleForm(vehicle: vehicle);
                                } else {
                                  confirmDelete(vehicle);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Hapus'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

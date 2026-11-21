
import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Booking> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      final result = await BookingService.getBookings();

      if (!mounted) return;

      setState(() {
        bookings = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> cancelBooking(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Booking'),
        content: const Text(
          'Apakah kamu yakin ingin membatalkan booking ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await BookingService.cancelBooking(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking berhasil dibatalkan'),
        ),
      );

      loadBookings();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void showBookingDetail(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Booking'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Jenis Servis: ${booking.jenisServis}'),
              const SizedBox(height: 8),
              Text('Tanggal: ${formatDate(booking.tanggalBooking)}'),
              const SizedBox(height: 8),
              Text('Odometer: ${booking.odometerKm} KM'),
              const SizedBox(height: 8),
              Text('Bengkel: ${booking.namaBengkel ?? "-"}'),
              const SizedBox(height: 8),
              Text('Keluhan: ${booking.keluhan ?? "-"}'),
              const SizedBox(height: 8),
              Text(
                'Estimasi Biaya: Rp ${booking.biayaEstimasi.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 8),
              Text(
                'Biaya Final: Rp ${booking.biayaFinal.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 8),
              Text('Status: ${statusLabel(booking.status)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> openBookingForm({Booking? booking}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFormPage(booking: booking),
      ),
    );

    if (result == true) {
      loadBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Servis'),
        actions: [
          IconButton(
            onPressed: loadBookings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openBookingForm(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(
                  child: Text('Belum ada booking servis'),
                )
              : RefreshIndicator(
                  onRefresh: loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.jenisServis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      statusLabel(booking.status),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                    backgroundColor:
                                        statusColor(booking.status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tanggal: ${formatDate(booking.tanggalBooking)}',
                              ),
                              Text(
                                'Odometer: ${booking.odometerKm} KM',
                              ),
                              Text(
                                'Bengkel: ${booking.namaBengkel ?? "-"}',
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        showBookingDetail(booking),
                                    child: const Text('Detail'),
                                  ),
                                  if (booking.status == 'pending') ...[
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () =>
                                          openBookingForm(
                                        booking: booking,
                                      ),
                                      child: const Text('Edit'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          cancelBooking(
                                        booking.idBooking,
                                      ),
                                      child: const Text(
                                        'Batalkan',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
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

// FORM BOOKING
class BookingFormPage extends StatefulWidget {
  final Booking? booking;

  const BookingFormPage({
    super.key,
    this.booking,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final formKey = GlobalKey<FormState>();

  final keluhanController = TextEditingController();
  final odometerController = TextEditingController();
  final bengkelController = TextEditingController();
  final alamatController = TextEditingController();
  final biayaController = TextEditingController();

  List<Vehicle> vehicles = [];
  int? selectedVehicle;
  String? selectedService;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isLoading = true;
  bool isSaving = false;

  final List<String> serviceTypes = [
    'Servis Rutin',
    'Ganti Oli',
    'Servis Mesin',
    'Servis Rem',
    'Servis Kelistrikan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    final booking = widget.booking;

    if (booking != null) {
      selectedVehicle = booking.idVehicle;
      selectedService = booking.jenisServis;
      keluhanController.text = booking.keluhan ?? '';
      odometerController.text = booking.odometerKm.toString();
      bengkelController.text = booking.namaBengkel ?? '';
      alamatController.text = booking.alamatBengkel ?? '';
      biayaController.text = booking.biayaEstimasi.toStringAsFixed(0);
      selectedDate = booking.tanggalBooking;
      selectedTime = TimeOfDay.fromDateTime(
        booking.tanggalBooking,
      );
    }

    loadVehicles();
  }

  Future<void> loadVehicles() async {
    try {
      final result = await VehicleService.getVehicles();

      if (!mounted) return;

      setState(() {
        vehicles = result;

        if (widget.booking == null && vehicles.isNotEmpty) {
          selectedVehicle = vehicles.first.idVehicle;
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> chooseTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  Future<void> saveBooking() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedVehicle == null ||
        selectedService == null ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi kendaraan, servis, tanggal, dan waktu'),
        ),
      );
      return;
    }

    final bookingDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (bookingDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal booking tidak boleh di masa lalu'),
        ),
      );
      return;
    }

    final data = {
      'id_vehicle': selectedVehicle,
      'jenis_servis': selectedService,
      'keluhan': keluhanController.text,
      'tanggal_booking': bookingDate.toIso8601String(),
      'odometer_km': int.parse(odometerController.text),
      'nama_bengkel': bengkelController.text,
      'alamat_bengkel': alamatController.text,
      'biaya_estimasi': double.tryParse(
            biayaController.text,
          ) ??
          0,
    };

    setState(() {
      isSaving = true;
    });

    try {
      if (widget.booking == null) {
        await BookingService.createBooking(data);
      } else {
        await BookingService.updateBooking(
          widget.booking!.idBooking,
          data,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.booking == null
                ? 'Booking berhasil dibuat'
                : 'Booking berhasil diperbarui',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    keluhanController.dispose();
    odometerController.dispose();
    bengkelController.dispose();
    alamatController.dispose();
    biayaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.booking == null
              ? 'Tambah Booking'
              : 'Edit Booking',
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
              ? const Center(
                  child: Text(
                    'Daftarkan kendaraan terlebih dahulu.',
                  ),
                )
              : Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      DropdownButtonFormField<int>(
                        value: selectedVehicle,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Kendaraan',
                          border: OutlineInputBorder(),
                        ),
                        items: vehicles.map((vehicle) {
                          return DropdownMenuItem(
                            value: vehicle.idVehicle,
                            child: Text(
                              '${vehicle.merk} ${vehicle.model} - ${vehicle.nomorPolisi}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedVehicle = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedService,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Servis',
                          border: OutlineInputBorder(),
                        ),
                        items: serviceTypes.map((service) {
                          return DropdownMenuItem(
                            value: service,
                            child: Text(service),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedService = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: odometerController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Odometer (KM)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Odometer wajib diisi';
                          }

                          if (int.tryParse(value) == null ||
                              int.parse(value) < 0) {
                            return 'Masukkan angka KM yang valid';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: keluhanController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Keluhan Kendaraan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: bengkelController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Bengkel',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: alamatController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Bengkel',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: biayaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Estimasi Biaya (Rp)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null ||
                                double.parse(value) < 0) {
                              return 'Masukkan biaya yang valid';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: chooseDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          selectedDate == null
                              ? 'Pilih Tanggal Servis'
                              : '${selectedDate!.day}/'
                                  '${selectedDate!.month}/'
                                  '${selectedDate!.year}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: chooseTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          selectedTime == null
                              ? 'Pilih Waktu Servis'
                              : selectedTime!.format(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isSaving ? null : saveBooking,
                        child: isSaving
                            ? const CircularProgressIndicator()
                            : const Text('Simpan Booking'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

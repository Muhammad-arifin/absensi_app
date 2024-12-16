import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>> userAbsensi;
  late TextEditingController jamMasukController;
  late TextEditingController jamKeluarController;
  String selectedStatus = 'Hadir'; // Default status

  @override
  void initState() {
    super.initState();
    jamMasukController = TextEditingController();
    jamKeluarController = TextEditingController();
    userAbsensi = fetchUserAbsensi();
  }

  Future<Map<String, dynamic>> fetchUserAbsensi() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final response = await _supabase
        .from('absensi')
        .select()
        .eq('user_id', user.id)
        .order('tanggal', ascending: false)
        .limit(1)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }

    return response.data != null && response.data.isNotEmpty
        ? response.data[0]
        : {};
  }

  void addAbsensi() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in')),
      );
      return;
    }

    if (jamMasukController.text.isEmpty || jamKeluarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Normalize status to lowercase before inserting into the database
    String normalizedStatus = selectedStatus.toLowerCase();

    final response = await _supabase.from('absensi').insert([
      {
        'user_id': user.id,
        'tanggal': DateTime.now().toIso8601String().split('T').first,
        'jam_masuk': jamMasukController.text,
        'jam_keluar': jamKeluarController.text,
        'status': normalizedStatus, // Use the normalized status
        'keterlambatan': '00:00:00',
        'keterangan': '',
      }
    ]).execute();

    if (response.error != null) {
      print('Failed to add absensi: ${response.error?.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add absensi')),
      );
    } else {
      setState(() {
        userAbsensi = fetchUserAbsensi();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Absensi berhasil ditambahkan')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final String formattedTime = pickedTime.format(context); // Format the time
      controller.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userAbsensi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final absensi = snapshot.data ?? {};
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Absensi Terakhir: ${absensi['tanggal'] ?? 'Belum ada absensi'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTimeField(jamMasukController, 'Jam Masuk'),
                        SizedBox(height: 20),
                        _buildTimeField(jamKeluarController, 'Jam Keluar'),
                        SizedBox(height: 20),
                        _buildStatusDropdown(),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: addAbsensi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 169, 200, 255),
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Tambah Absensi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return GestureDetector(
      onTap: () => _selectTime(context, controller), // Open the time picker on tap
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedStatus,
      onChanged: (value) {
        setState(() {
          selectedStatus = value!;
        });
      },
      items: ['Hadir', 'Sakit', 'Izin']
          .map((status) => DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              ))
          .toList(),
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserCutiPage extends StatefulWidget {
  @override
  _UserCutiPageState createState() => _UserCutiPageState();
}

class _UserCutiPageState extends State<UserCutiPage> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> cutiList;
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedLeaveType;

  @override
  void initState() {
    super.initState();
    cutiList = fetchCuti();
  }

  Future<List<Map<String, dynamic>>> fetchCuti() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final response = await _supabase
        .from('cuti')
        .select('id, tanggal_mulai, tanggal_selesai, status, jenis_cuti, keterangan')
        .eq('user_id', userId)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> submitCutiRequest() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty || _selectedLeaveType == null) {
      return;
    }

    final response = await _supabase.from('cuti').insert([
      {
        'user_id': userId,
        'tanggal_mulai': _startDateController.text,
        'tanggal_selesai': _endDateController.text,
        'jenis_cuti': _selectedLeaveType,
        'keterangan': _descriptionController.text,
        'status': 'pending',
      }
    ]).execute();

    if (response.error != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to submit leave request: ${response.error?.message}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      setState(() {
        cutiList = fetchCuti();
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuti'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cutiList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data cuti.'));
          } else {
            final cuti = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: cuti.length,
              itemBuilder: (context, index) {
                final item = cuti[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      'Tanggal Mulai: ${item['tanggal_mulai']} - Tanggal Selesai: ${item['tanggal_selesai']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Status: ${item['status']}'),
                    trailing: Icon(
                      item['status'] == 'pending' ? Icons.hourglass_empty : Icons.check_circle,
                      color: item['status'] == 'pending' ? Colors.orange : Colors.green,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Ajukan Cuti'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _startDateController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Mulai',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, _startDateController),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal mulai harus diisi';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _endDateController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Selesai',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, _endDateController),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal selesai harus diisi';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedLeaveType,
                          onChanged: (value) {
                            setState(() {
                              _selectedLeaveType = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Jenis Cuti',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ['liburan', 'sakit', 'pribadi', 'lainnya']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jenis cuti harus dipilih';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Keterangan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                submitCutiRequest();
                              }
                            },
                            child: Text('Kirim Cuti'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

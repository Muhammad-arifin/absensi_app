import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAbsensiPage extends StatefulWidget {
  final int? absensiId;

  AddAbsensiPage({this.absensiId});

  @override
  _AddAbsensiPageState createState() => _AddAbsensiPageState();
}

class _AddAbsensiPageState extends State<AddAbsensiPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  late String _status;
  late String _keterangan;
  late DateTime _tanggal;
  late TimeOfDay _waktuMasuk;
  late TimeOfDay _waktuPulang;

  @override
  void initState() {
    super.initState();
    _tanggal = DateTime.now();
    _waktuMasuk = TimeOfDay.now();
    _waktuPulang = TimeOfDay.now();
    _status = 'Hadir';
    _keterangan = '';

    if (widget.absensiId != null) {
      _loadAbsensiData();
    }
  }

  Future<void> _loadAbsensiData() async {
    final response = await supabase
        .from('absensi')
        .select()
        .eq('id', widget.absensiId)
        .single()
        .execute();

    if (response.error == null) {
      final absensi = response.data;
      setState(() {
        _tanggal = DateTime.parse(absensi['tanggal']);
        _status = absensi['status'];
        _keterangan = absensi['keterangan'];
      });
    } else {
      print('Error loading absensi: ${response.error!.message}');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await supabase.from('absensi').upsert({
        'id': widget.absensiId,
        'tanggal': _tanggal.toIso8601String(),
        'status': _status,
        'keterangan': _keterangan,
        'waktu_masuk': _waktuMasuk.format(context),
        'waktu_pulang': _waktuPulang.format(context),
      }).execute();

      if (response.error == null) {
        Navigator.pop(context);
      } else {
        print('Error saving absensi: ${response.error!.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah/Edit Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _keterangan,
                decoration: InputDecoration(labelText: 'Keterangan'),
                onSaved: (value) => _keterangan = value ?? '',
              ),
              DropdownButtonFormField<String>(
                value: _status,
                onChanged: (value) => setState(() => _status = value!),
                items: ['Hadir', 'Izin', 'Sakit', 'Absen']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Status Absensi'),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Simpan Absensi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:absensi_app/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://qnxkdhkmemrqauqdkeem.supabase.co', // Ganti dengan URL Supabase Anda
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFueGtkaGttZW1ycWF1cWRrZWVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMzOTE4NzAsImV4cCI6MjA0ODk2Nzg3MH0.16_txv8ipDx3a1GzHFewmiixRNDAX2BfgR2GzADajgQ', // Ganti dengan Anon Key Supabase Anda
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: LoginPage(),
    );
  }
}

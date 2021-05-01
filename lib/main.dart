// import 'package:barcode_absensi/page/login.dart';
import 'package:barcode_absensi/states/root.dart';
import 'package:barcode_absensi/states/statePetugas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StatePetugas(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Qrcode Scanner',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Root(),
      ),
    );
  }
}

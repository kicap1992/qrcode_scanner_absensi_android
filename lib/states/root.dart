// import 'dart:async';
import 'dart:convert';
import 'package:barcode_absensi/page/login.dart';
import 'package:barcode_absensi/page/scanQRcode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_absensi/states/statePetugas.dart';

class Root extends StatefulWidget {
  // Root({Key key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  late SharedPreferences sharedPreferences;
  int _isLoading = 0;

  @override
  // ignore: avoid_void_async
  void didChangeDependencies() async {
    super.didChangeDependencies();
    sharedPreferences = await SharedPreferences.getInstance();
    final json = sharedPreferences.getString("dataPetugas");
    final data1 = json != null ? jsonDecode(json) : null;
    // print(data1);
    if (sharedPreferences.getString("dataPetugas") != null) {
      if (data1?['level'] == 'petugas') {
        final StatePetugas _petugas =
            Provider.of<StatePetugas>(context, listen: false);

        try {
          final String _returnString = await _petugas.loginPetugas(
              data1!['username'].toString(), data1!['password'].toString());

          // print(_returnString);

          if (_returnString == 'success') {
            setState(() {
              // _login = false;
              _isLoading = 2;
            });
          } else {
            sharedPreferences.remove('dataPetugas');
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sila Login Kembali')));
            setState(() {
              // _login = false;
              _isLoading = 1;
            });
          }
        } catch (e) {
          // print(e);
          sharedPreferences.remove('dataPetugas');
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sila Login Kembali')));
          setState(() {
            _isLoading = 1;
            // _login = false;
          });
        }
      }
    } else {
      setState(() {
        // _login = false;
        _isLoading = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    late Widget retVal;
    switch (_isLoading) {
      case 0:
        retVal = Scaffold(
          appBar: AppBar(
            title: const Text("Loading"),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
        break;
      case 1:
        retVal = LoginPage();
        break;
      case 2:
        retVal = ScanQRCode();
        break;
    }
    return retVal;
  }
}

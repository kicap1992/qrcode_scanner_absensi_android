import 'package:barcode_absensi/page/login.dart';
import 'package:barcode_absensi/page/pencarian.dart';
import 'package:barcode_absensi/page/scanQRcode.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MyDrawer extends StatelessWidget {
  late SharedPreferences sharedPreferences;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          // ignore: sized_box_for_whitespace
          Container(
            height: 80.0,
            child: const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.all(0.0),
              child: Align(
                child: Text(
                  "Barcode Absensi",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Scan Barcode'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanQRCode(),
                )),
          ),
          ListTile(
            leading: const Icon(Icons.search_sharp),
            title: const Text('Pencarian NIK / Nama'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Pencarian(),
                )),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text("Logoout ?"),
                        content: const Text("Anda Akan Logout Dari Sistem?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batalkan')),
                          TextButton(
                              onPressed: () async {
                                sharedPreferences =
                                    await SharedPreferences.getInstance();
                                sharedPreferences.remove('dataPetugas');
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text('Ya')),
                        ],
                      ));
            },
          ),
        ],
      ),
    );
  }
}

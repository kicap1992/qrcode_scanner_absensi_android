import 'dart:convert';
import 'package:barcode_absensi/page/login.dart';
import 'package:barcode_absensi/page/pencarian.dart';
import 'package:barcode_absensi/states/statePetugas.dart';
import 'package:barcode_absensi/widgets/myWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanQRCode extends StatefulWidget {
  @override
  _ScanQRCodeState createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  final int _selectedIndex = 0;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    // if (index == 1) {
    //   print('sini logout');
    // }
    // setState(() {
    //   _selectedIndex = index;
    // });
    if (index == 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanQRCode(),
          ));
    } else if (index == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Pencarian(),
          ));
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Logout ?"),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Halaman Scan QR-Code"),
        ),
        body: const Center(
          child: Text(
            "Tekan tombol kamera pada sebelah kanan bawah skrin untuk scan QRCode karyawan",
            textAlign: TextAlign.center,
          ),
        ),
        drawer: MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => AbsensiScanner(context),
          child: const Icon(Icons.center_focus_strong),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'Scan QRCode',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Pencarian',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Logout',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    bool ini = false;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Keluar"),
              content: const Text("Yakin Ingin Keluar Dari Aplikasi ?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                      ini = true;
                    },
                    child: const Text('Yes')),
              ],
            ));
    return ini;
  }

  // ignore: non_constant_identifier_names
  Future<void> AbsensiScanner(BuildContext context) async {
    // print("hehe");
    final StatePetugas _petugas =
        Provider.of<StatePetugas>(context, listen: false);

    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      // print(qrCode);

      try {
        final String _returnString =
            await _petugas.scanPetugas(qrCode.toString());
        sharedPreferences = await SharedPreferences.getInstance();
        // print(_returnString);
        if (_returnString == 'error') {
          alertDialognya('Jaringan Bermasalah111, Sila Coba Kembali');
        } else if (_returnString == 'suda_absen') {
          final json = jsonDecode(sharedPreferences.getString("errornya")!);

          alertDialognya(json['message'].toString());
          sharedPreferences.remove('errornya');
        } else if (_returnString == 'data_tiada') {
          final json = jsonDecode(sharedPreferences.getString("errornya")!);

          alertDialognya(json['message'].toString());
          sharedPreferences.remove('errornya');
        } else {
          final data = jsonDecode(_returnString);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Icon(
                      Icons.info,
                      color: Colors.blue,
                    ),
                    const Text(
                      'Absensi Karyawan',
                      style: TextStyle(color: Colors.blue),
                    )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        masukkanAbsensi(
                            data['nik'].toString(),
                            data['jam_masuk'].toString(),
                            data['jam_keluar'].toString(),
                            data['tanggal'].toString(),
                            context);
                      },
                      child: const Text('Masukkan Absensi')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batalkan')),
                ],
                content: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Text(
                              'Nama : ',
                              style: TextStyle(),
                              textAlign: TextAlign.left,
                            ),
                            Flexible(
                              child: Text(
                                data['nama'].toString(),
                                style: const TextStyle(),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Text(
                              'NIK : ',
                              style: TextStyle(),
                              textAlign: TextAlign.left,
                            ),
                            Flexible(
                              child: Text(
                                data['nik'].toString(),
                                style: const TextStyle(),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Text(
                              'Tanggal : ',
                              style: TextStyle(),
                              textAlign: TextAlign.left,
                            ),
                            // ignore: prefer_const_constructors
                            Flexible(
                              child: Text(
                                data['tanggal'].toString(),
                                style: const TextStyle(),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Text(
                              'Jam Masuk : ',
                              style: TextStyle(),
                              textAlign: TextAlign.left,
                            ),
                            Flexible(
                              child: Text(
                                data['jam_masuk'].toString(),
                                style: const TextStyle(),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Text(
                              'Jam Keluar : ',
                              style: TextStyle(),
                              textAlign: TextAlign.left,
                            ),
                            Flexible(
                              child: Text(
                                data['jam_keluar'].toString(),
                                style: const TextStyle(),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      } catch (e) {
        print(e);
        alertDialognya('Jaringan Bermasalah222, Sila Coba Kembali');
      }
    } catch (e) {
      alertDialognya('Scanner Barcode Gagal Berfungsi');
    }

    // return 'hehe';
  }

  // ignore: avoid_void_async
  void masukkanAbsensi(
      // ignore: non_constant_identifier_names
      String NIK,
      String jamMasuk,
      String jamKeluar,
      String tanggal,
      BuildContext context) async {
    final StatePetugas _petugas =
        Provider.of<StatePetugas>(context, listen: false);
    Navigator.pop(context, true);
    try {
      final String _returnString =
          await _petugas.absensiPetugas(NIK, jamMasuk, jamKeluar, tanggal);
      if (_returnString == 'success') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            Future.delayed(const Duration(seconds: 6), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              title: Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const Text(
                    'Sukses',
                    style: TextStyle(color: Colors.blue),
                  )
                ],
              ),
              content: const Text("Karyawan Sukses Diabsensi"),
            );
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Karyawan Sukses Diabsensi')));
      } else {
        alertDialognya('Jaringan Bermasalah333, Sila Coba Kembali');
      }
    } catch (e) {
      print(e);
    }
  }

  // ignore: always_declare_return_types
  void alertDialognya(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 5), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          title: Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Icon(
                Icons.dangerous,
                color: Colors.red,
              ),
              const Text(
                'Gagal',
                style: TextStyle(color: Colors.red),
              )
            ],
          ),
          content: Text(message),
        );
      },
    );
  }
}

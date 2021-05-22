import 'dart:convert';
import 'package:barcode_absensi/models/modelKaryawan.dart';
import 'package:barcode_absensi/page/login.dart';
import 'package:barcode_absensi/page/scanQRcode.dart';
import 'package:barcode_absensi/states/statePetugas.dart';
import 'package:barcode_absensi/widgets/myWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// ignore_for_file: all

class Pencarian extends StatefulWidget {
  @override
  _PencarianState createState() => _PencarianState();
}

class _PencarianState extends State<Pencarian> {
  final int _selectedIndex = 1;
  late SharedPreferences sharedPreferences;

  // ignore: non_constant_identifier_names
  int _cek_list = 1;

  // var data;

  final List<Note> _notes = <Note>[];
  List<Note> _notesForDisplay = <Note>[];

  Future<List<Note>> fetchNotes() async {
    const url =
        'https://barcode-absensi.kicap-karan.com/api_server/list_karyawan';

    try {
      final response = await http.get(Uri.parse(url));
      final notes = <Note>[];

      if (response.statusCode == 200) {
        final notesJson = json.decode(response.body);
        for (final noteJson in notesJson) {
          notes.add(Note.fromJson(noteJson));
        }
        setState(() {
          _cek_list = 2;
        });
        return notes;
      } else {
        setState(() {
          _cek_list = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Jaringan Bermaslah, Sila Coba Kembali')));
        throw Exception("Error on server");
      }
    } on Exception catch (_) {
      // print('sini tidak dapat data');
      setState(() {
        _cek_list = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Jaringan Bermasalah, Sila Coba Kembali')));
      throw Exception("Error on server");
    }
  }

  @override
  void initState() {
    fetchNotes().then((value) {
      setState(() {
        _notes.addAll(value);
        _notesForDisplay = _notes;
      });
    });
    super.initState();
  }

  void _onItemTapped(int index) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Karyawan"),
        actions: [
          IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, true)),
        ],
      ),
      body: (_cek_list == 1)
          ? const Center(child: CircularProgressIndicator())
          : ((_cek_list == 2)
              ? ListView.builder(
                  itemBuilder: (context, index) {
                    return index == 0
                        ? _searchBar()
                        : _listItem(index, context);
                  },
                  itemCount: _notesForDisplay.length + 1,
                )
              : const Center(
                  child: Text("Masalah Jaringan, Sila Coba Kembali"))),
      drawer: MyDrawer(),
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
    );
  }

  Padding _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: TextField(
        decoration: const InputDecoration(hintText: 'Search...'),
        onChanged: (text) {
          text = text.toLowerCase();
          setState(() {
            _notesForDisplay = _notes.where((note) {
              final noteTitle = note.nik_karyawan.toLowerCase();
              return noteTitle.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  Card _listItem(index, context) {
    return Card(
      child: Slidable(
        actionPane: const SlidableDrawerActionPane(),
        secondaryActions: [
          IconSlideAction(
            caption: 'Absensi',
            color: Colors.blue,
            icon: Icons.archive,
            onTap: () => _cek_absensi(
                _notesForDisplay[index - 1].nik_karyawan.toString(), context),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _notesForDisplay[index - 1].nik_karyawan.toString(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                _notesForDisplay[index - 1].nama.toString(),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Future<void> _cek_absensi(String nik_karyawan, BuildContext context) async {
    final StatePetugas _petugas =
        Provider.of<StatePetugas>(context, listen: false);

    // print(_petugas);
    try {
      final String _returnString = await _petugas.scanPetugas(nik_karyawan);
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
  }

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
}

// ignore: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatePetugas extends ChangeNotifier {
  Future<String> loginPetugas(String username, String password) async {
    // ignore: prefer_final_locals
    String retVal = "error";
    try {
      // ignore: prefer_final_locals
      var uri = Uri.parse(
          // ignore: prefer_interpolation_to_compose_strings
          "https://barcode-absensi.kicap-karan.com/api_server/login_petugas?username=" +
              username +
              "&password=" +
              password);
      // ignore: prefer_final_locals
      var response = await http.get(uri);
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      switch (response.statusCode) {
        case 200:
          sharedPreferences.setString('dataPetugas', response.body);
          retVal = "success";
          break;
        case 401:
          final detail = jsonDecode(response.body);

          retVal = detail['message'].toString();
          break;
        default:
      }
    } catch (e) {
      print(e);
      retVal = "Masalah Jaringan";
    }

    return retVal;
  }

  Future<String> scanPetugas(String qrcode) async {
    String retVal = "error";

    try {
      final uri = Uri.parse(
          // ignore: prefer_interpolation_to_compose_strings
          "https://barcode-absensi.kicap-karan.com/api_server/cek_karyawan_by_qrcode?nik=" +
              qrcode);
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final response = await http.get(uri);
      final data = response.body;
      switch (response.statusCode) {
        case 200:
          retVal = data;
          break;
        case 401:
          retVal = 'suda_absen';
          sharedPreferences.setString('errornya', data);
          break;
        case 404:
          retVal = 'data_tiada';
          sharedPreferences.setString('errornya', data);
          break;
      }
    } catch (e) {
      print(e);
      retVal = "error";
    }

    // print(uri);
    return retVal;
  }

  Future<String> absensiPetugas(
      String nik, String jamMasuk, String jamKeluar, String tanggal) async {
    String retVal = 'error';

    try {
      final uri = Uri.parse(
          // ignore: prefer_interpolation_to_compose_strings
          "https://barcode-absensi.kicap-karan.com/api_server/absensi_karyawan");
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'nik_karyawan': nik,
          'jam_masuk': jamMasuk,
          'jam_keluar': jamKeluar,
          'tanggal': tanggal,
        }),
      );
      // final data = response.body;
      // print(data);
      switch (response.statusCode) {
        case 200:
          retVal = 'success';
          break;
        default:
          retVal = 'error';
      }
    } catch (e) {
      print(e);
      retVal = 'error';
    }
    return retVal;
  }
}

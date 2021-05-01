// ignore_for_file: type_annotate_public_apis
// ignore_for_file: prefer_typing_uninitialized_variables
// ignore_for_file: non_constant_identifier_names
class Note {
  var nik_karyawan;
  var nama;

  Note({required this.nik_karyawan, required this.nama});

  Note.fromJson(Map<String, dynamic> json) {
    nik_karyawan = json['nik_karyawan'];
    nama = json['nama'];
  }
}

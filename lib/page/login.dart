import 'dart:async';
// import 'dart:convert';
import 'package:barcode_absensi/page/scanQRcode.dart';
import 'package:barcode_absensi/states/statePetugas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  // bool _login = false;
  late SharedPreferences sharedPreferences;

  // @override
  // void initState() {
  //   // ignore: todo
  // ignore: todo
  //   // TODO: implement initState
  //   super.initState();
  //   checkLoginStatus();
  // }

  // ignore: always_declare_return_types
  // ignore: avoid_void_async
  // void checkLoginStatus() async {
  //   sharedPreferences = await SharedPreferences.getInstance();
  //   final json = sharedPreferences.getString("dataPetugas");
  //   final data1 = json != null ? jsonDecode(json) : null;
  //   // print(data1);
  //   if (sharedPreferences.getString("dataPetugas") != null) {
  //     if (data1?['level'] == 'petugas') {
  //       final StatePetugas _petugas =
  //           Provider.of<StatePetugas>(context, listen: false);

  //       try {
  //         final String _returnString = await _petugas.loginPetugas(
  //             data1!['username'].toString(), data1!['password'].toString());

  //         // print(_returnString);

  //         if (_returnString == 'success') {
  //           Navigator.pushAndRemoveUntil(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => ScanQRCode(),
  //               ),
  //               (route) => false);
  //         } else {
  //           sharedPreferences.remove('dataPetugas');
  //           ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Sila Login Kembali')));
  //           setState(() {
  //             // _login = false;
  //             _isLoading = false;
  //           });
  //         }
  //       } catch (e) {
  //         // print(e);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Sila Login Kembali')));
  //         setState(() {
  //           _isLoading = false;
  //           // _login = false;
  //         });
  //       }
  //     }
  //   }
  // }

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // ignore: avoid_void_async
  void _loginPetugas(
      {required String username,
      required String password,
      required BuildContext context}) async {
    final StatePetugas _petugas =
        Provider.of<StatePetugas>(context, listen: false);

    try {
      final String _returnString =
          await _petugas.loginPetugas(username, password);

      setState(() {
        _isLoading = false;
      });

      if (_returnString == 'success') {
        // print(_returnString);
        // sharedPreferences = await SharedPreferences.getInstance();
        // // print(sharedPreferences);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            Future.delayed(const Duration(milliseconds: 2001), () {
              Navigator.of(context).pop(true);
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => ScanQRCode(),
              //     ),
              //     (route) => false);
            });
            return const AlertDialog(
              title: Text("Sukses"),
              content: Text("Selamat Betugas"),
            );
          },
        );

        Future.delayed(const Duration(seconds: 3), () {
          // Navigator.of(context).pop(true);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ScanQRCode(),
              ),
              (route) => false);
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_returnString.toString())));
      }
    } catch (e) {
      // print(e);
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Jaringan Bermasalahsadsad")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Login Petugas"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Form(
                  key: formkey,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            TextFormField(
                              // focusNode: usernameFocus,
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Masukkan Username ",
                                labelText: "Username",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Username Harus Terisi";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              // focusNode: passwordFocus,
                              controller: _passwordController,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Masukkan Password ",
                                labelText: "Password",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Password Harus Terisi";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (formkey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _loginPetugas(
                                    username: _usernameController.text,
                                    password: _passwordController.text,
                                    context: context,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                              ),
                              child: const Text("Login"),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

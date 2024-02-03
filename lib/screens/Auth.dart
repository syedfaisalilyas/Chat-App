import 'dart:io';
import 'package:chat_app/widgets/imagepicker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isauthenticating = false;
  File? _selectedimage;
  var _enteredemail = '';
  var _enteredusername = '';
  var _enteredpassword = '';
  var _islogin = true;

  void _issubmit() async {
    var isvalid = _form.currentState!.validate();
    if (!isvalid || !_islogin && _selectedimage == null) {
      //show error
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error: Something went wrong'),
      //   ),
      // );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Something went wrong'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        _isauthenticating = true;
      });
      if (_islogin) {
        final usercredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredemail, password: _enteredpassword);
      } else {
        final usercredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredemail, password: _enteredpassword);
        final StorageRef = FirebaseStorage.instance
            .ref()
            .child('User_Images')
            .child('${usercredentials.user!.uid}.jpg');

        await StorageRef.putFile(_selectedimage!);
        final imageurl = await StorageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(usercredentials.user!.uid)
            .set({
          'username': _enteredusername,
          'email': _enteredemail,
          'image url': imageurl
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Authentication failed',
          ),
        ),
      );
      setState(() {
        _isauthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              width: 200,
              child: Image.asset(
                  'C:\\Flutter Projects\\chat_app\\lib\\assets\\images\\chat.png'),
            ),
            Card(
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_islogin)
                          UserImagePicker(Imagepicker: (pickedimage) {
                            _selectedimage = pickedimage;
                          }),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredemail = value!;
                          },
                        ),
                        if (!_islogin)
                          TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Username',
                              ),
                              enableSuggestions: true,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter atleast 4 letters';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredusername = value!;
                              }),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be atleast 6 characters long';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredpassword = value!;
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (_isauthenticating)
                          const CircularProgressIndicator(),
                        if (!_isauthenticating)
                          ElevatedButton(
                            onPressed: _issubmit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: Text(_islogin ? 'Login' : 'Signup'),
                          ),
                        if (!_isauthenticating)
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _islogin = !_islogin;
                                });
                              },
                              child: Text(_islogin
                                  ? 'Create an account'
                                  : 'I already have an account'))
                      ],
                    )),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

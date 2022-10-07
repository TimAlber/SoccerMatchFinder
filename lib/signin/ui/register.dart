import 'dart:io';

import 'package:flutter/material.dart';
import 'package:soccer_finder/signin/buisness-logic/service.dart';
import 'package:soccer_finder/signin/ui/choose-team.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailTextController = TextEditingController();
  final userNameTextController = TextEditingController();
  final pwTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  var isloading = false;

  XFile? picture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isloading
          ? Center(
              child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 50, left: 10, right: 10),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte gebe deinen Nutznamen an';
                            }
                            return null;
                          },
                          controller: userNameTextController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Benutzername',
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 25, left: 10, right: 10),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte gebe eine valide email adresse ein';
                            }
                            bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value);
                            if (!emailValid) {
                              return 'Bitte gebe eine valide email adresse ein';
                            }
                            return null;
                          },
                          controller: emailTextController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Email',
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 25, left: 10, right: 10),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte gebe ein Passwort ein';
                            }
                            if (value.length < 6) {
                              return 'Passwort muss mindestens 6 Zeichen lang sein';
                            }
                            return null;
                          },
                          obscureText: true,
                          controller: pwTextController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Password',
                          ),
                        ),
                      ),
                      if(picture != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipOval(
                          child: Image.file(
                            File(picture!.path),
                            fit: BoxFit.cover,
                            width: 180.0,
                            height: 180.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.grey),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(100, 50))),
                            onPressed: () {
                              showModalSheet();
                            },
                            child: picture == null ? Text( 'Profilbild hinzufügen') : Text( 'Profilbild ändern')),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: TextButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.grey),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(200, 100))),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isloading = true;
                                });
                                AuthService()
                                    .register(
                                        email: emailTextController.text,
                                        pw: pwTextController.text,
                                        username: userNameTextController.text,
                                        profilePicture: picture,
                                )
                                    .then((worked) => {
                                          AuthService()
                                              .signIn(
                                                  email:
                                                      emailTextController.text,
                                                  pw: pwTextController.text)
                                              .then((innerWorked) => {
                                                    if (worked && innerWorked)
                                                      {
                                                        print(
                                                            'register and login worked'),

                                                        setState(() {
                                                          isloading = false;
                                                        }),

                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const ChooseTeam()),
                                                        ),
                                                      }
                                                  })
                                        });
                              }
                            },
                            child: const Text('Registrieren')),
                      ),
                    ]),
              ),
            ))
          : const Center(child: CircularProgressIndicator()),
    );
  }


  void showModalSheet(){
    showModalBottomSheet<void>(
      elevation: 10,
      context: context,
      builder: (BuildContext context) {
        return ListView(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Profilbild mit Kamera machen'),
                onTap: () {
                  final ImagePicker _picker = ImagePicker();
                  _picker.pickImage(source: ImageSource.camera).then((value) => {
                    setState(() {
                      picture = value;
                      Navigator.of(context).pop();
                    }),
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Profilbild aus Gallery wählen'),
                onTap: (){
                  final ImagePicker _picker = ImagePicker();
                  _picker.pickImage(source: ImageSource.gallery).then((value) => {
                    setState(() {
                      picture = value;
                      Navigator.of(context).pop();
                    }),
                  });
                },
              )
            ],
        );
      },
    );
  }
}

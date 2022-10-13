import 'package:flutter/material.dart';
import 'package:soccer_finder/signin/buisness-logic/service.dart';
import 'package:soccer_finder/signin/ui/register.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailTextController = TextEditingController();
  final pwTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Soccerball.svg/1200px-Soccerball.svg.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte gebe eine valide email adresse ein';
                      }
                      bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
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
                  padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
                  child: TextField(
                    obscureText: true,
                    controller: pwTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Password',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                          foregroundColor: MaterialStateProperty.all(Colors.black),
                          minimumSize:
                              MaterialStateProperty.all(const Size(100, 50))),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if(await AuthService().signIn(email: emailTextController.text, pw: pwTextController.text)){
                          } else {
                            showErrorAlert(context, 'Fehler beim einloggen');
                          }
                        }
                      },
                      child: const Text('Log in')),
                ),
                const Divider(
                  thickness: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                          foregroundColor: MaterialStateProperty.all(Colors.black),
                          minimumSize:
                              MaterialStateProperty.all(const Size(200, 100))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const Register()),
                        );
                      },
                      child: const Text('Registrieren')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showErrorAlert(BuildContext context, String text) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(text),
      ));
}

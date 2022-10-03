import 'package:flutter/material.dart';

class ChallengeOthers extends StatefulWidget {
  final topic = 'Fordere ein aderes Team auf';
  const ChallengeOthers({Key? key}) : super(key: key);

  @override
  State<ChallengeOthers> createState() => _ChallengeOthersState();
}

class _ChallengeOthersState extends State<ChallengeOthers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Bidy')),
    );
  }
}

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class PledgedGiftsTempPage extends StatefulWidget {
  const PledgedGiftsTempPage({
    super.key,
  });

  @override
  State<PledgedGiftsTempPage> createState() => _PledgedGiftsTempPageState();
}

class _PledgedGiftsTempPageState extends State<PledgedGiftsTempPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: const Text('Pledged Gifts',
                  style: TextStyle(color: Colors.white))),
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            textAlign: TextAlign.center,
            'The Gifts you pledged for each friend are present in their gift list page!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ));
  }
}

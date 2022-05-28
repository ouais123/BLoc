import 'package:flutter/material.dart';
import 'dart:math' as math show Random;
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const List<String> names = [
  'owais',
  'ahmad',
  'oamer',
  'jamal',
];

extension RondomValue<T> on Iterable<T> {
  T getRondomValue() => elementAt(math.Random().nextInt(length));
}

class NamesCubit extends Cubit<String?> {
  NamesCubit() : super(null);
  void pickRandomName() {
    emit(names.getRondomValue());
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late NamesCubit namesCubit;
  @override
  void initState() {
    namesCubit = NamesCubit();
    super.initState();
  }

  @override
  void dispose() {
    namesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: StreamBuilder<String?>(
        stream: namesCubit.stream,
        builder: (ctx, snapshot) {
          Widget button = TextButton(
            onPressed: () {
              namesCubit.pickRandomName();
            },
            child: const Text("Click Here!"),
          );
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return button;
            case ConnectionState.waiting:
              return button;
            case ConnectionState.active:
              return Column(
                children: [
                  button,
                  Text(snapshot.data ?? ""),
                ],
              );
            case ConnectionState.done:
              return const SizedBox();
          }
        },
      ),
    );
  }
}

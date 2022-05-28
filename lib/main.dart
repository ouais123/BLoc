// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math show Random;

import 'package:bloc/bloc.dart';
import 'package:bloc_course/bloc/person.dart';
import 'package:bloc_course/bloc/person_action.dart';
import 'package:bloc_course/bloc/person_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((res) => res.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List)
    .then((list) => list.map((e) => Person.formMap(e)));

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
      home: BlocProvider(
        create: (context) => BolcPerson(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<BolcPerson>().add(
                        LoadPersonAction(
                          url: person1Url,
                          personsLoader: getPersons,
                        ),
                      );
                },
                child: const Text("load json #1"),
              ),
              TextButton(
                onPressed: () {
                  context.read<BolcPerson>().add(
                        LoadPersonAction(
                          url: person2Url,
                          personsLoader: getPersons,
                        ),
                      );
                },
                child: const Text("load json #2"),
              ),
            ],
          ),
          BlocBuilder<BolcPerson, FetchResult?>(
            buildWhen: (previous, current) {
              return previous?.persons != current?.persons;
            },
            builder: (_, fetchResult) {
              fetchResult?.log();
              final persons = fetchResult?.persons;
              if (persons == null) return const SizedBox();
              return Expanded(
                child: ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (_, index) => ListTile(
                    title: Text(persons[index]!.name),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

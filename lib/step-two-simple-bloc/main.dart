// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math show Random;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

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

abstract class LoadAction {
  const LoadAction();
}

class LoadPersonAction extends LoadAction {
  PersonsUrl url;
  LoadPersonAction({
    required this.url,
  }) : super();
}

enum PersonsUrl {
  persons1,
  persons2,
}

extension UrlString on PersonsUrl {
  String get urlString {
    switch (this) {
      case PersonsUrl.persons1:
        return "http://192.168.1.111:5500/api/persons1.json";
      case PersonsUrl.persons2:
        return "http://192.168.1.111:5500/api/persons2.json";
    }
  }
}

class Person {
  final String name;
  final int age;

  Person.formMap(Map<String, dynamic> map)
      : name = map['name'],
        age = map['age'];
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((res) => res.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List)
    .then((list) => list.map((e) => Person.formMap(e)));

class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;
  FetchResult({
    required this.persons,
    required this.isRetrievedFromCache,
  });
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class BolcPerson extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonsUrl, Iterable<Person>> _cache = {};
  BolcPerson() : super(null) {
    on<LoadPersonAction>((event, emit) async {
      final PersonsUrl url = event.url;
      if (_cache.containsKey(url)) {
        final catchedPersons = _cache[url]!;
        final result = FetchResult(
          persons: catchedPersons,
          isRetrievedFromCache: true,
        );
        emit(result);
      } else {
        final persons = await getPersons(url.urlString);
        _cache[url] = persons;
        final result = FetchResult(
          persons: persons,
          isRetrievedFromCache: false,
        );
        emit(result);
      }
    });
  }
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
                  context
                      .read<BolcPerson>()
                      .add(LoadPersonAction(url: PersonsUrl.persons1));
                },
                child: const Text("load json #1"),
              ),
              TextButton(
                onPressed: () {
                  context
                      .read<BolcPerson>()
                      .add(LoadPersonAction(url: PersonsUrl.persons2));
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

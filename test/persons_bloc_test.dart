import 'package:bloc_course/bloc/person.dart';
import 'package:bloc_course/bloc/person_action.dart';
import 'package:bloc_course/bloc/person_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

const Iterable<Person> mockPersons1 = [];
const Iterable<Person> mockPersons2 = [];

Future<Iterable<Person>> mockGetPersons1(String _) =>
    Future.value(mockPersons1);
Future<Iterable<Person>> mockGetPersons2(String _) =>
    Future.value(mockPersons2);

void main() {
  group("test init", () {
    late PersonBloc personBloc;
    setUp(() {
      personBloc = PersonBloc();
    });

    blocTest<PersonBloc, FetchResult?>(
      "test init state",
      build: () => personBloc,
      verify: (bloc) => bloc.state == null,
    );

    blocTest<PersonBloc, FetchResult?>(
      "mock retrievoing persons from first iterable",
      build: () => personBloc,
      act: (bloc) {
        bloc.add(LoadPersonAction(url: "", personsLoader: mockGetPersons1));
      },
    );
  });
}

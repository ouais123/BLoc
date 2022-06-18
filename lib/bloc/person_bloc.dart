import 'package:bloc_course/bloc/person.dart';
import 'package:bloc_course/bloc/person_action.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  FetchResult({
    required this.persons,
    required this.isRetrievedFromCache,
  });

  @override
  bool operator ==(covariant FetchResult other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashCode => Object.hash(
        persons,
        isRetrievedFromCache,
      );
}

class PersonBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> _cache = {};

  PersonBloc() : super(null) {
    on<LoadPersonAction>((event, emit) async {
      final String url = event.url;
      if (_cache.containsKey(url)) {
        final catchedPersons = _cache[url]!;
        final result = FetchResult(
          persons: catchedPersons,
          isRetrievedFromCache: true,
        );
        emit(result);
      } else {
        final loader = event.personsLoader;
        final persons = await loader(url);
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

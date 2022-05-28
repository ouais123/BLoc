import 'package:bloc_course/bloc/person.dart';

const String person1Url = "http://192.168.1.111:5500/api/persons1.json";
const String person2Url = "http://192.168.1.111:5500/api/persons2.json";

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

abstract class LoadAction {
  const LoadAction();
}

class LoadPersonAction extends LoadAction {
  final String url;
  final PersonsLoader personsLoader;
  LoadPersonAction({
    required this.url,
    required this.personsLoader,
  }) : super();
}

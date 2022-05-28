class Person {
  final String name;
  final int age;

  Person.formMap(Map<String, dynamic> map)
      : name = map['name'],
        age = map['age'];
}

import 'package:flutter/material.dart';
import '../dao/person_dao.dart';
import '../models/person.dart';

class PersonViewModel extends ChangeNotifier {
  final PersonDao _personDao;
  Stream<List<Person>>? _persons;

  PersonViewModel(this._personDao) {
    _persons = _personDao.getAllPersons();
  }

  Stream<List<Person>> get persons => _persons!;

  Future<void> addPerson(String name, int age) async {
    final person = Person(null, name, age);
    await _personDao.insertPerson(person);
    notifyListeners();
  }
}

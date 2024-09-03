import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'database/app_database.dart';
import 'dao/person_dao.dart';
import 'viewmodels/person_view_model.dart';
import 'models/person.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationDocumentsDirectory();
  final databasePath = join(directory.path, 'app_database.db');

  final database = await $FloorAppDatabase
      .databaseBuilder(databasePath)
      .build();

  runApp(MyApp(database.personDao));
}

class MyApp extends StatelessWidget {
  final PersonDao personDao;

  const MyApp(this.personDao, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PersonViewModel(personDao),
      child: MaterialApp(
        title: 'Person Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PersonScreen(),
      ),
    );
  }
}

class PersonScreen extends StatefulWidget {
  const PersonScreen({super.key});

  @override
  _PersonScreenState createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PersonViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final age = int.tryParse(_ageController.text) ?? 0;
                viewModel.addPerson(name, age);
                _nameController.clear();
                _ageController.clear();
              },
              child: const Text('Add'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Person>>(
                stream: viewModel.persons,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final persons = snapshot.data!;
                    return ListView.builder(
                      itemCount: persons.length,
                      itemBuilder: (context, index) {
                        final person = persons[index];
                        return ListTile(
                          title: Text(person.name),
                          subtitle: Text('Age: ${person.age}'),
                        );
                      },
                    );
                  } else {
                    return const Text('No data available');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _branch;
  String? _year;

  final List<String> _branches = [
    'IT',
    'CS',
    'AIDS',
    'ENTC',
    'Electrical',
    'Instrumentation',
  ];

  final List<String> _years = ['1st', '2nd', '3rd', '4th'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Branch'),
                value: _branch,
                items: _branches.map((branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _branch = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your branch';
                  }
                  return null;
                },
                onSaved: (value) {
                  _branch = value;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Year'),
                value: _year,
                items: _years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _year = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your year';
                  }
                  return null;
                },
                onSaved: (value) {
                  _year = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Process the data (e.g., save to database)
                    print('Name: $_name, Email: $_email, Branch: $_branch, Year: $_year');
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

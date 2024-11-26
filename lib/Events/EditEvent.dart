import 'package:flutter/material.dart';
import 'package:hedieaty_project/Database/DatabaseClass.dart';
import 'package:hedieaty_project/Models/Event.dart';

class EditEvent extends StatefulWidget {
  const EditEvent({required this.event, required this.onEventUpdated,super.key});

  final Events event;
  final void Function() onEventUpdated;
  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  final _editNameController = TextEditingController();
  final _editDateController = TextEditingController();
  final _editLocationController = TextEditingController();
  final _editDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DataBaseClass _mydb = DataBaseClass();

  @override
  void initState() {
    super.initState();
    _editNameController.text = widget.event.name;
    _editDateController.text = widget.event.Date;
    _editLocationController.text = widget.event.Location;
    _editDescriptionController.text = widget.event.Description;
  }

  @override
  void dispose() {
    _editNameController.dispose();
    _editDateController.dispose();
    _editLocationController.dispose();
    _editDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateEventData() async {
    if (_formKey.currentState!.validate()) {
      try {
        String sqlQuery = '''
          UPDATE Events 
          SET Name = "${_editNameController.text}",
              Date = "${_editDateController.text}",
              Location = "${_editLocationController.text}",
              Description = "${_editDescriptionController.text}"
          WHERE ID = ${widget.event.ID}
        ''';

        int response = await _mydb.updateData(sqlQuery);

        if (response > 0) {
          Navigator.pop(context, true); // Return to the previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update the event.")),
          );
        }
      } catch (e) {
        print("Error updating event: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while updating.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event",style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _editNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().length < 3) {
                    return 'Please enter a valid event name (min 3 characters).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _editDateController,
                decoration: const InputDecoration(labelText: 'Event Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid date.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _editLocationController,
                decoration: const InputDecoration(labelText: 'Event Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid location.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _editDescriptionController,
                decoration: const InputDecoration(labelText: 'Event Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',style: TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: _updateEventData,
                    child: const Text('Save Changes',style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

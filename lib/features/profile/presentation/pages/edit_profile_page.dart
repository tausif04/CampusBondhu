import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final universityController = TextEditingController();
  final departmentController = TextEditingController();
  final bioController = TextEditingController();

  String? selectedYear;

  List<String> interests = [];
  List<String> skills = [];

  final interestController = TextEditingController();
  final skillController = TextEditingController();

  final years = ["1st", "2nd", "3rd", "4th"];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // 🔥 Load existing data
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nameController.text = prefs.getString('name') ?? "";
      universityController.text = prefs.getString('university') ?? "";
      departmentController.text = prefs.getString('department') ?? "";
      bioController.text = prefs.getString('bio') ?? "";
      selectedYear = prefs.getString('year');
      interests = prefs.getStringList('interests') ?? [];
      skills = prefs.getStringList('skills') ?? [];
    });
  }

  // 💾 Save data
  Future<void> saveUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', nameController.text);
    await prefs.setString('university', universityController.text);
    await prefs.setString('department', departmentController.text);
    await prefs.setString('bio', bioController.text);
    await prefs.setString('year', selectedYear ?? "");
    await prefs.setStringList('interests', interests);
    await prefs.setStringList('skills', skills);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
          ),
        ),
        child: SafeArea(child: Column(children: [_header(), _body()])),
      ),
    );
  }

  // 🔹 Header
  Widget _header() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        "Edit Profile",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // 🔹 Body
  Widget _body() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _input(nameController, "Name"),
              _input(universityController, "University"),
              _input(departmentController, "Department"),

              // 🎯 Year Dropdown
              DropdownButtonFormField(
                value: selectedYear,
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) => setState(() => selectedYear = v),
                decoration: _inputDecoration("Year"),
              ),

              _input(bioController, "Bio"),

              const SizedBox(height: 15),

              _sectionTitle("Interests"),
              _addChipField(interestController, interests),

              const SizedBox(height: 15),

              _sectionTitle("Skills"),
              _addChipField(skillController, skills),

              const SizedBox(height: 25),

              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Input Field
  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // 🔹 Chip Input
  Widget _addChipField(TextEditingController controller, List<String> list) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "Add item"),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    list.add(controller.text);
                    controller.clear();
                  });
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: list.map((item) {
            return Chip(
              label: Text(item),
              onDeleted: () {
                setState(() => list.remove(item));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 🔹 Section Title
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 🔥 Save Button
  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          await saveUser();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Profile Updated")));

          Navigator.pop(context);
        },
        child: const Text(
          "Save Changes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

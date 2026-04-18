import '../models/buddy_model.dart';

class BuddyLocalDataSource {
  List<Buddy> getBuddies() {
    return [
      Buddy(
        name: "Tausif",
        department: "CSE",
        year: "3rd",
        subjects: ["DSA", "AI"],
        availability: "Evening",
      ),
      Buddy(
        name: "Rahim",
        department: "EEE",
        year: "2nd",
        subjects: ["Math", "Physics"],
        availability: "Morning",
      ),
      Buddy(
        name: "Karim",
        department: "BBA",
        year: "4th",
        subjects: ["Finance"],
        availability: "Evening",
      ),
    ];
  }
}

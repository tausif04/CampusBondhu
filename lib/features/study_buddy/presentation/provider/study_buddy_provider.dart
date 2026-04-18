import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/buddy_model.dart';
import '../../data/datasources/buddy_local_datasource.dart';

class StudyBuddyState {
  final List<Buddy> allBuddies;
  final String search;
  final String? department;
  final String? year;
  final String? availability;

  StudyBuddyState({
    required this.allBuddies,
    this.search = '',
    this.department,
    this.year,
    this.availability,
  });

  StudyBuddyState copyWith({
    List<Buddy>? allBuddies,
    String? search,
    String? department,
    String? year,
    String? availability,
  }) {
    return StudyBuddyState(
      allBuddies: allBuddies ?? this.allBuddies,
      search: search ?? this.search,
      department: department ?? this.department,
      year: year ?? this.year,
      availability: availability ?? this.availability,
    );
  }
}

class StudyBuddyNotifier extends StateNotifier<StudyBuddyState> {
  final BuddyLocalDataSource dataSource;

  StudyBuddyNotifier(this.dataSource)
    : super(StudyBuddyState(allBuddies: dataSource.getBuddies()));

  void setSearch(String value) {
    state = state.copyWith(search: value);
  }

  void setDepartment(String? value) {
    state = state.copyWith(department: value);
  }

  void setYear(String? value) {
    state = state.copyWith(year: value);
  }

  void setAvailability(String? value) {
    state = state.copyWith(availability: value);
  }

  List<Buddy> get filtered {
    return state.allBuddies.where((b) {
      final matchSearch =
          b.name.toLowerCase().contains(state.search.toLowerCase()) ||
          b.subjects.any(
            (s) => s.toLowerCase().contains(state.search.toLowerCase()),
          );

      final matchDept =
          state.department == null || b.department == state.department;

      final matchYear = state.year == null || b.year == state.year;

      final matchAvail =
          state.availability == null || b.availability == state.availability;

      return matchSearch && matchDept && matchYear && matchAvail;
    }).toList();
  }
}

final studyBuddyProvider =
    StateNotifierProvider<StudyBuddyNotifier, StudyBuddyState>((ref) {
      return StudyBuddyNotifier(BuddyLocalDataSource());
    });

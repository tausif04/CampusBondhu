class AppConstants {
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String studyGroupsCollection = 'study_groups';
  static const String messagesCollection = 'messages';
  static const String eventsCollection = 'events';
  static const String registrationsCollection = 'registrations';
  static const String notificationsCollection = 'notifications';

  // Firebase Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String eventImagesPath = 'event_images';

  // Predefined Interests
  static const List<String> interests = [
    'Machine Learning',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Cybersecurity',
    'Cloud Computing',
    'Blockchain',
    'Robotics',
    'UI/UX Design',
    'Game Development',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Environmental Science',
    'Economics',
    'Finance',
    'Marketing',
    'Entrepreneurship',
    'Literature',
    'Philosophy',
    'Psychology',
    'History',
    'Photography',
    'Music',
    'Art & Design',
    'Sports',
    'Fitness',
    'Debate & Public Speaking',
    'Research & Academia',
    'Other',
  ];

  // Departments
  static const List<String> departments = [
    'Computer Science & Engineering',
    'Electrical & Electronic Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Business Administration',
    'Economics',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Law',
    'Medicine',
    'Pharmacy',
    'Architecture',
    'Other',
  ];

  // Years/Semesters
  static const List<String> yearSemesters = [
    '1st Year / 1st Semester',
    '1st Year / 2nd Semester',
    '2nd Year / 3rd Semester',
    '2nd Year / 4th Semester',
    '3rd Year / 5th Semester',
    '3rd Year / 6th Semester',
    '4th Year / 7th Semester',
    '4th Year / 8th Semester',
    'Masters / 1st Semester',
    'Masters / 2nd Semester',
    'PhD',
  ];

  // Event Statuses
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
}

class Student {
  final String id;
  final String name;
  bool isPresent;

  Student({required this.id, required this.name, this.isPresent = true});
}

class ClassRoom {
  final String id;
  final String name;
  final String teacherName;
  final List<Student> students;

  ClassRoom({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.students,
  });
}

final mockClasses = [
  ClassRoom(
    id: 'c1',
    name: 'Grade 6A',
    teacherName: 'Mrs. Johnson',
    students: List.generate(20, (index) => Student(id: 's${index + 1}', name: 'Student ${index + 1}')),
  ),
  ClassRoom(
    id: 'c2',
    name: 'Grade 7B',
    teacherName: 'Mr. Smith',
    students: List.generate(25, (index) => Student(id: 's${index + 21}', name: 'Student ${index + 1}')),
  ),
  ClassRoom(
    id: 'c3',
    name: 'Grade 8C',
    teacherName: 'Ms. Davis',
    students: List.generate(30, (index) => Student(id: 's${index + 46}', name: 'Student ${index + 1}')),
  ),
  ClassRoom(
    id: 'c4',
    name: 'Grade 9A',
    teacherName: 'Mr. Wilson',
    students: List.generate(22, (index) => Student(id: 's${index + 76}', name: 'Student ${index + 1}')),
  ),
  ClassRoom(
    id: 'c5',
    name: 'Grade 10B',
    teacherName: 'Mrs. Taylor',
    students: List.generate(28, (index) => Student(id: 's${index + 98}', name: 'Student ${index + 1}')),
  ),
];

class AttendanceHistory {
  final DateTime date;
  final String classId;
  final List<String> presentStudentNames;
  final List<String> absentStudentNames;

  AttendanceHistory({
    required this.date,
    required this.classId,
    required this.presentStudentNames,
    required this.absentStudentNames,
  });

  int get presentCount => presentStudentNames.length;
  int get totalCount => presentStudentNames.length + absentStudentNames.length;
}

final List<AttendanceHistory> mockHistory = [
  AttendanceHistory(
    date: DateTime.now().subtract(const Duration(days: 1)),
    classId: 'c1',
    presentStudentNames: List.generate(18, (i) => 'Student ${i + 1}'),
    absentStudentNames: ['Student 19', 'Student 20'],
  ),
  AttendanceHistory(
    date: DateTime.now().subtract(const Duration(days: 1)),
    classId: 'c2',
    presentStudentNames: List.generate(22, (i) => 'Student ${i + 1}'),
    absentStudentNames: ['Student 23', 'Student 24', 'Student 25'],
  ),
  AttendanceHistory(
    date: DateTime.now().subtract(const Duration(days: 2)),
    classId: 'c1',
    presentStudentNames: List.generate(19, (i) => 'Student ${i + 1}'),
    absentStudentNames: ['Student 20'],
  ),
  AttendanceHistory(
    date: DateTime.now().subtract(const Duration(days: 3)),
    classId: 'c3',
    presentStudentNames: List.generate(28, (i) => 'Student ${i + 1}'),
    absentStudentNames: ['Student 29', 'Student 30'],
  ),
];

// Mock Credentials
const String mockEmail = 'admin@school.com';
const String mockPassword = 'password123';

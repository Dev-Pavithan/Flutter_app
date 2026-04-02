import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../mock_data.dart';
import '../main.dart';
import '../widgets/custom_app_bar.dart';

class AttendanceScreen extends StatefulWidget {
  final ClassRoom? classRoom;

  const AttendanceScreen({super.key, this.classRoom});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late ClassRoom currentClass;
  late List<Student> students;
  late List<Student> filteredStudents;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    currentClass = widget.classRoom ?? mockClasses.last;
    students = currentClass.students;
    filteredStudents = students;
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents(String query) {
    setState(() {
      filteredStudents = students.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void _saveAttendance() async {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text('Confirm Attendance'),
        content: Text('Marking ${students.where((s) => s.isPresent).length} students as present for ${currentClass.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess();
            },
            child: Text('Confirm', style: TextStyle(color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSuccess() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.checkCircle, color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Success!', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text('Attendance record has been saved successfully.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1E1B4B), // Deep navy matching the app gradient
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String todayDate = DateFormat('EEEE, MMMM dth').format(DateTime.now());
    // Adding 'th' suffix is tricky with DateFormat, let's just use manual string for now to match screenshot "Thursday, October 24th"
    String displayDate = "Thursday, October 24th"; 

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentClass.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 34, height: 1.1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildPeriodBadge('PERIOD 4'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$displayDate \u2022 ${students.length} Students',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterStudents,
                      decoration: const InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: Icon(LucideIcons.search, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? null : Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(LucideIcons.slidersHorizontal, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Summary Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryCard('Present Today', '22', '/ 24', isDark)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Class Average', '94.2%', '', isDark, isHighlight: true)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Student List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('STUDENT NAME', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
                  Text('STATUS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
                ],
              ),
            ),

            // Student List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredStudents.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return _buildStudentTile(student, isDark);
              },
            ),

            const SizedBox(height: 100), // Space for button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: ElevatedButton(
          onPressed: _saveAttendance,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: isDark ? AppTheme.darkAccent : AppTheme.lightAccent,
            foregroundColor: isDark ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.checkCircle2, size: 20),
              const SizedBox(width: 12),
              const Text('Save Attendance'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String mainValue, String subValue, bool isDark, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          if (isHighlight)
            Positioned(
              left: -10,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(mainValue, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: isHighlight ? (isDark ? AppTheme.darkAccent : AppTheme.lightAccent) : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary))),
                  if (subValue.isNotEmpty)
                    Text(' $subValue', style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white38 : Colors.black38)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodBadge(String text) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkPeriod : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('PERIOD', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70)),
          Text(text.replaceAll('PERIOD ', ''), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStudentTile(Student student, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? null : Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://i.pravatar.cc/150?u=${student.name}',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 48,
                height: 48,
                color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.1),
                child: Center(child: Text(student.name.substring(0, 1), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent))),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                const SizedBox(height: 2),
                Text('Roll No: #${(100 + students.indexOf(student)).toString()}', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
              ],
            ),
          ),
          Text(
            student.isPresent ? 'Present' : 'Absent',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
          ),
          const SizedBox(width: 8),
          Switch(
            value: student.isPresent,
            activeColor: Colors.white,
            activeTrackColor: isDark ? AppTheme.darkAccent : AppTheme.lightAccent,
            onChanged: (val) => setState(() => student.isPresent = val),
          ),
        ],
      ),
    );
  }
}

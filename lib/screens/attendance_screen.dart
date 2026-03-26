import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../mock_data.dart';

class AttendanceScreen extends StatefulWidget {
  final ClassRoom classRoom;

  const AttendanceScreen({super.key, required this.classRoom});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late List<Student> students;
  late List<Student> filteredStudents;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    students = widget.classRoom.students;
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

  void _batchAction(bool present) {
    setState(() {
      for (var s in filteredStudents) {
        s.isPresent = present;
      }
    });
  }

  void _saveAttendance() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Confirm Attendance'),
        content: Text('Marking ${students.where((s) => s.isPresent).length} students as present for ${widget.classRoom.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess();
            },
            child: const Text('Confirm', style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: const [Icon(LucideIcons.checkCircle, color: Colors.white), SizedBox(width: 12), Text('Attendance Saved Successfully!')]),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classRoom.name, style: AppTheme.darkTheme.textTheme.headlineMedium),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Header Summary
          FadeTransition(
            opacity: _animationController,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(todayDate, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Mark your student attendance', style: GoogleFonts.inter(fontSize: 14, color: Colors.white54)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.users, color: AppTheme.primaryColor, size: 16),
                            const SizedBox(width: 8),
                            Text(students.length.toString(), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Search & Batch Actions
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterStudents,
                          decoration: InputDecoration(
                            hintText: 'Search student...',
                            hintStyle: const TextStyle(color: Colors.white24),
                            prefixIcon: const Icon(LucideIcons.search, size: 18, color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.04),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      PopupMenuButton<bool>(
                        onSelected: _batchAction,
                        color: AppTheme.surfaceColor,
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: true, child: Text('Mark All Present')),
                          const PopupMenuItem(value: false, child: Text('Mark All Absent')),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                          child: const Icon(LucideIcons.moreVertical, color: Colors.white60),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(height: 1, color: Colors.white10),
          
          // Student List
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              padding: const EdgeInsets.only(bottom: 100),
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return _buildStudentTile(student, index);
              },
            ),
          ),
        ],
      ),
      
      // Floating Bottom Bar
      bottomSheet: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${students.where((s) => s.isPresent).length} Present', style: const TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${students.where((s) => !s.isPresent).length} Absent', style: const TextStyle(color: AppTheme.errorColor, fontSize: 13)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _saveAttendance,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTile(Student student, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: student.isPresent ? Colors.transparent : AppTheme.errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(student.name[0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        ),
        title: Text(student.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
        subtitle: Text(student.isPresent ? 'Present' : 'Absent', style: TextStyle(color: student.isPresent ? AppTheme.successColor : AppTheme.errorColor, fontSize: 12)),
        trailing: Switch(
          value: student.isPresent,
          activeColor: AppTheme.successColor,
          inactiveThumbColor: AppTheme.errorColor,
          inactiveTrackColor: AppTheme.errorColor.withOpacity(0.2),
          onChanged: (val) => setState(() => student.isPresent = val),
        ),
      ),
    );
  }
}

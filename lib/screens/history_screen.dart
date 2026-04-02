import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../mock_data.dart';
import '../main.dart';
import '../widgets/custom_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

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
                  Text('Attendance History', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text('Review and manage past student\nattendance records.', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),

            // Date Selection Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? null : Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Date', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                        Text('OCTOBER 2023', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateItem('MON', '23', false, isDark),
                        _buildDateItem('TUE', '24', true, isDark),
                        _buildDateItem('WED', '25', false, isDark),
                        _buildDateItem('THU', '26', false, isDark),
                        _buildDateItem('FRI', '27', false, isDark),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.calendar, size: 18, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                          const SizedBox(width: 12),
                          Text('Open Full Calendar', style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Daily Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? null : Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Summary', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: 0.9,
                                strokeWidth: 10,
                                backgroundColor: isDark ? Colors.white12 : Colors.grey.shade100,
                                color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text('90%', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('95% Present', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                              Text('Target: 98%', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildCountBox('38', 'PRESENT', isDark)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCountBox('02', 'ABSENT', isDark, isAlert: true)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Student Records List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Student\nRecords',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search name...',
                        prefixIcon: Icon(LucideIcons.search, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Student Records List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4, // Example count from screenshot
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final List<Map<String, dynamic>> students = [
                  {'name': 'Alex Rivera', 'id': 'ST-88219', 'status': 'PRESENT'},
                  {'name': 'Maya Jenkins', 'id': 'ST-88402', 'status': 'ABSENT'},
                  {'name': 'Elena Petrova', 'id': 'ST-88115', 'status': 'PRESENT'},
                  {'name': 'Marcus Wong', 'id': 'ST-88901', 'status': 'LATE'},
                ];
                final student = students[index];
                return _buildRecordTile(student, isDark);
              },
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(String day, String date, bool isSelected, bool isDark) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected 
          ? (isDark ? AppTheme.darkAccent : AppTheme.lightAccent) 
          : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected ? [BoxShadow(color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
      ),
      child: Column(
        children: [
          Text(day, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.black87 : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary))),
          const SizedBox(height: 8),
          Text(date, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary))),
        ],
      ),
    );
  }

  Widget _buildCountBox(String count, String label, bool isDark, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: isAlert ? (isDark ? Color(0xFFEF4444) : Colors.red) : (isDark ? AppTheme.darkAccent : AppTheme.lightAccent))),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildRecordTile(Map<String, dynamic> student, bool isDark) {
    Color statusColor;
    if (student['status'] == 'PRESENT') {
      statusColor = isDark ? Color(0xFF10B981).withOpacity(0.2) : Colors.green.shade100;
    } else if (student['status'] == 'ABSENT') {
      statusColor = isDark ? Color(0xFFEF4444).withOpacity(0.2) : Colors.red.shade100;
    } else {
      statusColor = isDark ? Color(0xFF3F4FA7).withOpacity(0.2) : Colors.indigo.shade100;
    }

    Color textStatusColor;
    if (student['status'] == 'PRESENT') {
      textStatusColor = isDark ? Color(0xFF10B981) : Colors.green.shade700;
    } else if (student['status'] == 'ABSENT') {
      textStatusColor = isDark ? Color(0xFFEF4444) : Colors.red.shade700;
    } else {
      textStatusColor = isDark ? Color(0xFF7C8DFF) : Colors.indigo.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://i.pravatar.cc/150?u=${student['name']}',
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 54,
                height: 54,
                color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.1),
                child: Center(child: Text(student['name'].substring(0, 1), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent))),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                const SizedBox(height: 4),
                Text('ID: #${student['id']}', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              student['status'],
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: textStatusColor),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(LucideIcons.moreVertical, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary, size: 20),
          ),
        ],
      ),
    );
  }
}

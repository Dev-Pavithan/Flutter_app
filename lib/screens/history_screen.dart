import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../mock_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));
  late List<AttendanceHistory> filteredHistory;

  @override
  void initState() {
    super.initState();
    _filterByDate(selectedDate);
  }

  void _filterByDate(DateTime date) {
    setState(() {
      selectedDate = date;
      filteredHistory = mockHistory.where((h) => 
        h.date.year == date.year && 
        h.date.month == date.month && 
        h.date.day == date.day
      ).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      _filterByDate(picked);
    }
  }

  void _showHistoryDetails(AttendanceHistory history, ClassRoom classObj) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(classObj.name, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(DateFormat('EEE, d MMM yyyy').format(history.date), style: GoogleFonts.inter(color: Colors.white38)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: Text('${((history.presentCount / history.totalCount) * 100).toInt()}%', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: AppTheme.primaryColor,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: Colors.white38,
                      tabs: [
                        Tab(text: 'Present (${history.presentCount})'),
                        Tab(text: 'Absent (${history.absentStudentNames.length})'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildStudentList(history.presentStudentNames, AppTheme.successColor, LucideIcons.userCheck),
                          _buildStudentList(history.absentStudentNames, AppTheme.errorColor, LucideIcons.userMinus),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList(List<String> names, Color color, IconData icon) {
    if (names.isEmpty) {
      return Center(child: Text('No students listed', style: TextStyle(color: Colors.white24)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: names.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
      itemBuilder: (context, index) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, size: 16, color: color),
        ),
        title: Text(names[index], style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEE, d MMM yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('History', style: AppTheme.darkTheme.textTheme.headlineMedium),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Date Selector Strip
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendar, color: AppTheme.primaryColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Viewing Date', style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
                        Text(formattedDate, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronDown, color: AppTheme.primaryColor, size: 20),
                ],
              ),
            ),
          ),
          
          const Divider(height: 1, color: Colors.white10),
          
          Expanded(
            child: filteredHistory.isEmpty 
              ? _buildEmptyState()
              : ListView.separated(
                  itemCount: filteredHistory.length,
                  padding: const EdgeInsets.all(24),
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final historyItem = filteredHistory[index];
                    final classObj = mockClasses.firstWhere((c) => c.id == historyItem.classId);
                    return InkWell(
                      onTap: () => _showHistoryDetails(historyItem, classObj),
                      borderRadius: BorderRadius.circular(24),
                      child: _buildHistoryCard(historyItem, classObj),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.fileSearch, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text('No records found for this date', style: GoogleFonts.inter(color: Colors.white38, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(AttendanceHistory item, ClassRoom classObj) {
    double percentage = (item.presentCount / item.totalCount) * 100;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.clock, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(classObj.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(classObj.teacherName, style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${percentage.toInt()}%', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Attendance', style: TextStyle(fontSize: 10, color: Colors.white38)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildCompactBadge(LucideIcons.userCheck, '${item.presentCount} Present', AppTheme.successColor),
              const SizedBox(width: 12),
              _buildCompactBadge(LucideIcons.userMinus, '${item.absentStudentNames.length} Absent', AppTheme.errorColor),
            ],
          ),
          const SizedBox(height: 12),
          Text('Tap to view student details', style: TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCompactBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
        ],
      ),
    );
  }
}

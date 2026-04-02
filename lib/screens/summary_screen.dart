import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_theme.dart';
import '../widgets/custom_app_bar.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

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
                  Text('Performance Summary', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text('Comprehensive overview of your classroom\nattendance analytics.', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),

            // Top Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Attendance Rate',
                      '94.2%',
                      '+2.1%',
                      LucideIcons.trendingUp,
                      isDark,
                      AppTheme.darkAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Students',
                      '42',
                      'Stable',
                      LucideIcons.users,
                      isDark,
                      const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Weekly Trend Chart Placeholder (Visual Component)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Weekly Trend', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Last 7 Days', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildChartBar('Mon', 0.8, isDark),
                          _buildChartBar('Tue', 0.95, isDark, isHighlighted: true),
                          _buildChartBar('Wed', 0.7, isDark),
                          _buildChartBar('Thu', 0.85, isDark),
                          _buildChartBar('Fri', 0.9, isDark),
                          _buildChartBar('Sat', 0.4, isDark),
                          _buildChartBar('Sun', 0.3, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Distribution Card
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
                    Text('Attendance Status Distribution', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
                    const SizedBox(height: 20),
                    _buildDistributionRow('Present', '88%', AppTheme.darkAccent, isDark),
                    const SizedBox(height: 12),
                    _buildDistributionRow('Absent', '8%', Colors.redAccent, isDark),
                    const SizedBox(height: 12),
                    _buildDistributionRow('Late', '4%', Colors.amber, isDark),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            
            // Top Performers Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Top Performers', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
            ),
            
            const SizedBox(height: 12),
            
            // List of top performers
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final names = ['Alex Rivera', 'Elena Petrova', 'Maya Jenkins'];
                final rates = ['100%', '98%', '97%'];
                return _buildPerformerTile(names[index], rates[index], isDark);
              },
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String change, IconData icon, bool isDark, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
              const Spacer(),
              Text(change, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.darkSuccess)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double percent, bool isDark, {bool isHighlighted = false}) {
    Color barColor = isHighlighted 
        ? (isDark ? AppTheme.darkAccent : AppTheme.lightAccent)
        : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 100 * percent,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isHighlighted ? [BoxShadow(color: barColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(day, style: GoogleFonts.inter(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
      ],
    );
  }

  Widget _buildDistributionRow(String label, String value, Color color, bool isDark) {
    double percent = double.parse(value.replaceAll('%', '')) / 100.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
            Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformerTile(String name, String rate, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? null : Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$name'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.darkSuccess.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(rate, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkSuccess)),
          ),
        ],
      ),
    );
  }
}

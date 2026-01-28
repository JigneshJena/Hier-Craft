import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app/themes/app_colors.dart';
import '../../core/services/history_service.dart';
import '../widgets/common_background.dart';
import '../widgets/common_card.dart';

class InterviewHistoryView extends StatelessWidget {
  const InterviewHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final historyService = Get.find<HistoryService>();
    final sessions = historyService.getSessions();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: sessions.isEmpty 
                  ? _buildEmptyState()
                  : _buildSessionsList(sessions, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryStart.withOpacity(0.1),
              padding: EdgeInsets.all(12.w),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            "Interview History",
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<Map<String, dynamic>> sessions, bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final bool isComplete = session['isComplete'] ?? false;
        final double score = (session['score'] as num?)?.toDouble() ?? 0.0;
        final DateTime date = DateTime.parse(session['timestamp']);
        final String formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: CommonCard(
            padding: EdgeInsets.all(20.w),
            onTap: () => _showSessionDetails(session),
            child: Row(
              children: [
                _buildStatusIndicator(isComplete, score),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session['domain'] ?? 'General',
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isComplete)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      "${(score * 10).toInt()}%",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        color: AppColors.primaryStart,
                      ),
                    ),
                  ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.withOpacity(0.5)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(bool isComplete, double score) {
    Color color = Colors.orange;
    IconData icon = Icons.timer_rounded;

    if (isComplete) {
      if (score >= 7.0) {
        color = AppColors.success;
        icon = Icons.check_circle_rounded;
      } else {
        color = AppColors.primaryStart;
        icon = Icons.assignment_turned_in_rounded;
      }
    }

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24.sp),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80.sp, color: Colors.grey.withOpacity(0.2)),
          SizedBox(height: 24.h),
          Text(
            "No sessions yet",
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Start an AI interview to track your progress!",
            style: GoogleFonts.outfit(color: Colors.grey.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  void _showSessionDetails(Map<String, dynamic> session) {
    final List<dynamic> conversation = session['conversation'] ?? [];
    
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Interview Details",
                  style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            SizedBox(height: 16.h),
            Text("${session['domain']} - ${session['level']}", 
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.primaryStart)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: conversation.length,
                itemBuilder: (context, index) {
                  final message = conversation[index];
                  final isQuestion = message['type'] == 'question';
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isQuestion 
                        ? AppColors.primaryStart.withOpacity(0.05) 
                        : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isQuestion ? "AI Question" : "Your Answer",
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: isQuestion ? AppColors.primaryStart : Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(message['text'] ?? ''),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/results_controller.dart';
import '../../app/routes/app_routes.dart';

class ResultsView extends StatelessWidget {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResultsController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Interview Results"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildScoreCard(context, controller),
            SizedBox(height: 30.h),
            _buildCategoryBreakdown(context, controller),
            SizedBox(height: 30.h),
            _buildActionButtons(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, ResultsController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.colorScheme.primary,
            Get.theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            controller.performanceMessage,
            style: Get.theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 24.sp),
          ),
          SizedBox(height: 20.h),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150.h,
                width: 150.w,
                child: CircularProgressIndicator(
                  value: controller.percentage / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    "${controller.totalScore}",
                    style: Get.theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 40.sp),
                  ),
                  Text(
                    "out of ${controller.maxScore}",
                    style: Get.theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            "Overall Performance in ${controller.domain}",
            style: Get.theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, ResultsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Question Breakdown",
          style: Get.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 15.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.results.length,
          itemBuilder: (context, index) {
            final result = controller.results[index];
            final score = result['score'] as int;
            
            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: score >= 7 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  child: Text("$score", style: TextStyle(color: score >= 7 ? Colors.green : Colors.orange)),
                ),
                title: Text(
                  result['question'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Get.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  result['feedback'],
                  style: Get.theme.textTheme.bodySmall,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Your Answer:", style: Get.theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text(result['answer'], style: Get.theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(ResultsController controller) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Get.offAllNamed(AppRoutes.domain),
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 55.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          ),
          child: const Text("Try Different Domain"),
        ),
        SizedBox(height: 12.h),
        OutlinedButton(
          onPressed: () {
             Get.back(); // Returns to InterviewView which will show difficulty selection
          },
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 55.h),
            side: BorderSide(color: Get.theme.colorScheme.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          ),
          child: const Text("Retake Interview"),
        ),
      ],
    );
  }
}

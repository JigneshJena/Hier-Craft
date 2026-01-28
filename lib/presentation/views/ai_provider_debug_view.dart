import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/ai_config_service.dart';
import '../../core/services/ai_api_service.dart';
import '../../app/themes/app_colors.dart';

/// Debug view to test AI providers
class AiProviderDebugView extends StatefulWidget {
  const AiProviderDebugView({super.key});

  @override
  State<AiProviderDebugView> createState() => _AiProviderDebugViewState();
}

class _AiProviderDebugViewState extends State<AiProviderDebugView> {
  final aiConfig = Get.find<AiConfigService>();
  final aiService = Get.find<AiApiService>();
  
  String? testResult;
  bool isTestingtext = false;

  Future<void> testCurrentProvider() async {
    setState(() {
      isTestingtext = true;
      testResult = null;
    });

    try {
      final questions = await aiService.generateQuestions(
        domain: 'Flutter Development',
        difficulty: 'Intermediate',
        apiKey: aiConfig.apiKey.value,
        provider: aiConfig.provider.value,
        model: aiConfig.model.value,
        count: 1,
      );

      setState(() {
        if (questions.isNotEmpty) {
          testResult = '✅ SUCCESS!\n\nGenerated question:\n"${questions.first.text}"';
        } else {
          testResult = '❌ FAILED: No questions returned.\nCheck logs for details.';
        }
        isTestingtext = false;
      });
    } catch (e) {
      setState(() {
        testResult = '❌ ERROR: $e';
        isTestingtext = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Provider Diagnostics', style: GoogleFonts.outfit()),
        backgroundColor: AppColors.primaryStart,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              '📡 Current Configuration',
              [
                Obx(() => _buildInfoRow('Provider', aiConfig.provider.value)),
                Obx(() => _buildInfoRow('Model', aiConfig.model.value)),
                Obx(() => _buildInfoRow(
                  'API Key',
                  aiConfig.apiKey.value.isEmpty
                      ? 'NOT SET'
                      : '${aiConfig.apiKey.value.substring(0, 4)}...${aiConfig.apiKey.value.substring(aiConfig.apiKey.value.length - 4)}',
                )),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            _buildInfoCard(
              '🔍 Provider Details',
              [
                Obx(() {
                  final provider = aiConfig.provider.value;
                  if (provider == 'gemini') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Type', 'Google Gemini'),
                        _buildInfoRow('Default Model', 'gemini-1.5-flash'),
                        _buildInfoRow('API Base', 'generativelanguage.googleapis.com'),
                      ],
                    );
                  } else if (provider == 'groq') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Type', 'Groq (OpenAI Compatible)'),
                        _buildInfoRow('Default Model', 'llama-3.3-70b-versatile'),
                        _buildInfoRow('API Base', 'api.groq.com'),
                        SizedBox(height: 12.h),
                        Text(
                          '⚠️ Groq Checklist:',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.accentAmber),
                        ),
                        SizedBox(height: 8.h),
                        _buildCheckItem('API key starts with "gsk_"'),
                        _buildCheckItem('Model name is correct'),
                        _buildCheckItem('Provider name is lowercase "groq"'),
                      ],
                    );
                  } else {
                    return Text('Unknown provider: $provider');
                  }
                }),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isTestingtext ? null : testCurrentProvider,
                icon: isTestingtext
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(
                  isTestingtext ? 'Testing...' : 'Test Current Provider',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryStart,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            
            if (testResult != null) ...[
              SizedBox(height: 24.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: testResult!.startsWith('✅')
                      ? AppColors.accentEmerald.withOpacity(0.1)
                      : AppColors.accentRose.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: testResult!.startsWith('✅')
                        ? AppColors.accentEmerald
                        : AppColors.accentRose,
                  ),
                ),
                child: Text(
                  testResult!,
                  style: GoogleFonts.robotoMono(fontSize: 12.sp),
                ),
              ),
            ],
            
            SizedBox(height: 24.h),
            
            _buildInfoCard(
              '💡 Troubleshooting Tips',
              [
                _buildTipItem('1. Check Flutter logs (Run tab) for detailed error messages'),
                _buildTipItem('2. Verify your Firestore "aiproviders" collection'),
                _buildTipItem('3. Make sure only ONE provider has isActive=true'),
                _buildTipItem('4. Test API key directly on Groq/Gemini playground'),
                _buildTipItem('5. Check your internet connection'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.snackbar('Copied', '$label copied to clipboard');
              },
              child: Text(
                value,
                style: GoogleFonts.robotoMono(fontSize: 13.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16.sp, color: AppColors.accentEmerald),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey[700]),
      ),
    );
  }
}

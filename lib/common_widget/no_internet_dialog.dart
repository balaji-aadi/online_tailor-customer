
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';
import 'package:khyate_tailor_app/constants/text_styles.dart';

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: ColorConstants.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Icon(Icons.signal_wifi_off,
                    size: 50, color: ColorConstants.lightGold),
                SizedBox(height: 20.h),
                Text(
                  'No Internet Connection',
                  style: AppTextStyles.heading2,
                ),
                SizedBox(height: 10.h),
                Text(
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/responsive_utils.dart';

/// Responsive container that adapts to different screen sizes
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      width: width?.w,
      height: height?.h,
      constraints: constraints,
      alignment: alignment,
      child: child,
    );
  }
}

/// Responsive text that adapts to screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const ResponsiveText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: fontSize?.sp,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

/// Responsive button with consistent sizing
class ResponsiveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final bool isLoading;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.width,
    this.borderRadius,
    this.padding,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height?.h ?? 48.h,
      width: width?.w,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius?.r ?? 12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Responsive card with consistent styling
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? EdgeInsets.all(16.w),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius?.r ?? 12.r),
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius?.r ?? 12.r),
        child: card,
      );
    }

    return card;
  }
}

/// Responsive scaffold with safe area
class ResponsiveScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool useSafeArea;
  final EdgeInsetsGeometry? padding;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.useSafeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = body;

    if (padding != null) {
      bodyWidget = Padding(padding: padding!, child: bodyWidget);
    }

    if (useSafeArea) {
      bodyWidget = SafeArea(child: bodyWidget);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          if (appBar != null) appBar!,
          Expanded(child: bodyWidget),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    // Adaptive cross axis count based on screen width
    final adaptiveCrossAxisCount = ResponsiveUtils.adaptive(
      small: crossAxisCount,
      medium: crossAxisCount,
      large: crossAxisCount + 1,
      tablet: crossAxisCount + 2,
    );

    return GridView.count(
      crossAxisCount: adaptiveCrossAxisCount,
      mainAxisSpacing: mainAxisSpacing?.h ?? 16.h,
      crossAxisSpacing: crossAxisSpacing?.w ?? 16.w,
      childAspectRatio: childAspectRatio ?? 1.0,
      padding: padding ?? EdgeInsets.all(16.w),
      physics: physics ?? const BouncingScrollPhysics(),
      children: children,
    );
  }
}

/// Responsive list view
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double? itemSpacing;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.itemSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? EdgeInsets.all(16.w),
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: itemSpacing?.h ?? 12.h),
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive app bar
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double? elevation;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}

import 'dart:ui'; // مهم للـ ImageFilter
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:venom_config/venom_config.dart';

// 1. هذا هو الـ Layout الرئيسي الذي ستستخدمه في تطبيقك
class VenomScaffold extends StatefulWidget {
  final Widget body; // محتوى الصفحة (الإعدادات)
  final String title;

  const VenomScaffold({super.key, required this.body, this.title = "Settings"});

  @override
  State<VenomScaffold> createState() => _VenomScaffoldState();
}

class _VenomScaffoldState extends State<VenomScaffold> {
  bool _isCinematicBlurActive = false;

  // Default colors
  Color _backgroundColor = const Color.fromARGB(100, 0, 0, 0);
  Color _textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadConfig(VenomConfig().getAll());
    VenomConfig().onConfigChanged.listen((config) {
      _loadConfig(config);
    });
  }

  void _loadConfig(Map<String, dynamic> config) {
    if (mounted) {
      final bgHex = config['system.background_color'] as String?;
      final textHex = config['system.text_color'] as String?;

      setState(() {
        if (bgHex != null) _backgroundColor = _parseColor(bgHex);
        if (textHex != null) _textColor = _parseColor(textHex);
      });
    }
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color.fromARGB(100, 0, 0, 0); // Default fallback
  }

  void _setBlur(bool active) {
    if (_isCinematicBlurActive != active) {
      setState(() {
        _isCinematicBlurActive = active;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get current theme
    final currentTheme = Theme.of(context);

    // 2. Create a dynamic theme based on config
    // 2. Create a comprehensive dynamic theme based on config
    final dynamicTheme = currentTheme.copyWith(
      // 1. Base Text & Icons
      iconTheme: currentTheme.iconTheme.copyWith(color: _textColor),
      textTheme: currentTheme.textTheme.apply(
        bodyColor: _textColor,
        displayColor: _textColor,
        decorationColor: _textColor,
      ),

      // 2. Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: _textColor, // Text & Icon color
        ).merge(currentTheme.elevatedButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textColor,
        ).merge(currentTheme.outlinedButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _textColor,
        ).merge(currentTheme.textButtonTheme.style),
      ),

      // 3. Inputs
      inputDecorationTheme: currentTheme.inputDecorationTheme.copyWith(
        labelStyle: TextStyle(color: _textColor),
        hintStyle: TextStyle(color: _textColor.withOpacity(0.6)),
        prefixStyle: TextStyle(color: _textColor),
        suffixStyle: TextStyle(color: _textColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _textColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _textColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // 4. List Tiles
      listTileTheme: currentTheme.listTileTheme.copyWith(
        textColor: _textColor,
        iconColor: _textColor,
      ),

      // 5. AppBar
      appBarTheme: currentTheme.appBarTheme.copyWith(
        foregroundColor: _textColor,
        titleTextStyle: TextStyle(
          color: _textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: _textColor),
      ),

      // 6. TabBar
      tabBarTheme: currentTheme.tabBarTheme.copyWith(
        labelColor: _textColor,
        unselectedLabelColor: _textColor.withOpacity(0.6),
      ),

      // 7. Dialogs & Sheets
      dialogTheme: currentTheme.dialogTheme.copyWith(
        titleTextStyle: TextStyle(
          color: _textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: _textColor.withOpacity(0.8)),
      ),
      bottomSheetTheme: currentTheme.bottomSheetTheme.copyWith(
        // Background color usually handled by container, but could be set here
      ),

      // 8. Expansion Tile
      expansionTileTheme: currentTheme.expansionTileTheme.copyWith(
        textColor: _textColor,
        iconColor: _textColor,
        collapsedTextColor: _textColor,
        collapsedIconColor: _textColor,
      ),

      // 9. Menus
      popupMenuTheme: currentTheme.popupMenuTheme.copyWith(
        textStyle: TextStyle(color: _textColor),
        labelTextStyle: WidgetStateProperty.all(TextStyle(color: _textColor)),
      ),

      // 10. Chips
      chipTheme: currentTheme.chipTheme.copyWith(
        labelStyle: TextStyle(color: _textColor),
        secondaryLabelStyle: TextStyle(color: _textColor),
        deleteIconColor: _textColor,
        checkmarkColor: _textColor,
      ),

      // 11. Data Table
      dataTableTheme: currentTheme.dataTableTheme.copyWith(
        headingTextStyle: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: TextStyle(color: _textColor),
      ),

      // 12. Navigation
      bottomNavigationBarTheme: currentTheme.bottomNavigationBarTheme.copyWith(
        selectedItemColor: _textColor,
        unselectedItemColor: _textColor.withOpacity(0.6),
        selectedLabelStyle: TextStyle(color: _textColor),
        unselectedLabelStyle: TextStyle(color: _textColor.withOpacity(0.6)),
      ),
      navigationRailTheme: currentTheme.navigationRailTheme.copyWith(
        selectedLabelTextStyle: TextStyle(color: _textColor),
        unselectedLabelTextStyle: TextStyle(color: _textColor.withOpacity(0.6)),
        selectedIconTheme: IconThemeData(color: _textColor),
        unselectedIconTheme: IconThemeData(color: _textColor.withOpacity(0.6)),
      ),

      // 13. Feedback
      snackBarTheme: currentTheme.snackBarTheme.copyWith(
        contentTextStyle: TextStyle(
          color: _textColor,
        ), // Usually white on dark, but customizable
        actionTextColor: _textColor, // Or a contrasting color
      ),
      tooltipTheme: currentTheme.tooltipTheme.copyWith(
        textStyle: TextStyle(
          color: Colors.white,
        ), // Tooltips usually have dark bg
      ),

      // 14. Cards & Dividers
      cardTheme: currentTheme.cardTheme.copyWith(
        // Text color usually inherited from bodyText, but good to have
      ),
      dividerTheme: currentTheme.dividerTheme.copyWith(
        color: _textColor.withOpacity(0.1),
      ),

      // 15. Selection Controls
      checkboxTheme: currentTheme.checkboxTheme.copyWith(
        checkColor: WidgetStateProperty.all(
          _textColor,
        ), // Color of the check mark
        // fillColor: WidgetStateProperty.all(_textColor), // Usually primary color
      ),
      radioTheme: currentTheme.radioTheme.copyWith(
        // fillColor: WidgetStateProperty.all(_textColor),
      ),
      switchTheme: currentTheme.switchTheme.copyWith(
        // thumbColor: WidgetStateProperty.all(_textColor),
      ),
    );

    return Theme(
      data: dynamicTheme,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: Stack(
          children: [
            // --- الطبقة 1: محتوى التطبيق ---
            // نستخدم TweenAnimationBuilder لتحريك قيمة الـ Blur بنعومة
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: _isCinematicBlurActive
                    ? 10.0
                    : 0.0, // قوة البلور (10 قوية وجميلة)
              ),
              duration: const Duration(milliseconds: 300), // سرعة الأنيميشن
              curve: Curves.easeOutCubic, // منحنى حركة ناعم
              builder: (context, blurValue, child) {
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: blurValue,
                    sigmaY: blurValue,
                  ),
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 40), // نترك مساحة للـ Appbar
                child: widget.body,
              ),
            ),

            // --- الطبقة 2: شريط العنوان (فوق الكل) ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: VenomAppbar(
                title: widget.title,
                textColor: _textColor,
                // تمرير دالة للتحكم في البلور عند لمس الأزرار
                onHoverEnter: () => _setBlur(true),
                onHoverExit: () => _setBlur(false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. شريط العنوان المعدل (يرسل إشارات الهوفر)
class VenomAppbar extends StatelessWidget {
  final String title;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;
  final Color textColor;

  const VenomAppbar({
    super.key,
    required this.title,
    required this.onHoverEnter,
    required this.onHoverExit,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) async {
        await windowManager.startDragging();
      },
      child: Container(
        height: 40,
        alignment: Alignment.centerRight,
        // color: const Color.fromARGB(100, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),

            // مجموعة الأزرار
            // نستخدم MouseRegion واحد كبير حول الأزرار الثلاثة
            // لضمان استمرار البلور عند التنقل بين زر وآخر
            MouseRegion(
              onEnter: (_) => onHoverEnter(),
              onExit: (_) => onHoverExit(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VenomWindowButton(
                    color: const Color(0xFFFFBD2E),
                    icon: Icons.remove,
                    onPressed: () => windowManager.minimize(),
                  ),

                  const SizedBox(width: 8),
                  VenomWindowButton(
                    color: const Color(0xFF28C840),
                    icon: Icons.check_box_outline_blank_rounded,
                    onPressed: () async {
                      if (await windowManager.isMaximized()) {
                        windowManager.unmaximize();
                      } else {
                        windowManager.maximize();
                      }
                    },
                  ),
                  const SizedBox(width: 8),

                  VenomWindowButton(
                    color: const Color(0xFFFF5F57),
                    icon: Icons.close,
                    onPressed: () => windowManager.close(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. زر النافذة (نفس الذي صممناه سابقاً مع تحسينات طفيفة)
class VenomWindowButton extends StatefulWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const VenomWindowButton({
    Key? key,
    required this.color,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<VenomWindowButton> createState() => _VenomWindowButtonState();
}

class _VenomWindowButtonState extends State<VenomWindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.8),
                      blurRadius: 10, // زيادة التوهج قليلاً
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isHovered ? 1.0 : 0.0,
              child: Icon(
                widget.icon,
                size: 10,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

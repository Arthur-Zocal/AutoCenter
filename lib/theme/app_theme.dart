import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const surfaceDeep = Color(0xFF0A0A0A);
  static const surfaceElevated = Color(0xFF141414);
  static const surfaceOverlay = Color(0xFF1E1E1E);
  static const borderSubtle = Color(0xFF2A2A2A);
  static const borderEmphasis = Color(0xFF3A3A3A);

  static const accentPrimary = Color(0xFFE03E3E);
  static const accentGlow = Color(0xFFFF6B35);
  static const accentPress = Color(0xFFB71C1C);

  static const textPrimary = Color(0xFFF5F5F0);
  static const textMuted = Color(0xFF8A8A8A);
  static const textDim = Color(0xFF5A5A5A);
  static const textOnAccent = Color(0xFFFFFFFF);

  static const success = Color(0xFF2E7D32);
  static const successBg = Color(0xFF1B5E20);
  static const warning = Color(0xFFF57F17);
  static const warningBg = Color(0xFFFF6F00);
  static const error = Color(0xFFC62828);
  static const errorBg = Color(0xFFB71C1C);

  static const overlayScrim = Color(0xCC000000);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const none = 0.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

class AppBorder {
  static const none = BorderSide.none;
  static const hairline = BorderSide(color: AppColors.borderSubtle, width: 0.5);
  static const thin = BorderSide(color: AppColors.borderSubtle, width: 1.0);
  static const medium = BorderSide(color: AppColors.borderEmphasis, width: 1.5);
  static const accent = BorderSide(color: AppColors.accentPrimary, width: 1.0);
  static const accentGlow = BorderSide(color: AppColors.accentGlow, width: 2.0);
}

class AppShadows {
  static const none = [];
  static const card = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  static const modal = [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
  static const glow = [
    BoxShadow(
      color: Color(0x33E03E3E),
      blurRadius: 16,
      offset: Offset(0, 0),
    ),
  ];
}

class AppTextStyles {
  static TextStyle _display({
    required FontWeight fontWeight,
    required double fontSize,
    required double height,
    required double letterSpacing,
    required Color color,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontWeight: fontWeight,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle _ui({
    required FontWeight fontWeight,
    required double fontSize,
    required double height,
    required double letterSpacing,
    required Color color,
  }) =>
      GoogleFonts.ibmPlexSans(
        fontWeight: fontWeight,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle _mono({
    required FontWeight fontWeight,
    required double fontSize,
    required double height,
    required double letterSpacing,
    required Color color,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontWeight: fontWeight,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle get displayLarge => _display(
    fontWeight: FontWeight.w700,
    fontSize: 36,
    height: 1.1,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => _display(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.15,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => _display(
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 1.2,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineLarge => _display(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => _display(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => _display(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleLarge => _ui(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => _ui(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => _ui(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => _ui(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => _ui(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => _ui(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0.3,
    color: AppColors.textMuted,
  );

  static TextStyle get labelLarge => _ui(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textMuted,
  );

  static TextStyle get labelMedium => _ui(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textDim,
  );

  static TextStyle get labelSmall => _ui(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textDim,
  );

  static TextStyle get monoLarge => _mono(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get monoMedium => _mono(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get monoSmall => _mono(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textMuted,
  );

  static TextStyle get buttonLarge => _display(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.0,
    letterSpacing: 0.5,
    color: AppColors.textOnAccent,
  );

  static TextStyle get buttonMedium => _display(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.0,
    letterSpacing: 0.5,
    color: AppColors.textOnAccent,
  );

  static TextStyle get caption => _ui(
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.textDim,
  );
}

class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accentPrimary,
      secondary: AppColors.accentGlow,
      surface: AppColors.surfaceElevated,
      surfaceContainerHighest: AppColors.surfaceOverlay,
      outline: AppColors.borderSubtle,
      outlineVariant: AppColors.borderEmphasis,
      error: AppColors.error,
      onPrimary: AppColors.textOnAccent,
      onSecondary: AppColors.textOnAccent,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textOnAccent,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceDeep,
      canvasColor: AppColors.surfaceElevated,
      fontFamily: 'IBMPlexSans',
      shadowColor: Colors.black,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceElevated,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
        toolbarHeight: 56,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: AppBorder.thin,
        ),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: AppColors.textOnAccent,
          disabledBackgroundColor: AppColors.borderSubtle,
          disabledForegroundColor: AppColors.textDim,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.none),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(double.infinity, 52),
          textStyle: AppTextStyles.buttonLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.accentPress.withValues(alpha: 0.3);
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.accentGlow.withValues(alpha: 0.15);
              }
              if (states.contains(WidgetState.focused)) {
                return AppColors.accentGlow.withValues(alpha: 0.15);
              }
              return null;
            },
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.surfaceOverlay,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.borderSubtle,
          disabledForegroundColor: AppColors.textDim,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: AppBorder.thin,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(double.infinity, 52),
          textStyle: AppTextStyles.buttonMedium,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.borderEmphasis;
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.borderEmphasis.withValues(alpha: 0.5);
              }
              return null;
            },
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textDim,
          side: AppBorder.thin,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(double.infinity, 52),
          textStyle: AppTextStyles.buttonMedium,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.borderEmphasis;
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.borderEmphasis.withValues(alpha: 0.5);
              }
              return null;
            },
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          disabledForegroundColor: AppColors.textDim,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(0, 44),
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: AppColors.accentPrimary,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.accentPrimary.withValues(alpha: 0.15);
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.accentPrimary.withValues(alpha: 0.08);
              }
              return null;
            },
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.borderEmphasis;
              }
              if (states.contains(WidgetState.hovered)) {
                return AppColors.borderEmphasis.withValues(alpha: 0.5);
              }
              return null;
            },
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceOverlay,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textDim),
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim),
        floatingLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.accentPrimary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        prefixIconColor: AppColors.textDim,
        suffixIconColor: AppColors.textDim,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: AppBorder.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: AppBorder.thin,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: AppBorder.accent,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: AppColors.borderSubtle.withValues(alpha: 0.5), width: 0.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceOverlay,
        disabledColor: AppColors.borderSubtle,
        selectedColor: AppColors.accentPrimary.withValues(alpha: 0.15),
        secondarySelectedColor: AppColors.accentPrimary.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.accentPrimary),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          side: AppBorder.hairline,
        ),
        selectedShadowColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        pressElevation: 0,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: AppBorder.thin,
        ),
        titleTextStyle: AppTextStyles.headlineMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          side: AppBorder.thin,
        ),
        modalBackgroundColor: AppColors.surfaceElevated,
        dragHandleColor: AppColors.borderSubtle,
        dragHandleSize: const Size(40, 4),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 0.5,
        space: AppSpacing.lg,
        indent: 0,
        endIndent: 0,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: AppTextStyles.titleMedium,
        subtitleTextStyle: AppTextStyles.bodySmall,
        leadingAndTrailingTextStyle: AppTextStyles.bodySmall,
        iconColor: AppColors.textMuted,
        textColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        selectedTileColor: AppColors.accentPrimary.withValues(alpha: 0.08),
        selectedColor: AppColors.accentPrimary,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: AppColors.accentPrimary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelSmall.copyWith(color: AppColors.accentPrimary);
            }
            return AppTextStyles.labelSmall.copyWith(color: AppColors.textDim);
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.accentPrimary, size: 24);
            }
            return const IconThemeData(color: AppColors.textDim, size: 24);
          },
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.accentPrimary,
        unselectedLabelColor: AppColors.textDim,
        indicatorColor: AppColors.accentPrimary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentPrimary.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.accentPrimary.withValues(alpha: 0.05);
            }
            return null;
          },
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentPrimary;
            }
            return AppColors.textDim;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentPrimary.withValues(alpha: 0.3);
            }
            return AppColors.borderSubtle;
          },
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => null,
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentPrimary.withValues(alpha: 0.15);
            }
            return null;
          },
        ),
        thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const Icon(Icons.check, size: 16, color: AppColors.textOnAccent);
            }
            return null;
          },
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentPrimary;
            }
            return Colors.transparent;
          },
        ),
        checkColor: WidgetStateProperty.all(AppColors.textOnAccent),
        side: WidgetStateBorderSide.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: AppColors.accentPrimary, width: 2);
            }
            return AppBorder.thin;
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentPrimary.withValues(alpha: 0.15);
            }
            return null;
          },
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentPrimary;
            }
            return AppColors.textDim;
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentPrimary.withValues(alpha: 0.15);
            }
            return null;
          },
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accentPrimary,
        inactiveTrackColor: AppColors.borderSubtle,
        thumbColor: AppColors.accentPrimary,
        overlayColor: AppColors.accentPrimary.withValues(alpha: 0.15),
        valueIndicatorColor: AppColors.accentPrimary,
        valueIndicatorTextStyle: AppTextStyles.monoSmall.copyWith(color: AppColors.textOnAccent),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.accentPrimary,
        linearTrackColor: AppColors.borderSubtle,
        circularTrackColor: AppColors.borderSubtle,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceOverlay,
        contentTextStyle: AppTextStyles.bodyMedium,
        actionTextColor: AppColors.accentGlow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: AppBorder.thin,
        ),
        elevation: 0,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceOverlay,
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        textStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        preferBelow: true,
        verticalOffset: 8,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.borderEmphasis),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(4),
        radius: Radius.circular(AppRadius.xs),
        crossAxisMargin: 4,
        mainAxisMargin: 4,
      ),

      splashFactory: NoSplash.splashFactory,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.borderSubtle, width: 1),
  );

  static BoxDecoration cardHover = BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.accentPrimary, width: 1),
  );

  static BoxDecoration cardPressed = BoxDecoration(
    color: AppColors.surfaceOverlay,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.accentPrimary, width: 1),
  );

  static BoxDecoration input = BoxDecoration(
    color: AppColors.surfaceOverlay,
    borderRadius: BorderRadius.circular(AppRadius.sm),
    border: Border.all(color: AppColors.borderSubtle, width: 1),
  );

  static BoxDecoration inputFocused = BoxDecoration(
    color: AppColors.surfaceOverlay,
    borderRadius: BorderRadius.circular(AppRadius.sm),
    border: Border.all(color: AppColors.accentPrimary, width: 2),
  );

  static BoxDecoration modal = BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(color: AppColors.borderSubtle, width: 1),
    boxShadow: AppShadows.modal,
  );

  static BoxDecoration badge = BoxDecoration(
    color: AppColors.accentPrimary.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(AppRadius.xs),
    border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.5), width: 0.5),
  );

  static BoxDecoration badgeSuccess = BoxDecoration(
    color: AppColors.successBg.withValues(alpha: 0.3),
    borderRadius: BorderRadius.circular(AppRadius.xs),
    border: Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 0.5),
  );

  static BoxDecoration badgeWarning = BoxDecoration(
    color: AppColors.warningBg.withValues(alpha: 0.3),
    borderRadius: BorderRadius.circular(AppRadius.xs),
    border: Border.all(color: AppColors.warning.withValues(alpha: 0.5), width: 0.5),
  );

  static BoxDecoration badgeError = BoxDecoration(
    color: AppColors.errorBg.withValues(alpha: 0.3),
    borderRadius: BorderRadius.circular(AppRadius.xs),
    border: Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 0.5),
  );
}

extension AppTextStyleExtensions on TextStyle {
  TextStyle get primary => copyWith(color: AppColors.textPrimary);
  TextStyle get muted => copyWith(color: AppColors.textMuted);
  TextStyle get dim => copyWith(color: AppColors.textDim);
  TextStyle get accent => copyWith(color: AppColors.accentPrimary);
  TextStyle get glow => copyWith(color: AppColors.accentGlow);
  TextStyle get success => copyWith(color: AppColors.success);
  TextStyle get warning => copyWith(color: AppColors.warning);
  TextStyle get error => copyWith(color: AppColors.error);
  TextStyle get onAccent => copyWith(color: AppColors.textOnAccent);

  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  TextStyle get mono => copyWith(fontFamily: 'JetBrainsMono');
  TextStyle get display => copyWith(fontFamily: 'SpaceGrotesk');
  TextStyle get ui => copyWith(fontFamily: 'IBMPlexSans');
}

extension AppColorExtensions on Color {
  Color withAlpha(double alpha) => withValues(alpha: alpha);
}
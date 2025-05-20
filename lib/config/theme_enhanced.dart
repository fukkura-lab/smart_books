import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // メインカラー
  static const Color primaryColor = Color(0xFF3BCFD4); // ターコイズ
  static const Color secondaryColor = Color(0xFF1A237E); // 濃紺
  static const Color accentColor = Color(0xFFF8BBD0); // 薄ピンク

  // テキストカラー
  static const Color textDarkColor = Color(0xFF333333);
  static const Color textLightColor = Color(0xFFFFFFFF);
  static const Color textMutedColor = Color(0xFF666666);

  // 背景色
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFFFFFFF);

  // 状態カラー
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // ダークモードカラー
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1D1D1D);
  static const Color darkCardColor = Color(0xFF252525);

  // テーマ設定（ライトモード）
  static ThemeData lightTheme() {
    final base = ThemeData.light();
    
    // ライトモード用のテキストテーマ
    final TextTheme textTheme = GoogleFonts.notoSansTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.notoSans(
        color: textDarkColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.notoSans(
        color: textDarkColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.notoSans(
        color: textDarkColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.notoSans(
        color: textDarkColor,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.notoSans(
        color: textDarkColor,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.notoSans(
        color: textMutedColor,
        fontSize: 12,
      ),
    );

    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      canvasColor: backgroundColor, // ドロップダウンメニューの背景色
      dialogBackgroundColor: cardColor,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      // テキスト選択色
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withOpacity(0.3),
        selectionHandleColor: primaryColor,
      ),
      // 入力装飾
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: GoogleFonts.notoSans(
          color: textMutedColor,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.notoSans(
          color: textMutedColor,
          fontSize: 14,
        ),
        // テキストフィールドのスタイル
        prefixStyle: TextStyle(color: textDarkColor),
        suffixStyle: TextStyle(color: textDarkColor),
      ),
      // カラースキーム
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: textLightColor,
        onSecondary: textLightColor,
        onSurface: textDarkColor,
        onBackground: textDarkColor,
        onError: textLightColor,
        brightness: Brightness.light,
      ),
      // AppBarスタイル
      appBarTheme: const AppBarTheme(
        color: primaryColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: textLightColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textLightColor),
      ),
      // ボタンスタイル
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textLightColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      // カードスタイル
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // BottomNavigationBarスタイル
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMutedColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // アニメーション設定
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // テーマ設定（ダークモード）
  static ThemeData darkTheme() {
    final base = ThemeData.dark();
    
    // ダークモード用のテキストテーマ
    final TextTheme textTheme = GoogleFonts.notoSansTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.notoSans(
        color: textLightColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.notoSans(
        color: textLightColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.notoSans(
        color: textLightColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.notoSans(
        color: textLightColor,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.notoSans(
        color: textLightColor,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.notoSans(
        color: textLightColor.withOpacity(0.7),
        fontSize: 12,
      ),
      // TextField内のスタイルを強制的に設定
      labelMedium: GoogleFonts.notoSans(
        color: textLightColor,
        fontSize: 14,
      ),
    );

    return base.copyWith(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      canvasColor: darkSurfaceColor, // ドロップダウンメニューの背景色
      dialogBackgroundColor: darkCardColor,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      // テキスト選択
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withOpacity(0.3),
        selectionHandleColor: primaryColor,
      ),
      // 入力装飾
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: GoogleFonts.notoSans(
          color: textLightColor.withOpacity(0.5),
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.notoSans(
          color: textLightColor.withOpacity(0.8),
          fontSize: 14,
        ),
        // テキストスタイル
        prefixStyle: TextStyle(color: textLightColor),
        suffixStyle: TextStyle(color: textLightColor),
      ),
      // カラースキーム
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        error: errorColor,
        onPrimary: textLightColor,
        onSecondary: textLightColor,
        onSurface: textLightColor,
        onBackground: textLightColor,
        onError: textLightColor,
        brightness: Brightness.dark,
      ),
      // AppBarスタイル
      appBarTheme: const AppBarTheme(
        color: darkSurfaceColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: textLightColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textLightColor),
      ),
      // ボタンスタイル
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textLightColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      // DropdownButtonスタイル
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: textLightColor),
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all(darkCardColor),
        ),
      ),
      // PopupMenuスタイル
      popupMenuTheme: PopupMenuThemeData(
        color: darkCardColor,
        textStyle: TextStyle(color: textLightColor),
      ),
      // テーブルスタイル
      dataTableTheme: DataTableThemeData(
        headingTextStyle: TextStyle(color: textLightColor, fontWeight: FontWeight.bold),
        dataTextStyle: TextStyle(color: textLightColor),
        headingRowColor: MaterialStateProperty.all(darkSurfaceColor),
        dataRowColor: MaterialStateProperty.all(darkCardColor),
      ),
      // カードスタイル
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // BottomNavigationBarスタイル
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLightColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // Dividerスタイル
      dividerTheme: DividerThemeData(
        color: textLightColor.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),
      // Checkboxスタイル
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return Colors.transparent;
          },
        ),
        side: const BorderSide(width: 2, color: textLightColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      // Chipスタイル
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceColor,
        disabledColor: Colors.grey[800]!,
        selectedColor: primaryColor.withOpacity(0.3),
        secondarySelectedColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: TextStyle(
          color: textLightColor,
          fontSize: 14,
        ),
        secondaryLabelStyle: TextStyle(
          color: primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // SnackBarスタイル
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCardColor,
        contentTextStyle: GoogleFonts.notoSans(
          color: textLightColor,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      // Dialogスタイル
      dialogTheme: DialogTheme(
        backgroundColor: darkCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        titleTextStyle: TextStyle(
          color: textLightColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: textLightColor,
          fontSize: 14,
        ),
      ),
      // FloatingActionButtonスタイル
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textLightColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      // BottomSheetスタイル
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      // Scrollbarスタイル
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(primaryColor.withOpacity(0.5)),
        radius: const Radius.circular(10),
        thickness: MaterialStateProperty.all(6),
        thumbVisibility: MaterialStateProperty.all(true),
      ),
      // タブバースタイル
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: textLightColor.withOpacity(0.7),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: primaryColor.withOpacity(0.2),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
        ),
      ),
      // アニメーション設定
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }


}

// アプリのアニメーション・エフェクト管理クラス
class AppEffects {
  // ボタンアクション時の触覚フィードバック
  static void buttonFeedback() {
    HapticFeedback.lightImpact();
  }

  // 成功時の触覚フィードバック
  static void successFeedback() {
    HapticFeedback.mediumImpact();
  }

  // エラー時の触覚フィードバック
  static void errorFeedback() {
    HapticFeedback.heavyImpact();
  }

  // 選択時の触覚フィードバック
  static void selectionFeedback() {
    HapticFeedback.selectionClick();
  }
}

// スライド方向の列挙型
enum SlideDirection {
  rightToLeft,
  leftToRight,
  bottomToTop,
  topToBottom,
}

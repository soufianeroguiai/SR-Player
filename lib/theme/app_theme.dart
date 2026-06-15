import 'package:flutter/material.dart';

class AppTheme {
  static const orange = Color(0xFFFF6B35);
  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF1A1A1A);
  static const card = Color(0xFF1E1E1E);
  static const divider = Color(0xFF2A2A2A);

  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: orange,
        secondary: orange,
        surface: surface,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: orange,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white70),
      ),
      tabBarTheme: const TabBarThemeData(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: orange, width: 2),
        ),
        labelColor: orange,
        unselectedLabelColor: Colors.white38,
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: orange,
        unselectedItemColor: Colors.white38,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white54,
        textColor: Colors.white,
      ),
      dividerColor: divider,
      sliderTheme: const SliderThemeData(
        activeTrackColor: orange,
        thumbColor: orange,
        inactiveTrackColor: Colors.white24,
        overlayColor: Color(0x29FF6B35),
      ),
    );
  }
}

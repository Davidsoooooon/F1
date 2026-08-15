import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const f1Red = Color(0xFFE10600);
  static const f1Black = Color(0xFF0A0A0A);
  static const f1Surface = Color(0xFF141414);
  static const f1Card = Color(0xFF1C1C1E);
  static const f1Border = Color(0xFF2C2C2E);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE4E4E7);
  static const lightText = Color(0xFF111827);
  static const lightMuted = Color(0xFF6B7280);
}

class AppDecorations {
  const AppDecorations._();

  static BoxDecoration darkCard({double radius = 16}) {
    return BoxDecoration(
      color: AppColors.f1Card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.f1Border),
    );
  }

  static BoxDecoration lightCard({double radius = 16}) {
    return BoxDecoration(
      color: AppColors.lightCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.lightBorder),
    );
  }

  static BoxDecoration heroGradient({double radius = 20}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.f1Red, Color(0xFF6B0000), AppColors.f1Black],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Color(0x66E10600)),
    );
  }
}

extension AppTextStyles on TextTheme {
  TextStyle? get lightTitle => titleSmall?.copyWith(
    color: AppColors.lightText,
    fontWeight: FontWeight.w700,
  );

  TextStyle? get lightBody => bodySmall?.copyWith(color: AppColors.lightMuted);
}

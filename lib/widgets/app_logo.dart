import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catalyze/constants/app_sizes.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.school,
          size: p64,
          color: Theme.of(context).colorScheme.primary,
        ),
        Text(
          'Study AI Assistant',
          style: GoogleFonts.notoSansJp(
            fontSize: p24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

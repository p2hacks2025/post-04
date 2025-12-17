import 'package:flutter/material.dart';
import 'nameplate_editor_page.dart';
import '../nameplate/nameplate_constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NameplateColors.backgroundColors[0],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ネームプレートを作成',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: NameplateColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NameplateEditorPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NameplateColors.accentPrimary,
                foregroundColor: NameplateColors.textOnAccent,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'つくる',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//QR交換メニュー画面は一時削除
// import 'package:flutter/material.dart';
// import 'qr_generate_page.dart';
// import 'qr_scan_page.dart';

// class TradeMenuPage extends StatelessWidget {
//   const TradeMenuPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFF8F0),
//       appBar: AppBar(
//         title: const Text('シール交換'),
//         backgroundColor: const Color(0xFFC6845A),
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _MenuButton(
//               icon: Icons.qr_code_2,
//               label: 'シールをあげる\n(QR作成)',
//               color: Colors.orange,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const QrGeneratePage()),
//                 );
//               },
//             ),
//             const SizedBox(height: 40),
//             _MenuButton(
//               icon: Icons.qr_code_scanner,
//               label: 'シールをもらう\n(QR読取)',
//               color: Colors.blueAccent,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const QrScanPage()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MenuButton extends StatelessWidget {
//   const _MenuButton({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });

//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: 200,
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: color, width: 2),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 60, color: color),
//             const SizedBox(height: 10),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGeneratePage extends StatefulWidget {
  const QrGeneratePage({super.key});

  @override
  State<QrGeneratePage> createState() => _QrGeneratePageState();
}

class _QrGeneratePageState extends State<QrGeneratePage> {
  // 本来はここを自分のインベントリデータにする
  final List<Map<String, String>> _myStickers = [
    {'id': 'cat_001', 'name': 'ミケネコ', 'asset': 'assets/icons/cat.png'},
    {'id': 'dog_001', 'name': 'シバイヌ', 'asset': 'assets/icons/dog.png'},
    {'id': 'car_001', 'name': 'パトカー', 'asset': 'assets/icons/police_car.png'},
  ];

  Map<String, String>? _selectedSticker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('シールをあげる')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('あげるシールを選んでください', style: TextStyle(fontSize: 18)),
          ),
          // シール選択リスト
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _myStickers.length,
              itemBuilder: (context, index) {
                final sticker = _myStickers[index];
                final isSelected = _selectedSticker == sticker;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSticker = sticker),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // 画像を表示（なければアイコン）
                        Expanded(child: Icon(Icons.star, size: 50, color: Colors.orange)), 
                        Text(sticker['name']!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 40),
          // QRコード表示エリア
          Expanded(
            child: Center(
              child: _selectedSticker == null
                  ? const Text('シールを選択するとQRコードが表示されます')
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '「${_selectedSticker!['name']}」をあげる',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        QrImageView(
                          data: jsonEncode(_selectedSticker), // データをJSONにして埋め込む
                          version: QrVersions.auto,
                          size: 250.0,
                        ),
                        const SizedBox(height: 20),
                        const Text('相手にこの画面をスキャンしてもらおう！'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
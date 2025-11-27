// lib/core/shared_widgets/whatsapp_helper.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const String whatsappNumber = '6285788837057';
  static const String adminName = 'Admin Vika';

  static Future<void> openWhatsApp(BuildContext context, String productName) async {
    final cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    final message = Uri.encodeComponent(
      'Halo $adminName, saya ingin menanyakan perihal produk $productName',
    );

    final List<String> whatsappUrls = [
      'https://wa.me/$cleanNumber?text=$message',
      'https://api.whatsapp.com/send?phone=$cleanNumber&text=$message',
      'whatsapp://send?phone=$cleanNumber&text=$message',
    ];

    bool successfullyOpened = false;

    for (String url in whatsappUrls) {
      try {
        final uri = Uri.parse(url);
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          successfullyOpened = true;
          print('✅ WhatsApp opened with: $url');
          break;
        }
      } catch (e) {
        print('⚠️ Failed to open with $url: $e');
        continue;
      }
    }

    if (!successfullyOpened && context.mounted) {
      _showWhatsAppNotAvailableDialog(context, cleanNumber);
    }
  }

  static void _showWhatsAppNotAvailableDialog(BuildContext context, String cleanNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WhatsApp Tidak Tersedia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pastikan WhatsApp sudah terinstall di perangkat Anda.'),
            const SizedBox(height: 12),
            const Text('Nomor yang akan dihubungi:'),
            const SizedBox(height: 4),
            SelectableText(
              cleanNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final storeUrl = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.whatsapp',
              );
              if (await canLaunchUrl(storeUrl)) {
                await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Install WhatsApp'),
          ),
        ],
      ),
    );
  }
}
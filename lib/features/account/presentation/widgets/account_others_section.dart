// lib/features/account/presentation/widgets/account_others_section.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountOthersSection extends StatelessWidget {
  const AccountOthersSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lainnya',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),

          // Tentang Ekatunggal
          _buildListItem(
            context: context,
            asset: 'assets/images/account/logoETM.png',
            title: 'Tentang Ekatunggal',
            fallbackIcon: Icons.info,
            onTap: () => context.pushNamed('about'),
          ),

          const Divider(height: 1),

          // Tanya Vika
          _buildListItem(
            context: context,
            asset: 'assets/images/account/tanyaVika.png',
            title: 'Tanya Vika',
            fallbackIcon: Icons.chat,
            onTap: () {
              // TODO: Navigate to Tanya Vika
              // context.pushNamed('tanyaVika');
            },
          ),

          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required String asset,
    required String title,
    required IconData fallbackIcon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 36,
        height: 36,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon,
              size: 28,
              color: Colors.black54,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.black38,
      ),
      onTap: onTap,
    );
  }
}
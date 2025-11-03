import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/cupertino.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.location_city, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ekatunggal di sekitar Anda', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Aktifkan Lokasi', style: TextStyle(color: AppColors.grayColor, fontSize: 12)),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: AppColors.grayColor,
                      size: 12,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

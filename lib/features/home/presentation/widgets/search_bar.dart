import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color.fromARGB(39, 0, 0, 0)),
        // boxShadow: [BoxShadow(color: Colors.black, blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk',
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.filter_list),
          // )
        ],
      ),
    );
  }
}

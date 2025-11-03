import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum UserStatus { guest, loggedIn, member }

class ProfileHeader extends StatelessWidget {
  final UserStatus status;
  final String? name;
  final String? company;
  final VoidCallback? onLoginTap;
  final VoidCallback? onCompanyTap;

  const ProfileHeader({
    super.key,
    this.status = UserStatus.guest,
    this.name,
    this.company,
    this.onLoginTap,
    this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarImage = Image.asset(
      'assets/images/avatar_placeholder.png',
      fit: BoxFit.cover,
    );

    // konten teks tergantung status
    Widget buildTextArea() {
      switch (status) {
        case UserStatus.guest:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, Selamat Datang',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              // const SizedBox(height: 4),
              GestureDetector(
                onTap: onLoginTap ??
                    () {
                      // default navigation ke LoginPage (stub)
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Masuk atau Daftar Sekarang',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    // const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.primaryColor),
                  ],
                ),
              ),
            ],
          );

        case UserStatus.loggedIn:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? 'Halo, Pengguna',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              // bisa kosong atau subtitle kecil
              // const SizedBox(height: 4),
              // Text(
              //   'Selamat berbelanja',
              //   style: TextStyle(
              //     color: Colors.grey.shade600,
              //     fontSize: 12,
              //     fontFamily: AppFonts.primaryFont,
              //   ),
              // ),
            ],
          );

        case UserStatus.member:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? 'Halo, Pengguna',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onCompanyTap ??
                    () {
                      // stub: nanti akan show company selector
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih perusahaan (stub)')),
                      );
                    },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      company ?? 'PT Nama Perusahaan',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.expand_more, size: 18), // chevron down
                  ],
                ),
              ),
            ],
          );
      }
    }

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(child: avatarImage),
        ),
        const SizedBox(width: 12),
        Expanded(child: buildTextArea()),
        IconButton(
          onPressed: () {
            // notifikasi tap (stub)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifikasi (stub)')));
          },
          icon: const Icon(CupertinoIcons.bell_solid, color: AppColors.grayColor,)
        ),
      ],
    );
  }
}

/// --- Halaman login stub untuk demo navigasi ---
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masuk / Daftar'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // contoh: kembali ke home
            Navigator.of(context).pop();
          },
          child: const Text('Kembali (stub)'),
        ),
      ),
    );
  }
}

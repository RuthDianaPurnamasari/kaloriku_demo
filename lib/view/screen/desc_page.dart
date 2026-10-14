import 'package:flutter/material.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:kaloriku/view/screen/login_page.dart';

class DescPage extends StatelessWidget {
  const DescPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('About', style: TextStyle(color: Colors.white)),
            backgroundColor: Color.fromARGB(255, 16, 81, 50),
            actions: [
              IconButton(
                onPressed: () {
                  _showLogoutConfirmationDialog(context);
                },
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Image(
                  image: AssetImage('assets/images/logo.png'),
                  height: 120,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tentang Aplikasi",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 16, 81, 50),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "KaloriKu adalah aplikasi catering sehat yang membantu pengguna dalam memilih menu makanan sehat, menghitung kalori, dan mendapatkan informasi gizi yang sesuai dengan kebutuhan mereka. Dengan fitur-fitur unggulan, KaloriKu bertujuan untuk memberikan solusi makan sehat dengan mudah dan praktis.",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isWideScreen
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: _buildFeatureCard(icon: Icons.fastfood, title: "Pilih Menu Sehat", description: "Temukan berbagai pilihan menu sehat yang sesuai dengan kebutuhan diet Anda.")),
                            Expanded(child: _buildFeatureCard(icon: Icons.calculate, title: "Hitung Kalori", description: "Lacak asupan kalori harian Anda dan pastikan sesuai dengan target kesehatan.")),
                            Expanded(child: _buildFeatureCard(icon: Icons.article, title: "Artikel Kesehatan", description: "Dapatkan tips dan informasi terbaru seputar pola makan sehat dan gaya hidup sehat.")),
                          ],
                        )
                      : Column(
                          children: [
                            _buildFeatureCard(
                              icon: Icons.fastfood,
                              title: "Pilih Menu Sehat",
                              description:
                                  "Temukan berbagai pilihan menu sehat yang sesuai dengan kebutuhan diet Anda.",
                            ),
                            _buildFeatureCard(
                              icon: Icons.calculate,
                              title: "Hitung Kalori",
                              description:
                                  "Lacak asupan kalori harian Anda dan pastikan sesuai dengan target kesehatan.",
                            ),
                            _buildFeatureCard(
                              icon: Icons.article,
                              title: "Artikel Kesehatan",
                              description:
                                  "Dapatkan tips dan informasi terbaru seputar pola makan sehat dan gaya hidup sehat.",
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Color.fromARGB(255, 16, 81, 50)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Anda yakin ingin logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              await AuthManager.logout();
              Navigator.pushAndRemoveUntil(
                dialogContext,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Ya'),
          ),
        ],
      );
    },
  );
}

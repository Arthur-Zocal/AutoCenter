import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const AppAutoCenter());
}

class AppAutoCenter extends StatelessWidget {
  const AppAutoCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AZ Auto Center',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // Cores baseadas no logotipo AZ (Vermelho e Preto/Cinza)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F), // Vermelho do logotipo
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212), // Fundo preto/cinza escuro
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F), // Botão vermelho
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: const Color(0xFFD32F2F).withOpacity(0.4),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// SPLASH SCREEN (Tela de Abertura)
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navegarParaHome();
  }

  _navegarParaHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AzHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Fundo preto puro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo da AZ Auto Center
            Image.asset(
              'assets/images/logoAZ.png',
              width: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 50),
            // Carregamento estilizado
            const CircularProgressIndicator(
              color: Color(0xFFD32F2F),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// HOME PAGE (Tela Principal da AZ Auto Center)
// ==========================================
class AzHomePage extends StatelessWidget {
  const AzHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AZ Auto Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de destaque
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2A2A), Color(0xFF121212)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFFD32F2F), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD32F2F).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_car, size: 48, color: Color(0xFFD32F2F)),
                    const SizedBox(height: 8),
                    const Text(
                      'Oficina de Confiança',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Segurança e qualidade para seu veículo',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Título dos serviços
            const Text(
              'Nossos Serviços',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grid de serviços
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildServiceCard(Icons.build, 'Mecânica Geral'),
                _buildServiceCard(Icons.oil_barrel, 'Troca de Óleo'),
                _buildServiceCard(Icons.tire_repair, 'Pneus & Alinhamento'),
                _buildServiceCard(Icons.engineering, 'Revisão Completa'),
                _buildServiceCard(Icons.clean_hands, 'Estética Automotiva'),
                _buildServiceCard(Icons.directions_car, 'Suspensão & Freios'),
              ],
            ),
            const SizedBox(height: 24),

            // Botão de agendamento
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'AGENDAR SERVIÇO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: const Color(0xFFD32F2F)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'products_screen.dart';
import '../theme/app_theme.dart';

class AzHomePage extends StatelessWidget {
  const AzHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDeep,
      appBar: AppBar(
        title: Text(
          'AZ Auto Center',
          style: AppTextStyles.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            tooltip: 'Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader(context, 'Nossas Categorias'),
            const SizedBox(height: AppSpacing.md),
            _buildCategoryGrid(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        image: const DecorationImage(
          image: AssetImage('assets/images/logoAZ_02.png'),
          fit: BoxFit.cover,
          opacity: 0.08,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPrimary.withValues(alpha: 0.15),
                    AppColors.surfaceElevated.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3), width: 1),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        size: 28,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AZ AUTO CENTER',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.accentPrimary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Loja especializada em peças automotivas',
                            style: AppTextStyles.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Segurança e qualidade para seu veículo',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineSmall,
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductsScreen()),
            );
          },
          icon: const Icon(Icons.chevron_right, size: 18),
          label: Text(
            'Ver todas',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      _CategoryData(Icons.build, 'Mecânica Geral'),
      _CategoryData(Icons.clean_hands, 'Estética Automotiva'),
      _CategoryData(Icons.directions_car, 'Suspensão e Freios'),
      _CategoryData(Icons.light_mode, 'Faróis e Lâmpadas'),
      _CategoryData(Icons.local_gas_station, 'Lubrificantes'),
      _CategoryData(Icons.battery_charging_full, 'Baterias'),
      _CategoryData(Icons.layers, 'Adesivo/Envelopamento'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.15,
      children: categories.map((cat) => _CategoryCard(data: cat)).toList(),
    );
  }
}

class _CategoryData {
  final IconData icon;
  final String title;

  const _CategoryData(this.icon, this.title);
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData data;

  const _CategoryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductsScreen(initialCategory: data.title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: AppColors.accentPrimary.withValues(alpha: 0.1),
        highlightColor: AppColors.accentPrimary.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.2), width: 1),
                ),
                child: Icon(data.icon, size: 32, color: AppColors.accentPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  data.title,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
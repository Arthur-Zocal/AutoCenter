import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  final String category;

  const ProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final products = _getProductsForCategory(category);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum produto cadastrado',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Categoria: $category',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(product: product);
              },
            ),
    );
  }

  List<Product> _getProductsForCategory(String category) {
    switch (category) {
      case 'Mecânica Geral':
        return [
          Product(name: 'Kit Embreagem', price: 'R\$ 450,00', description: 'Kit completo com disco, platô e rolamento', icon: Icons.settings),
          Product(name: 'Correia Dentada', price: 'R\$ 89,90', description: 'Correia de distribuição reforçada', icon: Icons.build),
          Product(name: 'Filtro de Óleo', price: 'R\$ 35,00', description: 'Filtro original para motor 1.0 a 2.0', icon: Icons.filter_alt),
          Product(name: 'Vela de Ignição', price: 'R\$ 28,00', description: 'Jogo com 4 velas de irídio', icon: Icons.electric_bolt),
        ];
      case 'Estética Automotiva':
        return [
          Product(name: 'Cera Sintética', price: 'R\$ 120,00', description: 'Proteção 6 meses, brilho espelhado', icon: Icons.auto_fix_high),
          Product(name: 'Shampoo Neutro', price: 'R\$ 45,00', description: '1L - pH neutro, não remove cera', icon: Icons.local_car_wash),
          Product(name: 'Pneu Pretinho', price: 'R\$ 38,00', description: '500ml - acabamento seco, não gorduroso', icon: Icons.circle),
          Product(name: 'Kit Polimento', price: 'R\$ 280,00', description: 'Massa + cera + aplicadores', icon: Icons.auto_awesome),
        ];
      case 'Suspensão e Freios':
        return [
          Product(name: 'Amortecedor Dianteiro', price: 'R\$ 320,00', description: 'Par - gás pressurizado, garantia 2 anos', icon: Icons.vertical_distribute),
          Product(name: 'Pastilha de Freio', price: 'R\$ 180,00', description: 'Jogo dianteiro - cerâmica, baixa poeira', icon: Icons.stop_circle),
          Product(name: 'Disco de Freio', price: 'R\$ 220,00', description: 'Par - ventilado, alta performance', icon: Icons.donut_large),
          Product(name: 'Bandeja Suspensão', price: 'R\$ 195,00', description: 'Unidade - com pivô e buchas', icon: Icons.architecture),
        ];
      case 'Faróis e Lâmpadas':
        return [
          Product(name: 'Lâmpada H7 LED', price: 'R\$ 180,00', description: 'Par - 6000K, 8000lm, plug & play', icon: Icons.lightbulb),
          Product(name: 'Farol Auxiliar LED', price: 'R\$ 250,00', description: 'Par - 72W, 6000lm, à prova d\'água', icon: Icons.highlight),
          Product(name: 'Lâmpada H4 Super Branca', price: 'R\$ 95,00', description: 'Par - 4300K, homologada', icon: Icons.wb_incandescent),
          Product(name: 'Kit Xenon 35W', price: 'R\$ 350,00', description: 'Com reatores slim, 6000K', icon: Icons.flash_on),
        ];
      case 'Lubrificantes':
        return [
          Product(name: 'Óleo 5W30 Sintético', price: 'R\$ 120,00', description: '4L - API SN, para motores modernos', icon: Icons.opacity),
          Product(name: 'Óleo 10W40 Semi Sintético', price: 'R\$ 85,00', description: '4L - uso misto cidade/estrada', icon: Icons.local_gas_station),
          Product(name: 'Óleo 20W50 Mineral', price: 'R\$ 55,00', description: '4L - motores com maior quilometragem', icon: Icons.speed),
          Product(name: 'Fluido de Freio DOT 4', price: 'R\$ 42,00', description: '500ml - ponto de ebulição alto', icon: Icons.water_drop),
        ];
      case 'Baterias':
        return [
          Product(name: 'Bateria 60Ah', price: 'R\$ 420,00', description: 'Selada, livre de manutenção, 24 meses garantia', icon: Icons.battery_full),
          Product(name: 'Bateria 70Ah', price: 'R\$ 480,00', description: 'Alta partida a frio, 30 meses garantia', icon: Icons.battery_charging_full),
          Product(name: 'Bateria Start-Stop 70Ah', price: 'R\$ 680,00', description: 'EFB, para carros com start-stop', icon: Icons.battery_saver),
          Product(name: 'Carregador Inteligente', price: 'R\$ 180,00', description: '12V/24V - recupera baterias sulfatadas', icon: Icons.power),
        ];
      default:
        return [];
    }
  }
}

class Product {
  final String name;
  final String price;
  final String description;
  final IconData icon;

  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.icon,
  });
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(product.icon, color: const Color(0xFFD32F2F), size: 28),
        ),
        title: Text(
          product.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              product.description,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              product.price,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart, color: Color(0xFFD32F2F)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} adicionado ao carrinho'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        onTap: () {},
      ),
    );
  }
}
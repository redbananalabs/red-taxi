import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

import '../../providers/customer_auth_provider.dart';

class _Tenant {
  final String id;
  final String name;
  final String location;
  final IconData icon;

  const _Tenant({
    required this.id,
    required this.name,
    required this.location,
    required this.icon,
  });
}

const _mockTenants = [
  _Tenant(id: 't1', name: 'City Cabs', location: 'Dublin', icon: Icons.local_taxi),
  _Tenant(id: 't2', name: 'Metro Taxi', location: 'Cork', icon: Icons.local_taxi),
  _Tenant(id: 't3', name: 'Express Cars', location: 'Galway', icon: Icons.directions_car),
  _Tenant(id: 't4', name: 'Airport Transfers', location: 'Shannon', icon: Icons.flight),
  _Tenant(id: 't5', name: 'Coastal Cabs', location: 'Limerick', icon: Icons.local_taxi),
];

/// Select which taxi company (tenant) to book with.
class TenantSelectScreen extends StatefulWidget {
  const TenantSelectScreen({super.key});

  @override
  State<TenantSelectScreen> createState() => _TenantSelectScreenState();
}

class _TenantSelectScreenState extends State<TenantSelectScreen> {
  final _searchController = TextEditingController();
  List<_Tenant> _filtered = _mockTenants;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _mockTenants.where((t) {
        return t.name.toLowerCase().contains(query) ||
            t.location.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.local_taxi, size: 48, color: RedTaxiColors.brandRed),
              const SizedBox(height: 16),
              Text(
                'Choose your\ntaxi company',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: RedTaxiColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search by name or location',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: RedTaxiColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              // Search field
              TextField(
                controller: _searchController,
                style: const TextStyle(color: RedTaxiColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search taxi companies...',
                  hintStyle: const TextStyle(color: RedTaxiColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: RedTaxiColors.textSecondary),
                  filled: true,
                  fillColor: RedTaxiColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tenant list
              Expanded(
                child: ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tenant = _filtered[index];
                    return _TenantCard(
                      tenant: tenant,
                      onTap: () {
                        context.read<CustomerAuthProvider>().selectTenant(
                              tenant.id,
                              tenant.name,
                            );
                        context.go('/login');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final _Tenant tenant;
  final VoidCallback onTap;

  const _TenantCard({required this.tenant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RedTaxiColors.backgroundCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: RedTaxiColors.brandRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tenant.icon, color: RedTaxiColors.brandRed),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.name,
                      style: const TextStyle(
                        color: RedTaxiColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: RedTaxiColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          tenant.location,
                          style: const TextStyle(
                            color: RedTaxiColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: RedTaxiColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

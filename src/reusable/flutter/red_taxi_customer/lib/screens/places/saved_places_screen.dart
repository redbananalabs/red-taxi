import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:red_taxi_shared/red_taxi_shared.dart';

/// Saved places: Home, Work, and custom saved locations.
class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final List<_SavedPlace> _places = [
    _SavedPlace(
      icon: Icons.home_outlined,
      label: 'Home',
      address: null,
      isDefault: true,
    ),
    _SavedPlace(
      icon: Icons.work_outline,
      label: 'Work',
      address: null,
      isDefault: true,
    ),
    _SavedPlace(
      icon: Icons.favorite_border,
      label: 'Gym',
      address: '42 Fitness Lane, Dublin',
      isDefault: false,
    ),
  ];

  void _addPlace() {
    showModalBottomSheet(
      context: context,
      backgroundColor: RedTaxiColors.backgroundSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final nameCtrl = TextEditingController();
        final addrCtrl = TextEditingController();

        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a place',
                style: TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: RedTaxiColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Place name',
                  hintStyle:
                      const TextStyle(color: RedTaxiColors.textSecondary),
                  filled: true,
                  fillColor: RedTaxiColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrCtrl,
                style: const TextStyle(color: RedTaxiColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Address',
                  hintStyle:
                      const TextStyle(color: RedTaxiColors.textSecondary),
                  filled: true,
                  fillColor: RedTaxiColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && addrCtrl.text.isNotEmpty) {
                      setState(() {
                        _places.add(_SavedPlace(
                          icon: Icons.place_outlined,
                          label: nameCtrl.text,
                          address: addrCtrl.text,
                          isDefault: false,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Place'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Saved Places'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlace,
        backgroundColor: RedTaxiColors.brandRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _places.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final place = _places[index];
          return Container(
            decoration: BoxDecoration(
              color: RedTaxiColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: RedTaxiColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(place.icon, color: RedTaxiColors.brandRed, size: 22),
              ),
              title: Text(
                place.label,
                style: const TextStyle(
                  color: RedTaxiColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                place.address ?? 'Tap to set address',
                style: TextStyle(
                  color: place.address != null
                      ? RedTaxiColors.textSecondary
                      : RedTaxiColors.brandRed,
                  fontSize: 13,
                ),
              ),
              trailing: place.isDefault
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: RedTaxiColors.textSecondary, size: 20),
                      onPressed: () {
                        setState(() => _places.removeAt(index));
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _SavedPlace {
  final IconData icon;
  final String label;
  final String? address;
  final bool isDefault;

  _SavedPlace({
    required this.icon,
    required this.label,
    this.address,
    required this.isDefault,
  });
}

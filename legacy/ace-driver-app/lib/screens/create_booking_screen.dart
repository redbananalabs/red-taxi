import 'dart:async';
import 'dart:convert';
import 'package:ace_taxis/helpers/api_constants.dart';
import 'package:ace_taxis/helpers/shared_pref_helper.dart';
import 'package:ace_taxis/models/create_booking_model.dart';
import 'package:ace_taxis/providers/booking_log_provider.dart';
import 'package:ace_taxis/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../providers/create_booking_provider.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dropController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _passengerNameController = TextEditingController();

  static const String _hardcodedPickupAddress = "Rank Pickup";
  static const String _hardcodedPickupPostcode = "SP8 4PZ";

  String _pickupAddress = _hardcodedPickupAddress;
  String _pickupPostcode = _hardcodedPickupPostcode;
  String _dropPostcode = "";
  List<Map<String, dynamic>> _dropSuggestions = [];

  double _mileage = 0;
  String _mileageText = "";
  int _durationMinutes = 0;
  String _durationText = "";

  bool _isFetchingPrice = false;
  bool _isResolving = false;

  Timer? _debounce;
  final _uuid = const Uuid();
  // We no longer need a global session token variable here because it's generated per-request

  @override
  void initState() {
    super.initState();
    _pickupAddress = _hardcodedPickupAddress;
    _pickupPostcode = _hardcodedPickupPostcode;
  }

  List<Map<String, dynamic>> _castToMapList(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // Modified to accept the token as a parameter
  Future<void> _fetchAddressSuggestions(String term, String token) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/address/dispatchsearch?q=$term&sessionToken=$token");

    try {
      debugPrint("🔵 REQUEST TOKEN: $token");
      final res = await http.get(url, headers: {"Accept": "application/json"});
      if (res.statusCode == 200) {
        final dynamic rawData = jsonDecode(res.body);
        setState(() {
          _dropSuggestions = _castToMapList(rawData);
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    }
  }

  Future<void> _resolveAddress(String id, String token) async {
    setState(() {
      _isResolving = true;
      _dropSuggestions = [];
    });

    final url = Uri.parse("${ApiConstants.baseUrl}/address/resolve?id=$id&sessionToken=$token");

    try {
      final res = await http.get(url, headers: {"Accept": "application/json"});
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(res.body));

        final String resolvedAddress = data['formattedAddress'] ?? data['displayLabel'] ?? "";
        final String resolvedPostcode = data['postcode'] ?? "";

        setState(() {
          _dropController.text = resolvedAddress;
          _dropPostcode = resolvedPostcode;
          _dropController.selection = TextSelection.fromPosition(
            TextPosition(offset: _dropController.text.length),
          );
        });

        _fetchPriceForTrip();
      }
    } catch (e) {
      debugPrint("Resolve Error: $e");
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  void _onDropChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (value.length < 4) {
      setState(() => _dropSuggestions = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      // ✅ Generate a BRAND NEW token right here, just before the request
      final String requestToken = _uuid.v4();
      _fetchAddressSuggestions(value, requestToken);
    });
  }

  Future<void> _fetchPriceForTrip() async {
    final String pPostcode = _pickupPostcode.isEmpty ? _hardcodedPickupPostcode : _pickupPostcode;
    final String dPostcode = _dropPostcode;

    if (pPostcode.isEmpty || dPostcode.isEmpty) return;

    setState(() => _isFetchingPrice = true);

    try {
      final body = {
        "pickupPostcode": pPostcode,
        "viaPostcodes": [],
        "destinationPostcode": dPostcode,
        "pickupDateTime": DateTime.now().toUtc().toIso8601String(),
        "passengers": 1,
        "priceFromBase": true,
        "accountNo": 9999,
      };

      final res = await http.post(
        Uri.parse(ApiConstants.getPriceEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _priceController.text = data["priceDriver"].toString();
          _mileage = (data["totalMileage"] as num).toDouble();
          _mileageText = data["mileageText"];
          _durationMinutes = data["totalMinutes"];
          _durationText = data["durationText"];
        });
      }
    } catch (e) {
      debugPrint("Price Error: $e");
    } finally {
      if (mounted) setState(() => _isFetchingPrice = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingProvider = Provider.of<CreateBookingProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: const Text("Create Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_isResolving || _isFetchingPrice) const LinearProgressIndicator(color: Colors.red),
              _card(theme, _textField(
                theme: theme,
                controller: _dropController,
                label: "Destination Address",
                icon: Icons.search,
                onChange: _onDropChanged,
              )),
              if (_dropSuggestions.isNotEmpty) _suggestionBox(theme),
              const SizedBox(height: 14),
              _card(theme, _textField(theme: theme, controller: _passengerNameController, label: "Passenger Name", icon: Icons.person_outline)),
              const SizedBox(height: 14),
              _card(theme, _textField(
                theme: theme,
                controller: _priceController,
                label: "Price",
                prefixText: "£",
                type: TextInputType.number,
                suffix: _isFetchingPrice ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
              )),
              const SizedBox(height: 26),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: (bookingProvider.isLoading || _isResolving || _isFetchingPrice) ? null : _submit,
                child: (bookingProvider.isLoading || _isResolving)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Booking", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestionBox(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dropSuggestions.length,
        itemBuilder: (context, i) {
          final item = _dropSuggestions[i];
          return ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Colors.red),
            title: Text(item['label'] ?? ""),
            subtitle: item['secondaryText'] != null ? Text(item['secondaryText']) : null,
            onTap: () {
              // ✅ For Resolve, we generate a final token for this selection
              final String resolveToken = _uuid.v4();
              _resolveAddress(item['id'].toString(), resolveToken);
            },
          );
        },
      ),
    );
  }

  Widget _card(ThemeData theme, Widget child) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))]),
    child: child,
  );

  Widget _textField({required ThemeData theme, required TextEditingController controller, required String label, IconData? icon, String? prefixText, TextInputType type = TextInputType.text, Function(String)? onChange, Widget? suffix}) => TextFormField(
    controller: controller, onChanged: onChange, keyboardType: type, style: TextStyle(color: theme.colorScheme.onSurface),
    decoration: InputDecoration(labelText: label, border: InputBorder.none, suffixIcon: suffix, prefixIcon: prefixText != null ? Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text(prefixText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))) : (icon != null ? Icon(icon, color: theme.colorScheme.primary) : null)),
    validator: (v) => v == null || v.isEmpty ? "Required" : null,
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final bookingProvider = Provider.of<CreateBookingProvider>(context, listen: false);
    final success = await bookingProvider.createBooking(
      pickup: _pickupAddress,
      pickupPostcode: _pickupPostcode,
      destination: _dropController.text,
      destinationPostcode: _dropPostcode,
      name: _passengerNameController.text.trim(),
      mileage: _mileage,
      mileageText: _mileageText,
      durationMinutes: _durationMinutes,
      durationText: _durationText,
      price: double.tryParse(_priceController.text) ?? 0,
    );
    if (success) {
      Provider.of<BookingLogProvider>(context, listen: false).addLog(CreateBookingModel(
        pickup: _pickupAddress,
        pickupPostcode: _pickupPostcode,
        destination: _dropController.text,
        destinationPostcode: _dropPostcode,
        name: _passengerNameController.text.trim(),
        mileage: _mileage,
        mileageText: _mileageText,
        durationMinutes: _durationMinutes,
        durationText: _durationText,
        price: double.tryParse(_priceController.text) ?? 0,
        date: DateTime.now(),
        time: TimeOfDay.now(),
      ));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }
}
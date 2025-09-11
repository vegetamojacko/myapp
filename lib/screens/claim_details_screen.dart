import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_event.dart';
import '../models/claim.dart';

class ClaimDetailsScreen extends StatefulWidget {
  final Claim claim;

  const ClaimDetailsScreen({super.key, required this.claim});

  @override
  State<ClaimDetailsScreen> createState() => _ClaimDetailsScreenState();
}

class _ClaimDetailsScreenState extends State<ClaimDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vehicleRegController;
  late DateTime _selectedDate;
  late String _selectedWash;

  @override
  void initState() {
    super.initState();
    _vehicleRegController = TextEditingController(text: widget.claim.vehicleReg);
    _selectedDate = widget.claim.washDate ?? DateTime.now();
    _selectedWash = widget.claim.washType ?? 'Express Wash';
  }

  @override
  void dispose() {
    _vehicleRegController.dispose();
    super.dispose();
  }

  void _updateClaim() {
    if (_formKey.currentState!.validate()) {
      final updatedClaim = widget.claim.copyWith(
        vehicleReg: _vehicleRegController.text,
        washDate: _selectedDate,
        washType: _selectedWash,
        totalAmount: _getWashPrice(_selectedWash),
        status: 'Pending',
      );
      context.read<ClaimsBloc>().add(UpdateClaim(updatedClaim));
      Navigator.pop(context);
    }
  }

  double _getWashPrice(String wash) {
    switch (wash) {
      case 'Express Wash':
        return 50.0;
      case 'Standard Wash':
        return 80.0;
      case 'Premium Wash':
        return 120.0;
      default:
        return 0.0;
    }
  }

  final List<Map<String, String>> _washOptions = [
    {'value': 'Express Wash', 'title': 'Express Wash (R50)'},
    {'value': 'Standard Wash', 'title': 'Standard Wash (R80)'},
    {'value': 'Premium Wash', 'title': 'Premium Wash (R120)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Car Wash Claim'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _vehicleRegController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Registration',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your vehicle registration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          'Date of Wash: ${DateFormat.yMd().format(_selectedDate)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final newDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (newDate != null) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        }
                      },
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Wash Options'),
                _RadioGroup(
                  selectedValue: _selectedWash,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedWash = value!;
                    });
                  },
                  options: _washOptions,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateClaim,
                  child: const Text('Update Claim'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioGroup extends StatefulWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;
  final List<Map<String, String>> options;

  const _RadioGroup({
    required this.selectedValue,
    required this.onChanged,
    required this.options,
  });

  @override
  State<_RadioGroup> createState() => _RadioGroupState();
}

class _RadioGroupState extends State<_RadioGroup> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        return RadioListTile<String>(
          title: Text(option['title']!),
          value: option['value']!,
          groupValue: _selectedValue,
          onChanged: (String? value) {
            setState(() {
              _selectedValue = value!;
            });
            widget.onChanged(value);
          },
        );
      }).toList(),
    );
  }
}

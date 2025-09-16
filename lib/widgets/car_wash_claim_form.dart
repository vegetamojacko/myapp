import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_event.dart';
import '../models/claim.dart';
import '../providers/car_wash_provider.dart';

class CarWashClaimForm extends StatefulWidget {
  final Claim? claim;

  const CarWashClaimForm({super.key, this.claim});

  @override
  State<CarWashClaimForm> createState() => _CarWashClaimFormState();
}

class _CarWashClaimFormState extends State<CarWashClaimForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _carRegController;
  late TextEditingController _washTypeController;
  late TextEditingController _totalAmountController;
  DateTime? _washDate;
  String? _selectedCarWashName;

  @override
  void initState() {
    super.initState();
    _carRegController = TextEditingController(text: widget.claim?.vehicleReg);
    _washTypeController = TextEditingController(text: widget.claim?.washType);
    _totalAmountController = TextEditingController(
        text: widget.claim?.totalAmount.toString() ?? '');
    _washDate = widget.claim?.washDate ?? DateTime.now();
    _selectedCarWashName = widget.claim?.carWashName;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (widget.claim != null) {
        // We are updating an existing claim
        final updatedClaim = widget.claim!.copyWith(
          carWashName: _selectedCarWashName,
          vehicleReg: _carRegController.text,
          washType: _washTypeController.text,
          washDate: _washDate,
          totalAmount: double.parse(_totalAmountController.text),
          status: 'Pending', // Reset status on update
        );
        context.read<ClaimsBloc>().add(UpdateClaim(updatedClaim));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car wash claim updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // We are creating a new claim
        final newClaim = Claim(
          id: const Uuid().v4(),
          carWashName: _selectedCarWashName!,
          vehicleReg: _carRegController.text,
          washType: _washTypeController.text,
          washDate: _washDate,
          status: 'Pending',
          submittedDate: DateTime.now().toIso8601String(),
          totalAmount: double.parse(_totalAmountController.text),
          isCarWashClaim: true,
        );
        context.read<ClaimsBloc>().add(AddClaim(newClaim));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car wash claim submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final carWashProvider = Provider.of<CarWashProvider>(context);
    final carWashes = carWashProvider.carWashes;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.claim == null
                          ? 'Car Wash Booking'
                          : 'Edit Car Wash Booking',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Fields
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration(context, labelText: 'Car Wash Name'),
                  hint: const Text('Select a car wash'),
                  items: carWashes.map((CarWash carWash) {
                    return DropdownMenuItem<String>(
                      value: carWash.name,
                      child: Text(carWash.name),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCarWashName = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a car wash';
                    }
                    return null;
                  },
                  initialValue: _selectedCarWashName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _washTypeController,
                  decoration: _inputDecoration(
                    context,
                    labelText: 'Type of Wash',
                    hintText: 'e.g., Full Valet',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the type of wash';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _carRegController,
                  decoration: _inputDecoration(
                    context,
                    labelText: 'Car Registration',
                    hintText: 'e.g., GP 123 AB',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your car registration number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Field
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: _inputDecoration(context, labelText: 'Date'),
                    child: Text(
                      _washDate != null
                          ? '${_washDate!.toLocal()}'.split(' ')[0]
                          : 'Select a date',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _totalAmountController,
                  decoration: _inputDecoration(
                    context,
                    labelText: 'Total Amount',
                    hintText: 'e.g., 250.00',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the total amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Text(
                    widget.claim == null ? 'Submit Request' : 'Update Request',
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _washDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _washDate) {
      setState(() {
        _washDate = picked;
      });
    }
  }
}

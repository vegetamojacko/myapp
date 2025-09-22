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
  TextEditingController? _carWashNameController;
  late final ValueNotifier<bool> _isSubmitEnabled;
  DateTime? _washDate;

  @override
  void initState() {
    super.initState();
    _carRegController = TextEditingController(text: widget.claim?.vehicleReg);
    _washTypeController = TextEditingController(text: widget.claim?.washType);
    _totalAmountController =
        TextEditingController(text: widget.claim?.totalAmount.toString() ?? '');
    _washDate = widget.claim?.washDate ?? DateTime.now();
    _isSubmitEnabled = ValueNotifier<bool>(false);

    // Defer initial validation to ensure controller is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validateCarWashName();
      }
    });
  }

  @override
  void dispose() {
    _carWashNameController?.removeListener(_validateCarWashName);
    _carRegController.dispose();
    _washTypeController.dispose();
    _totalAmountController.dispose();
    _isSubmitEnabled.dispose();
    // The Autocomplete widget manages its own controller's disposal.
    super.dispose();
  }

  void _validateCarWashName() {
    if (_carWashNameController == null) return;
    final carWashProvider = Provider.of<CarWashProvider>(context, listen: false);
    final carWashNames = carWashProvider.carWashes.map((e) => e.name).toList();
    final isNameValid = carWashNames.contains(_carWashNameController!.text);

    if (_isSubmitEnabled.value != isNameValid) {
      _isSubmitEnabled.value = isNameValid;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (widget.claim != null) {
        final newTotalAmount = double.parse(_totalAmountController.text);
        final updatedClaim = widget.claim!.copyWith(
          carWashName: _carWashNameController!.text,
          vehicleReg: _carRegController.text,
          washType: _washTypeController.text,
          washDate: _washDate,
          totalAmount: newTotalAmount,
          status: 'Pending',
        );
        context.read<ClaimsBloc>().add(UpdateClaim(updatedClaim));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Car wash claim updated successfully!'),
              backgroundColor: Colors.green),
        );
      } else {
        final newTotalAmount = double.parse(_totalAmountController.text);
        final newClaim = Claim(
          id: const Uuid().v4(),
          carWashName: _carWashNameController!.text,
          vehicleReg: _carRegController.text,
          washType: _washTypeController.text,
          washDate: _washDate,
          status: 'Pending',
          submittedDate: DateTime.now().toIso8601String(),
          totalAmount: newTotalAmount,
          isCarWashClaim: true,
        );
        context.read<ClaimsBloc>().add(AddClaim(newClaim));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Car wash claim submitted successfully!'),
              backgroundColor: Colors.green),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use watch here to react to changes in the car wash list itself.
    final carWashProvider = context.watch<CarWashProvider>();
    final carWashNames = carWashProvider.carWashes.map((e) => e.name).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24.0,
          right: 24.0,
          top: 24.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.claim == null
                        ? 'Car Wash Booking'
                        : 'Edit Car Wash Booking',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Autocomplete<String>(
                // Set initial value for editing.
                initialValue: TextEditingValue(text: widget.claim?.carWashName ?? ''),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return carWashNames.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  // When a user selects an item, we manually trigger validation.
                  _validateCarWashName();
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  // This is the correct pattern to safely manage the controller.
                  if (_carWashNameController != fieldController) {
                    _carWashNameController?.removeListener(_validateCarWashName);
                    _carWashNameController = fieldController;
                    _carWashNameController!.addListener(_validateCarWashName);
                  }

                  return TextFormField(
                    controller: fieldController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Car Wash Name',
                      hintText: 'Search and select a car wash',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !carWashNames.contains(value)) {
                        return 'Please select a valid car wash from the list';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _washTypeController,
                decoration: InputDecoration(
                  labelText: 'Type of Wash',
                  hintText: 'e.g., Full Valet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Car Registration',
                  hintText: 'e.g., GP 123 AB',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your car registration number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Total Amount',
                  hintText: 'e.g., 250.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: _isSubmitEnabled,
                builder: (context, isEnabled, child) {
                  return ElevatedButton(
                    onPressed: isEnabled ? _submitForm : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      disabledBackgroundColor:
                          Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      disabledForegroundColor:
                          Theme.of(context).colorScheme.onSecondary.withOpacity(0.7),
                    ),
                    child: const Text('Submit Claim'),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _washDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _washDate) {
      setState(() {
        _washDate = picked;
      });
    }
  }
}

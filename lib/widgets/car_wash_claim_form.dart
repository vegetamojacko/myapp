import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:uuid/uuid.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_event.dart';
import '../models/claim.dart';
import '../providers/car_wash_provider.dart';
import '../models/car_wash.dart';

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
  late TextEditingController _carWashNameController;
  DateTime? _washDate;

  @override
  void initState() {
    super.initState();
    _carRegController = TextEditingController(text: widget.claim?.vehicleReg);
    _washTypeController = TextEditingController(text: widget.claim?.washType);
    _totalAmountController =
        TextEditingController(text: widget.claim?.totalAmount.toString() ?? '');
    _carWashNameController =
        TextEditingController(text: widget.claim?.carWashName);
    _washDate = widget.claim?.washDate ?? DateTime.now();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (widget.claim != null) {
        // We are updating an existing claim
        final newTotalAmount = double.parse(_totalAmountController.text);

        final updatedClaim = widget.claim!.copyWith(
          carWashName: _carWashNameController.text,
          vehicleReg: _carRegController.text,
          washType: _washTypeController.text,
          washDate: _washDate,
          totalAmount: newTotalAmount,
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
        final newTotalAmount = double.parse(_totalAmountController.text);
        final newClaim = Claim(
          id: const Uuid().v4(),
          carWashName: _carWashNameController.text,
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

                // Form Fields
                SearchField(
                  suggestions: carWashes
                      .map((carWash) =>
                          SearchFieldListItem(carWash.name, item: carWash))
                      .toList(),
                  suggestionState: Suggestion.expand,
                  textInputAction: TextInputAction.next,
                  controller: _carWashNameController,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !carWashes.any((wash) => wash.name == value)) {
                      return 'Please select a valid car wash from the list';
                    }
                    return null;
                  },
                  searchInputDecoration: SearchInputDecoration(
                    labelText: 'Car Wash Name',
                    hintText: 'Select a car wash',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSuggestionTap: (SearchFieldListItem<dynamic> x) {
                    _carWashNameController.text = (x.item as CarWash).name;
                    FocusScope.of(context).unfocus();
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

                // Date Field
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
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

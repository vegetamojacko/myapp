import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_event.dart';
import '../models/claim.dart';

class AddClaimForm extends StatefulWidget {
  const AddClaimForm({super.key});

  @override
  State<AddClaimForm> createState() => _AddClaimFormState();
}

class _AddClaimFormState extends State<AddClaimForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _ticketCostController;
  late TextEditingController _numTicketsController;
  DateTime? _eventDate;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController();
    _ticketCostController = TextEditingController();
    _numTicketsController = TextEditingController();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _eventDate) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final ticketCost = double.tryParse(_ticketCostController.text) ?? 0.0;
      final numTickets = int.tryParse(_numTicketsController.text) ?? 0;

      final newClaim = Claim(
        id: const Uuid().v4(), // Generate a unique ID
        eventName: _eventNameController.text,
        eventDate: _eventDate,
        ticketCost: ticketCost,
        numTickets: numTickets,
        status: 'Pending',
        submittedDate: DateTime.now().toIso8601String(),
        totalAmount: ticketCost * numTickets,
        isCarWashClaim: false,
      );

      context.read<ClaimsBloc>().add(AddClaim(newClaim));
      Navigator.of(context).pop(true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Event Claim',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the event name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _eventDate == null
                        ? 'No date chosen'
                        : 'Event Date: \${_eventDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Choose Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ticketCostController,
              decoration: const InputDecoration(
                labelText: 'Ticket Cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the ticket cost';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numTicketsController,
              decoration: const InputDecoration(
                labelText: 'Number of Tickets',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number of tickets';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit Claim'),
            ),
          ],
        ),
      ),
    );
  }
}

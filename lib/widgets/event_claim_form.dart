import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_event.dart';
import '../models/claim.dart';

class EventClaimForm extends StatefulWidget {
  final Claim? claim;

  const EventClaimForm({super.key, this.claim});

  @override
  State<EventClaimForm> createState() => _EventClaimFormState();
}

class _EventClaimFormState extends State<EventClaimForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _ticketCostController;
  late TextEditingController _numTicketsController;
  late TextEditingController _deliveryAddressController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.claim?.eventName);
    _ticketCostController = TextEditingController(
      text: widget.claim?.ticketCost?.toString(),
    );
    _numTicketsController = TextEditingController(
      text: widget.claim?.numTickets?.toString(),
    );
    _deliveryAddressController = TextEditingController(
      text: widget.claim?.deliveryAddress,
    );
    _selectedDate = widget.claim?.eventDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _ticketCostController.dispose();
    _numTicketsController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final ticketCost = double.parse(_ticketCostController.text);
      final numTickets = int.parse(_numTicketsController.text);

      if (widget.claim != null) {
        // Update existing claim
        final updatedClaim = widget.claim!.copyWith(
          eventName: _eventNameController.text,
          eventDate: _selectedDate,
          ticketCost: ticketCost,
          numTickets: numTickets,
          deliveryAddress: _deliveryAddressController.text,
          totalAmount: ticketCost * numTickets,
        );
        context.read<ClaimsBloc>().add(UpdateClaim(updatedClaim));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event claim updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Add new claim
        final newClaim = Claim(
          id: const Uuid().v4(),
          eventName: _eventNameController.text,
          eventDate: _selectedDate,
          totalAmount: ticketCost * numTickets,
          status: 'Pending',
          isCarWashClaim: false,
          numTickets: numTickets,
          deliveryAddress: _deliveryAddressController.text,
          submittedDate: DateTime.now().toIso8601String(),
        );
        context.read<ClaimsBloc>().add(AddClaim(newClaim));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event claim submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.claim != null
                        ? 'Edit Event Claim'
                        : 'Claim Event Tickets',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Event Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                controller: TextEditingController(
                  text: DateFormat.yMMMd().format(_selectedDate),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ticketCostController,
                decoration: const InputDecoration(
                  labelText: 'Ticket Cost (R)',
                  border: OutlineInputBorder(),
                  prefixText: 'R ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _deliveryAddressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'e.g. 123 test street, dlamini, 1818',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the delivery address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(widget.claim != null ? 'Update' : 'Submit'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

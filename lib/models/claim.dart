import 'package:equatable/equatable.dart';

class Claim extends Equatable {
  final String eventName;
  final DateTime eventDate;
  final double ticketCost;
  final int numTickets;
  final double totalAmount;
  final String submittedDate;

  const Claim({
    required this.eventName,
    required this.eventDate,
    required this.ticketCost,
    required this.numTickets,
    required this.totalAmount,
    required this.submittedDate,
  });

  @override
  List<Object> get props => [
        eventName,
        eventDate,
        ticketCost,
        numTickets,
        totalAmount,
        submittedDate,
      ];

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      eventName: json['eventName'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      ticketCost: json['ticketCost'] as double,
      numTickets: json['numTickets'] as int,
      totalAmount: json['totalAmount'] as double,
      submittedDate: json['submittedDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'ticketCost': ticketCost,
      'numTickets': numTickets,
      'totalAmount': totalAmount,
      'submittedDate': submittedDate,
    };
  }
}

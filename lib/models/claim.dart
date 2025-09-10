
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Claim extends Equatable {
  final String eventName;
  final DateTime? eventDate;
  final double? ticketCost;
  final int? numTickets;
  final double totalAmount;
  final String submittedDate;
  final String status; // 'Pending', 'Approved', 'Cancelled'

  // Car Wash specific fields
  final String? washType;
  final String? vehicleReg;
  final DateTime? washDate;
  final TimeOfDay? arrivalTime;

  const Claim({
    required this.eventName,
    required this.totalAmount,
    required this.submittedDate,
    required this.status,
    this.eventDate,
    this.ticketCost,
    this.numTickets,
    this.washType,
    this.vehicleReg,
    this.washDate,
    this.arrivalTime,
  });

  @override
  List<Object?> get props => [
        eventName,
        eventDate,
        ticketCost,
        numTickets,
        totalAmount,
        submittedDate,
        status,
        washType,
        vehicleReg,
        washDate,
        arrivalTime,
      ];

  bool get isCarWashClaim => washType != null;

  Claim copyWith({
    String? eventName,
    DateTime? eventDate,
    double? ticketCost,
    int? numTickets,
    double? totalAmount,
    String? submittedDate,
    String? status,
    String? washType,
    String? vehicleReg,
    DateTime? washDate,
    TimeOfDay? arrivalTime,
  }) {
    return Claim(
      eventName: eventName ?? this.eventName,
      eventDate: eventDate ?? this.eventDate,
      ticketCost: ticketCost ?? this.ticketCost,
      numTickets: numTickets ?? this.numTickets,
      totalAmount: totalAmount ?? this.totalAmount,
      submittedDate: submittedDate ?? this.submittedDate,
      status: status ?? this.status,
      washType: washType ?? this.washType,
      vehicleReg: vehicleReg ?? this.vehicleReg,
      washDate: washDate ?? this.washDate,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      eventName: json['eventName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      submittedDate: json['submittedDate'] as String,
      status: json['status'] as String? ?? 'Pending',
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'] as String)
          : null,
      ticketCost: (json['ticketCost'] as num?)?.toDouble(),
      numTickets: json['numTickets'] as int?,
      washType: json['washType'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      washDate: json['washDate'] != null
          ? DateTime.parse(json['washDate'] as String)
          : null,
      arrivalTime: json['arrivalTime'] != null
          ? TimeOfDay(
              hour: int.parse((json['arrivalTime'] as String).split(':')[0]),
              minute: int.parse((json['arrivalTime'] as String).split(':')[1]),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'totalAmount': totalAmount,
      'submittedDate': submittedDate,
      'status': status,
      'eventDate': eventDate?.toIso8601String(),
      'ticketCost': ticketCost,
      'numTickets': numTickets,
      'washType': washType,
      'vehicleReg': vehicleReg,
      'washDate': washDate?.toIso8601String(),
      'arrivalTime': arrivalTime != null ? '${arrivalTime!.hour}:${arrivalTime!.minute}' : null,
    };
  }
}

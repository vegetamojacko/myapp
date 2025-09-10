import 'package:equatable/equatable.dart';

class Claim extends Equatable {
  final String id;
  final double totalAmount;
  final String submittedDate;
  final String status; // 'Pending', 'Approved', 'Cancelled'

  // Event specific fields
  final String? eventName;
  final DateTime? eventDate;
  final double? ticketCost;
  final int? numTickets;

  // Car Wash specific fields
  final String? washType;
  final String? vehicleReg;
  final DateTime? washDate;

  final bool isCarWashClaim;

  const Claim({
    required this.id,
    required this.totalAmount,
    required this.submittedDate,
    required this.status,
    this.eventName,
    this.eventDate,
    this.ticketCost,
    this.numTickets,
    this.washType,
    this.vehicleReg,
    this.washDate,
    this.isCarWashClaim = false,
  });

  @override
  List<Object?> get props => [
        id,
        totalAmount,
        submittedDate,
        status,
        eventName,
        eventDate,
        ticketCost,
        numTickets,
        washType,
        vehicleReg,
        washDate,
        isCarWashClaim,
      ];

  Claim copyWith({
    String? id,
    double? totalAmount,
    String? submittedDate,
    String? status,
    String? eventName,
    DateTime? eventDate,
    double? ticketCost,
    int? numTickets,
    String? washType,
    String? vehicleReg,
    DateTime? washDate,
    bool? isCarWashClaim,
  }) {
    return Claim(
      id: id ?? this.id,
      totalAmount: totalAmount ?? this.totalAmount,
      submittedDate: submittedDate ?? this.submittedDate,
      status: status ?? this.status,
      eventName: eventName ?? this.eventName,
      eventDate: eventDate ?? this.eventDate,
      ticketCost: ticketCost ?? this.ticketCost,
      numTickets: numTickets ?? this.numTickets,
      washType: washType ?? this.washType,
      vehicleReg: vehicleReg ?? this.vehicleReg,
      washDate: washDate ?? this.washDate,
      isCarWashClaim: isCarWashClaim ?? this.isCarWashClaim,
    );
  }

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      submittedDate: json['submittedDate'] as String,
      status: json['status'] as String? ?? 'Pending',
      eventName: json['eventName'] as String?,
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
      isCarWashClaim: json['isCarWashClaim'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'submittedDate': submittedDate,
      'status': status,
      'eventName': eventName,
      'eventDate': eventDate?.toIso8601String(),
      'ticketCost': ticketCost,
      'numTickets': numTickets,
      'washType': washType,
      'vehicleReg': vehicleReg,
      'washDate': washDate?.toIso8601String(),
      'isCarWashClaim': isCarWashClaim,
    };
  }
}

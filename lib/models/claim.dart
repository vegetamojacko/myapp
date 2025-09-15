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
  final String? deliveryAddress;

  // Car Wash specific fields
  final String? washType;
  final String? vehicleReg;
  final DateTime? washDate;
  final String? carWash;


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
    this.deliveryAddress,
    this.washType,
    this.vehicleReg,
    this.washDate,
    this.isCarWashClaim = false,
    this.carWash,
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
        deliveryAddress,
        washType,
        vehicleReg,
        washDate,
        isCarWashClaim,
        carWash,
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
    String? deliveryAddress,
    String? washType,
    String? vehicleReg,
    DateTime? washDate,
    bool? isCarWashClaim,
    String? carWash,
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
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      washType: washType ?? this.washType,
      vehicleReg: vehicleReg ?? this.vehicleReg,
      washDate: washDate ?? this.washDate,
      isCarWashClaim: isCarWashClaim ?? this.isCarWashClaim,
      carWash: carWash ?? this.carWash,
    );
  }

  factory Claim.fromJson(Map<dynamic, dynamic> json) {
    return Claim(
      id: json['id'] as String,
      totalAmount: double.tryParse(json['totalAmount'].toString()) ?? 0.0,
      submittedDate: json['submittedDate'] as String,
      status: json['status'] as String? ?? 'Pending',
      eventName: json['eventName'] as String?,
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'] as String)
          : null,
      ticketCost: (json['ticketCost'] as num?)?.toDouble(),
      numTickets: (json['numTickets'] as num?)?.toInt(),
      deliveryAddress: json['deliveryAddress'] as String?,
      washType: json['washType'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      washDate: json['washDate'] != null
          ? DateTime.parse(json['washDate'] as String)
          : null,
      isCarWashClaim: json['isCarWashClaim'] as bool? ?? false,
      carWash: json['carWash'] as String?,
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
      'deliveryAddress': deliveryAddress,
      'washType': washType,
      'vehicleReg': vehicleReg,
      'washDate': washDate?.toIso8601String(),
      'isCarWashClaim': isCarWashClaim,
      'carWash': carWash,
    };
  }
}

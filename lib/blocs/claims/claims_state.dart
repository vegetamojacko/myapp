import 'package:equatable/equatable.dart';

import '../../models/claim.dart';

abstract class ClaimsState extends Equatable {
  const ClaimsState();

  @override
  List<Object> get props => [];
}

class ClaimsInitial extends ClaimsState {}

class ClaimsLoaded extends ClaimsState {
  final List<Claim> claims;

  const ClaimsLoaded(this.claims);

  @override
  List<Object> get props => [claims];
}

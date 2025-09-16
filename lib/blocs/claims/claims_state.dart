import 'package:equatable/equatable.dart';

import '../../models/claim.dart';

abstract class ClaimsState extends Equatable {
  const ClaimsState();

  @override
  List<Object> get props => [];
}

class ClaimsInitial extends ClaimsState {}

class ClaimsLoading extends ClaimsState {}

class ClaimsLoaded extends ClaimsState {
  final List<Claim> claims;

  const ClaimsLoaded(this.claims);

  @override
  List<Object> get props => [claims];
}

class ClaimsError extends ClaimsState {
  final String message;

  const ClaimsError(this.message);

  @override
  List<Object> get props => [message];
}

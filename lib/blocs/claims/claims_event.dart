import 'package:equatable/equatable.dart';

import '../../models/claim.dart';

abstract class ClaimsEvent extends Equatable {
  const ClaimsEvent();

  @override
  List<Object> get props => [];
}

class LoadClaims extends ClaimsEvent {}

class AddClaim extends ClaimsEvent {
  final Claim claim;

  const AddClaim(this.claim);

  @override
  List<Object> get props => [claim];
}

class ClearClaims extends ClaimsEvent {}

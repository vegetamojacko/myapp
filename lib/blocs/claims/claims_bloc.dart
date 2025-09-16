import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/claim.dart';
import '../../services/storage_service.dart';
import 'claims_event.dart';
import 'claims_state.dart';

class ClaimsBloc extends Bloc<ClaimsEvent, ClaimsState> {
  final StorageService _storageService;
  StreamSubscription? _claimsSubscription;

  ClaimsBloc({required StorageService storageService})
      : _storageService = storageService,
        super(ClaimsInitial()) {
    on<LoadClaims>(_onLoadClaims);
    on<AddClaim>(_onAddClaim);
    on<UpdateClaim>(_onUpdateClaim);
    on<DeleteClaim>(_onDeleteClaim);
    on<ClearClaims>(_onClearClaims);
    on<_ClaimsUpdated>(_onClaimsUpdated);
  }

  @override
  Future<void> close() {
    _claimsSubscription?.cancel();
    return super.close();
  }

  void _onLoadClaims(LoadClaims event, Emitter<ClaimsState> emit) {
    emit(ClaimsLoading());
    _claimsSubscription?.cancel();
    _claimsSubscription = _storageService.getClaimsStream().listen(
      (claims) {
        add(_ClaimsUpdated(claims));
      },
      onError: (error) {
        emit(ClaimsError("Failed to load claims: $error"));
      },
    );
  }
  
  void _onAddClaim(AddClaim event, Emitter<ClaimsState> emit) async {
    final currentState = state;
    if (currentState is ClaimsLoaded) {
      try {
        final List<Claim> updatedClaims = List.from(currentState.claims)..insert(0, event.claim);
        await _storageService.saveClaims(updatedClaims);
        // No need to emit here, the stream will do it
      } catch (e) {
        emit(ClaimsError("Failed to add claim: $e"));
      }
    }
  }

  void _onUpdateClaim(UpdateClaim event, Emitter<ClaimsState> emit) async {
    final currentState = state;
    if (currentState is ClaimsLoaded) {
      try {
        final List<Claim> updatedClaims = currentState.claims.map((claim) {
          return claim.submittedDate == event.claim.submittedDate ? event.claim : claim;
        }).toList();
        await _storageService.saveClaims(updatedClaims);
      } catch (e) {
        emit(ClaimsError("Failed to update claim: $e"));
      }
    }
  }

  void _onDeleteClaim(DeleteClaim event, Emitter<ClaimsState> emit) async {
    final currentState = state;
    if (currentState is ClaimsLoaded) {
      try {
        final List<Claim> updatedClaims = currentState.claims
            .where((claim) => claim.submittedDate != event.claim.submittedDate)
            .toList();
        await _storageService.saveClaims(updatedClaims);
      } catch (e) {
        emit(ClaimsError("Failed to delete claim: $e"));
      }
    }
  }

  void _onClearClaims(ClearClaims event, Emitter<ClaimsState> emit) async {
    try {
      await _storageService.clearClaims();
      // The stream will emit an empty list
    } catch (e) {
      emit(ClaimsError("Failed to clear claims: $e"));
    }
  }

  void _onClaimsUpdated(_ClaimsUpdated event, Emitter<ClaimsState> emit) {
    emit(ClaimsLoaded(event.claims));
  }
}

// Add this new private event
class _ClaimsUpdated extends ClaimsEvent {
  final List<Claim> claims;

  const _ClaimsUpdated(this.claims);

  @override
  List<Object> get props => [claims];
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/claim.dart';
import '../../services/storage_service.dart';
import 'claims_event.dart';
import 'claims_state.dart';

class ClaimsBloc extends Bloc<ClaimsEvent, ClaimsState> {
  final StorageService _storageService;

  ClaimsBloc({required StorageService storageService})
      : _storageService = storageService,
        super(ClaimsInitial()) {
    on<LoadClaims>(_onLoadClaims);
    on<AddClaim>(_onAddClaim);
    on<ClearClaims>(_onClearClaims);
  }

  void _onLoadClaims(LoadClaims event, Emitter<ClaimsState> emit) async {
    if (state is! ClaimsLoaded) {
      final claims = await _storageService.loadClaims();
      emit(ClaimsLoaded(claims));
    }
  }

  void _onAddClaim(AddClaim event, Emitter<ClaimsState> emit) async {
    final currentState = state;
    List<Claim> currentClaims = [];

    if (currentState is ClaimsLoaded) {
      currentClaims = currentState.claims;
    } else {
      currentClaims = await _storageService.loadClaims();
    }

    final List<Claim> updatedClaims = List.from(currentClaims)
      ..insert(0, event.claim);

    await _storageService.saveClaims(updatedClaims);

    emit(ClaimsLoaded(updatedClaims));
  }

  void _onClearClaims(ClearClaims event, Emitter<ClaimsState> emit) async {
    await _storageService.clearClaims();
    emit(const ClaimsLoaded([]));
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/api_client.dart';
import 'match_model.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(ref.watch(apiClientProvider));
});

final matchesProvider = FutureProvider<List<NbaMatch>>((ref) {
  return ref.watch(matchRepositoryProvider).listMatches();
});

final matchProvider = FutureProvider.family<NbaMatch, int>((ref, matchId) {
  return ref.watch(matchRepositoryProvider).getMatch(matchId);
});

class MatchRepository {
  MatchRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<NbaMatch>> listMatches() async {
    final response = await _apiClient.dio.get('/matches');
    final data = _apiClient.unwrap<List<dynamic>>(response);
    return data
        .cast<Map<String, dynamic>>()
        .map(NbaMatch.fromJson)
        .toList(growable: false);
  }

  Future<NbaMatch> getMatch(int matchId) async {
    final response = await _apiClient.dio.get('/matches/$matchId');
    final data = _apiClient.unwrap<Map<String, dynamic>>(response);
    return NbaMatch.fromJson(data);
  }
}

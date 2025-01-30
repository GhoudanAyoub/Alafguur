import '../../../app/service/auth_service.dart';
import '../../../app/service/http_service.dart';

class RootService {
  final HttpService httpService;
  final AuthService authService;

  // we have to send data hashes every time to prevent getting old data
  Map<String, String?> _serverUpdatesDataHashes = {};
  final String _serverUpdatesRequestName = 'server_updates';

  RootService({
    required this.httpService,
    required this.authService,
  });

  /// load site settings
  Future<Map<String, dynamic>?> loadSettings() async {
    return await this.httpService.get('configs');
  }

  // ping api
  Future<dynamic> pingApi() async {
    final response = await httpService.get('check-api');

    return response;
  }

  /// cancel an active server updates request
  void cancelServerUpdatesRequest({
    bool cleanDataHashes = true,
    bool useDelay = true,
  }) {
    httpService.cancelRequestByName(
      _serverUpdatesRequestName,
      useDelay: useDelay,
    );

    if (cleanDataHashes) {
      _serverUpdatesDataHashes.clear();
    }
  }

  /// get a list of updates from the server
  Future<Map<String, dynamic>?> getServerUpdates() async {
    final response = await httpService.post(
      'server-updates',
      data: {
        'token': authService.isAuthenticated ? authService.authToken : null,
        'data_hashes': _serverUpdatesDataHashes,
      },
      requestName: _serverUpdatesRequestName,
    );

    // the request might be cancelled
    if (response == null) {
      return response;
    }

    // save the data hashes for the next requests to avoid getting old data
    if (response.containsKey('data_hashes')) {
      // update hashes
      response['data_hashes'].forEach((key, dataHash) {
        _serverUpdatesDataHashes[key] = dataHash;
      });
    }

    return response.containsKey('data') ? response['data'] : {};
  }
}

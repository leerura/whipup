import 'package:test/test.dart';
import 'package:api_client/api_client.dart';


/// tests for AuthApi
void main() {
  final instance = ApiClient().getAuthApi();

  group(AuthApi, () {
    //Future<LoginResponse> loginWithKakao(KakaoLoginRequest kakaoLoginRequest) async
    test('test loginWithKakao', () async {
      // TODO
    });

  });
}

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);

  runApp(const WhipupApp());
}

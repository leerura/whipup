## 목적

WhipUp V2의 로컬 개발에서 Flutter App이 어떤 Backend에 연결하는지와 Physical iPhone의 LAN 접근 규칙을 정의한다.

## Backend 연결 규칙

개발 시 Backend 위치는 실행 대상에 따라 고정한다.

```plain text
iOS Simulator
→ Mac Local Backend
→ http://localhost:8080

Physical iPhone
→ Home Wi-Fi / LAN
→ Windows Development Server
→ http://<WINDOWS_LAN_IP>:8080
```

Simulator와 Physical iPhone이 같은 Backend 주소를 사용하도록 맞추지 않는다. Simulator는 Mac의 local Backend를 사용하고, Physical iPhone은 Windows 개발 서버를 사용한다.

Backend는 두 머신 모두 기존 Docker Compose 구성을 사용한다.

## API Base URL 선택

Flutter가 실행 환경을 자동 판별하여 API Base URL을 선택한다. 개발자가 Run할 때 API 주소를 별도로 선택하지 않는다.

```plain text
iOS Simulator
→ http://localhost:8080

Physical iPhone
→ LocalConfig.deviceApiBaseUrl
```

iOS의 Simulator / Physical Device 판별은 `device_info_plus`의 `isPhysicalDevice`를 사용한다.

환경 판별은 App startup에서 한 번 수행하고, 결정된 Base URL을 `core/config`에서 API Client에 주입한다. Feature 코드나 Generated API Client 내부에서 실행 환경을 다시 판별하거나 주소를 하드코딩하지 않는다.

Physical iPhone에서 Device API URL이 설정되지 않은 경우 `localhost`로 fallback하지 않는다. 설정 누락을 명확한 development configuration error로 처리한다.

Xcode에서는 Simulator 또는 Physical iPhone을 선택한 뒤 동일하게 Run하여 실행한다.

## Local Device Configuration

Windows 개발 서버의 실제 LAN 주소는 Git에 포함하지 않는 local configuration에서 관리한다.

```plain text
app/lib/core/config/
├── app_config.dart
├── local_config.dart
└── local_config.example.dart
```

`local_config.dart`는 Git에 commit하지 않는다. Repository에는 구조 참고용 `local_config.example.dart`만 포함한다.

예:

```dart
abstract final class LocalConfig {
  static const deviceApiBaseUrl = 'http://192.168.x.x:8080';
}
```

Windows LAN IP는 현재 DHCP 주소를 사용하며 고정 IP 또는 DHCP reservation을 MVP 개발환경의 필수 조건으로 두지 않는다. IP가 변경되면 `local_config.dart`의 주소 한 곳만 갱신한다.

## iOS Local Network

Physical iPhone과 Windows 개발 서버는 동일한 Wi-Fi / LAN에 연결되어 있어야 한다.

`Info.plist`에 Local Network 사용 목적을 선언한다.

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>개발 서버와 통신하기 위해 로컬 네트워크를 사용합니다.</string>
```

Local Network 권한이 거부된 경우 Physical iPhone은 Windows 개발 서버에 접근할 수 없다.

## App Transport Security

Windows 개발 서버는 Local Development에서 HTTP를 사용한다.

```plain text
http://<WINDOWS_LAN_IP>:8080
```

ATS 전체를 해제하는 `NSAllowsArbitraryLoads = YES`는 사용하지 않는다.

`NSAllowsLocalNetworking = YES`로 Local Network 사용 의도를 명시한다. Physical iPhone이 숫자 IP에 HTTP로 접근하므로 iOS 17 이상에서는 현재 개발 LAN의 Private IPv4 CIDR을 `NSExceptionDomains`에 등록하고 해당 범위에만 `NSExceptionAllowsInsecureHTTPLoads = YES`를 적용한다.

정확한 Windows Host IP 하나가 아니라 개발 LAN의 CIDR을 예외로 사용하여 DHCP로 Host IP가 바뀌어도 ATS 설정을 수정하지 않도록 한다.

Production 환경이 추가되면 HTTPS를 사용하며 Local Development용 ATS 예외에 의존하지 않는다.

## Windows Network Exposure

Docker Compose의 Backend Port는 Windows Host의 `8080`에 expose한다.

```yaml
ports:
  - "8080:8080"
```

Windows Firewall에서는 Private Network에 대해서만 TCP `8080` inbound를 허용한다.

공유기 Port Forwarding은 설정하지 않는다. Windows 개발 서버는 동일 LAN 내부에서만 접근하는 것을 기본으로 하며 인터넷에 직접 공개하지 않는다.

## 현재 범위에서 하지 않는 것

- Windows LAN IP 고정 또는 DHCP reservation을 필수화하지 않는다.
- 공유기 Port Forwarding을 사용하지 않는다.
- 개발 서버를 Public Internet에 공개하지 않는다.
- Local Development를 위해 `NSAllowsArbitraryLoads`로 ATS 전체를 해제하지 않는다.
- Production Network / Deployment 규칙은 여기서 정의하지 않는다.

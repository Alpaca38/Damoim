# 다모임(Damoim)

## 프로젝트 소개
> 보드게임 같이할 사람들을 모집하거나 참여할 수 있는 앱 서비스

### 화면
| 모임 둘러보기 | 모임 상세화면 | 댓글 화면 | 지도 화면 | 모임 검색 | 프로필 화면 |
| --- | --- | --- | --- | --- | --- |
| ![Simulator Screenshot - iPhone 15 Pro - 2024-09-02 at 12 49 42](https://github.com/user-attachments/assets/581c693e-fc90-452a-83a9-39124b3db077) | ![Simulator Screenshot - iPhone 15 Pro - 2024-09-02 at 12 53 12](https://github.com/user-attachments/assets/f9cf5e0f-ec83-4268-ae47-3c84160d1248) | ![Simulator Screenshot - iPhone 15 Pro - 2024-09-02 at 12 55 20](https://github.com/user-attachments/assets/f2004e06-914b-4878-9c8a-1dac74ee0f7d) | ![Simulator Screenshot - iPhone 15 Pro - 2024-09-02 at 12 58 23](https://github.com/user-attachments/assets/09108b98-aad0-4351-9d96-eb77487aed09) | ![Simulator Screenshot - iPhone 15 Pro - 2024-09-02 at 12 56 31](https://github.com/user-attachments/assets/17e9a810-541a-4a8a-b018-e8d6c3e185ca) | ![Simulator Screenshot - iPhone 15 Pro - 2024-09-02 at 12 57 25](https://github.com/user-attachments/assets/99dbcd59-bf15-4802-812b-b34876b985f5) |

### 최소 지원 버전
> iOS 16

### 개발 기간
> 2024.08.14 ~ 2024.09.01

### 개발 환경
- **IDE** : Xcode 15.4
- **Language** : Swift 5.10

### 핵심 기능
**1. 모임 관리**

    - 보드게임 모임 둘러보기
    - 모임 생성/삭제/찜/참여(결제)
    - 상세 모임 정보 확인 및 유료모임 PG결제

**2. 위치 기반 서비스**

    - 지도에서 주변 모임 확인
    - 해당 모임의 대표 이미지로 시각화

**3. 보드게임 커뮤니티**

    - 댓글 작성/수정/삭제
    - 프로필 관리
    - 사용자 팔로우

### 사용 기술 및 라이브러리
- UIKit, SnapKit, MVVM
- NWPathMonitor
- RxSwift, RxDataSource
- Alamofire
- JWT
- 네이버 지역 검색 API, 카카오 지도 SDK

### 주요 기술
#### 네트워크
    - URLRequestConvertible을 채택한 TargetType 프로토콜로 Router 설계
    - 열거형과 연관값으로 Router를 구성하여 요청을 구조화
    - 열거형으로 커스텀 에러를 구성해 에러 발생시 유저가 인지할 수 있도록 Toast 형태로 description을 표시

#### 토큰갱신
    - 보안을 위해 짧은 유효기간을 갖는 AccessToken과 갱신하기 위한
    - AccessToken의 유효성을 검사하는 Adapt와 토큰을 갱신하고 RefreshToken 활용
    - 실패한 요청을 재시도하는 Retry로 Interceptor 설계

#### 이미지 업로드
    - UIGraphicsGetImageFromCurrentImageContext()로 모바일 환경에 맞는 사이즈로 리사이징해 서버에 업로드
    - 이미지 데이터를 .jpegData(compressionQuality: 0.5)로 압축하여 MultipartFormData 형식으로 서버에 업로드

#### NWPathMonitor
    - 네트워크 상태를 PassthroughSubject<Bool, Never>()로 관리하여 path.status 이벤트를 전달 받고 Subject를 구독하는 Base Controller를 구성해 뷰에 상속
    - Bool 값의 변화에 따라 상단에 Custom UI인 네트워크 상태 바 표시

#### 화면 전환
    - 이전 화면이 더 이상 메모리에 남아있지 않아도 되는 경우, window.rootViewController를 갱신하는 것으로 화면 전환
    - 불필요한 인스턴스 생성을 하지 않기 위해 싱글톤 패턴으로 설계

#### 페이지네이션
    - IndexPath.item값이 총 item 개수와 동일한 순간에 prefetching을 통해 페이지네이션 구현
    - RxSwift의 .filter 연산자로 마지막 페이지 도달 시, 포스트 조회 요청으로 가는 스트림 중단

#### Single
    - 네트워크 요청에 Observable 사용 시 의도치 않은 다중 값 방출이나 스트림이 종료되지 않아 불필요한 리소스를 사용하게 되는 문제 발생
    - 성공과 에러만을 방출하고 스트림이 종료되는 Single 활용

#### 커스텀 UI
    - Custom UI component를 구성해 재사용성 증대
    - Compositional layout 및 RxDataSource 로 다양한 UI 구성

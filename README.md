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
- **Language** : Swift 5.7

### 핵심 기능
1. 모임 관리
    - 보드게임 모임 둘러보기
    - 모임 생성/삭제/찜/참여(결제) 기능
    - 상세 화면에서 모임 정보 확인

2. 위치 기반 서비스
    - 지도에서 주변 모임 확인
    - POI(장소) 데이터 통합 및 시각화

3. 보드게임 커뮤니티
    - 모임 검색 기능
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
#### 아키텍쳐
- **MVVM**
![mvvm](https://github.com/user-attachments/assets/a585c0e8-2c06-4a77-83c6-f73606298034)
  - RxSwift를 이용해 데이터 바인딩을 구현
  - Input-Output 패턴을 이용해 VM과 VC의 데이터 바인딩을 구현

#### 네트워킹
- **Router**
  - REST API 통신
  - 라우터 패턴과 TargetType 프로토콜을 이용해 네트워크 작업을 추상화
  - RxSwift의 Single을 사용해 네트워크 요청이 실패 했을 때에도 스트림이 유지

- **JWT 관리**
  - UserDefaults를 활용한 토큰 관리
  - access token & refresh token 인증 구현

- **네트워크 에러 처리**
  - 커스텀 에러를 만들어 상태코드에 따라 다르게 처리

#### UI/UX
- **UIKit & SnapKit**
  - 코드 기반 UI 구현
  - 오토레이아웃 관리

- **NWPathMonitor**
  - 네트워크 상태 모니터링
  - 상태 변화에 따른 뷰 변경

- **RxSwift & RxDataSource**
  - 반응형 프로그래밍 구현
  - 데이터 스트림 관리

#### 페이지네이션
  - 커서 기반 페이지네이션 구현
  - 스트림에 .filter 메서드를 이용해 마지막 페이지에서는 네트워크 요청을 하지 않게 처리

#### 결제
  - 포스트 기반 결제 구현
  - 실재하는 상품인지 서버에 검증요청을 거쳐 통과 시 최종 결제

#### 이미지 업로드
  - multipart/form-data 형태로 서버에 이미지 업로드
  - 이미지 압축 후 업로드

#### 지도
  - 게시된 모임들을 지도에서 한눈에 볼 수 있게 구현
  - Poi(마커) 데이터 시각화


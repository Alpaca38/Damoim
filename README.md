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
- 보드게임 모임 둘러보기
- 모임 만들기 / 삭제하기 / 찜하기 / 참여하기(결제)
- 지도에서 모임 조회 및 참여하기
- 사용자 프로필 조회 및 수정 및 팔로우
- 모임 검색하기
- 댓글 작성 / 수정 / 삭제

### 사용 기술 및 라이브러리
- UIKit, SnapKit, MVVM
- NWPathMonitor
- RxSwift, RxDataSource
- Alamofire
- JWT
- 네이버 지역 검색 API, 카카오 지도 SDK

### 주요 기술
- **MVVM**
![mvvm](https://github.com/user-attachments/assets/a585c0e8-2c06-4a77-83c6-f73606298034)
  - RxSwift와 Input-Output 패턴을 이용해 VM과 VC의 데이터 바인딩을 구현했습니다.

- **Router**
  - 라우터 패턴과 TargetType 프로토콜을 이용해 네트워크 작업을 추상화 했습니다.
  - RxSwift의 Single을 사용해 네트워크 요청이 실패 했을 때에도 스트림이 유지되도록 했습니다.

- **JWT 관리**
  - 대부분의 서버 통신에 토큰이 필요하기 때문에 access token과 refresh token을 UserDefaults로 저장해 사용했습니다.
  - access 토큰 만료시 refresh token을 이용해 토큰을 재발급 하도록 구현해주었습니다.

- **네트워크 에러 처리**
  - 커스텀 에러를 만들어 상태코드에 따라 다르게 처리해 주었습니다.

- **페이지네이션**
  - 커서 기반 페이지네이션을 구현하였습니다.
  - 스트림에 .filter 메서드를 이용해 마지막 페이지에서는 네트워크 요청을 하지 않게 처리해주었습니다.

- **결제**
  - 포스트 기반 결제를 구현하였습니다.
  - 실재하는 상품인지 서버에 검증요청을 거쳐 통과 시 최종 결제가 이루어집니다.

- **사진을 포함한 포스트**
  - multipart/form-data 형태로 서버에 이미지를 업로드합니다.

- **지도**
  - 게시된 모임들을 지도에서 한눈에 볼 수 있게 구현했습니다.
  - Poi(마커)가 모든 포스트 데이터를 갖고 있게 구현해 Poi에 해당 포스트의 이미지를 표시해주고 클릭시 해당 포스트가 present 되게 구현했습니다.


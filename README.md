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

### 구조
- **MVVM**
![mvvm](https://github.com/user-attachments/assets/a585c0e8-2c06-4a77-83c6-f73606298034)
- **Router**
![Router](https://github.com/user-attachments/assets/467bdb23-b9df-47a5-8158-3ac45ca6e5a4)
- **Repository**
![Repository](https://github.com/user-attachments/assets/e4f91f29-6421-4f98-8761-c9d4599c3637)

### 사용 기술 및 라이브러리
- UIKit, SnapKit, MVVM
- NWPathMonitor
- RxSwift, RxDataSource
- Alamofire
- JWT
- 네이버 지역 검색 API, 카카오 지도 SDK



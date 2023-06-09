# EZENSEOULLO
[Spring Project] 가이드와 함께하는 서울 투어 예약 사이트

## 🏙 프로젝트 소개
'유로자전거나라'(<https://www.eurobike.kr/>)를 참고하여 만든 서울 투어 예약 사이트입니다.
* 가이드 회원은 본인이 운영하는 서울 투어 정보를 등록하고 수정한다.
* 일반 회원은 투어 정보를 확인하고 원하는 날짜의 투어를 예약한다.
* 회원들은 익명 커뮤니티와 후기 게시판에서 여행 정보를 공유할 수 있다.
* 사이트나 투어 관련 문의는 QnA 게시판에서 질문하여 답변을 받을 수 있다.
* 사이트는 가이드에게 플랫폼 이용료를 받아 수익을 창출한다.

## ⌛ 개발 기간
* 2022.03.08. ~ 2022.04.12.

## 👥 담당자별 개발 내용
* 정다희(팀장) - 투어 예약 및 장바구니 기능, 메인 및 내비게이션 바 필터
* 정하영(PL) - 투어 CRUD, 로그 출력 AOP
* 김소연(PM) - 후기 CRUD, 별점 기능
* 서상희(DBA) - 회원관리 기능
* 김수현(테스트) - QnA CRUD, 익명 커뮤니티 CRUD

## ⚙ 개발 환경
* Java 8
* JDK 1.8
* IDE: STS 4
* Framework: Spring
* Database: OracleDB 11g XE
* ORM: MyBatis
* DBCP: HikariCP
* 기타 주요 라이브러리: jdbc, lombok, aspectJ, log4j, log4j2

***
## 🔔 사용법
1. SQL Developer에서 계정 생성 후 'seoullo.sql' 파일을 그대로 실행하여 필요한 테이블과 프로시저, 트리거를 생성한다.
2. root-context.xml의 20~22행(jdbcUrl의 value 값과 username, password)을 수정한다.
3. Tomcat Server의 Modules에서 포트번호는 80, Path는 "/"로 수정한다.
4. src/main/webapp/WEB-INF/views/tour 폴더의 preview.jsp, update.jsp, view.jsp, write.jsp 상단의 [src="//dapi.kakao.~] 부분에 Kakao 지도 API의 appkey를 넣는다.
5. 서버가 정상적으로 구동되는 것을 확인 후 브라우저에서 접속한다.
* 투어 데이터 중 '연남동 카페 투어'와 '인사동 전통체험 투어'에만 상세 정보가 들어가 있고, 이 두 투어만 수정 작업이 정상적으로 동작합니다. 다른 투어들은 리스트 목록을 위해 기본정보와 태그만 INSERT한 데이터임을 참고해 주세요.

***
## 📚 주요 개발 기능

상세한 내용은 Wiki 탭을 참조해 주세요.

투어 리스트 및 정렬 : <https://github.com/LucyJay/ezenseoullo/wiki/1.-투어-리스트>

투어 상세보기(기본정보 탭, 상세보기 탭) : <https://github.com/LucyJay/ezenseoullo/wiki/2.-투어-상세보기>

투어 등록 : <https://github.com/LucyJay/ezenseoullo/wiki/3.-투어-등록>

투어 수정 : <https://github.com/LucyJay/ezenseoullo/wiki/4.-투어-수정>

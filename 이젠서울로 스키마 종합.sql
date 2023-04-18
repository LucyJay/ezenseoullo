-- 후기 제거
drop table review cascade constraints;
drop table review_image cascade constraints;
drop table review_like cascade constraints;
drop sequence review_seq;
drop sequence review_image_seq;
drop trigger review_like_insert_tr;
drop trigger reivew_like_delete_tr;

-- QNA 제거
DROP SEQUENCE anonymous_seq;
DROP SEQUENCE anony_reply_seq;
DROP SEQUENCE qna_seq;
DROP SEQUENCE siteqna_seq;

-- 예약, 장바구니 제거
DROP SEQUENCE bookDetail_seq;
DROP SEQUENCE booking_seq;
DROP SEQUENCE cart_seq;
DROP TABLE bookDetail CASCADE CONSTRAINTS;
DROP TABLE booking CASCADE CONSTRAINTS;
DROP TABLE cart CASCADE CONSTRAINTS;

-- 투어 제거
DROP SEQUENCE checkpoint_seq;
DROP SEQUENCE tourpoint_seq;
DROP SEQUENCE schedule_seq;
DROP SEQUENCE tour_seq;
DROP TABLE checkpoint CASCADE CONSTRAINTS;
DROP TABLE tourpoint CASCADE CONSTRAINTS;
DROP TABLE schedule CASCADE CONSTRAINTS;
DROP TABLE tag CASCADE CONSTRAINTS;
DROP TABLE tourdate CASCADE CONSTRAINTS;
DROP TABLE tour CASCADE CONSTRAINTS;

-- 회원 제거
DROP SEQUENCE guidePay_seq;
DROP TABLE grade CASCADE CONSTRAINTS;
DROP TABLE guidePay CASCADE CONSTRAINTS;
DROP TABLE member CASCADE CONSTRAINTS;

-- 회원 생성
CREATE TABLE grade(
    gradeNo   NUMBER(2)  PRIMARY key,
    gradeName  VARCHAR2(30) NOT NULL  CONSTRAINT
    gradeName CHECK (gradeName in('일반회원','일반가이드','슈퍼가이드', '운영자')) 
);

create TABLE guidePay
(
    paymentNo  NUMBER(38) primary KEY,
    id         VARCHAR2(25) REFERENCES member(id) NOT NULL,
    cardNo     VARCHAR2(20) NOT NULL,
    cardName   VARCHAR2(10) NOT NULL,
    gradeNo    NUMBER(2) NOT NULL,
    payMt      NUMBER(10) NOT NULL,
    payDate    DATE DEFAULT  sysdate NOT NULL,
    total      NUMBER(38) NOT NULL

);

create SEQUENCE guidePay_seq;

CREATE TABLE member(
    id      VARCHAR2(25)  PRIMARY key ,
    name     VARCHAR2(30)  NOT NULL ,
    gradeNo   NUMBER(2) REFERENCES grade(gradeNo) NOT NULL,
    nickName   VARCHAR2(30) ,
    age    DATE,
    pw   VARCHAR2(20)  NOT NULL ,
    tel    VARCHAR2(18) ,
    e_mail    VARCHAR2(50),
    paymentNo    NUMBER(38) ,
    gender   VARCHAR2(6)  CONSTRAINT  gender CHECK (gender in('남자','여자'))  ,
    status   VARCHAR2(10)   DEFAULT  '정상' CONSTRAINT  status CHECK (status in('정상','강퇴','탈퇴','휴면','기간만료')),
    regDate  date   DEFAULT  sysdate ,
    conDate  date   DEFAULT  sysdate  ,
    payDate date DEFAULT  sysdate  ,
    memo VARCHAR2(300)   
);

-- 투어 생성
CREATE TABLE tour (
	no NUMBER PRIMARY KEY,
	status VARCHAR2(20) DEFAULT '신규' CHECK (status IN('신규', '예약가능', '모집종료', '마감임박', '마감')) NOT NULL,
	type VARCHAR(20) NOT NULL, --당일, 1박2일 등
	title VARCHAR(300) NOT NULL, --리스트에 보이는 제목
	description VARCHAR(300) NOT NULL, --리스트에 나오는 짧은 설명
	regDate DATE DEFAULT sysdate NOT NULL, --등록일
	region VARCHAR2(100) NOT NULL, --지역(구 단위)
	guideId VARCHAR2(30) REFERENCES member(id) NOT NULL,
	thumbnail VARCHAR2(200) NOT NULL, --썸네일 이미지
	mainImg VARCHAR2(200) NOT NULL, --본문 최상단 이미지
	subImg VARCHAR2(200) NOT NULL, --소제목 옆 이미지
	subtitle VARCHAR2(300) NOT NULL, --소제목
	content VARCHAR2(2000) NOT NULL, --소제목 밑 소개글
	meetLat NUMBER, --출발지 위도(상세일정 페이지 내 지도에 사용)
	meetLng NUMBER, --출발지 경도
	meetPlace VARCHAR2(300), --출발지
	hit NUMBER DEFAULT 0 NOT NULL --조회수
);

CREATE SEQUENCE tour_seq;

CREATE TABLE tourdate(
	tourNo NUMBER REFERENCES tour(no), --투어번호 FK
	day DATE, --예약가능일자
	status VARCHAR2(20) DEFAULT '예약가능' CHECK(status IN ('예약가능', '마감')) NOT NULL,
	maxNum NUMBER NOT NULL CHECK(maxNum > 0), --일자별 최대인원
	reserveNum NUMBER DEFAULT 0 NOT NULL, -- 현재 예약인원
	priceA NUMBER NOT NULL CHECK(priceA > 0), --대인가격
	priceB NUMBER NOT NULL CHECK(priceB > 0), --소인가격
	PRIMARY KEY(tourNo, day)
);

CREATE TABLE tag (
	tourNo NUMBER REFERENCES tour(no), --투어번호 FK
	tag VARCHAR2(30), -- 태그내용
	PRIMARY KEY(tourNo, tag)
);

CREATE TABLE schedule (
	no NUMBER PRIMARY KEY,
	tourNo NUMBER REFERENCES tour(no) NOT NULL, --투어번호 FK
	dayNum NUMBER(6) NOT NULL, --DAY1, DAY2 등
	scheduleNum NUMBER(6) NOT NULL, --그 날의 몇 번째 일정인지
	starthour NUMBER CHECK (starthour BETWEEN 0 AND 23), --일정 시작 시
	startminute NUMBER CHECK (startminute BETWEEN 0 AND 59), --일정 시작 분
	schedule VARCHAR2(200) NOT NULL, --뭐 하는지 간단하게(기본정보에도 나옴)
	description VARCHAR2(1000) --자세한 설명(상세일정 탭에서 나옴)
);

CREATE SEQUENCE schedule_seq;

CREATE TABLE tourpoint (
	no NUMBER PRIMARY KEY,
	tourNo NUMBER REFERENCES tour(no) NOT NULL, --투어번호 FK
	image VARCHAR2(200) NOT NULL, --포인트 이미지
	title VARCHAR2(300) NOT NULL, --소제목
	content VARCHAR2(2000) NOT NULL --설명
);
!
CREATE SEQUENCE tourpoint_seq;

CREATE TABLE checkpoint (
	no NUMBER PRIMARY KEY,
	tourNo NUMBER REFERENCES tour(no) NOT NULL, --투어번호 FK
	content VARCHAR2(2000) NOT NULL -- 주의사항 내용
);
CREATE SEQUENCE checkpoint_seq;

-- 예약 생성
CREATE TABLE booking (
    no NUMBER PRIMARY KEY,
    mId VARCHAR2(25) REFERENCES member(id),
    name VARCHAR2(30) NOT NULL, -- 예약자 이름
    gender VARCHAR2(6) NOT NULL, -- 예약자 성별
    email VARCHAR2(50) NOT NULL, -- 예약자 이메일
    tel VARCHAR2(20) NOT NULL, -- 예약자 연락처
    bookDate DATE DEFAULT SYSDATE NOT NULL, -- 예약일자
    payStatus VARCHAR2(50) NOT NULL CHECK (payStatus IN ('결제대기', '결제완료')),
    payMethod VARCHAR2(50) NOT NULL CHECK (payMethod IN ('신용카드', '무통장입금')),
    payPrice NUMBER NOT NULL -- 최종 결제 금액 = (투어가격 * 인원)  * 투어갯수 : 장바구니에서 여러개 투어 결제 시 필요 
);

CREATE SEQUENCE booking_seq;

CREATE TABLE bookDetail (
    no NUMBER PRIMARY KEY,
    bookNo NUMBER REFERENCES booking(no) ON DELETE CASCADE,
    tourNo NUMBER NOT NULL,
    day DATE NOT NULL,
    peopleA NUMBER DEFAULT 0, -- 대인
    peopleB NUMBER DEFAULT 0, -- 소인
    tourPrice NUMBER NOT NULL, -- 투어가격 * 인원
    bookStatus VARCHAR2(50) NOT NULL CHECK (bookStatus IN('예약대기', '예약완료', '예약취소')),
    review VARCHAR2(50) DEFAULT '작성불가' CHECK (review IN('작성불가', '작성가능', '작성완료')),
    FOREIGN KEY (tourNo, day) REFERENCES tourdate(tourNo, day)
);


CREATE SEQUENCE bookDetail_seq;

CREATE TABLE cart (
    no NUMBER PRIMARY KEY,
    tourNo NUMBER NOT NULL,
    mId VARCHAR2(25) REFERENCES member(id),
    day DATE NOT NULL,
    peopleA NUMBER DEFAULT 0, -- 대인
    peopleB NUMBER DEFAULT 0, -- 소인
    tourPrice NUMBER NOT NULL,
    FOREIGN KEY (tourNo, day) REFERENCES tourdate(tourNo, day)
);

CREATE SEQUENCE cart_seq;

-- QnA 생성
CREATE TABLE anonymous
(
	anonyNo               NUMBER  PRIMARY KEY ,
	id                    VARCHAR2(25) NULL REFERENCES member (id) ON DELETE CASCADE,
	title                 VARCHAR2(300)  NOT NULL ,
	content               VARCHAR2(3000)  NOT NULL ,
	writeDate             DATE default sysdate ,
	hit                   NUMBER  default 0 ,
	replyCnt              NUMBER  default 0 ,
    likeCnt             number default 0,
    writer                varchar2(10)
);
CREATE UNIQUE INDEX XPKanonymous ON anonymous
(anonyNo  ASC);
CREATE SEQUENCE anonymous_seq;

CREATE TABLE anony_reply
(
	rno                   NUMBER  PRIMARY key,
	anonyNo               NUMBER   not null  REFERENCES anonymous (anonyNo) ON DELETE CASCADE ,
    id                    VARCHAR2(25)  NULL REFERENCES member(id) ON DELETE CASCADE ,
	reply                 VARCHAR2(100)  NULL ,
	writeDate             DATE  default sysdate ,
	replyCnt              NUMBER  NULL ,
	replyer                VARCHAR2(50)  NULL ,
    updateDate            DATE  default sysdate
);
CREATE SEQUENCE anony_reply_seq;
CREATE UNIQUE INDEX XPKanony_reply ON anony_reply (rno  ASC);

CREATE TABLE anonymous_like
(
	anonyNo               NUMBER  CONSTRAINT anonymous_like_anonyNo_nn NOT NULL ,
	id                    VARCHAR2(25)  CONSTRAINT anonymous_like_id_nn NOT NULL,
    status                number default 0 check(status in(0,1)),
    CONSTRAINT anonymous_like_id_anonyNo_pk PRIMARY KEY (id, anonyNo),
    CONSTRAINT anonymous_like_id_fk FOREIGN KEY (id) REFERENCES member(id) ON DELETE CASCADE,
    CONSTRAINT anonymous_like_anonyNo_fk FOREIGN KEY (anonyNo) REFERENCES anonymous(anonyNo)ON DELETE CASCADE
);

CREATE TABLE qna
(
	qnaNo                 NUMBER  PRIMARY key ,
	id                    VARCHAR2(25)  REFERENCES member(id) ON DELETE CASCADE,
	title                 VARCHAR2(300)  NOT NULL ,
	content               VARCHAR2(3000)  NOT NULL ,
	writeDate             DATE  default sysdate ,
	hit                   NUMBER  default 0 ,
	refNo                 NUMBER  REFERENCES qna(qnaNo) ,
	ordNo                 NUMBER  NULL ,
	levNo                 NUMBER  NULL , 
--	parentNo              NUMBER  NULL REFERENCES tour(no) ON DELETE CASCADE,--qnaNO삭제시 모든관련자식글삭제
	status                VARCHAR2(50)  default '미응답' check(status in('응답','미응답')) ,
	region                VARCHAR2(100)  NULL ,
	tourNo                NUMBER  NULL REFERENCES tour(no)
);
CREATE SEQUENCE qna_seq;

CREATE TABLE siteqna
(
	siteNo                NUMBER  primary  key,
	id                    VARCHAR2(25)  NOT NULL REFERENCES member(id) on DELETE CASCADE,
	title                 VARCHAR2(300)  NOT NULL ,
	content               VARCHAR2(3000)  NOT NULL ,
	writeDate             DATE  default sysdate ,
	hit                   NUMBER default 0 ,
	status                VARCHAR2(50) default '미응답' check(status in('응답','미응답')),
    refNo                 NUMBER  REFERENCES siteqna(siteNo) on delete cascade,
	ordNo                 NUMBER  NULL ,
    --질문은 0, 답변은 1들여쓰기 로 들여쓰기한다.
	levNo                 NUMBER  NULL 
);
CREATE UNIQUE INDEX XPKsiteqna ON siteqna
(siteNo  ASC);
CREATE SEQUENCE siteqna_seq;

-- 후기 생성
create table review(
    tourNo number references tour(no) on delete cascade,
    revNo number primary key,
    title varchar2(300) not null,
    content varchar2(2000) not null,
    rating number,
    id varchar2(25) not null references member(id) on delete cascade,
    writeDate date default sysdate,
    hit number default 0,
    refNo number references review(revNo),
    ordNo number,
    levNo number,
    parentNo references review(revNo),
    bookNo number,
    likeCnt number default 0
);
create sequence review_seq;

create table review_image(
    imgNo number primary key,
    revNo number references review(revNo) on delete cascade,
    imgName varchar2(100),
    thumbnail number(1)
);
create sequence review_image_seq;

create table review_like(
    id varchar2(25) constraint review_like_id_nn not null,
    revNo number constraint review_like_revNo_nn not null,
    constraint review_like_id_revNo_pk primary key(id, revNo),
    constraint review_like_id_fk foreign key(id) references member(id) on delete cascade,
    constraint review_like_evNo_fk foreign key(revNo) references review(revNo) on delete cascade
);

-- 프로시저
-- 예약시
create or replace PROCEDURE tour_Status_at_Reserve (
	ptourNo NUMBER
) IS
	pendDay NUMBER;
	ptotalDay NUMBER;
BEGIN
	SELECT count(*) INTO ptotalDay FROM tourdate WHERE tourNo = ptourNo;
	SELECT count(*) INTO pendDay FROM tourdate WHERE tourNo = ptourNo AND status = '마감';
	IF (pendDay/ptotalDay >=1) THEN
		UPDATE tour SET status = '마감' WHERE no = ptourNo AND status <> '모집종료';
	ELSIF (pendDay/ptotalDay >= 0.75) THEN
		UPDATE tour SET status = '마감임박' WHERE no = ptourNo AND status <> '모집종료';
	END IF;
END;

-- 예약 취소시
create or replace PROCEDURE tour_Status_at_Cancel (
	ptourNo NUMBER
) IS
	pregDate DATE;
	pendDay NUMBER;
	ptotalDay NUMBER;
BEGIN
	SELECT regDate INTO pregDate FROM tour WHERE no = ptourNo;
	SELECT count(*) INTO ptotalDay FROM tourdate WHERE tourNo = ptourNo;
	SELECT count(*) INTO pendDay FROM tourdate WHERE tourNo = ptourNo AND status = '마감';
	IF (pendDay/ptotalDay <0.75) THEN
		UPDATE tour SET status = '예약가능' WHERE no = ptourNo AND regdate < sysdate - 3 AND status <> '모집종료';
		UPDATE tour SET status = '신규' WHERE no = ptourNo AND regdate >= sysdate - 3 AND status <> '모집종료';
	ELSIF (pendDay/ptotalDay < 1) THEN
		UPDATE tour SET status = '마감임박' WHERE no = ptourNo AND status <> '모집종료';
	END IF;
END;

-- 트리거
--댓글 트리거
drop trigger anony_reply_insert;
drop trigger anony_reply_delete;

--댓글 작성시 replyCnt+1
CREATE OR REPLACE TRIGGER anony_reply_insert
AFTER INSERT ON anony_reply
FOR EACH ROW
BEGIN
    UPDATE anonymous SET replyCnt = replyCnt+1
    WHERE anonyNo =:NEW.anonyNo;
END;
/
--댓글 삭제시 replyCnt-1
CREATE OR REPLACE TRIGGER anony_reply_delete
after DELETE ON anony_reply
FOR EACH ROW
BEGIN
    UPDATE anonymous SET replyCnt = replyCnt-1
    WHERE anonyNo =:OLD.anonyNo;
END;
/

-- 좋아요 트리거
drop trigger anonymous_like_insert;
drop trigger anonymous_like_delete;

-- 좋아요 눌렀을 때
create or replace TRIGGER anonymous_like_insert
AFTER INSERT ON anonymous_like
FOR EACH ROW
BEGIN
    UPDATE anonymous SET likeCnt = likeCnt+1
    WHERE anonyNo =:NEW.anonyNo;
END;

-- 좋아요 취소할 때
create or replace TRIGGER anonymous_like_delete
AFTER DELETE ON anonymous_like
FOR EACH ROW
BEGIN
    UPDATE anonymous SET likeCnt = likeCnt-1
    WHERE anonyNo =:OLD.anonyNo;
END;

-- 후기 트리거
drop trigger areview_like_insert_tr;
drop trigger review_like_delete_tr;
-- review_like 트리거
-- 좋아요 눌렀을 때
create or replace trigger review_like_insert_tr
after insert on review_like
for each row
begin
    update review set likeCnt = likeCnt + 1
    where revNo = :new.revNo;
end;
/

-- 좋아요 취소할 때
create or replace trigger review_like_delete_tr
after delete on review_like
for each row
begin
    update review set likeCnt = likeCnt - 1
    where revNo = :old.revNo;
end;
/


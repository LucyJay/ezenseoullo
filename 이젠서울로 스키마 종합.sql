-- �ı� ����
drop table review cascade constraints;
drop table review_image cascade constraints;
drop table review_like cascade constraints;
drop sequence review_seq;
drop sequence review_image_seq;
drop trigger review_like_insert_tr;
drop trigger reivew_like_delete_tr;

-- QNA ����
DROP SEQUENCE anonymous_seq;
DROP SEQUENCE anony_reply_seq;
DROP SEQUENCE qna_seq;
DROP SEQUENCE siteqna_seq;

-- ����, ��ٱ��� ����
DROP SEQUENCE bookDetail_seq;
DROP SEQUENCE booking_seq;
DROP SEQUENCE cart_seq;
DROP TABLE bookDetail CASCADE CONSTRAINTS;
DROP TABLE booking CASCADE CONSTRAINTS;
DROP TABLE cart CASCADE CONSTRAINTS;

-- ���� ����
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

-- ȸ�� ����
DROP SEQUENCE guidePay_seq;
DROP TABLE grade CASCADE CONSTRAINTS;
DROP TABLE guidePay CASCADE CONSTRAINTS;
DROP TABLE member CASCADE CONSTRAINTS;

-- ȸ�� ����
CREATE TABLE grade(
    gradeNo   NUMBER(2)  PRIMARY key,
    gradeName  VARCHAR2(30) NOT NULL  CONSTRAINT
    gradeName CHECK (gradeName in('�Ϲ�ȸ��','�Ϲݰ��̵�','���۰��̵�', '���')) 
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
    gender   VARCHAR2(6)  CONSTRAINT  gender CHECK (gender in('����','����'))  ,
    status   VARCHAR2(10)   DEFAULT  '����' CONSTRAINT  status CHECK (status in('����','����','Ż��','�޸�','�Ⱓ����')),
    regDate  date   DEFAULT  sysdate ,
    conDate  date   DEFAULT  sysdate  ,
    payDate date DEFAULT  sysdate  ,
    memo VARCHAR2(300)   
);

-- ���� ����
CREATE TABLE tour (
	no NUMBER PRIMARY KEY,
	status VARCHAR2(20) DEFAULT '�ű�' CHECK (status IN('�ű�', '���డ��', '��������', '�����ӹ�', '����')) NOT NULL,
	type VARCHAR(20) NOT NULL, --����, 1��2�� ��
	title VARCHAR(300) NOT NULL, --����Ʈ�� ���̴� ����
	description VARCHAR(300) NOT NULL, --����Ʈ�� ������ ª�� ����
	regDate DATE DEFAULT sysdate NOT NULL, --�����
	region VARCHAR2(100) NOT NULL, --����(�� ����)
	guideId VARCHAR2(30) REFERENCES member(id) NOT NULL,
	thumbnail VARCHAR2(200) NOT NULL, --����� �̹���
	mainImg VARCHAR2(200) NOT NULL, --���� �ֻ�� �̹���
	subImg VARCHAR2(200) NOT NULL, --������ �� �̹���
	subtitle VARCHAR2(300) NOT NULL, --������
	content VARCHAR2(2000) NOT NULL, --������ �� �Ұ���
	meetLat NUMBER, --����� ����(������ ������ �� ������ ���)
	meetLng NUMBER, --����� �浵
	meetPlace VARCHAR2(300), --�����
	hit NUMBER DEFAULT 0 NOT NULL --��ȸ��
);

CREATE SEQUENCE tour_seq;

CREATE TABLE tourdate(
	tourNo NUMBER REFERENCES tour(no), --�����ȣ FK
	day DATE, --���డ������
	status VARCHAR2(20) DEFAULT '���డ��' CHECK(status IN ('���డ��', '����')) NOT NULL,
	maxNum NUMBER NOT NULL CHECK(maxNum > 0), --���ں� �ִ��ο�
	reserveNum NUMBER DEFAULT 0 NOT NULL, -- ���� �����ο�
	priceA NUMBER NOT NULL CHECK(priceA > 0), --���ΰ���
	priceB NUMBER NOT NULL CHECK(priceB > 0), --���ΰ���
	PRIMARY KEY(tourNo, day)
);

CREATE TABLE tag (
	tourNo NUMBER REFERENCES tour(no), --�����ȣ FK
	tag VARCHAR2(30), -- �±׳���
	PRIMARY KEY(tourNo, tag)
);

CREATE TABLE schedule (
	no NUMBER PRIMARY KEY,
	tourNo NUMBER REFERENCES tour(no) NOT NULL, --�����ȣ FK
	dayNum NUMBER(6) NOT NULL, --DAY1, DAY2 ��
	scheduleNum NUMBER(6) NOT NULL, --�� ���� �� ��° ��������
	starthour NUMBER CHECK (starthour BETWEEN 0 AND 23), --���� ���� ��
	startminute NUMBER CHECK (startminute BETWEEN 0 AND 59), --���� ���� ��
	schedule VARCHAR2(200) NOT NULL, --�� �ϴ��� �����ϰ�(�⺻�������� ����)
	description VARCHAR2(1000) --�ڼ��� ����(������ �ǿ��� ����)
);

CREATE SEQUENCE schedule_seq;

CREATE TABLE tourpoint (
	no NUMBER PRIMARY KEY,
	tourNo NUMBER REFERENCES tour(no) NOT NULL, --�����ȣ FK
	image VARCHAR2(200) NOT NULL, --����Ʈ �̹���
	title VARCHAR2(300) NOT NULL, --������
	content VARCHAR2(2000) NOT NULL --����
);
!
CREATE SEQUENCE tourpoint_seq;

CREATE TABLE checkpoint (
	no NUMBER PRIMARY KEY,
	tourNo NUMBER REFERENCES tour(no) NOT NULL, --�����ȣ FK
	content VARCHAR2(2000) NOT NULL -- ���ǻ��� ����
);
CREATE SEQUENCE checkpoint_seq;

-- ���� ����
CREATE TABLE booking (
    no NUMBER PRIMARY KEY,
    mId VARCHAR2(25) REFERENCES member(id),
    name VARCHAR2(30) NOT NULL, -- ������ �̸�
    gender VARCHAR2(6) NOT NULL, -- ������ ����
    email VARCHAR2(50) NOT NULL, -- ������ �̸���
    tel VARCHAR2(20) NOT NULL, -- ������ ����ó
    bookDate DATE DEFAULT SYSDATE NOT NULL, -- ��������
    payStatus VARCHAR2(50) NOT NULL CHECK (payStatus IN ('�������', '�����Ϸ�')),
    payMethod VARCHAR2(50) NOT NULL CHECK (payMethod IN ('�ſ�ī��', '�������Ա�')),
    payPrice NUMBER NOT NULL -- ���� ���� �ݾ� = (����� * �ο�)  * ����� : ��ٱ��Ͽ��� ������ ���� ���� �� �ʿ� 
);

CREATE SEQUENCE booking_seq;

CREATE TABLE bookDetail (
    no NUMBER PRIMARY KEY,
    bookNo NUMBER REFERENCES booking(no) ON DELETE CASCADE,
    tourNo NUMBER NOT NULL,
    day DATE NOT NULL,
    peopleA NUMBER DEFAULT 0, -- ����
    peopleB NUMBER DEFAULT 0, -- ����
    tourPrice NUMBER NOT NULL, -- ����� * �ο�
    bookStatus VARCHAR2(50) NOT NULL CHECK (bookStatus IN('������', '����Ϸ�', '�������')),
    review VARCHAR2(50) DEFAULT '�ۼ��Ұ�' CHECK (review IN('�ۼ��Ұ�', '�ۼ�����', '�ۼ��Ϸ�')),
    FOREIGN KEY (tourNo, day) REFERENCES tourdate(tourNo, day)
);


CREATE SEQUENCE bookDetail_seq;

CREATE TABLE cart (
    no NUMBER PRIMARY KEY,
    tourNo NUMBER NOT NULL,
    mId VARCHAR2(25) REFERENCES member(id),
    day DATE NOT NULL,
    peopleA NUMBER DEFAULT 0, -- ����
    peopleB NUMBER DEFAULT 0, -- ����
    tourPrice NUMBER NOT NULL,
    FOREIGN KEY (tourNo, day) REFERENCES tourdate(tourNo, day)
);

CREATE SEQUENCE cart_seq;

-- QnA ����
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
--	parentNo              NUMBER  NULL REFERENCES tour(no) ON DELETE CASCADE,--qnaNO������ �������ڽıۻ���
	status                VARCHAR2(50)  default '������' check(status in('����','������')) ,
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
	status                VARCHAR2(50) default '������' check(status in('����','������')),
    refNo                 NUMBER  REFERENCES siteqna(siteNo) on delete cascade,
	ordNo                 NUMBER  NULL ,
    --������ 0, �亯�� 1�鿩���� �� �鿩�����Ѵ�.
	levNo                 NUMBER  NULL 
);
CREATE UNIQUE INDEX XPKsiteqna ON siteqna
(siteNo  ASC);
CREATE SEQUENCE siteqna_seq;

-- �ı� ����
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

-- ���ν���
-- �����
create or replace PROCEDURE tour_Status_at_Reserve (
	ptourNo NUMBER
) IS
	pendDay NUMBER;
	ptotalDay NUMBER;
BEGIN
	SELECT count(*) INTO ptotalDay FROM tourdate WHERE tourNo = ptourNo;
	SELECT count(*) INTO pendDay FROM tourdate WHERE tourNo = ptourNo AND status = '����';
	IF (pendDay/ptotalDay >=1) THEN
		UPDATE tour SET status = '����' WHERE no = ptourNo AND status <> '��������';
	ELSIF (pendDay/ptotalDay >= 0.75) THEN
		UPDATE tour SET status = '�����ӹ�' WHERE no = ptourNo AND status <> '��������';
	END IF;
END;

-- ���� ��ҽ�
create or replace PROCEDURE tour_Status_at_Cancel (
	ptourNo NUMBER
) IS
	pregDate DATE;
	pendDay NUMBER;
	ptotalDay NUMBER;
BEGIN
	SELECT regDate INTO pregDate FROM tour WHERE no = ptourNo;
	SELECT count(*) INTO ptotalDay FROM tourdate WHERE tourNo = ptourNo;
	SELECT count(*) INTO pendDay FROM tourdate WHERE tourNo = ptourNo AND status = '����';
	IF (pendDay/ptotalDay <0.75) THEN
		UPDATE tour SET status = '���డ��' WHERE no = ptourNo AND regdate < sysdate - 3 AND status <> '��������';
		UPDATE tour SET status = '�ű�' WHERE no = ptourNo AND regdate >= sysdate - 3 AND status <> '��������';
	ELSIF (pendDay/ptotalDay < 1) THEN
		UPDATE tour SET status = '�����ӹ�' WHERE no = ptourNo AND status <> '��������';
	END IF;
END;

-- Ʈ����
--��� Ʈ����
drop trigger anony_reply_insert;
drop trigger anony_reply_delete;

--��� �ۼ��� replyCnt+1
CREATE OR REPLACE TRIGGER anony_reply_insert
AFTER INSERT ON anony_reply
FOR EACH ROW
BEGIN
    UPDATE anonymous SET replyCnt = replyCnt+1
    WHERE anonyNo =:NEW.anonyNo;
END;
/
--��� ������ replyCnt-1
CREATE OR REPLACE TRIGGER anony_reply_delete
after DELETE ON anony_reply
FOR EACH ROW
BEGIN
    UPDATE anonymous SET replyCnt = replyCnt-1
    WHERE anonyNo =:OLD.anonyNo;
END;
/

-- ���ƿ� Ʈ����
drop trigger anonymous_like_insert;
drop trigger anonymous_like_delete;

-- ���ƿ� ������ ��
create or replace TRIGGER anonymous_like_insert
AFTER INSERT ON anonymous_like
FOR EACH ROW
BEGIN
    UPDATE anonymous SET likeCnt = likeCnt+1
    WHERE anonyNo =:NEW.anonyNo;
END;

-- ���ƿ� ����� ��
create or replace TRIGGER anonymous_like_delete
AFTER DELETE ON anonymous_like
FOR EACH ROW
BEGIN
    UPDATE anonymous SET likeCnt = likeCnt-1
    WHERE anonyNo =:OLD.anonyNo;
END;

-- �ı� Ʈ����
drop trigger areview_like_insert_tr;
drop trigger review_like_delete_tr;
-- review_like Ʈ����
-- ���ƿ� ������ ��
create or replace trigger review_like_insert_tr
after insert on review_like
for each row
begin
    update review set likeCnt = likeCnt + 1
    where revNo = :new.revNo;
end;
/

-- ���ƿ� ����� ��
create or replace trigger review_like_delete_tr
after delete on review_like
for each row
begin
    update review set likeCnt = likeCnt - 1
    where revNo = :old.revNo;
end;
/


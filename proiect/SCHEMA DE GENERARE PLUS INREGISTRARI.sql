drop table client cascade constraints;
drop table adresa cascade constraints;
drop table sediu_inchiriere cascade constraints;
drop table inchiriere cascade constraints;
drop table masina cascade constraints;
drop table stare_returnare cascade constraints;
drop table avarie cascade constraints;

create table adresa(
id_adresa number(10) primary key,
cod_postal  varchar2(10) not null,
oras varchar2(30) not null,
strada varchar2(30) not null
);

create table client(
id_client number(10) primary key,
id_adresa number(10) references adresa(id_adresa) not null,
nume varchar2(30) not null,
prenume varchar2(30) not null,
telefon varchar2(10) not null,
cnp number(20) not null
);

create table sediu_inchiriere(
id_sediu number(10) primary key,
id_adresa number(10) references adresa(id_adresa) not null,
denumire varchar2(10),
telefon varchar2(10) not null
);

create table masina(
id_masina number(10) primary key,
marca varchar2(100) not null,
tip varchar2(40) not null,
combustibil varchar2(40) not null,
cutie_de_viteze varchar2(40) not null
);

create table inchiriere(
id_inchiriere number(10) primary key,
id_client number(20) references client(id_client) not null,
id_sediu number(20) references sediu_inchiriere(id_sediu) not null,
id_masina number(10) references masina(id_masina) not null,
data_inchiriere date not null,
data_returnare date not null,
pret_inchiriere number(10) not null,
penalizare_depasire_termen number(10) check(penalizare_depasire_termen >= 0)
);

create table avarie(
id_avarie number(10) primary key,
tip_avarie varchar2(100) not null
);

create table stare_returnare(
id_client number(20) references client(id_client) not null,
id_sediu number(20) references sediu_inchiriere(id_sediu) not null,
id_avarie number(10) references avarie(id_avarie) not null,
stare varchar2(20) not null,
data_examinare date not null,
valoare_reparatie number(10) check(valoare_reparatie >= 0),
constraint pk_client_sediu primary key(id_client, id_sediu, id_avarie)
);

insert into adresa
values(1, '354829', 'Bucuresti', 'Oltului');

insert into adresa
values(2, '111536', 'Bucuresti', 'Libertatii');

insert into adresa
values(3, '565656', 'Cluj', 'Constantin Brancoveanu');

insert into adresa
values(4, '888888', 'Cluj', 'Mihai Eminescu');

insert into adresa
values(5, '077111', 'Cluj', 'Cantacuzino');

insert into adresa
values(6, '123456', 'Constanta', 'Ion Barbu');

insert into adresa
values(7, '191919','Constanta', 'Argesului');

insert into adresa
values(8, '551199','Arad', 'Panselutelor');

insert into adresa
values(9, '194521', 'Timisoara', 'Unirii');

insert into adresa
values(10, '121210', 'Timisoara', 'Mihai Viteazul');

insert into adresa
values(11, '812900', 'Bucuresti', 'Stirbei Voda');

insert into adresa
values(12, '712034' ,'Bucuresti', 'Ion Creanga');

insert into adresa
values(13, '193423', 'Oradea', 'Democratiei');

insert into adresa
values(14, '110101', 'Timisoara', '1 Decembrie');

insert into adresa
values(15, '475623', 'Turnu-Severin', 'Unirii');

insert into adresa
values(16, '222222', 'Oradea', 'Revolutiei');

insert into adresa
values(17, '333333', 'Arad', 'Soimului');

insert into adresa
values(18, '444444', 'Cluj', 'Nichita Stanescu');

insert into adresa
values(19, '555555', 'Cluj', 'Lalelelor');

insert into adresa
values(20, '666666', 'Constanta', 'George Calinescu');

insert into client
values(111,10,'Dinculescu','Andreea','0761339864',1112223334445);

insert into client
values(222,8,'Avramescu','Eduard','0761092385',5556667778889);

insert into client
values(333,6,'Oncescu','Marius','0741497290',6667778889990);

insert into client
values(444, 4,'Simbler','Ana','0147283421',7778889990001);

insert into client
values(555,2,'Doicaru','Claudiu','0774442229',8889990001112);

insert into client
values(666,1,'Bruma','Flavius','0451990007',9990001112223);

insert into client
values(777,3,'Apostolache','Miruna','0264382934',2223334445556);

insert into client
values(888,5,'Dima','Ramona','0649275470',3334445556667);

insert into client
values(999,7,'Antal','George','0542875489',4445556667778);

insert into client
values(998,9,'Popa','Andrei','0781230986',1827364978290);

insert into client
values(997,5,'Dinculescu','Andreea','0799999999',9999993334445);

insert into sediu_inchiriere
values(1,20,'A','0786986756');

insert into sediu_inchiriere
values(2,19,'B','0953275930');

insert into sediu_inchiriere
values(3,18,'C','0384527583');

insert into sediu_inchiriere
values(4,17,'D','0735185926');

insert into sediu_inchiriere
values(5,16,'E','0125482065');

insert into sediu_inchiriere
values(6,15,'F','0659878788');

insert into sediu_inchiriere
values(7,14,'G','0987654321');

insert into sediu_inchiriere
values(8,13,'H','0341853424');

insert into sediu_inchiriere
values(9,12,'I','0945286965');

insert into sediu_inchiriere
values(10,11,'A','0559476397');

insert into masina
values(1, 'Opel', 'Sedan', 'Benzina', 'Manuala');

insert into masina
values(2, 'Opel', 'SUV', 'Diesel', 'Manuala');

insert into masina
values(3, 'Renault', 'VAN', 'Diesel', 'Manuala');

insert into masina
values(4, 'BMW', 'Sedan', 'Benzina', 'Automata');

insert into masina
values(5, 'Toyota', 'SUV', 'Benzina', 'Automata');

insert into masina
values(6, 'Skoda', 'SUV', 'Benzina', 'Manuala');

insert into masina
values(7, 'Opel', 'VAN', 'Benzina', 'Manuala');

insert into masina
values(8, 'Volkswagen', 'Sedan', 'Diesel', 'Automata');

insert into masina
values(9, 'Ford', 'Sedan', 'Diesel', 'Manuala');

insert into masina
values(10, 'Subaru', 'SUV', 'Benzina', 'Manuala');

insert into inchiriere
values(1,666,10,1,TO_DATE('03-02-2017','dd-mm-yyyy'),TO_DATE('17-02-2017','dd-mm-yyyy'),850,null);

insert into inchiriere
values(2,555,10,3,TO_DATE('03-03-2012','dd-mm-yyyy'),TO_DATE('13-03-2012','dd-mm-yyyy'),500,150);

insert into inchiriere
values(3,777,3,5,TO_DATE('01-01-2020','dd-mm-yyyy'),TO_DATE('03-01-2020','dd-mm-yyyy'),200,null);

insert into inchiriere
values(4,444,2,7,TO_DATE('01-04-2020','dd-mm-yyyy'),TO_DATE('21-04-2020','dd-mm-yyyy'),1000,200);

insert into inchiriere
values(5,888,3,9,TO_DATE('01-07-2013','dd-mm-yyyy'),TO_DATE('15-08-2013','dd-mm-yyyy'),2000,null);

insert into inchiriere
values(6,888,3,2,TO_DATE('20-11-2014','dd-mm-yyyy'),TO_DATE('30-11-2014','dd-mm-yyyy'),647,null);

insert into inchiriere
values(7,333,1,4,TO_DATE('01-12-2014','dd-mm-yyyy'),TO_DATE('15-12-2014','dd-mm-yyyy'),500,null);

insert into inchiriere
values(8,222,4,6,TO_DATE('02-02-2015','dd-mm-yyyy'),TO_DATE('13-02-2015','dd-mm-yyyy'),900,100);

insert into inchiriere
values(9,222,4,8,TO_DATE('14-06-2015','dd-mm-yyyy'),TO_DATE('14-07-2015','dd-mm-yyyy'),2500,null);

insert into inchiriere
values(10,998,7,10,TO_DATE('01-11-2015','dd-mm-yyyy'),TO_DATE('10-11-2015','dd-mm-yyyy'),400,null);

insert into inchiriere
values(11,111,7,7,TO_DATE('01-07-2016','dd-mm-yyyy'),TO_DATE('17-07-2017','dd-mm-yyyy'),350,null);

insert into inchiriere
values(12,222,2,1,TO_DATE('10-10-2016','dd-mm-yyyy'),TO_DATE('20-10-2016','dd-mm-yyyy'),700,150);

insert into inchiriere
values(13,666,3,9,TO_DATE('02-08-2018','dd-mm-yyyy'),TO_DATE('17-08-2018','dd-mm-yyyy'),980,null);

insert into avarie
values(1,'Usa stanga fata zgarietura minora');

insert into avarie
values(2,'Spate infundat');

insert into avarie
values(3,'Parbriz spart');

insert into avarie
values(4,'Defectiune electromotor');

insert into avarie
values(5,'Curea de distributie rupta, pistoane afectate');

insert into avarie
values(6,'Parte stanga zgariata');

insert into avarie
values(7,'Parte stanga si spate grav avariate');

insert into avarie
values(8,'Ambreiaj defectat');

insert into avarie
values(9,'Aripa dreapta fata avariata');

insert into avarie
values(10,'Avariere usoara fata');

insert into avarie
values(11, 'Fara avarii');

insert into stare_returnare
values(666,10,11,'OK',TO_DATE('17-02-2017','dd-mm-yyyy'),null);

insert into stare_returnare
values(555,10,8,'ACCIDENT',TO_DATE('13-03-2012','dd-mm-yyyy'),1200);

insert into stare_returnare
values(777,3,11,'OK',TO_DATE('03-01-2020','dd-mm-yyyy'),null);

insert into stare_returnare
values(444,2,11,'OK',TO_DATE('21-04-2020','dd-mm-yyyy'),null);

insert into stare_returnare
values(888,3,1,'ACCIDENT',TO_DATE('15-08-2013','dd-mm-yyyy'),500);

insert into stare_returnare
values(888,3,2,'ACCIDENT',TO_DATE('30-11-2014','dd-mm-yyyy'),1500);

insert into stare_returnare
values(333,1,11,'OK',TO_DATE('15-12-2014','dd-mm-yyyy'),null);

insert into stare_returnare
values(222,4,9,'ACCIDENT',TO_DATE('17-02-2017','dd-mm-yyyy'),860);

insert into stare_returnare
values(222,4,11,'OK',TO_DATE('14-07-2015','dd-mm-yyyy'),null);

insert into stare_returnare
values(998,7,11,'OK',TO_DATE('10-11-2015','dd-mm-yyyy'),null);

insert into stare_returnare
values(111,7,3,'ACCIDENT',TO_DATE('17-07-2017','dd-mm-yyyy'),1240);

insert into stare_returnare
values(222,2,11,'OK',TO_DATE('20-10-2016','dd-mm-yyyy'),null);

insert into stare_returnare
values(666,3,10,'ACCIDENT',TO_DATE('17-08-2018','dd-mm-yyyy'),300);

insert into stare_returnare
values(111,7,1,'ACCIDENT',TO_DATE('18-08-2018','dd-mm-yyyy'),400);

insert into stare_returnare
values(111,7,6,'ACCIDENT',TO_DATE('21-12-2018','dd-mm-yyyy'),600);

insert into stare_returnare
values(111,7,7,'ACCIDENT',TO_DATE('29-12-2018','dd-mm-yyyy'),550);
commit;
%web_drop_table(WORK.POLICE);


FILENAME REFFILE '/home/u62791186/PoliceProject/police_data.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.POLICE;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.POLICE; RUN;


%web_open_table(WORK.POLICE);

DATA WORK.POLICE;
    SET WORK.POLICE;
    ID+1;
RUN;

DATA work.police;
  SET work.police;
  stopdate = PUT(stop_date,MMDDYY10.); 
  format stopdate MMDDYY10.;
RUN;

data work.police;
set work.police;
drop country_name search_type stop_date;
run;

%MACRO police_gen(id=, stopdate=, driver_gender=, driver_age=, driver_race=, violation=, is_arrested=);
	%put id = &id;
	%put stopdate = &stopdate;
	%put driver_gender = &driver_gender;
	%put driver_age = &driver_age;
	%put driver_race = &driver_race;
	%put violation = &violation;
	%put is_arrested = &is_arrested;

	data work.temp;
		id = &id;
		stopdate = &stopdate;
		driver_gender = &driver_gender;
		driver_age = &driver_age;
		driver_race = &driver_race;
		violation = &violation;
		is_arrested = &is_arrested;
		format stopdate ddmmyyyy10.;
	run;
	
	proc print data = work.police; 
	title 'Police Dataset';
	where id = &id;
	 
run;
%MEND police_gen;
%police_gen(id= 1, stopdate='01/02/2005', driver_gender='M',driver_age=20,driver_race='White',violation='Speeding', is_arrested='FALSE');
 
proc print data = work.temp;
title 'Temporary Table';
run;

%MACRO police_modify(id=, stopdate=, driver_gender=, driver_age=, driver_race=, violation=, is_arrested=);
	data work.temp;
    modify work.temp ; 
		stopdate = &stopdate;
		driver_gender = &driver_gender;
		driver_age = &driver_age;
		driver_race = &driver_race;
		violation = &violation;
		is_arrested = &is_arrested;
		format stopdate ddmmyyyy10.;
		where id = &id;
		
	proc print data = work.police; 
	title 'Police Dataset';
	where id = &id;
	
	proc print data = work.temp (obs=5);
    title'Modified Temporary Table';
    RUN; 
run;
%MEND police_modify;
%police_modify(id=1, stopdate='10/21/1996', driver_gender='F',driver_age=12,driver_race='Black',violation='Speeding', is_arrested='FALSE');



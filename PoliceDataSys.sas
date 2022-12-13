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

%MACRO police_insert(stopdate=, driver_gender=, driver_age=, driver_race=, violation=, is_arrested=);
	%put stopdate = &stopdate;
	%put driver_gender = &driver_gender;
	%put driver_age = &driver_age;
	%put driver_race = &driver_race;
	%put violation = &violation;
	%put is_arrested = &is_arrested;

	data temp;
		stopdate = &stopdate;
		driver_gender = &driver_gender;
		driver_age = &driver_age;
		driver_race = &driver_race;
		violation = &violation;
		is_arrested = &is_arrested;
		format stopdate ddmmyyyy10.;
	run;
	
	data new_id;
	set work.police end=last;
	by id;
	if last;
	keep id;
	id = id + 1;
	run;
	
	data new_table;
	merge temp new_id;
	run;
	
proc sort data = work.new_table;
   by id;
run;

proc print data = work.new_table; 
title 'Temporary Table';
run; 

run;
%MEND police_insert;
%police_insert(stopdate='01/02/2022', driver_gender='M',driver_age=20,driver_race='White',violation='Speeding', is_arrested='FALSE');


%MACRO police_modify(id=, stopdate=, driver_gender=, driver_age=, driver_race=, violation=, is_arrested=);
	data work.police;
    modify work.police ; 
		stopdate = &stopdate;
		driver_gender = &driver_gender;
		driver_age = &driver_age;
		driver_race = &driver_race;
		violation = &violation;
		is_arrested = &is_arrested;
		format stopdate ddmmyyyy10.;
		where id = &id;
		
    proc print data = work.police(obs=5); 
	title 'Modified Police Dataset';
	run;
	
%MEND police_modify;
%police_modify(id=1, stopdate='10/21/2008', driver_gender='F',driver_age=19,driver_race='Black', violation='Drunk', is_arrested='TRUE');



%macro delete_user(id);
%put id = &id;
  data temp;
  set work.police;
  if id = 4 then delete;
 
  proc sort data = work.police(obs=5);
    by id;
  run;

%mend delete;
%delete_user(5);

proc print data = temp(obs=5);
run;

%macro search_id(is_arrested=, driver_race=, driver_gender=);
%put is_arrested= &is_arrested;
%put driver_race= &driver_race;
%put driver_gender= &driver_gender;
  proc print data =work.police(OBS=100);
  where is_arrested = &is_arrested and driver_race = &driver_race and driver_gender= &driver_gender;
  run;
%mend search_id;
%search_id(is_arrested='TRUE', driver_race='White', driver_gender='F');

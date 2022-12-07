proc print data=work.police(obs=1000);
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

proc print data=work.police(obs=1000);
RUN;

proc means data=work.police nmiss n;
run;

data work.police;
    SET work.police; 
    IF cmiss(of _character_) > 5
    OR nmiss(of _numeric_) > 2
     THEN 
      DELETE;
run;

proc sort data=work.police;
by violation;
run;

title 'Distributing violations that occur most frequently';
proc sgplot data=WORK.POLICE;
	vbar violation / datalabel stat=percent
	categoryorder=respdesc nostatlabel;
	yaxis grid;
run;

proc sort data=work.police;
by driver_gender;
run;

title 'Distributing the gender that violate driving laws most frequently';
proc sgplot data=WORK.POLICE;
	vbar violation / group=driver_gender groupdisplay=cluster datalabel stat=sum
	categoryorder=respdesc nostatlabel;
	yaxis grid;
	
run;

title 'Distributing the number of drivers by race and gender';
proc sgplot data=WORK.POLICE;
	vbar driver_race / group=driver_gender groupdisplay=cluster datalabel stat=sum
	categoryorder=respdesc nostatlabel;
	yaxis grid;
run;


proc sort data=WORK.POLICE;
	by driver_gender;
run;

title'Distributing the number of drivers who were arrested versus those who were not by gender';
proc sgplot data=WORK.POLICE;
	vbar is_arrested / group=driver_gender groupdisplay=stack datalabel stat=sum;
	yaxis grid;
run;

data WORK.POLICE; 
set WORK.POLICE; 
month_only = put(stopdate, mm2.); 
run; 

DATA WORK.POLICE;
SET WORK.POLICE (WHERE=(is_arrested = 'TRUE'));
RUN;

title 'Distributing month that has the most arrests';
proc sgplot data=WORK.POLICE;
	vline month_only / group=is_arrested datalabel stat=sum;
	yaxis grid;
run;


proc sort data=WORK.POLICE;
	by month_only;
run;

title 'Distributing the month with the highest violation rate';
proc sgplot data=WORK.POLICE;
	vbar month_only / group=violation groupdisplay=cluster datalabel stat=sum;
	yaxis grid;
run;

DATA WORK.POLICE;
 ATTRIB age_range LENGTH=$5;
 SET WORK.POLICE;
 SELECT;
 WHEN (driver_age < 20) age_range = '20s';
 WHEN (driver_age < 30) age_range = '30s';
 WHEN (driver_age < 40) age_range = '40s';
 WHEN (driver_age < 50) age_range = '50s';
 WHEN (driver_age < 60) age_range = '60s';
 WHEN (driver_age < 70) age_range = '70s';
 OTHERWISE age_range = '80s';
 END;


proc sort data=WORK.POLICE;
	by age_range;
run;

title 'Distributing the age group that cause violation most frequently';
proc sgplot data=WORK.POLICE;
	vbar violation / group=age_range groupdisplay=cluster datalabel stat=sum
	categoryorder=respdesc nostatlabel;
	yaxis grid;	
run;

DATA WORK.POLICE;
SET WORK.POLICE (WHERE=(violation = 'Speeding'));
RUN;

proc template;
	define statgraph SASStudio.Pie;
		begingraph;
		layout region;
		piechart category=age_range / group=violation groupgap=2% stat=pct 
			datalabellocation=inside;
		endlayout;
		endgraph;
	end;
run;


title 'Distributing age group that most commonly violates speeding';
proc sgrender template=SASStudio.Pie data=WORK.POLICE;
run;


title 'Distributing the age group with the highest number of stop outcome';
proc sgplot data=WORK.POLICE;
	vbar stop_outcome / group=age_range groupdisplay=cluster datalabel 
		stat=percent
		categoryorder=respdesc nostatlabel;
	yaxis grid;
run;


DATA WORK.POLICE;
SET WORK.POLICE (WHERE=(search_conducted = 'TRUE'));
RUN;

title 'Distributing the number of search conducted per driver race';
proc sgplot data=WORK.POLICE;
	vbar driver_race / group=search_conducted groupdisplay=cluster datalabel
	categoryorder=respdesc nostatlabel;
	yaxis grid;
run;

DATA WORK.POLICE;
SET WORK.POLICE (WHERE=(drugs_related_stop = 'TRUE'));
RUN;

title 'Distributing the number of drugs related stop per driver race';
proc sgplot data=WORK.DDEALERS;
	vbar drugs_related_stop / group=driver_race groupdisplay=cluster datalabel
	categoryorder=respdesc nostatlabel;
	yaxis grid;
run;





%let PATH 	= /folders/myfolders/sasuser.v94/Data;
%let NAME 	= OLS;
%let LIB	= &NAME..;

libname &NAME. "&PATH.";


%let INFILE		= &LIB.INSURANCE;
%let TEMPFILE 	= TEMPFILE;
%let TESTFILE	= &LIB.INSURANCE_TEST;


proc contents data=&INFILE.;
run;

proc print data=&INFILE.(obs=10);
run;

proc corr data=&INFILE.;
var _numeric_;
with TARGET;
run;





proc means data=&INFILE. nmiss mean median p1 p5 p95 p99;
var _numeric_;
run;


proc freq data=&INFILE.;
table _character_ /missing;
run;




proc means data=&INFILE. median;
class MSTATUS;
var TARGET;
run;


proc means data=&INFILE. median;
class JOB;
var INCOME;
run;



proc means data=&INFILE. nmiss min mean median max;
var AGE;
run;







data &TEMPFILE.;
set &INFILE.;
drop INDEX;

label IMP_AGE = "Imputed Age";
IMP_AGE = AGE;
if missing( IMP_AGE ) then IMP_AGE=43;
drop AGE;


label IMP_YOJ = "Imputed Years on Job";
IMP_YOJ = YOJ;
if missing( IMP_YOJ ) then IMP_YOJ = 11;
drop YOJ;


label IMP_INCOME = "Imputed Income";
IMP_INCOME = INCOME;
if missing( IMP_INCOME ) then IMP_INCOME = 43486;
	if JOB in ("Clerical") 		then IMP_INCOME = 28877.71;
	if JOB in ("Doctor") 		then IMP_INCOME = 135810.03;
	if JOB in ("Home Maker") 	then IMP_INCOME = 0; 
	if JOB in ("Lawyer") 		then IMP_INCOME = 76847.90; 
	if JOB in ("Manager") 		then IMP_INCOME = 73641.78; 
	if JOB in ("Professional") 	then IMP_INCOME = 63215.24; 
	if JOB in ("Student") 		then IMP_INCOME = 0; 
	if JOB in ("z_Blue Collar") then IMP_INCOME = 50521.71;
if missing( IMP_INCOME ) then IMP_INCOME = 43000;
drop INCOME;


label IMP_HOME_VAL = "Imputed Home Value";
IMP_HOME_VAL = HOME_VAL;
if missing( IMP_HOME_VAL ) then IMP_HOME_VAL = 110615;
drop HOME_VAL;


label IMP_CAR_AGE = "Imputed Car Age";
IMP_CAR_AGE = CAR_AGE;
if missing( IMP_CAR_AGE ) then IMP_CAR_AGE = 7;
drop CAR_AGE;

if BLUEBOOK > 38000 then BLUEBOOK = 38000;
if IMP_CAR_AGE < 0 then IMP_CAR_AGE = 0;
if IMP_CAR_AGE > 18 then IMP_CAR_AGE = 18;

run;


proc print data=&TEMPFILE.(obs=15);
run;


proc contents data=&TEMPFILE.;
run;



proc means data=&TEMPFILE. nmiss mean median min max;
var _numeric_;
run;

proc freq data=&TEMPFILE.;
table _character_ /missing;
run;



proc reg data=&TEMPFILE.;
model TARGET = 	BLUEBOOK
				CLM_FREQ
				HOMEKIDS
				IMP_CAR_AGE
				IMP_HOME_VAL
				IMP_INCOME
				IMP_YOJ
				KIDSDRIV
				MVR_PTS
				OLDCLAIM
				TIF
				TRAVTIME
				/selection = stepwise;
				;				
run; 
quit;




******SCORE FILE***********;


%macro SCORE( INFILE, OUTFILE );

data &OUTFILE.;
set &INFILE.;

label IMP_AGE = "Imputed Age";
IMP_AGE = AGE;
if missing( IMP_AGE ) then IMP_AGE=43;
drop AGE;


label IMP_YOJ = "Imputed Years on Job";
IMP_YOJ = YOJ;
if missing( IMP_YOJ ) then IMP_YOJ = 11;
drop YOJ;


label IMP_INCOME = "Imputed Income";
IMP_INCOME = INCOME;
if missing( IMP_INCOME ) then IMP_INCOME = 43486;
	if JOB in ("Clerical") 		then IMP_INCOME = 28877.71;
	if JOB in ("Doctor") 		then IMP_INCOME = 135810.03;
	if JOB in ("Home Maker") 	then IMP_INCOME = 0; 
	if JOB in ("Lawyer") 		then IMP_INCOME = 76847.90; 
	if JOB in ("Manager") 		then IMP_INCOME = 73641.78; 
	if JOB in ("Professional") 	then IMP_INCOME = 63215.24; 
	if JOB in ("Student") 		then IMP_INCOME = 0; 
	if JOB in ("z_Blue Collar") then IMP_INCOME = 50521.71;
if missing( IMP_INCOME ) then IMP_INCOME = 43000;
drop INCOME;


label IMP_HOME_VAL = "Imputed Home Value";
IMP_HOME_VAL = HOME_VAL;
if missing( IMP_HOME_VAL ) then IMP_HOME_VAL = 110615;
drop HOME_VAL;


label IMP_CAR_AGE = "Imputed Car Age";
IMP_CAR_AGE = CAR_AGE;
if missing( IMP_CAR_AGE ) then IMP_CAR_AGE = 7;
drop CAR_AGE;

if BLUEBOOK > 38000 then BLUEBOOK = 38000;
if IMP_CAR_AGE < 0 then IMP_CAR_AGE = 0;
if IMP_CAR_AGE > 18 then IMP_CAR_AGE = 18;


P_TARGET = 4429.08915 + 0.12714*BLUEBOOK - 66.23893*IMP_CAR_AGE;

keep INDEX P_TARGET;

run;

%mend;




%score( &TESTFILE., SCOREFILE );

proc print data=SCOREFILE;
run;



proc export data=SCOREFILE
outfile=" /folders/myfolders/sasuser.v94/Unit01/INSURANCE2.csv "
dbms=;
run;


data "/folders/myfolders/sasuser.v94/Unit01/KEVIN_WONG_INSURANCE_SCORED";
set SCOREFILE;
run;



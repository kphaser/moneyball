
%let PATH = /folders/myfolders/sasuser.v94/Data;
%let NAME = BB;
%let LIB = &NAME..;

libname &NAME. "&PATH.";

%let INFILE 	= &LIB.MONEYBALL;
%let TEMPFILE 	= TEMPFILE;
%let SCOREDFILE	= SCOREDFILE;

proc print data=&INFILE.(obs=10);
run;

proc univariate data=&INFILE. plot;
var TARGET_WINS;
run;

proc means data=&INFILE. mean median stddev n nmiss;
run;

proc corr data=&INFILE.;
	var _all_;
	with TARGET_WINS;
run;


*********************************
MEAN MODEL
*********************************;

data &TEMPFILE.;
set &INFILE.;

if missing( TEAM_BASERUN_SB ) then TEAM_BASERUN_SB = 125;
if missing( TEAM_FIELDING_DP ) then TEAM_FIELDING_DP = 146;
if missing( TEAM_PITCHING_SO ) then TEAM_PITCHING_SO = 818;
if missing( TEAM_BATTING_SO ) then TEAM_BATTING_SO = 736;
if missing( TEAM_BASERUN_CS ) then TEAM_BASERUN_CS = 53;

drop
		INDEX
		TEAM_BATTING_HBP
		;
run;

proc means data=&TEMPFILE. n nmiss;
run;

proc reg data=&TEMPFILE.;
model TARGET_WINS = 
						TEAM_BATTING_H 
						TEAM_BATTING_2B 
						TEAM_BATTING_3B 
						TEAM_BATTING_HR 
						TEAM_BATTING_BB
				 		TEAM_BATTING_SO
						TEAM_BASERUN_SB
						TEAM_BASERUN_CS 
						TEAM_PITCHING_H 
						TEAM_PITCHING_HR 
						TEAM_PITCHING_BB
						TEAM_PITCHING_SO 
						TEAM_FIELDING_E
						TEAM_FIELDING_DP
						/selection=stepwise aic sbc adjrsq; *remove this when creating the full model;
						;
run;
quit;

proc univariate data=&TEMPFILE. plot;
var _all_;
run;

proc means data=&TEMPFILE. n nmiss min max mean stddev p1 p99;
run;


***********************************
MEDIAN MODEL
***********************************;

data &TEMPFILE.;
set &INFILE.;

if missing( TEAM_BASERUN_SB ) then TEAM_BASERUN_SB = 101;
if missing( TEAM_FIELDING_DP ) then TEAM_FIELDING_DP = 149;
if missing( TEAM_PITCHING_SO ) then TEAM_PITCHING_SO = 813.5;
if missing( TEAM_BATTING_SO ) then TEAM_BATTING_SO = 750;
if missing( TEAM_BASERUN_CS ) then TEAM_BASERUN_CS = 49;

drop
		INDEX
		TEAM_BATTING_HBP
		;
run;

proc means data=&TEMPFILE. n nmiss;
run;

proc reg data=&TEMPFILE.;
model TARGET_WINS = 
						TEAM_BATTING_H 
						TEAM_BATTING_2B 
						TEAM_BATTING_3B 
						TEAM_BATTING_HR 
						TEAM_BATTING_BB
				 		TEAM_BATTING_SO
						TEAM_BASERUN_SB
						TEAM_BASERUN_CS 
						TEAM_PITCHING_H 
						TEAM_PITCHING_HR 
						TEAM_PITCHING_BB
						TEAM_PITCHING_SO 
						TEAM_FIELDING_E
						TEAM_FIELDING_DP
						/selection=stepwise aic sbc adjrsq;
						;
run;
quit;

proc univariate data=&TEMPFILE. plot;
var _all_;
run;

proc means data=&TEMPFILE. n nmiss min max mean stddev p1 p99;
run;


***********************************
DECISION TREE MODEL
***********************************;

data &TEMPFILE.;
set &INFILE.;

IMP_TEAM_BATTING_SO = TEAM_BATTING_SO;
BATTING_SO_FLAG=0;
if missing( IMP_TEAM_BATTING_SO ) then do;
	BATTING_SO_FLAG=1;
	IMP_TEAM_BATTING_SO = 55.51;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO < 569.5) and (TEAM_PITCHING_H < 3091) then IMP_TEAM_BATTING_SO = 438.9;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO > 569.5) and (TEAM_PITCHING_H > 2425) then IMP_TEAM_BATTING_SO = 266.6;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO > 569.5) and (TEAM_PITCHING_H < 2425) and (TEAM_PITCHING_SO < 679.5) then IMP_TEAM_BATTING_SO = 578.3;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO > 569.5) and (TEAM_PITCHING_H < 2425) and (TEAM_PITCHING_SO > 679.5) then IMP_TEAM_BATTING_SO = 686;
	
	if (TEAM_BATTING_SO > 790.5) and (TEAM_FIELDING_E > 363) then IMP_TEAM_BATTING_SO = 627.3;
	if (TEAM_BATTING_SO > 790.5) and (TEAM_FIELDING_E < 363) and (TEAM_PITCHING_SO < 971) then IMP_TEAM_BATTING_SO = 872.4;
	if (TEAM_BATTING_SO > 790.5) and (TEAM_FIELDING_E < 363) and (TEAM_PITCHING_SO > 971) then IMP_TEAM_BATTING_SO = 1045;
end;


IMP_TEAM_BASERUN_CS = TEAM_BASERUN_CS;
BASERUN_CS_FLAG=0;
if missing( IMP_TEAM_BASERUN_CS ) then do;
	BASERUN_CS_FLAG=1;
	IMP_TEAM_BASERUN_CS = 31.42;
	if (TEAM_BASERUN_SB < 117.5) and (TEAM_BASERUN_SB < 72.5) and (TEAM_BASERUN_SB > 47.5) then IMP_TEAM_BASERUN_CS = 42.07;
	if (TEAM_BASERUN_SB < 117.5) and (TEAM_BASERUN_SB > 72.5) and (TEAM_PITCHING_SO > 603.5) then IMP_TEAM_BASERUN_CS = 49.45;
	if (TEAM_BASERUN_SB < 117.5) and (TEAM_BASERUN_SB > 72.5) and (TEAM_PITCHING_SO < 603.5) then IMP_TEAM_BASERUN_CS = 70.56;
	
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR > 116.5) then IMP_TEAM_BASERUN_CS = 59.97;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR < 116.5) and (TEAM_FIELDING_E < 177.5) and (TEAM_BASERUN_SB < 188) then IMP_TEAM_BASERUN_CS = 67.12;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR < 116.5) and (TEAM_FIELDING_E < 177.5) and (TEAM_BASERUN_SB > 188) then IMP_TEAM_BASERUN_CS = 87.68;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR < 116.5) and (TEAM_FIELDING_E > 177.5) then IMP_TEAM_BASERUN_CS = 92.56;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR < 35.5) and (TEAM_BASERUN_SB < 155.5) then IMP_TEAM_BASERUN_CS = 102.1;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR < 35.5) and (TEAM_BASERUN_SB > 155.5) then IMP_TEAM_BASERUN_CS = 160.3;
end;	

IMP_TEAM_BASERUN_SB = TEAM_BASERUN_SB;
BASERUN_SB_FLAG=0;
if missing( IMP_TEAM_BASERUN_SB ) then do;
	BASERUN_SB_FLAG=1;
	IMP_TEAM_BASERUN_SB = 69.38;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR > 21.5) and (TEAM_BATTING_SO < 712) then IMP_TEAM_BASERUN_SB = 88.21;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR > 21.5) and (TEAM_BATTING_SO > 712) and (TEAM_BASERUN_CS < 65.5) then IMP_TEAM_BASERUN_SB = 112.8;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR > 21.5) and (TEAM_BATTING_SO > 712) and (TEAM_BASERUN_CS > 65.5) then IMP_TEAM_BASERUN_SB = 149.8;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR < 21.5) then IMP_TEAM_BASERUN_SB = 184.1;

	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB < 584) and (TEAM_BATTING_SO < 215) then IMP_TEAM_BASERUN_SB = 72.2;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB < 584) and (TEAM_BATTING_SO > 215) and (TEAM_FIELDING_E < 496) then IMP_TEAM_BASERUN_SB = 194.6;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB < 584) and (TEAM_BATTING_SO > 215) and (TEAM_FIELDING_E > 496) then IMP_TEAM_BASERUN_SB = 330.9;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB > 584) and (TEAM_FIELDING_E < 343.5) then IMP_TEAM_BASERUN_SB = 230.6;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB > 584) and (TEAM_FIELDING_E > 343.5) and (TEAM_BATTING_BB < 282.5) then IMP_TEAM_BASERUN_SB = 179;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB > 584) and (TEAM_FIELDING_E > 343.5) and (TEAM_BATTING_BB > 282.5) then IMP_TEAM_BASERUN_SB = 344.2;
end;

IMP_TEAM_PITCHING_SO = TEAM_PITCHING_SO;
PITCHING_SO_FLAG=0;
if missing( IMP_TEAM_PITCHING_SO ) then do;
	PITCHING_SO_FLAG=1;
	IMP_TEAM_PITCHING_SO = 505.9;
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO < 737.5) and (TEAM_BATTING_SO < 531.5) then IMP_TEAM_PITCHING_SO = 700.7;
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO > 737.5) and (TEAM_FIELDING_E < 869.5) and (TEAM_BATTING_SO < 942.5) then IMP_TEAM_PITCHING_SO = 879.7;	
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO > 737.5) and (TEAM_FIELDING_E < 869.5) and (TEAM_BATTING_SO > 942.5) then IMP_TEAM_PITCHING_SO = 1078;
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO > 737.5) and (TEAM_FIELDING_E > 869.5) then IMP_TEAM_PITCHING_SO = 2865;		
	if (TEAM_PITCHING_BB > 1618) then IMP_TEAM_PITCHING_SO = 5663;	
end;


IMP_TEAM_FIELDING_DP = TEAM_FIELDING_DP;
FIELDING_DP_FLAG=0;
if missing( IMP_TEAM_FIELDING_DP ) then do;
	FIELDING_DP_FLAG=1;
	IMP_TEAM_FIELDING_DP = 108.2;
	if (TEAM_FIELDING_E > 234.5) and (TEAM_BASERUN_SB < 105.5) then IMP_TEAM_FIELDING_DP = 145.5;
	
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB > 122.5) and (TEAM_BATTING_HR < 34.5) then IMP_TEAM_FIELDING_DP = 118.7;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB > 122.5) and (TEAM_BATTING_HR > 34.5) then IMP_TEAM_FIELDING_DP = 147.4;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB < 122.5) and (TEAM_BATTING_SO > 794.5) then IMP_TEAM_FIELDING_DP = 153.2;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB < 122.5) and (TEAM_BATTING_SO < 794.5) and (TEAM_FIELDING_E > 181.5) then IMP_TEAM_FIELDING_DP = 152.8;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB < 122.5) and (TEAM_BATTING_SO < 794.5) and (TEAM_FIELDING_E < 181.5) then IMP_TEAM_FIELDING_DP = 163.9;
end;	


drop
		INDEX
		TEAM_BATTING_HBP
		;
run;

proc univariate data=&TEMPFILE. plot;
var _all_;
run;

proc means data=&TEMPFILE. n nmiss min max mean stddev p1 p99;
run;

proc univariate data=&TEMPFILE. plot;
var TEAM_BASERUN_CS;
run;

proc univariate data=&TEMPFILE. plot;
var IMP_TEAM_BASERUN_CS;
run;


proc reg data=&TEMPFILE. outest=ESTFILE;
model TARGET_WINS = 
						TEAM_BATTING_H 
						TEAM_BATTING_2B
						TEAM_BATTING_3B
						TEAM_BATTING_HR 
						TEAM_BATTING_BB 
						TEAM_PITCHING_H 
						TEAM_PITCHING_HR 
						TEAM_PITCHING_BB 
						TEAM_FIELDING_E
						IMP_TEAM_BASERUN_SB
						IMP_TEAM_FIELDING_DP
						IMP_TEAM_PITCHING_SO
						IMP_TEAM_BATTING_SO
						IMP_TEAM_BASERUN_CS
						BASERUN_SB_FLAG
						FIELDING_DP_FLAG
						PITCHING_SO_FLAG
						BASERUN_CS_FLAG
						BATTING_SO_FLAG
						/selection=stepwise aic sbc adjrsq;
						;
output out=&SCOREDFILE. p=P_YHAT;
run;
quit;


proc print data=ESTFILE;
run;


proc print data=&SCOREDFILE.(obs=100);
run;

******************************************************************************
DECISION TREE MODEL EXCLUDING COUNTER-INTUITIVE AND NON SIGNIFICANT VARIABLES
******************************************************************************;
proc reg data=&TEMPFILE. outest=ESTFILE;
model TARGET_WINS = 
						TEAM_BATTING_H 
						TEAM_BATTING_HR 
						TEAM_BATTING_BB 
						TEAM_PITCHING_H 
						TEAM_PITCHING_HR 
						TEAM_PITCHING_BB 
						TEAM_FIELDING_E
						IMP_TEAM_BASERUN_SB
						IMP_TEAM_PITCHING_SO
						IMP_TEAM_BATTING_SO
						/selection=stepwise aic sbc adjrsq;
						;
output out=&SCOREDFILE. p=P_YHAT;
run;
quit;


**********************************************
BINGO BONUS - USE PROC GLM AND PROC GENMOD
**********************************************;
proc glm data=&TEMPFILE.;
model TARGET_WINS = 
						TEAM_BATTING_H 
						TEAM_BATTING_HR 
						TEAM_BATTING_BB 
						TEAM_PITCHING_H 
						TEAM_PITCHING_HR 
						TEAM_PITCHING_BB 
						TEAM_FIELDING_E
						IMP_TEAM_BASERUN_SB
						IMP_TEAM_PITCHING_SO
						IMP_TEAM_BATTING_SO
						;
output out=&SCOREDFILE. p=P_YHAT;
run;
quit;

proc genmod data=&TEMPFILE.;
model TARGET_WINS = 
						TEAM_BATTING_H 
						TEAM_BATTING_HR 
						TEAM_BATTING_BB 
						TEAM_PITCHING_H 
						TEAM_PITCHING_HR 
						TEAM_PITCHING_BB 
						TEAM_FIELDING_E
						IMP_TEAM_BASERUN_SB
						IMP_TEAM_PITCHING_SO
						IMP_TEAM_BATTING_SO
						;
output out=&SCOREDFILE. p=P_YHAT;
run;
quit;




**************************************
CREATE THE SCORED FILE FOR SUBMISSION
**************************************;

%let SCORE_ME = &LIB.MONEYBALL_TEST;

proc means data=&SCORE_ME. N;
var INDEX;
run;


data BB.KEVIN;
set &SCORE_ME.;


IMP_TEAM_BATTING_SO = TEAM_BATTING_SO;
if missing( IMP_TEAM_BATTING_SO ) then do;
	
	IMP_TEAM_BATTING_SO = 55.51;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO < 569.5) and (TEAM_PITCHING_H < 3091) then IMP_TEAM_BATTING_SO = 438.9;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO > 569.5) and (TEAM_PITCHING_H > 2425) then IMP_TEAM_BATTING_SO = 266.6;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO > 569.5) and (TEAM_PITCHING_H < 2425) and (TEAM_PITCHING_SO < 679.5) then IMP_TEAM_BATTING_SO = 578.3;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO > 569.5) and (TEAM_PITCHING_H < 2425) and (TEAM_PITCHING_SO > 679.5) then IMP_TEAM_BATTING_SO = 686;
	
	if (TEAM_BATTING_SO > 790.5) and (TEAM_FIELDING_E > 363) then IMP_TEAM_BATTING_SO = 627.3;
	if (TEAM_BATTING_SO > 790.5) and (TEAM_FIELDING_E < 363) and (TEAM_PITCHING_SO < 971) then IMP_TEAM_BATTING_SO = 872.4;
	if (TEAM_BATTING_SO > 790.5) and (TEAM_FIELDING_E < 363) and (TEAM_PITCHING_SO > 971) then IMP_TEAM_BATTING_SO = 1045;
end;


IMP_TEAM_BASERUN_CS = TEAM_BASERUN_CS;
if missing( IMP_TEAM_BASERUN_CS ) then do;

	IMP_TEAM_BASERUN_CS = 31.42;
	if (TEAM_BASERUN_SB < 117.5) and (TEAM_BASERUN_SB < 72.5) and (TEAM_BASERUN_SB > 47.5) then IMP_TEAM_BASERUN_CS = 42.07;
	if (TEAM_BASERUN_SB < 117.5) and (TEAM_BASERUN_SB > 72.5) and (TEAM_PITCHING_SO > 603.5) then IMP_TEAM_BASERUN_CS = 49.45;
	if (TEAM_BASERUN_SB < 117.5) and (TEAM_BASERUN_SB > 72.5) and (TEAM_PITCHING_SO < 603.5) then IMP_TEAM_BASERUN_CS = 70.56;
	
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR > 116.5) then IMP_TEAM_BASERUN_CS = 59.97;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR < 116.5) and (TEAM_FIELDING_E < 177.5) and (TEAM_BASERUN_SB < 188) then IMP_TEAM_BASERUN_CS = 67.12;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR < 116.5) and (TEAM_FIELDING_E < 177.5) and (TEAM_BASERUN_SB > 188) then IMP_TEAM_BASERUN_CS = 87.68;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR < 116.5) and (TEAM_FIELDING_E > 177.5) then IMP_TEAM_BASERUN_CS = 92.56;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR < 35.5) and (TEAM_BASERUN_SB < 155.5) then IMP_TEAM_BASERUN_CS = 102.1;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR < 35.5) and (TEAM_BASERUN_SB > 155.5) then IMP_TEAM_BASERUN_CS = 160.3;
end;	
	

IMP_TEAM_BASERUN_SB = TEAM_BASERUN_SB;
if missing( IMP_TEAM_BASERUN_SB ) then do;

	IMP_TEAM_BASERUN_SB = 69.38;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR > 21.5) and (TEAM_BATTING_SO < 712) then IMP_TEAM_BASERUN_SB = 88.21;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR > 21.5) and (TEAM_BATTING_SO > 712) and (TEAM_BASERUN_CS < 65.5) then IMP_TEAM_BASERUN_SB = 112.8;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR > 21.5) and (TEAM_BATTING_SO > 712) and (TEAM_BASERUN_CS > 65.5) then IMP_TEAM_BASERUN_SB = 149.8;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR < 21.5) then IMP_TEAM_BASERUN_SB = 184.1;

	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB < 584) and (TEAM_BATTING_SO < 215) then IMP_TEAM_BASERUN_SB = 72.2;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB < 584) and (TEAM_BATTING_SO > 215) and (TEAM_FIELDING_E < 496) then IMP_TEAM_BASERUN_SB = 194.6;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB < 584) and (TEAM_BATTING_SO > 215) and (TEAM_FIELDING_E > 496) then IMP_TEAM_BASERUN_SB = 330.9;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB > 584) and (TEAM_FIELDING_E < 343.5) then IMP_TEAM_BASERUN_SB = 230.6;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB > 584) and (TEAM_FIELDING_E > 343.5) and (TEAM_BATTING_BB < 282.5) then IMP_TEAM_BASERUN_SB = 179;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB > 584) and (TEAM_FIELDING_E > 343.5) and (TEAM_BATTING_BB > 282.5) then IMP_TEAM_BASERUN_SB = 344.2;
end;

IMP_TEAM_PITCHING_SO = TEAM_PITCHING_SO;
if missing( IMP_TEAM_PITCHING_SO ) then do;

	IMP_TEAM_PITCHING_SO = 505.9;
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO < 737.5) and (TEAM_BATTING_SO < 531.5) then IMP_TEAM_PITCHING_SO = 700.7;
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO > 737.5) and (TEAM_FIELDING_E < 869.5) and (TEAM_BATTING_SO < 942.5) then IMP_TEAM_PITCHING_SO = 879.7;	
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO > 737.5) and (TEAM_FIELDING_E < 869.5) and (TEAM_BATTING_SO > 942.5) then IMP_TEAM_PITCHING_SO = 1078;
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO > 737.5) and (TEAM_FIELDING_E > 869.5) then IMP_TEAM_PITCHING_SO = 2865;		
	if (TEAM_PITCHING_BB > 1618) then IMP_TEAM_PITCHING_SO = 5663;	
end;


IMP_TEAM_FIELDING_DP = TEAM_FIELDING_DP;
if missing( IMP_TEAM_FIELDING_DP ) then do;

	IMP_TEAM_FIELDING_DP = 108.2;
	if (TEAM_FIELDING_E > 234.5) and (TEAM_BASERUN_SB < 105.5) then IMP_TEAM_FIELDING_DP = 145.5;
	
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB > 122.5) and (TEAM_BATTING_HR < 34.5) then IMP_TEAM_FIELDING_DP = 118.7;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB > 122.5) and (TEAM_BATTING_HR > 34.5) then IMP_TEAM_FIELDING_DP = 147.4;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB < 122.5) and (TEAM_BATTING_SO > 794.5) then IMP_TEAM_FIELDING_DP = 153.2;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB < 122.5) and (TEAM_BATTING_SO < 794.5) and (TEAM_FIELDING_E > 181.5) then IMP_TEAM_FIELDING_DP = 152.8;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB < 122.5) and (TEAM_BATTING_SO < 794.5) and (TEAM_FIELDING_E < 181.5) then IMP_TEAM_FIELDING_DP = 163.9;
end;	

	
	
/*P_TARGET_WINS = 31.1667 + 0.044323*TEAM_BATTING_H - 0.022023*TEAM_BATTING_2B + 0.031852	*TEAM_BATTING_3B + 0.076650*TEAM_BATTING_HR + .006602563* TEAM_BATTING_BB - 0.033660*TEAM_FIELDING_E + 0.056551*IMP_TEAM_BASERUN_SB - 0.068809*IMP_TEAM_FIELDING_DP + .002208476*IMP_TEAM_PITCHING_SO - 0.016488*IMP_TEAM_BATTING_SO - 0.033578*IMP_TEAM_BASERUN_CS;*/
P_TARGET_WINS = 25.03673 + 0.04049*TEAM_BATTING_H + 0.07812*TEAM_BATTING_HR - 0.03251*TEAM_FIELDING_E + 0.06323*IMP_TEAM_BASERUN_SB + 0.00191*IMP_TEAM_PITCHING_SO - 0.01868*IMP_TEAM_BATTING_SO;
P_TARGET_WINS = round( P_TARGET_WINS, 1 );


keep INDEX P_TARGET_WINS;
run;


proc print data=BB.KEVIN(obs=7);
run;

proc means data=BB.KEVIN N NMISS MIN MEAN MAX;
var P_TARGET_WINS;
run;


proc export data=BB.KEVIN
outfile=" /folders/myfolders/sasuser.v94/Unit01/MONEYBALL_MODEL.csv "
dbms=csv;
run;





*****EXTRA******;

%let SCORE_ME = &LIB.MONEYBALL_TEST;

proc means data=&SCORE_ME. N;
var INDEX;
run;


data BB.KEVIN;
set &SCORE_ME.;
IMP_TEAM_BATTING_SO = TEAM_BATTING_SO;
BATTING_SO_FLAG=0;
if missing( IMP_TEAM_BATTING_SO ) then do;
	BATTING_SO_FLAG=1;
	IMP_TEAM_BATTING_SO = 55.51;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO < 569.5) and (TEAM_PITCHING_H < 3091) then IMP_TEAM_BATTING_SO = 438.9;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO > 569.5) and (TEAM_PITCHING_H > 2425) then IMP_TEAM_BATTING_SO = 266.6;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO > 569.5) and (TEAM_PITCHING_H < 2425) and (TEAM_PITCHING_SO < 679.5) then IMP_TEAM_BATTING_SO = 578.3;
	if (TEAM_BATTING_SO < 790.5) and (TEAM_BATTING_SO > 569.5) and (TEAM_PITCHING_H < 2425) and (TEAM_PITCHING_SO > 679.5) then IMP_TEAM_BATTING_SO = 686;
	
	if (TEAM_BATTING_SO > 790.5) and (TEAM_FIELDING_E > 363) then IMP_TEAM_BATTING_SO = 627.3;
	if (TEAM_BATTING_SO > 790.5) and (TEAM_FIELDING_E < 363) and (TEAM_PITCHING_SO < 971) then IMP_TEAM_BATTING_SO = 872.4;
	if (TEAM_BATTING_SO > 790.5) and (TEAM_FIELDING_E < 363) and (TEAM_PITCHING_SO > 971) then IMP_TEAM_BATTING_SO = 1045;
end;


IMP_TEAM_BASERUN_CS = TEAM_BASERUN_CS;
BASERUN_CS_FLAG=0;
if missing( IMP_TEAM_BASERUN_CS ) then do;
	BASERUN_CS_FLAG=1;
	IMP_TEAM_BASERUN_CS = 31.42;
	if (TEAM_BASERUN_SB < 117.5) and (TEAM_BASERUN_SB < 72.5) and (TEAM_BASERUN_SB > 47.5) then IMP_TEAM_BASERUN_CS = 42.07;
	if (TEAM_BASERUN_SB < 117.5) and (TEAM_BASERUN_SB > 72.5) and (TEAM_PITCHING_SO > 603.5) then IMP_TEAM_BASERUN_CS = 49.45;
	if (TEAM_BASERUN_SB < 117.5) and (TEAM_BASERUN_SB > 72.5) and (TEAM_PITCHING_SO < 603.5) then IMP_TEAM_BASERUN_CS = 70.56;
	
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR > 116.5) then IMP_TEAM_BASERUN_CS = 59.97;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR < 116.5) and (TEAM_FIELDING_E < 177.5) and (TEAM_BASERUN_SB < 188) then IMP_TEAM_BASERUN_CS = 67.12;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR < 116.5) and (TEAM_FIELDING_E < 177.5) and (TEAM_BASERUN_SB > 188) then IMP_TEAM_BASERUN_CS = 87.68;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR > 35.5) and (TEAM_BATTING_HR < 116.5) and (TEAM_FIELDING_E > 177.5) then IMP_TEAM_BASERUN_CS = 92.56;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR < 35.5) and (TEAM_BASERUN_SB < 155.5) then IMP_TEAM_BASERUN_CS = 102.1;
	if (TEAM_BASERUN_SB > 117.5) and (TEAM_PITCHING_HR < 35.5) and (TEAM_BASERUN_SB > 155.5) then IMP_TEAM_BASERUN_CS = 160.3;
end;	

IMP_TEAM_BASERUN_SB = TEAM_BASERUN_SB;
BASERUN_SB_FLAG=0;
if missing( IMP_TEAM_BASERUN_SB ) then do;
	BASERUN_SB_FLAG=1;
	IMP_TEAM_BASERUN_SB = 69.38;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR > 21.5) and (TEAM_BATTING_SO < 712) then IMP_TEAM_BASERUN_SB = 88.21;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR > 21.5) and (TEAM_BATTING_SO > 712) and (TEAM_BASERUN_CS < 65.5) then IMP_TEAM_BASERUN_SB = 112.8;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR > 21.5) and (TEAM_BATTING_SO > 712) and (TEAM_BASERUN_CS > 65.5) then IMP_TEAM_BASERUN_SB = 149.8;
	if (TEAM_FIELDING_E < 255.5) and (TEAM_BASERUN_CS > 48.5) and (TEAM_BATTING_HR < 21.5) then IMP_TEAM_BASERUN_SB = 184.1;

	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB < 584) and (TEAM_BATTING_SO < 215) then IMP_TEAM_BASERUN_SB = 72.2;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB < 584) and (TEAM_BATTING_SO > 215) and (TEAM_FIELDING_E < 496) then IMP_TEAM_BASERUN_SB = 194.6;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB < 584) and (TEAM_BATTING_SO > 215) and (TEAM_FIELDING_E > 496) then IMP_TEAM_BASERUN_SB = 330.9;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB > 584) and (TEAM_FIELDING_E < 343.5) then IMP_TEAM_BASERUN_SB = 230.6;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB > 584) and (TEAM_FIELDING_E > 343.5) and (TEAM_BATTING_BB < 282.5) then IMP_TEAM_BASERUN_SB = 179;
	if (TEAM_FIELDING_E > 255.5) and (TEAM_PITCHING_BB > 584) and (TEAM_FIELDING_E > 343.5) and (TEAM_BATTING_BB > 282.5) then IMP_TEAM_BASERUN_SB = 344.2;
end;

IMP_TEAM_PITCHING_SO = TEAM_PITCHING_SO;
PITCHING_SO_FLAG=0;
if missing( IMP_TEAM_PITCHING_SO ) then do;
	PITCHING_SO_FLAG=1;
	IMP_TEAM_PITCHING_SO = 505.9;
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO < 737.5) and (TEAM_BATTING_SO < 531.5) then IMP_TEAM_PITCHING_SO = 700.7;
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO > 737.5) and (TEAM_FIELDING_E < 869.5) and (TEAM_BATTING_SO < 942.5) then IMP_TEAM_PITCHING_SO = 879.7;	
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO > 737.5) and (TEAM_FIELDING_E < 869.5) and (TEAM_BATTING_SO > 942.5) then IMP_TEAM_PITCHING_SO = 1078;
	if (TEAM_PITCHING_BB < 1618) and (TEAM_BATTING_SO > 737.5) and (TEAM_FIELDING_E > 869.5) then IMP_TEAM_PITCHING_SO = 2865;		
	if (TEAM_PITCHING_BB > 1618) then IMP_TEAM_PITCHING_SO = 5663;	
end;


IMP_TEAM_FIELDING_DP = TEAM_FIELDING_DP;
FIELDING_DP_FLAG=0;
if missing( IMP_TEAM_FIELDING_DP ) then do;
	FIELDING_DP_FLAG=1;
	IMP_TEAM_FIELDING_DP = 108.2;
	if (TEAM_FIELDING_E > 234.5) and (TEAM_BASERUN_SB < 105.5) then IMP_TEAM_FIELDING_DP = 145.5;
	
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB > 122.5) and (TEAM_BATTING_HR < 34.5) then IMP_TEAM_FIELDING_DP = 118.7;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB > 122.5) and (TEAM_BATTING_HR > 34.5) then IMP_TEAM_FIELDING_DP = 147.4;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB < 122.5) and (TEAM_BATTING_SO > 794.5) then IMP_TEAM_FIELDING_DP = 153.2;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB < 122.5) and (TEAM_BATTING_SO < 794.5) and (TEAM_FIELDING_E > 181.5) then IMP_TEAM_FIELDING_DP = 152.8;
	if (TEAM_FIELDING_E < 234.5) and (TEAM_BASERUN_SB < 122.5) and (TEAM_BATTING_SO < 794.5) and (TEAM_FIELDING_E < 181.5) then IMP_TEAM_FIELDING_DP = 163.9;
end;

P_TARGET_WINS = 14.6713 + 0.04978*TEAM_BATTING_H -0.03607*TEAM_BATTING_2B + 0.04501*TEAM_BATTING_3B + 0.07883*TEAM_BATTING_HR + 0.02471*TEAM_BATTING_BB + 0.00178*TEAM_PITCHING_H - 0.05383*TEAM_FIELDING_E - 0.08155*IMP_TEAM_FIELDING_DP + 0.03342*IMP_TEAM_BASERUN_SB - 0.01193*IMP_TEAM_BATTING_SO + 0.03998	*IMP_TEAM_BASERUN_CS+ 29.89064*BASERUN_SB_FLAG + 2.63618*FIELDING_DP_FLAG + 5.00941*PITCHING_SO_FLAG;
P_TARGET_WINS = round( P_TARGET_WINS, 1 );

keep INDEX P_TARGET_WINS;
run;


proc print data=BB.KEVIN(obs=7);
run;

proc means data=BB.KEVIN N NMISS MIN MEAN MAX;
var P_TARGET_WINS;
run;


proc export data=BB.KEVIN
outfile=" /folders/myfolders/sasuser.v94/Unit01/FLAGMOD.csv "
dbms=csv;
run;


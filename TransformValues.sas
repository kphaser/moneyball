
%let PATH = /folders/myfolders/sasuser.v94/Data;
%let NAME = NWU;
%let LIB = &NAME..;

libname &NAME. "&PATH.";


%let HOWMANY = 10000;
%let SEED = 1;


data TEMPFILE;
call streaminit(&SEED.);
do i = 1 to &HOWMANY.;
	X = 10*rand("normal") + 10*rand("lognormal") - 10*rand("uniform");
	X = sign(X)*abs(X)**(1.5);
	length COLOR $6;
	COLOR = "???";
	if 		X < -100 	then 	COLOR = "RED";
	else if X < 0		then 	COLOR = "ORANGE";
	else if X < 100		then 	COLOR = "YELLOW";
	else if X < 500		then 	COLOR = "GREEN";
	else if X < 1000	then 	COLOR = "BLUE";
	else 						COLOR = "VIOLET";
	output;
end;
drop i;
run;





proc contents data=TEMPFILE;
run;

proc print data=TEMPFILE(obs=10);
run;



proc means data=TEMPFILE n mean stddev p1 p5 p95 p99 min max;
var X;
run;

proc univariate data=TEMPFILE noprint;
histogram X;
run;

proc freq data=TEMPFILE;
table COLOR / plots=freqplot;
run;




proc means data=TEMPFILE n mean stdDev p1 p5 p95 p99 min max;
var X;
run;


proc means data=TEMPFILE noprint;
output out=MEANFILE 
		mean(X)		=U 
		stddev(X)	=S 
		P1(X)		=P01x 
		P5(X)		=P05x 
		P95(X)		=P95x 
		P99(X)		=P99x 
		min(X)		=MINx 
		max(X)		=MAXx;
run;

proc print data=MEANFILE;
run;

data;
set MEANFILE;
call symput("U",U);
call symput("S",S);
call symput("P01x"	,P01x);
call symput("P05x"	,P05x);
call symput("P95x"	,P95x);
call symput("P99x"	,P99x);
call symput("MINx"	,MINx);
call symput("MAXx"	,MAXx);
run;

data XFORM;
set TEMPFILE;
T95_X 		= max(min(X,&P95x.),&P05x.);
T99_X 		= max(min(X,&P99x.),&P01x.);
STD_X 		= (X-&U.)/&S.;
T_STD_X		= max(min(STD_X,3),-3);
T_STD_X		= max(min(STD_X,3),-3);
LN_X 		= sign(X) * log(abs(X)+1);
LOG10_X 	= sign(X) * log10(abs(X)+1);
run;





proc univariate data=XFORM noprint;
histogram T95_X;
run;

proc univariate data=XFORM noprint;
histogram T99_X;
run;

proc univariate data=XFORM noprint;
histogram STD_X;
run;

proc univariate data=XFORM noprint;
histogram T_STD_X;
run;

proc univariate data=XFORM noprint;
histogram LN_X;
run;

proc univariate data=XFORM noprint;
histogram LOG10_X;
run;

proc univariate data=XFORM noprint;
histogram NORM_X;
run;

proc univariate data=XFORM noprint;
histogram N99_X;
run;

proc univariate data=XFORM noprint;
histogram N95_X;
run;











proc means data=TEMPFILE noprint;
output out=MEANFILE 
		min(X)		=MINx 
		max(X)		=MAXx;
run;


data;
set MEANFILE;
call symput("MINx"	,MINx);
call symput("MAXx"	,MAXx);
run;

%let BIN = 4;

data XFORM;
set TEMPFILE;
NORM_X  	= ( X - &MINX. ) / (&MAXX.-&MINX.);
BUCKET_X	= min(int(&BIN.*NORM_X),&BIN.-1);
run;

proc print data=XFORM(obs=20);
var X NORM_X BUCKET_X;
run;

proc freq data=XFORM;
table BUCKET_X / plots=freqplot;
run;






%let BIN = 4;

proc rank data=TEMPFILE out=RANKFILE  groups=&BIN.;
var X;
ranks QUANT_X;
run;

proc print data=RANKFILE(obs=10);
run;

proc means data=RANKFILE MAX;
class QUANT_X;
var X ;
run;

data XFORM;
set TEMPFILE;
if X <= -2.6412568 then
	QUANT_X = 0;
else if X <= 20.9473816 then
	QUANT_X = 1;
else if X <= 84.8102529 then
	QUANT_X = 2;
else 
	QUANT_X = 3;
run;

proc freq data=XFORM;
table QUANT_X / plots=freqplot;
run;










data XFORM;
set TEMPFILE;
if X <= 0 then
	ADHOC_X = 0;
else if X <= 100 then
	ADHOC_X = 1;
else if X <= 200 then
	ADHOC_X = 2;
else 
	ADHOC_X = 3;
run;

proc freq data=XFORM;
table ADHOC_X / plots=freqplot;
run;
















proc freq data=TEMPFILE;
table COLOR / plots=freqplot;
run;



data XFORM;
set TEMPFILE;
COLOR_RO 	= COLOR in ("RED","ORANGE");
COLOR_YG = COLOR in ("YELLOW","GREEN");
COLOR_BV 	= COLOR in ("BLUE","VIOLET");
run;

proc freq data=XFORM;
table COLOR_RO COLOR_YG COLOR_BV / plots=freqplot;
run;





data XFORM;
set TEMPFILE;
COLOR_ORANGE 	= COLOR in ("ORANGE");
COLOR_YELLOW 	= COLOR in ("YELLOW");
COLOR_GREEN 	= COLOR in ("GREEN");
COLOR_OTHER 	= COLOR in ("RED","BLUE","VIOLET");
run;

proc freq data=XFORM;
table COLOR_ORANGE COLOR_YELLOW COLOR_GREEN COLOR_OTHER / plots=freqplot;
run;










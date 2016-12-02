
data TEMPFILE;
label Y 	=	"Monthly use of steam (in pounds)";
label X6 	=	"Operating days per month";
label X8 	=	"Average atmospheric temperature (in degrees F)";
input X6 X8 Y;
datalines;
20  35.3  10.98
20  29.7  11.13
23  30.8  12.51
20  58.8  8.40
21  61.4  9.27
22  71.3  8.73
11  74.4  6.36
23  76.7  8.50
21  70.7  7.82
20  57.5  9.14
20  46.4  8.24
21  28.9  12.19
21  28.1  11.88
19  39.1  9.57
23  46.8  10.94
20  48.5  9.58
22  59.3  10.09
22  70.0  8.11
11  70.0  6.83
23  74.5  8.88
20  72.1  7.68
21  58.1  8.47
20  44.6  8.86
20  33.4  10.36
22  28.6  11.08
;
run; 



proc reg data=TEMPFILE outest=ESTFILE AIC SBC BIC CP ADJRSQ;
model Y = X6 X8;
run;
quit;

proc print data=ESTFILE;
run;


proc glm data=TEMPFILE;
model Y = X6 X8;
run;
quit;


proc genmod data=TEMPFILE;
model Y = X6 X8 / dist=normal link=identity;
run;
quit;






proc glm data=TEMPFILE;
model Y = X6 X8;
run;
quit;

proc genmod data=TEMPFILE;
model Y = X6 X8 / link=identity dist=normal;
run;





%macro SCORE( INFILE, OUTFILE );

data &OUTFILE.;
set &INFILE.;
YHAT = 9.12689 + 0.20282*X6 - 0.07239*X8;
run;

%mend;


data NEWFILE;
input X6 X8;
datalines;
25  35.0
24  30.0
23  25.5
22  40.0
21  15.5
;
run; 


%SCORE( TEMPFILE, SCOREFILE );
%SCORE( NEWFILE, NEWSCORE );

proc print data=SCOREFILE(obs=5);
run;

proc print data=NEWSCORE(obs=5);
run;




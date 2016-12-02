



data OUTLIER;
input X Y;
datalines;
1 2
2 4
3 6
4 8
5 10
1000 2000
;
run;

proc print data=OUTLIER;
run;

proc reg data=OUTLIER;
model Y = X;
run;
quit;



data OUTLIER;
input X Y;
datalines;
1.1 2
2.2 4
3.3 6
4.4 8
5.5 10
1000 2000
;
run;

proc print data=OUTLIER;
run;

proc reg data=OUTLIER;
model Y = X;
run;
quit;





data OUTLIER;
input X Y;
datalines;
1 2
2 4
3 6
4 8
5 10
1100 2000
;
run;

proc print data=OUTLIER;
run;

proc reg data=OUTLIER;
model Y = X;
run;
quit;



















data OUTLIER;
input X Y;
*X = (X-1)/(1100-1);
datalines;
1 2
2 4
3 6
4 8
5 10
1100 3000
;
run;

proc print data=OUTLIER;
run;

proc reg data=OUTLIER;
model Y = X;
run;
quit;


data OUTLIER;
input X Y;
YHat = round(2.72925*X-2.18643,1);
X = (X-1)/(1100-1);
YHat_N = round(2999.45053*X + 0.54282,1);
datalines;
10 20
20 40
30 60
40 80
50 100
;
run;


proc print data=OUTLIER;
run;











/*Import the data file and store it in the library*/
proc import datafile='/home/u50169597/prostate_cancer/prostate.csv'
	out=WORK.prostate 
	dbms=csv;
	guessingrows=20;
	getnames=yes;
run;
/*View the data*/
proc contents data=WORK.prostate;
run; *Variable attributes;
proc print data=WORK.prostate (obs=25);
run; *Print first 25 rows;
/**Univariate Analysis-Qualitative***/
/*Table ordered as in data for ekg*/
proc sort data= WORK.prostate;
by descending ekg;
run;
proc freq data=WORK.prostate order=data; *Table in descending order;
tables ekg;
run;
proc sgplot data=WORK.prostate; *Vertical bar chart-relative frequency;
title 'Electrocardiogram Test Results of Each Patient';
vbar ekg/stat=percent;
xaxis label='EKG Results';
yaxis label='Frequencies';
run;
proc gchart data=WORK.prostate;
pie ekg/type=pct;
legend;
run;
/*Table ordered as in data for status*/
proc sort data=WORK.prostate;
by descending status;
run;
proc freq data=WORK.prostate order=data;
tables status;
run;
proc sgplot data=WORK.prostate;
title 'Current Status Recorded of Each Patient';
vbar status/stat=percent;
xaxis label='Current Status';
yaxis label='Frequencies';
run;
proc format;
value yn
0='N'
1='Y';
run;
data WORK.prostate;
drop tmp_:;
set WORK.prostate (rename=(hx=tmp_hx));
hx=put(tmp_hx,yn.);
run;
/**Bivariate-Two Categorical Variables**/
*Contigency table of summary statistics;
proc freq data=WORK.prostate nlevels; *Introduce NLEVELS option;
table hx*ekg; *Row by column;
run;
*Side by side bar chaty-relative frequency;
proc sgplot data=WORK.prostate;
vbar ekg/group=hx groupdisplay=cluster stat=percent;
title 'Patients History of Cardiovascular Disease by Corresponding Electrocardiogram Results';
run;
*Method for 100% stacked bar chart;
*1-Write the frequencies to a new data set;
proc freq data=WORK.prostate;
tables hx*ekg;
ods output crosstabfreqs= WORK.categoricals; *Write output data set of counts;
run;
*2-Extract the row frequencies into a new data set;
data WORK.categoricals2;
set WORK.categoricals (drop=table);
if not missing (rowpercent);
run;
*3-Generate the plot;
proc sgplot data= WORK.categoricals2;
vbar ekg/group=hx groupdisplay=stack response=rowpercent;
title "Patients History of Cardiovascular Disease by Corresponding Electrocardiogram Results";
run;
/**Bivariate-Quantitative by qualitative**/
*Numerical sumaries by group with CI;
data WORK.prostate;
drop tmp_:;
set WORK.prostate (rename=(bm=tmp_bm));
bm=put(tmp_bm,yn.);
run;
proc means data=WORK.prostate n mean std min q1 median q3 max nmiss clm alpha=0.05 maxdec=3;
var hg;
class bm;
run;
*Side by side boxplots;
proc sgplot data=WORK.prostate;
vbox hg/category=bm;
title"Serum homoglobin measures of each patient by their corresponding histories of bone metastases";
yaxis label="Serum Hemoglobin Measures (grams/100mL)";
run;
*Histograms by group;
proc sort data=WORK.prostate; 
by bm;
run;
proc sgplot data=WORK.prostate;
histogram hg;
by bm;
xaxis label="Serum Hemoglobin Measures (grams/100mL)";
run;
/*Two quantitative variables*/
*Correlation;
proc corr data= WORK.prostate nomiss outp=WORK.CorrOutp; *outp=creates a data set of the output;
var sbp wt;
run;
proc print data=WORK.CorrOutp noobs;
run;
*Scatterplot and regression line coefficients;
proc reg data=WORK.prostate alpha=0.05 plots(only)=(residuals fitplot);
model sbp=wt; *Form y=x;
run;
quit;









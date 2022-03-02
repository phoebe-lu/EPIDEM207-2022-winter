/*Rename file*/
data john;
set work.johnetal;
run;

proc contents data=john order=varnum;
run;

/*Data cleaning*/
*auditc_cat variable coding does not match data codebook;
*Could not figure out all the variables to rename;
data john_clean1;
rename F1=age F3=sex F4=educ F7=cod_record F9=cod_cat F10=prsn_time F12=hlt_cat F14=auditc_cat 
F15=rsk_grp_tab_2 F16=rsk_grp_tab3 F17=rsk_grp_tab4 F18=smokehist F19=id_num;
set john;
run;
proc contents data=john_clean4;
run;
*Fix audit-c category;
data john_clean2;
format auditc_new $char32.;
set john_clean1;
if auditc_cat = "5. abstinent" then auditc_new = "Abstinent (AUDIT-C=0)";
if auditc_cat = "1. 1-3" then auditc_new = "Low to Moderate (AUDIT-C=1-3)";
if auditc_cat = "2. 4" then auditc_new = "Moderate to High (AUDIT-C=4)";
if auditc_cat = "3. 5" then auditc_new = "High (AUDIT-C=5)";
if auditc_cat = "4. 6-7" then auditc_new = "Very High (AUDIT-C=6-7)";
if auditc_cat = "6. 8-12" then auditc_new = "Extremely High (AUDIT-C=8-12)";
run;
*Rename self-rated health category;
data john_clean3;
set john_clean2;
if hlt_cat = "excell very good" then hlt_new = "Very good to excellent health";
if hlt_cat = "good" then hlt_new = "Good health";
if hlt_cat = "fair poor" then hlt_new = "Poor to fair health";
run;
data john_clean4;
set john_clean3;
format smoke_new $char32.;
if smokehist = "0. never smoker" then smoke_new = "Never smoker";
if smokehist = "1. ever ltd smoker" then smoke_new = "Ever less than daily";
if smokehist = "2. former daily smoker" then smoke_new = "Former daily";
if smokehist = "3. cs daily -19" then smoke_new = "Current daily <20 cpd";
if smokehist = "4. cs daily 20-" then smoke_new = "Current daily >=20 cpd";
run;
*Create format to reorder variables;
proc format;
value $auditorder
'Abstinent (AUDIT-C=0)' = 0
'Low to Moderate (AUDIT-C=1-3)' =1 
'Moderate to High (AUDIT-C=4)' =2 
'High (AUDIT-C=5)' =3
'Very High (AUDIT-C=6-7)' =4
'Extremely High (AUDIT-C=8-12)' =5;
value $hltorder
'Poor to fair health' =1
'Good health' =2
'Very good to excellent health'=3; 
value $smokeorder
'Never smoker'=1
'Ever less than daily'=2
'Former daily'=3
'Current daily <20 cpd'=4
'Current daily >=20 cpd'=5;
run;
*Add new variables - person-years, deceased binary;
data john_clean5;
set john_clean4;
prsn_time_yrs = round(prsn_time/365, 2);
if cod_record = "deceased" then deceased_bin =1;
if cod_record = "alive" then deceased_bin=0;
run;
*Apply formats to reorder data;
data john_format;
set john_clean5;
length auditc_order 8 hlt_order 8 smoke_order 8;
auditc_order = put(auditc_new, $auditorder.);
hlt_order = put(hlt_new, $hltorder.);
smoke_order = put(smoke_new, $smokeorder.);
run;


/*Table 1*/
/*ods trace on;*/
/*ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\Assignments\Assignment 3\Table 1.xlsx' options(sheet_interval='none');*/
proc means data=john_format n mean stddev maxdec=1;
var prsn_time_yrs;
run;
proc means data=john_format stackodsoutput n mean stddev maxdec=1;
var age;
run;
proc means data=john_format nonobs n mean stddev maxdec=1;
class sex;
var prsn_time_yrs;
where sex="female";
run;
proc freq data=john_format;
table sex /nofreq nocum;
run;
proc means data=john_format nonobs n mean stddev maxdec=1;
class educ;
var prsn_time_yrs;
run;
proc freq data=john_format;
table educ /nofreq nocum;
run;
proc means data=john_format nonobs n mean stddev maxdec=1;
class smoke_new;
var prsn_time_yrs;
run;
proc freq data=john_format;
table smoke_new /nofreq nocum;
run;
proc means data=john_format nonobs n mean stddev maxdec=1;
class hlt_new;
var prsn_time_yrs;
run;
proc freq data=john_format;
table hlt_new /nofreq nocum;
run;
proc means data=john_format nonobs n mean stddev maxdec=1;
class auditc_new;
var prsn_time_yrs;
run;
proc freq data=john_format;
table auditc_new /nofreq nocum;
run;
/*ods excel close;*/


/*Table 2*/
proc contents data=john_format order=varnum;
run;
*Frequency of Audit-c levels and death;
ods trace on;
/*ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\Assignments\Assignment 3\Table 2.xlsx' options(sheet_interval='none');*/
proc freq data=john_format;
table deceased_bin*auditc_new/nocol nopercent;
run;
*Unadjusted hazard ratios;
ods trace on;
ods select ParameterEstimates;
proc phreg data=john_format;
class auditc_new(ref="Abstinent (AUDIT-C=0)")/param=ref order=internal;
model prsn_time_yrs*deceased_bin(0)=auditc_new/rl;
run;
*Adjusted HR for sex, age, smoking status, and years of education at baseline;
ods select ParameterEstimates;
proc phreg data=john_format;
class auditc_new(ref="Abstinent (AUDIT-C=0)") sex(ref="female") smoke_new(ref="Never smoker") educ(ref="12 or more")/param=ref order=internal;
model prsn_time_yrs*deceased_bin(0)=auditc_new age sex smoke_new educ/rl;
run;
*Adjusted HR for sex, age, smoking status, years of education, and self-reported health at baseline;
ods select ParameterEstimates;
proc phreg data=john_format;
class auditc_new(ref="Abstinent (AUDIT-C=0)") sex(ref="female") smoke_new(ref="Never smoker") educ(ref="12 or more") hlt_new(ref="Very good to excellent health")/param=ref order=internal;
model prsn_time_yrs*deceased_bin(0)=auditc_new age sex smoke_new educ hlt_new/rl;
run;
/*ods excel close;*/


/*Figure 2*/
*Unadjusted plot;
*Create covariate values for graphing;
ods graphics on;
data fig1_unadjusted;
	format auditc_order auditorder.;
	input auditc_order $32.;
	datalines;
	0
	1
	2
	3
	4
	5
;
run;
*Unadjusted model survival curve
ods graphics on;
ods output survivalplot=_surv;
proc phreg 	data=john_format plots(overlay)=(survival);
format auditc_order auditorder.;
class 		auditc_order /param=ref order=internal;
model		prsn_time_yrs*deceased_bin(0)=auditc_order/rl;
baseline 	covariates=fig1_unadjusted/rowid=auditc_order;
	where 		auditc_order=0|auditc_order=1|auditc_order=2|auditc_order=3|
				auditc_order=4|auditc_order=5;
run;
/*ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\Assignments\Assignment 3\Figure2a.xlsx' options(sheet_interval='none');*/
ods graphics on;
proc sgplot data=_surv;
	step x=time y=survival/group=auditc_order;
	keylegend/title=" ";
	xaxis label="Person-Time (continuous, years)";
	yaxis label="Survival";
run;
/*ods excel close;*/

*Model 1;
*Covariate Baseline Dataset for Graphing;
data fig2_adjusted;
	format	auditc_order	auditorder.
			sex 			$CHAR6.
			educ			$CHAR10.;
	input	auditc_order
			sex
			smoke_order
			educ
			age;
	datalines;
	0 0 0 3 42
	1 0 0 3 42
	2 0 0 3 42
	3 0 0 3 42
	4 0 0 3 42
	5 0 0 3 42
	;
run;
*Model 1 survival curve;
ods output survivalplot=_surv;
proc phreg 	data=john_format plots(overlay)=(survival);
format auditc_order auditorder.;
class 		auditc_order sex(ref="female") smoke_order educ(ref="12 or more")/param=ref order=internal;
model		prsn_time_yrs*deceased_bin(0)=auditc_order age sex smoke_order educ/rl;
baseline 	covariates=fig2_adjusted/rowid=auditc_order;
	where 		auditc_order=0|auditc_order=1|auditc_order=2|auditc_order=3|
				auditc_order=4|auditc_order=5;
run;
/*ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\Assignments\Assignment 3\Figure2b.xlsx' options(sheet_interval='none');*/
ods graphics on;
proc sgplot data=_surv;
	step x=time y=survival/group=auditc_order;
	keylegend/title=" ";
	xaxis label="Person-Time (continuous, years)";
	yaxis label="Survival";
run;
/*ods excel close;*/

*Model 2;
data fig3_adjusted;
	format	auditc_order	auditorder.
			sex 			$CHAR6.
			educ			$CHAR10.;
	input	auditc_order
			sex
			smoke_order
			educ
			age
			hlt_order;
	datalines;
	0 0 0 3 42 3
	1 0 0 3 42 3
	2 0 0 3 42 3
	3 0 0 3 42 3
	4 0 0 3 42 3
	5 0 0 3 42 3
	;
ods output survivalplot=_surv;
proc phreg 	data=john_format plots(overlay)=(survival);
format auditc_order auditorder.;
class 		auditc_order(ref='0') sex(ref="female") smoke_order
educ(ref="12 or more") hlt_order(ref='3')/param=ref order=internal;
model		prsn_time_yrs*deceased_bin(0)=auditc_order age sex smoke_order educ hlt_order/rl;
baseline 	covariates=fig3_adjusted/rowid=auditc_order;
	where 		auditc_order=0|auditc_order=1|auditc_order=2|auditc_order=3|
				auditc_order=4|auditc_order=5;
run;

/*ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\Assignments\Assignment 3\Figure2c.xlsx' options(sheet_interval='none');*/
ods graphics on;
proc sgplot data=_surv;
	step x=time y=survival/group=auditc_order;
	keylegend/title=" ";
	xaxis label="Person-Time (continuous, years)";
	yaxis label="Survival";
run;
/*ods excel close;*/
ods graphics off;

/*0 = 'Abstinent (AUDIT-C=0)'*/
/*1 = 'Low to Moderate (AUDIT-C=1-3)'*/
/*2 = 'Moderate to High (AUDIT-C=4)'*/
/*3 = 'High (AUDIT-C=5)'*/
/*4 = 'Very High (AUDIT-C=6-7)'*/
/*5 = 'Extremely High (AUDIT-C=8-12)';*/
/*where 		auditc_new='Abstinent (AUDIT-C=0)'|auditc_new='Low to Moderate (AUDIT-C=1-3)'*/
/*	|auditc_new='Moderate to High (AUDIT-C=4)'|auditc_new='High (AUDIT-C=5)'|*/
/*	auditc_new='Very High (AUDIT-C=6-7)'|auditc_new='Extremely High (AUDIT-C=8-12)';*/

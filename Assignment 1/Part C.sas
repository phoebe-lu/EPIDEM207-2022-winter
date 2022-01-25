*Use kim2021_formats dataset from Part B;
/*Table 1*/
*proc tabulate guides: 
-https://www.sas.com/content/dam/SAS/en_ca/User%20Group%20Presentations/Vancouver-User-Group/Lai_ProcTabulateIntro_May2015.pdf
-https://support.sas.com/resources/papers/proceedings/pdfs/sgf2008/091-2008.pdf;
ods trace on;
ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Table_1.xlsx' options(sheet_interval='none');
proc tabulate data=kim2021_formats;
format obese_status obese_status. ms ms. ht ht. dm dm. shx_smoke_yn shx_smoke_yn. shx_alcohol_yn shx_alcohol_yn.;
	class ASM_quartile obese_status ms ht dm shx_smoke_yn shx_alcohol_yn;
	var 
		age bexam_wt bexam_BMI bexam_wc bexam_BP_systolic bexam_BP_diastolic height_m
		VFA_cm2 ASM_kg ASM_perc chol  hdl ldl tg glu got gpt uric_acid HbA1c insulin homa_ir crp;
	table 
		(age bexam_wt bexam_BMI bexam_wc bexam_BP_systolic bexam_BP_diastolic height_m
		VFA_cm2 ASM_kg ASM_perc chol  hdl ldl tg glu got gpt uric_acid HbA1c insulin homa_ir crp)
		* (N MEAN STD) (obese_status ms ht dm shx_smoke_yn shx_alcohol_yn) * (N), asm_quartile ALL/misstext='0';
run;
ods excel close;


/*Figure 3*/
ods trace on;
ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Figure_3.xlsx' options(sheet_interval='none');
proc freq data=kim2021_formats;
table ms*asm_quartile;
run;
ods excel close;
/*proc sgplot data=kim2021_formats;*/
/*vbar asm_quartile/response=ms stat=percent;*/
/*where ms=1;*/
/*run;*/

/*Table 2*/
ods trace on;
ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Table_2.xlsx' options(sheet_interval='none');
*Crude model;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class ms (ref='0')/param=reference;
model ms=sarcopenia /clodds=wald orpvalue;
run;
*Model 1;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0') sex (ref='1')/param=reference;
model ms=sarcopenia age sex/clodds=wald orpvalue;
run;
*Model 2;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0')/param=reference;
model ms=sarcopenia age sex obesity/clodds=wald orpvalue;
run;
*Model 3;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0') 
ht (ref='0') dm (ref='0') DysL (ref='0')/param=reference;
model ms = sarcopenia age sex obesity ht dm dysl/clodds=wald orpvalue;
run;
*Model 4;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0') 
ht (ref='0') dm (ref='0') DysL (ref='0') shx_smoke_yn (ref='0') shx_alcohol_yn (ref='0')/param=reference;
model ms=sarcopenia age sex obesity ht dm dysl shx_smoke_yn shx_alcohol_yn/clodds=wald orpvalue;
run;
*Model 5;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0') 
ht (ref='0') dm (ref='0') DysL (ref='0') shx_smoke_yn (ref='0') shx_alcohol_yn (ref='0')/param=reference;
model ms = sarcopenia age sex obesity ht dm dysl shx_smoke_yn shx_alcohol_yn crp/clodds=wald orpvalue;
run;
ods excel close;


proc print data=kim2021_formats (obs=10);
run;
/*Table 3*/
*Create new variable for underweight;
data kim2021_table3;
set kim2021_formats;
if obese_status = 1 then underweight=1;
else if obese_status ~= 1 then underweight = 0;
run;
proc freq data=kim2021_table3;
table obese_status*underweight;
run;
ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Table_3.xlsx' options(sheet_interval='none');
*Visceral obesity;
ods select cloddswald;
title 'Visceral obesity - Yes'.;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0')/ param=reference;
model ms = sarcopenia/clodds=wald orpvalue;
where vfa_obese=1;
run;
ods select cloddswald;
title 'Visceral obesity - No'.;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0')/ param=reference;
model ms = sarcopenia/clodds=wald orpvalue;
where vfa_obese=0;
run;
*Obesity;
ods select cloddswald;
title 'Obesity - Yes'.;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0')/ param=reference;
model ms = sarcopenia/clodds=wald orpvalue;
where obesity=1;
run;
ods select cloddswald;
title 'Obesity - No'.;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0')/ param=reference;
model ms = sarcopenia/clodds=wald orpvalue;
where obesity=0;
run;
*Underweight;
ods select cloddswald;
title 'Underweight - Yes'.;
proc logistic data=kim2021_table3 desc;
class sarcopenia (ref='0')/ param=reference;
model ms = sarcopenia/clodds=wald orpvalue;
where underweight=1;
run;
ods select cloddswald;
title 'Underweight - No'.;
proc logistic data=kim2021_table3 desc;
class sarcopenia (ref='0')/ param=reference;
model ms = sarcopenia/clodds=wald orpvalue;
where underweight=0;
run;
*Sex;
ods select cloddswald;
title 'Sex - Male'.;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0')/ param=reference;
model ms = sarcopenia/clodds=wald orpvalue;
where sex=1;
run;
ods select cloddswald;
title 'Sex - Female'.;
proc logistic data=kim2021_formats desc;
class sarcopenia (ref='0')/ param=reference;
model ms = sarcopenia/clodds=wald orpvalue;
where sex=2;
run;
ods excel close;

/*Figure 4*/
data kim2021_table4;
set kim2021_formats;
if 20 <= age <= 29 then agegroup="20-29";
else if 30 <= age <= 39 then agegroup="39-39";
else if 40 <= age <= 49 then agegroup="40-49";
else if 50 <= age <= 59 then agegroup="50-59";
else if 60 <= age <= 69 then agegroup="60-69";
else if age >= 70 then agegroup="70+";
run;
ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Figure_4.xlsx' options(sheet_interval='none');
proc freq data=kim2021_table4;
table agegroup*sarcopenia*MS;
run;
ods excel close;

/*Table 4*/
proc print data=work.kim2021 (obs=10);
run;
*Create new variables for severe MS;
data kim2021_table4;
set kim2021_formats;
if ms_5cri = 4 or ms_5cri = 5 then ms_4or5_crit = 1;
else ms_4or5_crit = 0;
if ms_5cri = 5 then ms_5_crit=1;
else ms_5_crit = 0;
run;
proc freq data=kim2021_table4;
table ms_5cri*severe_ms;
run;
*Crude;
ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Table_4.xlsx' options(sheet_interval='none');
ods select CLoddsWald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0')/ param=reference;
model ms_4or5_crit = sarcopenia/clodds=wald orpvalue;
run;
ods select CLoddswald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0')/ param=reference;
model ms_5_crit = sarcopenia/clodds=wald orpvalue;
run;
*Model 1;
ods select CLoddsWald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1')/ param=reference;
model ms_4or5_crit = sarcopenia age sex/clodds=wald orpvalue;
run;
ods select CLoddswald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1')/ param=reference;
model ms_5_crit = sarcopenia age sex/clodds=wald orpvalue;
run;
*Model 2;
ods select CLoddsWald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0')/ param=reference;
model ms_4or5_crit = sarcopenia age sex obesity/clodds=wald orpvalue;
run;
ods select CLoddswald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0')/ param=reference;
model ms_5_crit = sarcopenia age sex obesity/clodds=wald orpvalue;
run;
*Model 3;
ods select CLoddsWald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0') ht (ref='0')
dm (ref='0') dysl (ref='0')/ param=reference;
model ms_4or5_crit = sarcopenia age sex obesity ht dm dysl/clodds=wald orpvalue;
run;
ods select CLoddswald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0') ht (ref='0')
dm (ref='0') dysl (ref='0')/ param=reference;
model ms_5_crit = sarcopenia age sex obesity ht dm dysl/clodds=wald orpvalue;
run;
*Model 4;
ods select CLoddsWald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0') ht (ref='0')
dm (ref='0') dysl (ref='0') shx_smoke_yn (ref='0') shx_alcohol_yn (ref='0')/ param=reference;
model ms_4or5_crit = sarcopenia age sex obesity ht dm dysl
shx_smoke_yn shx_alcohol_yn/clodds=wald orpvalue;
run;
ods select CLoddswald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0') ht (ref='0')
dm (ref='0') dysl (ref='0') shx_smoke_yn (ref='0') shx_alcohol_yn (ref='0')/ param=reference;
model ms_5_crit = sarcopenia age sex obesity ht dm dysl
shx_smoke_yn shx_alcohol_yn/clodds=wald orpvalue;
run;
*Model 5;
ods select CLoddsWald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0') ht (ref='0')
dm (ref='0') dysl (ref='0') shx_smoke_yn (ref='0') shx_alcohol_yn (ref='0')/ param=reference;
model ms_4or5_crit = sarcopenia age sex obesity ht dm dysl
shx_smoke_yn shx_alcohol_yn crp/clodds=wald orpvalue;
run;
ods select CLoddswald;
proc logistic data=kim2021_table4 desc;
class sarcopenia (ref='0') sex (ref='1') obesity (ref='0') ht (ref='0')
dm (ref='0') dysl (ref='0') shx_smoke_yn (ref='0') shx_alcohol_yn (ref='0')/ param=reference;
model ms_5_crit = sarcopenia age sex obesity ht dm dysl
shx_smoke_yn shx_alcohol_yn crp/clodds=wald orpvalue;
run;
ods excel close;

/*Table 5*/
data kim2021_table5;
set kim2021_formats;
run;
proc sort data=kim2021_table5;
by asm_quartile;
run;
proc freq data=kim2021_table5;
table asm_quartile*ms;
run;
ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Table_5.xlsx' options(sheet_interval='none');
*Unadjusted;
ods select cloddswald;
proc logistic data=kim2021_table5 desc;
class ms (ref='0') asm_quartile (ref='1')/param=reference;
model ms=asm_quartile/clodds=wald orpvalue;
run;
*Model 1;
ods select CLoddsWald;
proc logistic data=kim2021_table5 desc;
class ms (ref='0') sex (ref='1') asm_quartile (ref='1')/param=reference;
model ms=asm_quartile age sex/clodds=wald orpvalue;
run;
*Model 2;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class ms (ref='0') sex (ref='1') obesity (ref='0') asm_quartile (ref='1')/param=reference;
model ms = asm_quartile age sex obesity/clodds=wald orpvalue;
run;
*Model 3;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class ms (ref='0') sex (ref='1') obesity (ref='0') 
ht (ref='0') dm (ref='0') DysL (ref='0') asm_quartile (ref='1')/param=reference;
model ms = asm_quartile age sex obesity ht dm dysl/clodds=wald orpvalue;
run;
*Model 4;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class ms (ref='0') sex (ref='1') obesity (ref='0') 
ht (ref='0') dm (ref='0') DysL (ref='0') shx_smoke_yn (ref='0') 
shx_alcohol_yn (ref='0') ASM_quartile (ref='1')/param=reference;
model ms = asm_quartile age sex obesity ht dm dysl shx_smoke_yn shx_alcohol_yn/clodds=wald orpvalue;
run;
*Model 5;
ods select CLoddsWald;
proc logistic data=kim2021_formats desc;
class ms (ref='0') sex (ref='1') obesity (ref='0') 
ht (ref='0') dm (ref='0') DysL (ref='0') shx_smoke_yn (ref='0') 
shx_alcohol_yn (ref='0') asm_quartile (ref='1')/param=reference;
model ms = asm_quartile age sex obesity ht dm dysl shx_smoke_yn shx_alcohol_yn crp/clodds=wald orpvalue;
run;
ods excel close;

/*Figure 5*/
*proc corr resource:
https://www.lexjansen.com/pharmasug/2008/tu/TU04.pdf
ods trace on;
ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Figure_5.xlsx' options(sheet_interval='none');
ods graphics on;
ods select pearsoncorr scatterplot;
proc corr data=kim2021_formats plots(maxpoints=none)=all;
var vfa_cm2 asm_kg;
run;
ods excel close;
proc means data=kim2021_formats;
var vfa_cm2 asm_kg;
run;
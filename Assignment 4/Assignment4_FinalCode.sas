/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*	Author: Tahmineh Romero*/
/*	Paper: Association between sarcopenia level and metabolic syndrome*/
/*	Su Hwan Kim, et, al*/
/*	Published: March 19, 2021*/
/*	https://doi.org/10.1371/journal.pone.0248856*/
/*	Data: https://doi.org/10.1371/journal.pone.0248856.s001*/
/*	purpose: Assignmet 1-PartB*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*libname A1 "\\Client\H$\Documents\UCLA\WQ2022\EPI207";*/
/**/
/**/
/*proc import datafile="\\Client\H$\Documents\UCLA\WQ2022\EPI207\Kim2021.csv" out=dat out=csv replace;*/
/*run;*/

data data;
set work.cleaneddata;
run;

proc contents data=data varnum;
run;

/*Setup data*/
/*Filter age 25-60 years and select needed varibles*/
DATA outdata;
	SET data;
	where 25<=age & age <=60;
	KEEP ID 
		 Sex 
		 Age 
		 HT 
		 DM 
		 DysL_ 
		 bexam_wc 
		 bexam_BMI 
		 ASM_Wt_
		 shx_smoke_yn
		 shx_alcohol_yn
		 mhx_HT_yn
		 bexam_BP_diastolic
		 bexam_BP_systolic;
RUN;

/*n=10759*/
PROC CONTENTS data=outdata VARNUM;
RUN;

/*Format data set*/

PROC FORMAT;
	value Sex 	1='Male'
				2='Female';
	value YN	0='No'
				1='Yes';
	value BMItx 0 = 'Under weight (BMI <18.5 kg/m^2)'
				1 = 'Normal (18.5 <= BMI < 23 kg/m^2)'
				2 = 'Overweight (23 <= BMI < 25 kg/m^2)'
				3 = 'Obesity (25 < BMI kg/m^2)';
RUN;	

data outdata_add;
set outdata;
if bexam_BMI < 18.5 then bmi_cat =0;
else if 18.5 <= bexam_BMI < 23 then bmi_cat =1;
else if 23 <= bexam_BMI < 25 then bmi_cat =2;
else if 25 <= bexam_BMI then bmi_cat=3;
run;


DATA outdata2;
	set outdata_add;
	MAP = bexam_BP_diastolic + (1/3 * (bexam_BP_systolic - bexam_BP_diastolic));
	ASM_10 = ASM_Wt_/10;
RUN;

PROC CONTENTS data=outdata2 VARNUM;
RUN;

DATA outdata_label;
SET outdata2;

Label	ID 					= "ID"
		Sex 				= "Sex (1=Male, 2=Female)"
		Age  				= "Age (years)"
		mhx_HT_yn			= "Medical history of hypertension"
		HT  				= "Hypertension (0=No, 1=Yes)"
		DM  				= "Diabetes (0=No, 1=Yes)"
		DysL_  				= "Dyslipidemia (0=No, 1=Yes)"
		bexam_wc  			= "Waist circumference (cm)"
		bexam_BMI  			= "Body mass index (kg/m^2)"
		ASM_Wt_ 			= "Appendicular skeletal muscle mass (%)"
		shx_smoke_yn		= "History of smoking (0=No, 1=Yes)"
		shx_alcohol_yn 		= "History of alcohol intake (0=No, 1=Yes)"
		BMI_cat				= "Obesity status according to BMI"
		bexam_BP_diastolic 	= "Diastolic blood pressure (mmHg)"
		bexam_BP_systolic	= "Systolic blood pressure (mmHg)"
		MAP					= "Mean arterial blood pressure (mmHg)"
		ASM_10				= "Re-scaled ASM%, 1 unit = 10% ASM"
;
FORMAT 	Sex 				Sex.;
FORMAT	mhx_HT_yn--DysL_  	YN.;
FORMAT	shx_smoke_yn		YN.;
FORMAT	shx_alcohol_yn		YN.;
FORMAT	BMI_cat				Bmitx.;
RUN;

PROC CONTENTS data=outdata_label VARNUM out=outdatalabdes;
RUN;

/*Descriptive statistics for codebook and Table 1*/
PROC FREQ data = outdata_label;
	TABLES 	Sex 
			mhx_HT_yn
			HT 
			DM 
			DysL_ 
			shx_smoke_yn
			shx_alcohol_yn
			BMI_cat;
RUN;

PROC MEANS data = outdata_label n mean std median min max nmiss;
	var Age
		bexam_wc
		bexam_BMI
		ASM_Wt_
		bexam_BP_diastolic
		bexam_BP_systolic
		MAP
		ASM_10;
RUN;

/* Logistic regressions (ASM% and HT) */
PROC LOGISTIC DATA=outdata_label;
TITLE "HTN: Crude Model";
MODEL HT (EVENT='Yes') = ASM_Wt_; 
RUN;
TITLE;

PROC LOGISTIC DATA=outdata_label;
MODEL HT (EVENT='Yes') = ASM_Wt_ Sex Age; 
TITLE "HTN: Model 1";
RUN;
TITLE;

PROC LOGISTIC DATA=outdata_label;
TITLE "HTN: Model 2";
MODEL HT (EVENT='Yes') = ASM_Wt_ Sex Age shx_smoke_yn shx_alcohol_yn; 
RUN;
TITLE;

/* Linear regressions (ASM% and MAP) */
PROC REG DATA=outdata_label
  plots =(DiagnosticsPanel ResidualPlot(smooth));
TITLE "MAP: Crude Model";
MODEL MAP = ASM_10/clb; 
RUN;
QUIT;
TITLE;

PROC REG DATA=outdata_label
  plots =(DiagnosticsPanel ResidualPlot(smooth));
TITLE "MAP: Model 1";
MODEL MAP = ASM_10 Sex Age/clb; 
RUN;
QUIT;
TITLE;

PROC REG DATA=outdata_label;
TITLE "MAP: Model 2"
  plots =(DiagnosticsPanel ResidualPlot(smooth));
MODEL MAP = ASM_10 Sex Age shx_smoke_yn shx_alcohol_yn/clb; 
RUN;
QUIT;
TITLE;

/* Sensitivity analysis for MAP linear regression, excluding history of HTN */
ods graphics on;
PROC REG DATA=outdata_label
  plots =(DiagnosticsPanel ResidualPlot(smooth));
TITLE "MAP: Crude Model";
MODEL MAP = ASM_10/clb; 
RUN;
QUIT;
TITLE;

ods graphics on;
PROC REG DATA=outdata_label
  plots =(DiagnosticsPanel ResidualPlot(smooth));
TITLE "MAP: Model 1";
MODEL MAP = ASM_10 Sex Age/clb; 
RUN;
QUIT;
TITLE;

ods graphics on
  plots =(DiagnosticsPanel ResidualPlot(smooth));
PROC REG DATA=outdata_label;
TITLE "MAP: Model 2";
MODEL MAP = ASM_10 Sex Age shx_smoke_yn shx_alcohol_yn/clb; 
RUN;
QUIT;
TITLE;

/* Data visualization (Figure 3) */

proc sgplot data=outdata_label;
title "Scatterplot ASM & MAP by Sex";
  reg x=ASM_Wt_ y=MAP / group=Sex;
run;
title;



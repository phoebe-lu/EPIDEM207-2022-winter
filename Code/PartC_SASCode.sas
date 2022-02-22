/* Load data */
proc import datafile="\\Client\H$\Desktop\journal.pone.0248856.s001.xlsx" dbms=xlsx out=kim2021 replace;
run;

proc contents data=kim2021 order=varnum;
run;

/*Setup data*/
/*Filter age 25-60 years and select needed varibles*/
DATA kim2021_vars;
	SET kim2021;
	where 25<=age & age <=60;
	KEEP ID 
		 Sex 
		 Age 
		 HT 
		 DM 
		 DysL_ 
		 bexam_wc 
		 bexam_BMI 
		 'ASM_Wt%'n
		 shx_smoke_yn
		 shx_alcohol_yn
		 mhx_HT_yn
		 bexam_BP_diastolic
		 bexam_BP_systolic;
RUN;

/*n=10759*/
PROC CONTENTS data=kim2021_vars VARNUM;
RUN;

/*Format data set*/
PROC FORMAT;
	value Sex 	1='Male'
				2='Female';
	value YN	0='No'
				1='Yes';
	value BMIgr low-<18.5 = '0'
				18.5-22.9 = '1'
				23-24.9	  = '2'
				25-high   = '3';
	value BMItx 0 = 'Under weight (BMI <18.5 kg/m^2)'
				1 = 'Normal (BMI 18.5-22.9 kg/m^2)'
				2 = 'Overweight (BMI 23-24.9 kg/m^2)'
				3 = 'Obesity (BMI >=25 kg/m^2)';
RUN;	

DATA kim2021_createvars;
	set kim2021_vars;
	BMIgr = put(bexam_BMI, BMIgr.);
	BMIgr2 = input(BMIgr,8.);
	MAP= bexam_BP_diastolic + (1/3 * (bexam_BP_systolic - bexam_BP_diastolic));
	drop BMIgr;
RUN;

PROC CONTENTS data=kim2021_createvars order=varnum;
RUN;

DATA kim2021_labels;
SET kim2021_createvars(rename=(BMIgr2=BMIgr));

Label	ID 					= "ID"
		Sex 				= "Sex (1=Male, 2=Female)"
		Age  				= "Age (years)"
		mhx_HT_yn			= "Medical history of hypertension"
		HT  				= "Hypertension (0=No, 1=Yes)"
		DM  				= "Diabetes (0=No, 1=Yes)"
		DysL_  				= "Dyslipidemia (0=No, 1=Yes)"
		bexam_wc  			= "Waist circumference (cm)"
		bexam_BMI  			= "Body mass index (kg/m^2)"
		'ASM_Wt%'n 			= "Appendicular skeletal muscle mass (%)"
		shx_smoke_yn		= "History of smoking (0=No, 1=Yes)"
		shx_alcohol_yn 		= "History of alcohol intake (0=No, 1=Yes)"
		BMIgr				= "Obesity status according to BMI"
		bexam_BP_diastolic 	= "Diastolic blood pressure (mmHg)"
		bexam_BP_systolic	= "Systolic blood pressure (mmHg)"
		MAP					= "Mean arterial blood pressure (mmHg)"
;
FORMAT 	Sex 				Sex.
		mhx_HT_yn--DysL_  	YN.
		shx_smoke_yn		YN.
		shx_alcohol_yn		YN.
		BMIgr				Bmitx.;
RUN;

PROC CONTENTS data=kim2021_labels order=varnum;
RUN;

/*Descriptive statistic for codebook and Table 1*/
PROC FREQ data = kim2021_labels;
	TABLES 	Sex 
			mhx_HT_yn
			HT 
			DM 
			DysL_ 
			shx_smoke_yn
			shx_alcohol_yn
			BMIgr;
RUN;

PROC MEANS data = kim2021_labels n mean std min max nmiss;
	var Age
		bexam_wc
		bexam_BMI
		'ASM_Wt%'n
		bexam_BP_diastolic
		bexam_BP_systolic
		MAP;
RUN;

/*Table 2*/
/*Crude*/
PROC logistic  data=kim2021_labels DESC;
   class HT(ref="No");
   model HT = 'ASM_Wt%'n/expb clodds=wald orpvalue;
   score fitstat;
run;

/*Model 1*/
PROC logistic  data=kim2021_labels DESC;
   class HT(ref="No") Sex(ref="Male");
   model HT = 'ASM_Wt%'n Age Sex/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_1;
run;

/*Model 2*/
PROC logistic  data=kim2021_labels DESC;
   class HT(ref="No") Sex(ref="Male");
   model HT = 'ASM_Wt%'n Age Sex bexam_BMI bexam_wc/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_2;
run;

/*Model 3*/
PROC logistic  data=kim2021_labels DESC;
   class HT(ref="No") Sex(ref="Male") DysL_(ref="No") DM(ref="No");
   model HT = 'ASM_Wt%'n Age Sex bexam_BMI bexam_wc DysL_ DM/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_3;
run;

/*Model 4*/
PROC logistic  data=kim2021_labels DESC;
   class HT(ref="No") Sex(ref="Male") DysL_(ref="No") DM(ref="No") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No");
   model HT = 'ASM_Wt%'n Age Sex bexam_BMI bexam_wc DysL_ DM shx_smoke_yn shx_alcohol_yn/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_4;
run;

/*Sensitivity analysis by exclusion mhx_HT_yn==1 */
DATA kim2021_labels2;
	SET epi207.outdata_label;
	where mhx_HT_yn=0;
RUN;

PROC CONTENTS data=epi207.outdata_label2;
RUN;

/*Crude*/
PROC logistic  data=kim2021_labels2 DESC;
   class HT(ref="No");
   model HT = 'ASM_Wt%'n/expb clodds=wald orpvalue;
   score fitstat;
run;

/*Model 1*/
PROC logistic  data=kim2021_labels2 DESC;
   class HT(ref="No") Sex(ref="Male");
   model HT = 'ASM_Wt%'n Age Sex/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_1;
run;

/*Age*/
PROC logistic  data=kim2021_labels2 DESC;
   class HT(ref="No") Sex(ref="Male");
   model HT = 'ASM_Wt%'n Age/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_1;
run;
/*Sex*/
PROC logistic  data=kim2021_labels2 DESC;
   class HT(ref="No") Sex(ref="Male");
   model HT = 'ASM_Wt%'n Sex/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_1;
run;

/*Model 2*/
PROC logistic  data=kim2021_labels2 DESC;
   class HT(ref="No") Sex(ref="Male");
   model HT = 'ASM_Wt%'n Age Sex bexam_BMI bexam_wc/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_2;
run;

/*Model 3*/
PROC logistic  data=kim2021_labels2 DESC;
   class HT(ref="No") Sex(ref="Male") DysL_(ref="No") DM(ref="No");
   model HT = 'ASM_Wt%'n Age Sex bexam_BMI bexam_wc DysL_ DM/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_3;
run;

/*Model 4*/
PROC logistic  data=kim2021_labels2 DESC;
   class HT(ref="No") Sex(ref="Male") DysL_(ref="No") DM(ref="No") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No");
   model HT = 'ASM_Wt%'n Age Sex bexam_BMI bexam_wc DysL_ DM shx_smoke_yn shx_alcohol_yn/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_4;
run;

/*Model 5*/
PROC logistic  data=kim2021_labels2 DESC;
   class HT(ref="No") Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No");
   model HT = 'ASM_Wt%'n Age Sex shx_smoke_yn shx_alcohol_yn/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_4;
run;

/*Test for association between ASM and MAP*/
PROC glm  data=kim2021_labels;
	model MAP = 'ASM_Wt%'n/ solution CLPARM;
RUN;

PROC glm  data=kim2021_labels;
	class Sex(ref="Male");
	model MAP = 'ASM_Wt%'n Sex/ solution CLPARM;
RUN;

PROC glm  data=kim2021_labels;
	model MAP = 'ASM_Wt%'n Age/ solution CLPARM;
RUN;

PROC glm  data=kim2021_labels;
	class Sex(ref="Male");
	model MAP = 'ASM_Wt%'n Age Sex/ solution CLPARM;
RUN;

PROC glm  data=kim2021_labels;
   class Sex(ref="Male");
   model MAP = 'ASM_Wt%'n Age Sex bexam_BMI bexam_wc/ solution CLPARM;
RUN;

/*Test for association between ASM and MAP after excluded mhx_HT_yn==1*/
PROC glm  data=kim2021_labels2;
	model MAP = 'ASM_Wt%'n/ solution CLPARM;
RUN;

PROC glm  data=kim2021_labels2;
	class Sex(ref="Male");
	model MAP = 'ASM_Wt%'n Sex/ solution CLPARM;
RUN;

PROC glm  data=kim2021_labels2;
	model MAP = 'ASM_Wt%'n Age/ solution CLPARM;
RUN;

PROC glm  data=kim2021_labels2;
	class Sex(ref="Male");
	model MAP = 'ASM_Wt%'n Age Sex/ solution CLPARM;
RUN;

PROC glm  data=kim2021_labels2;
   class Sex(ref="Male");
   model MAP = 'ASM_Wt%'n Age Sex bexam_BMI bexam_wc/ solution CLPARM;
RUN;

/*Plots*/
PROC sgscatter  DATA = kim2021_labels;
   PLOT MAP*'ASM_Wt%'n 
   /group = Sex grid;
RUN; 

/*Plot excluded mhx_HT_yn==1*/
PROC sgscatter  DATA = kim2021_labels2;
   PLOT MAP*'ASM_Wt%'n 
   /group = Sex grid;
RUN; 


/*Part B*/
proc contents data=work.kim2021 order=varnum;
run;

/*Create subset of dataset*/
*Keep only relevant variables for figures/tables. Kept all variables from Table 1 and added dyslipedemia (a variable
controlled for in one of the models);
*For Table 1: AST = GOT, ALT = GPT;
data kim2021_newvars;
	set work.kim2021;
	keep ID age Sex bexam_wt bexam_BMI bexam_wc bexam_BP_systolic bexam_BP_diastolic ht ht_m
		VFA_cm2 vfa_ ASM_kg ASM_Wt_ ASM_Wt__Q4 Sarco_ASM_Wt_ chol hdl ldl tg glu uric_acid HbA1c insulin crp MS MS_5cri
		ht dm Obesity shx_smoke_yn shx_alcohol_yn DysL_ got gpt;
run;

/*Data cleaning*/
*Rename variables that imported weirdly into SAS;
data kim2021_newvars_rename;
	set kim2021_newvars;
	rename vfa_ = vfa_obese
		dysL_ = DysL
		ht_m = height_m
		ASM_wt_ = ASM_perc
		ASM_Wt__Q4 = ASM_quartile
		Sarco_ASM_Wt_ = Sarcopenia;
run;
*Create variables that were mentioned in paper, but not in dataset-
HOMA-IR and obese_status categorical variables;
data kim2021_createvars;
	set kim2021_newvars_rename;
	format HOMA_IR BEST8.
		obese_status BEST8.;
	informat HOMA_IR BEST8.
		obese_status BEST8.;
	HOMA_IR = round((glu*insulin)/405, 0.01);

	if 0 <= bexam_BMI < 18.5 then
		Obese_Status = 1;
	else if 18.5 <= bexam_BMI <=22.9 then
		Obese_Status = 2;
	else if 23 <= bexam_BMI <= 24.9 then
		Obese_Status = 3;
	else if bexam_BMI >= 25 then
		Obese_Status = 4;
run;

/*Data formatting*/
*Create data formats for categorical variables;
proc format;
	value Sex		
		1 = "Male"
		2 = "Female";
	value Obese_status 	
		1 = "Underweight (BMI < 18.5)"
		2 = "Normal (18.5 <= BMI < 22.9)"
		3 = "Overweight (23 <= BMI < 24.9)"
		4 = "Obese (BMI >= 25)";
	value MS
		0 = "No"
		1 = "Yes";
	value HT
		0 = "No"
		1 = "Yes";
	value DM
		0 = "No"
		1 = "Yes";
	value DysL
		0 = "No"
		1 = "Yes";
	value Sarcopenia
		0 = "No"
		1 = "Yes";
	value ASM_quartile
		1 = "1st quartile"
		2 = "2nd quartile"
		3 = "3rd quartile"
		4 = "4th quartile";
	value shx_smoke_yn 
		0 = "No"
		1 = "Yes";
	value shx_alcohol_yn
		0 = "No"
		1 = "Yes";
run;

/*Create labels for variables*/
*Add variable labels for data dictionary and to facilitate data analysis;
data kim2021_labels;
	set kim2021_createvars;
	label ID=Individual ID
		Sex = Sex of individual
		Age= Age
		bexam_wt = Weight 
		bexam_BMI = Body mass index
		bexam_wc = Waist circumference
		bexam_BP_systolic = Systolic blood pressure
		bexam_BP_diastolic = Diastolic blood pressure
		height_m = Height (meters)
		VFA_cm2 = Visceral fat area (cm2)
		vfa_obese = Visceral obesity
		ASM_kg = Appendicular skeletal muscle mass (kg)
		chol = Cholesterol level
		hdl = High-density lipoprotein cholesterol
		ldl = Low-density lipoprotein cholesterol
		tg = Triglycerides
		glu = Glucose
		uric_acid = Uric acid
		HbA1c = Average blood glucose level over some time period
		Insulin = Insulin level
		crp = C-reactive protein
		MS = Metabolic syndrome 
		MS_5cri = Number of criteria met for metabolic syndrome diagnosis
		ht = Hypertension 
		dm = Diabetes mellitus
		Obesity = Obesity status
		shx_smoke_yn = Smoking status
		shx_alcohol_yn = Alcohol intake
		DysL = Dyslipedemia
		ASM_perc = ASM expressed as % of body weight
		ASM_quartile = Quartiles of ASM% for each sex
		Sarcopenia = Sarcopenia
		Obese_Status = Obesity status
		HOMA_IR = Homestatic model assessment of insulin resistance
		GOT = Glutamic oxaloacetic transaminase (AST)
		Gpt = Glutamic pyruvic transaminase (ALT);
run;
*Change obese_status to character format/informat;
data kim2021_formats;
	set kim2021_labels;
	format Obese_status $char11.;
	informat obese_status $char11.;
run;

/*Create data dictionary*/
ods select position;
ods excel file="\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Data_Dictionary.xlsx";
proc contents data=kim2021_formats order=varnum;
run;
ods excel close;

/*Create data codebook*/
*Need to create separate tables for continuous and categorical variables.
1) Create proc means table and save output for writing into Excel.
2) Write output from proc means and combine with proc freq output for categorical variables;
*Helpful resources:
https://social-science-data-editors.github.io/guidance/code/04_codebook_SAS.html
proc means guide: https://www.lexjansen.com/nesug/nesug08/ff/ff06.pdf
https://support.sas.com/kb/46/427.html for creating proc means output;
proc means data=kim2021_labels stackodsoutput n nmiss median mean stddev min max maxdec=2;
	var Age
		bexam_wt 
		bexam_BMI
		bexam_wc
		bexam_BP_systolic
		bexam_BP_diastolic
		height_m
		VFA_cm2
		vfa_obese
		ASM_kg
		chol
		hdl
		ldl
		tg
		glu
		uric_acid
		HbA1c
		Insulin
		crp
		ASM_perc
		HOMA_IR
		GOT
		Gpt
		MS_5cri;
	ods output summary=data_codebook1;
run;

*Write results to Excel;
*For continuous variables, write results from proc means table above. For categorical variables,
write directly to Excel;
ods trace on;
ods excel file='\\Client\H$\Documents\UCLA\WQ2022\EPI207\EPIDEM207-2022-winter\Assignment 1\Data_Codebook.xlsx' options(sheet_interval='none');
proc print data=work.data_codebook1 noobs;
proc freq data=kim2021_labels;
	format Sex Sex.
		MS MS.
		HT HT.
		DM DM.
		SHX_Smoke_Yn shx_smoke_yn.
		shx_alcohol_yn shx_alcohol_yn.
		dysL dysL.
		ASM_quartile ASM_quartile.
		Sarcopenia Sarcopenia.
		Obese_status Obese_status.;
	tables 	Sex
		MS
		ht
		dm
		shx_smoke_yn
		shx_alcohol_yn
		DysL
		ASM_quartile
		Sarcopenia
		Obese_Status/missing;
		run;
ods excel close;
/*proc import file="\\H$\Documents\UCLA\WQ2022\Kim2021.csv"*/
/*out=Kim2021*/
/*dbms=csv*/
/*replace;*/
/*run;*/
/*Importing directly from local disk doesn't work (can't find file), so manually import Kim2021.csv*/
/*(right click "Import Data (Kim2021.csv)") and run before running any code*/

/*Part A*/
proc contents data=work.kim2021 order=varnum;
run;
proc print data=work.kim2021 (obs=50);
run;
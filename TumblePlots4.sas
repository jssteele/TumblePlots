PROC IMPORT OUT= WORK.tpd DATAFILE= "~/Collaborations/TBodner/TumblePlots/tumblePlotExampleData.csv" DBMS=CSV REPLACE; GETNAMES=YES;
DATAROW=2; RUN;
* quick computation for interaction term;
DATA tumbledat; SET work.tpd;
dv=prestg80; tar=educ; mod=maeduc; educ=educ; maeduc=maeduc; tar_mod=tar*mod; *create a new interaction variable;
keep dv tar mod educ maeduc tar_mod; RUN;
PROC MEANS DATA=tumbledat NOPRINT; * do not print;
VAR mod; * do not save the type and frequency to the dataset;
OUTPUT out=sumout(DROP= _TYPE_ _FREQ_) MEAN= STD= /AUTONAME; RUN;
/*Compute the 1SD above and below the mean for the moderator */
DATA compout; SET sumout;
high_mod = mod_MEAN + mod_STDDEV;
low_mod = mod_MEAN - mod_STDDEV; RUN;
PROC PRINT DATA=sumout; TITLE 'Summary data from TumbleData';
PROC PRINT DATA=compout; TITLE 'Test of composite computations in PROC MEANS'; RUN;
TITLE;
/*reorganizing the computed data*/
PROC TRANSPOSE DATA=compout OUT=compout_t; RUN;
PROC PRINT DATA=compout_t; RUN;
PROC REG DATA=tumbledat OUTEST=intrxn_mod; TITLE 'Full Model output'; MODEL dv = tar mod tar_mod; RUN;
PROC REG DATA=tumbledat OUTEST=tarout_mod; TITLE 'Target As Outcome Model output'; MODEL tar = mod; RUN;
PROC PRINT DATA=intrxn_mod; TITLE 'Full interactions model estimates'; RUN;
PROC PRINT DATA=tarout_mod; TITLE 'target as outcome model estimates'; RUN;
TITLE;
/*New dataset for prediction via PROC SCORE*/
DATA predat; SET compout_t(RENAME(COL1=mod));
IF _NAME_ = 'high_mod' THEN moderator='HIGH';
ELSE IF _NAME_ = 'low_mod' THEN moderator='LOW';
ELSE DELETE;
KEEP moderator mod; RUN;
PROC PRINT DATA=predat;RUN;
PROC SCORE DATA=predat SCORE=tarout_mod TYPE=PARMS OUT=predTarget; VAR mod; RUN;
PROC PRINT DATA=predTarget; RUN;
/*Need to plus minus the residual standard error from the target as outcome model*/
/*This is in the regression output under the name _RMSE_*/
DATA tarout_mod2; SET tarout_mod(KEEP=_RMSE_);
DO i = 1 TO 4; OUTPUT; END; RUN;
DATA predTarget2; SET predTarget(RENAME=(MODEL1=target_est));
DO i=1 TO 2; OUTPUT; END; RUN;
/*New dataset with RMSE from target as outcome model*/
DATA predat2; MERGE predTarget2 tarout_mod2(KEEP=_RMSE_);
IF MODERATOR='HIGH' AND i=1 THEN
DO; TARGET='HIGH'; tar=target_est+_RMSE_; tar_mod=mod*tar;OUTPUT; END;
ELSE IF MODERATOR='HIGH' AND i=2 THEN
DO; TARGET='LOW'; tar=target_est-_RMSE_; tar_mod=mod*tar; OUTPUT; END;
ELSE IF MODERATOR='LOW' AND i=1 THEN
DO; TARGET='HIGH'; tar=target_est+_RMSE_; tar_mod=mod*tar; OUTPUT; END;
ELSE IF MODERATOR='LOW' AND i=2 THEN
DO; TARGET='LOW'; tar=target_est-_RMSE_; tar_mod=mod*tar; OUTPUT; END;
*KEEP Obs i _RMSE_ MODERATOR TARGET mod target_est target_adj;
RUN;
PROC PRINT DATA=predat2; TITLE 'Combined estimates and standard error'; RUN;TITLE;
/*New predictions of composite data*/
PROC SCORE DATA=predat2 SCORE=intrxn_mod TYPE=PARMS OUT=Tumble_out; VAR tar mod tar_mod; RUN;
PROC PRINT DATA=Tumble_out; RUN;

/* actual plotting of the tumble data */
PROC SGPLOT DATA=Tumble_out;
   label MODEL1='model based prediction' tar='target predictor';
   series x=tar y=MODEL1 /group=MODERATOR;
   yaxis label="Estimate" min=20 max=60;
   xaxis min=9 max=18;
RUN;











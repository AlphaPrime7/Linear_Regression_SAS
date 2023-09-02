* author: Tingwei Adeck
* date: 08-23-2023
* purpose: Linear Regression Modeling in SAS-A Machine Learning Primer
* license: public domain
* Input: brain_weight.sav
* Output: Linear_Regression_BW_SAS.pdf
* Description: Y~X (..~..) linear model-How much of ... variation is explained by ...
* Results: .. is a good predictor of ..
* The model is ..% predictive (NOT SO GOOD)-Poor from a machine learning perspective;

%let path=/home/u40967678/sasuser.v94;

libname linreg
    "&path/sas_umkc/input";
    
filename bw
    "&path/sas_umkc/input/brain_weight.sav";   
    
ods pdf file=
    "&path/sas_umkc/output/Linear_Regression_BW_SAS.pdf";
    
options papersize=(8in 11in) nonumber nodate;

proc import file= bw
	out=linreg.bw
	dbms=sav
	replace;
run;


title 'summary (first 5 obs) of respiratory data';
proc print data=linreg.bw (obs=5);

/*ASSUMPTION(S) CHECK NO TRANSFORMATION START*/

title 'Test for normality of Y and X';
proc univariate trimmed= 0.1 data=linreg.bw plot; *or replace plot with noprint-also can replace trimmed with winsorized;
var Brain_weight Body_Weight;
histogram / normal (color=RED);
run;

title 'Linear Relationship Assumption';
proc sgplot data=linreg.bw;
	reg y = Brain_weight x = Body_Weight;
run;

/*Outliers test by standardization (<3.29 = good)*/
title 'standardize variables';
proc stdize data=linreg.bw out=linreg.bw_standardized;
   var Brain_weight Body_Weight;
run;

/*Durbin-Watson test for independence of errors (autocorrelation)-Also asseses residuals normality*/
title 'Check autocorrelation';
proc autoreg data=linreg.bw; *can also use proc reg;
   model Brain_weight = Body_Weight / dw=4 dwprob;
   ods output ParameterEstimates=linreg.bw_PE;
run;

/*ASSUMPTION(S) CHECK NO TRANSFORMATION END*/

/*REGRESSION PROPER WITHOUT TRANSFORMATION START*/

*General regression model with Anova results;
title 'Regression Model with Fit Diagnostics';
proc reg data=linreg.bw;
    model Brain_weight = Body_Weight;
run;

*No visible output with noprint;
title 'Regression with R-squared value';
proc reg data=linreg.bw outest=linreg.bw_effsize noprint;
    model Brain_weight = Body_Weight / rsquare;
run;

data _null_;
   set linreg.bw_PE;
   if _n_ = 1 then call symput('Int', put(Estimate, BEST6.));    
   else            call symput('Slope', put(Estimate, BEST6.));  
run;

data _null_;
   set linreg.bw_effsize;
   if _n_ = 1 then call symput('rsquared', put(_RSQ_, BEST6.));    
run;

/*to push estimate parameters to graph*/
title 'Plot with insets for the slope and intercept';
proc sgplot data=linreg.bw noautolegend;
   title "Regression Line with Slope and Intercept";
   reg y=Brain_weight x=Body_Weight;
   inset "Intercept = &Int" "Slope (x-coefficient) = &Slope" "R-squared = &rsquared"/ 
         border title="Parameter Estimates" position=topleft;
run;

/*REGRESSION PROPER WITHOUT TRANSFORMATION END*/


/*BOX-COX TRANSFORMATIONS START*/

title 'Log transformation of variables';
data linreg.bw_transformed;
    set linreg.bw;
    log_brw = log(Brain_weight);
    log_bow = log(Body_Weight);
run;

title 'Test for normality of Log Y and X';
proc univariate data=linreg.bw_transformed plot; *or replace plot with noprint-also can replace trimmed with winsorized;
var log_brw log_bow;
histogram / normal;
run;

/*BOX-COX TRANSFORMATIONS END*/

/*REGRESSION PROPER WITH TRANSFORMATION START*/

*General regression model with Anova results;
title 'Regression Model for Log Data with Fit Diagnostics';
proc reg data=linreg.bw_transformed;
    model log_brw = log_bow;
run;

*No visible output with noprint;
title 'Regression (Log Data) with R-squared value';
proc reg data=linreg.bw_transformed outest=linreg.bw_effsize_transformed noprint;
    model log_brw = log_bow / rsquare;
run;

title 'Check autocorrelation (Log Data)';
proc autoreg data=linreg.bw_transformed; *can also use proc reg;
   model log_brw = log_bow / dw=4 dwprob;
   ods output ParameterEstimates=linreg.bw_PE_transformed;
run;

data _null_;
   set linreg.bw_PE_transformed;
   if _n_ = 1 then call symput('Int', put(Estimate, BEST6.));    
   else            call symput('Slope', put(Estimate, BEST6.));  
run;

data _null_;
   set linreg.bw_effsize_transformed;
   if _n_ = 1 then call symput('rsquared', put(_RSQ_, BEST6.));    
run;

*to push estimate parameters to graph;
title 'Plot with insets for the slope and intercept (Log Data)';
proc sgplot data=linreg.bw_transformed noautolegend;
   title "Regression Line with Slope and Intercept";
   reg y=log_brw x=log_bow;
   inset "Intercept = &Int" "Slope (x-coefficient) = &Slope" "R-squared = &rsquared"/ 
         border title="Parameter Estimates" position=topleft;
run;

/*REGRESSION PROPER WITH TRANSFORMATION END*/

/*QUICK MACRO CACLCULATION*/

%macro y_predict(x=);
data _null_ ;
   set linreg.bw_PE_transformed;
   	if _n_ = 1 then call symput('Int', put(Estimate, BEST6.));
   	else            call symput('Slope', put(Estimate, BEST6.));
   	run;
   	
proc sgplot data=linreg.bw noautolegend;
   title "Regression Line with Slope and Intercept";
   reg y=Brain_weight x=Body_Weight;
   inset "Intercept = &Int" "Slope (x-coefficient) = &Slope" "R-squared = &rsquared" "y_predict = (&Slope*&x + &Int)"/ 
         border title="Parameter Estimates" position=topleft;
run;  	
%mend y_predict;


%y_predict(x=2000);


ods pdf close;
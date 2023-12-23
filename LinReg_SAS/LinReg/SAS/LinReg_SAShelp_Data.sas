*Using sashelp data to optimize my linreg routine
A fun catch to these complex statistical projects is utilization of technical tools
like saving the output as an rtf file vs the normal pdf files I have often used
See here th  use of "ods rtf file=";

%let path=/home/u40967678/sasuser.v94;

ods rtf file=
    "&path/sas_umkc/output/LinReg_SAS_Primer.rtf";
    
options papersize=(8in 11in); *nonumber nodate;

*A quick SAS primer on LR and ML;
proc plot data = sashelp.applianc;
plot cycle*(units_1 units_10);
run;

data linreg.applianc;
set sashelp.applianc;
  call streaminit(1);
   do i = 1 to 156;
   dummy = rand("integer", 1, 4);
   output;
   end;
  run;

proc print data=linreg.applianc (obs=5);

*working dummies out;
data linreg.dum;
set linreg.applianc;
unitssq = units_1*units_10;
IF dummy=1 then do;
S1=0; S2=0; S3=0; end;
else if dummy=2 then do;
S1=1; S2=0; S3=0; end;
else if dummy=3 then do;
S1=0; S2=1; S3=0; end;
else do;
S1=0; S2=0; S3=1; end;
run;

*Running PROC REG not PROC GLM (later is better);
title 'PROC REG';
proc reg data=linreg.dum;
model Cycle = units_1 units_10 S1 S2 S3 unitssq; *R for cooks d
RUN;

*using the more acceptable PROC GLM (to avoid the use of creating dummy variables);
title 'PROC GLM';
proc glm data = linreg.dum;
	class dummy;
	model Cycle = units_1 units_10 dummy unitssq/solution;
run;

/*ASSUMPTIONS*/

*IID assumption test;
title 'IID tests';
proc reg data=linreg.dum;
model Cycle = units_1 units_10 S1 S2 S3 unitssq / dw spec;
output out=linreg.resids r=res;
run;

title 'IID tests-No unitssq';
proc reg data=linreg.dum;
model Cycle = units_1 units_10 S1 S2 S3 / dw spec;
output out=linreg.resids r=res;
run;

proc univariate data=linreg.resids
normal plot;
var RES;
run;

*Multicolinearity test(correlation between independent variables)-VIF;
title 'Variance Inflation Factor (VIF) test';
proc reg data=linreg.dum;
model Cycle = units_1 units_10 S1 S2 S3 unitssq / VIF;
run;

title 'Variance Inflation Factor (VIF) test-No Unitssq';
proc reg data=linreg.dum;
model Cycle = units_1 units_10 S1 S2 S3 / VIF;
run;

ods graphics on;
*testing model fit;
title 'Test Model Fit';
proc rsreg data=linreg.dum plots=residuals;
model Cycle = units_1 units_10 S1 S2 S3 / lackfit;
run;

*testing for outliers;
ods graphics off; 
ods exclude all;  
title 'Outliers Test-Cooks Distance';
proc reg data=linreg.dum;
model Cycle = units_1 units_10 S1 S2 S3 / influence R;
run;

ods rtf close;
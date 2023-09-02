%macro biserial(version, data= ,contin= ,binary= ,out=);

%if &version ne %then %put BISERIAL macro Version 2.2;

options nonotes;
* exclude observations with missing variables *;
data &out;
 set &data;
 where &contin>.;
 if &binary>.;
 run;

* compute the ranks for the continuous variable *;
proc rank data=&out out=&out ;
 var &contin;
 ranks r_contin;
 run;

* compute proportion of binary, std of contin, and n *;
proc means data=&out noprint;
 var &binary &contin;
 output out=_temp_(keep=p stdy n) mean=p std=stdx stdy n=n;
 run;

* sort by the binary variable *;
proc sort data=&out;
 by descending &binary;
 run;

* compute mean of contin and rank of contin var *;
proc means data=&out noprint;
 by notsorted &binary;
 var &contin r_contin;
 output out=&out mean=my r_contin;
 run;

* restructure the means computed in the step above *;
proc transpose data=&out out=&out(rename=(col1=my1 col2=my0));
 var r_contin my;
 run;

* combine the data needed to compute biserial correlation *;
data &out;
 set &out(drop= _name_ _label_);
 retain r1 r0 ;
 if _n_=1 then do;
  r1=my1;
  r0=my0;
 end;
 else do;
  set _temp_;
  output;
 end;
 run;

* compute point biserial correlation *;
proc corr data=&data  noprint outp=_temp_;
 var &binary &contin;
 run;



* extract the point biserial correlation from the matrix *;
data _temp_(keep=pntbisrl);
 set _temp_(rename=(&contin=pntbisrl));
 if _TYPE_='CORR' and &binary<>1 then output;

 run;

options notes;
* compute biserial and rank biserial *;
data &out;
 merge _temp_  &out;
 if pntbisrl=1 then delete;
 h=probit(1-p);
 u=exp(-h*h/2)/sqrt(2*arcos(-1));
 biserial=p*(1-p)*(my1-my0)/stdy/u;
 rnkbisrl=2*(r1-r0)/n;

 keep biserial pntbisrl rnkbisrl;
 label biserial='Biserial Corr'
       pntbisrl='Point Biserial Corr'
       rnkbisrl='Rank Biserial Corr';
 run;

%mend;


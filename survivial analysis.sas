/*read data from the path of dataset*/
Data dat3;
infile "your path/CTCarcinoma.csv" delimiter="," firstobs=2;
input TRT$ Time Status Age; RUN;
/*print the first 3 observations*/
PROC PRINT data= dat3(obs=3); RUN;
PROC SORT data= dat3 out= dat3;
by descending TRT; RUN;
/***** Section 5.5.1.1 ******************************/
/*fit Kaplan-Meier and
estimate suvival and cumulative harzard function and plot*/
PROC LIFETEST data= dat3;
time Time*Status(1); /*0 is event, 1 is censored*/
strata TRT; RUN;
/***** Section 5.5.1.2 **********************/
/*fit exponential model*/
PROC LIFEREG data= dat3 order= data;
class TRT;
model Time*Status(1)= TRT / dist= exponential; RUN;
/*fit Weibull model*/
PROC LIFEREG data= dat3 order= data;
class TRT;
model Time*Status(1)= TRT / dist=weibull; RUN;
/*fit exponential model+Age*/
PROC LIFEREG data= dat3 order= data;
class TRT;
model Time*Status(1)= TRT Age / dist= exponential;
RUN;
/*fit Weibull model+Age*/
PROC LIFEREG data= dat3 order= data;
class TRT;
model Time*Status(1)= TRT Age / dist= weibull; RUN;
/**** Section 5.5.1.3 *****************/
/*fit Cox regression model*/
PROC PHREG data= dat3;
class TRT(ref= "S+CT");
model Time*Status(1)= TRT/ ties=efron; RUN;
/*fit Cox regression model+Age*/

PROC PHREG data= dat3;
class TRT(ref= "S+CT");
model Time*Status(1)= TRT Age/ ties=efron; RUN;
/*** Section 5.5.2 *******************/
/*read data from the path of dataset*/
Data dat4;
infile "your path/BreastCancer.csv" delimiter="," firstobs=2;
input tL tU$ TRT Status;
if tU= "NA" then tU= .;
ntU= tU+0; /* transform the type of variable "tU"
from char to int*/
if ntU= . then time= tL;
else time= (tL+ntU)/2;
if tL= 0 then ntL= .;
else ntL= tL; RUN;
PROC SORT data= dat4 out= dat4;
by descending TRT; RUN;
/****** Section 5.5.2.1 *******************/
/*fit Turnbull's estimator*/
PROC ICLIFETEST data= dat4 impute(seed= 123) method= turnbull;
strata TRT;
time (tL,ntU);
RUN;
/*fit Kaplan-Meier estimator with midpoint or left point*/
PROC LIFETEST data= dat4;
time time*Status(0); /*0 is censored, 1 is event*/
strata TRT; RUN;
/*** Section 5.5.2.2 ***********************/
/*fit exponential model*/
PROC LIFEREG data= dat4 order= data;
class TRT;
model (ntL, ntU)= TRT / dist= exponential;RUN;
/*fit Weibull model*/
PROC LIFEREG data= dat4 order= data;
class TRT;
model (ntL, ntU)= TRT / dist= weibull; RUN;
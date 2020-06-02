/*Name: Aikerim Orken                              */
/***************************************************/
clear
capture log close
set more off, perm
* set mem 100m //Memory setup doesn't need to request for Stata13
log using  termpaper.log, text replace

// #0
// program setup

clear all
set linesize 80
matrix drop _all
set scheme s2mono

//#1 import data
/*  Data Recoding*/
/*****************************************/
 /*Select Data Set For Plan Attributes*/
clear all
insheet using "/Users/AikerimOrken/Desktop/Term paper sample (DANAL)/PlanAttributes.csv",clear
save insurancemaster, replace


use insurancemaster, clear
describe 

keep businessyear statecode isnewplan tehbinntier1individualmoop tehbinntier2individualmoop

rename businessyear year
rename tehbinntier1individualmoop dmooptier1
rename tehbinntier2individualmoop dmooptier2
drop if dmooptier1== " " | dmooptier2== ""
// transform isnewplan variable to bool
gen newplan=0 if isnewplan=="Existing"
replace newplan=1 if newplan==.

// destring the  ooptier1 and ooptier2 for further manipulations
destring dmooptier1, ignore("$") dpcomma gen(mooptier1) force
replace mooptier1=mooptier1*1000 if mooptier1<100

destring dmooptier2, ignore("$") dpcomma gen(mooptier2) force
replace mooptier2=mooptier2*1000 if mooptier2<100

drop isnewplan dmooptier1 dmooptier2

label var mooptier1 "Max out-of-pocket payments for Tier 1"
label var mooptier2 "Max out-of-pocket payments for Tier 2"

by statecode,sort: egen avgt1=mean(mooptier1)
save insurancemaster.dta, replace

// Import data for ideology measures
clear all
use "/Users/AikerimOrken/Desktop/Term paper sample (DANAL)/stateideology_v2018.dta",clear
save stateideology, replace

use stateideology,clear

//generate statecode as in insurancemaster.dta file

gen statecode="AL"
replace statecode="AK" if state==2
replace statecode="AZ" if state==3
replace statecode="AR" if state==4
replace statecode="CA" if state==5
replace statecode="CO" if state==6
replace statecode="CT" if state==7
replace statecode="DE" if state==8
replace statecode="FL" if state==9

replace statecode="GA" if state==10
replace statecode="HI" if state==11
replace statecode="ID" if state==12
replace statecode="IL" if state==13
replace statecode="IN" if state==14
replace statecode="IA" if state==15
replace statecode="KS" if state==16
replace statecode="KY" if state==17

replace statecode="LA" if state==18
replace statecode="ME" if state==19
replace statecode="MD" if state==20
replace statecode="MA" if state==21
replace statecode="MI" if state==22
replace statecode="MN" if state==23
replace statecode="MS" if state==24
replace statecode="MO" if state==25

replace statecode="MT" if state==26
replace statecode="NE" if state==27
replace statecode="NV" if state==28
replace statecode="NH" if state==29
replace statecode="NJ" if state==30
replace statecode="NM" if state==31
replace statecode="NY" if state==32
replace statecode="NC" if state==33

replace statecode="ND" if state==34
replace statecode="OH" if state==35
replace statecode="OK" if state==36
replace statecode="OR" if state==37
replace statecode="PA" if state==38
replace statecode="RI" if state==39
replace statecode="SC" if state==40
replace statecode="SD" if state==41

replace statecode="TN" if state==42
replace statecode="TX" if state==43
replace statecode="UT" if state==44
replace statecode="VT" if state==45
replace statecode="VA" if state==46
replace statecode="WA" if state==47
replace statecode="WV" if state==48
replace statecode="WI" if state==49
replace statecode="WY" if state==50

//drop all years data except for 2014,2015,2016
keep if year==2014 | year==2015 | year==2016
keep year statecode citi6016 inst6017_nom
rename citi6016 citizen_ideology
rename inst6017_nom institute_ideology
order year statecode
save stateideology.dta, replace

************
//Import dataset on age and sex by states
//2014 
clear all
insheet using "/Users/AikerimOrken/Desktop/Term paper sample (DANAL)/age&sex/ACSDP1Y2014.DP05_data_with_overlays_2020-05-08T134255.csv",clear
save age_sex2014, replace

use age_sex2014,clear
keep v2 v3 v10 v68
rename v2 statecode
rename v3 name
rename v10 male_ratio
rename v68 age_median
drop if length(statecode)>2
gen year=2014

destring male_ratio,replace
destring age_median,replace
sort year statecode
order year statecode

save age_sex2014.dta,replace

//2015
clear all
insheet using "/Users/AikerimOrken/Desktop/Term paper sample (DANAL)/age&sex/ACSDP1Y2015.DP05_data_with_overlays_2020-05-08T134255.csv",clear
save age_sex2015, replace

use age_sex2015,clear
keep v2 v3 v10 v67
rename v2 statecode
rename v3 name
rename v10 male_ratio
rename v67 age_median
drop if length(statecode)>2
gen year=2015

destring male_ratio,replace
destring age_median,replace
sort year statecode
order year statecode

save age_sex2015.dta,replace

//2016 
clear all
insheet using "/Users/AikerimOrken/Desktop/Term paper sample (DANAL)/age&sex/ACSDP1Y2016.DP05_data_with_overlays_2020-05-08T134255.csv",clear
save age_sex2016, replace

use age_sex2016,clear
keep v2 v3 v10 v68
rename v2 statecode
rename v3 name
rename v10 male_ratio
rename v68 age_median
drop if length(statecode)>2
gen year=2016

destring male_ratio,replace
destring age_median,replace
sort year statecode
order year statecode

save age_sex2016.dta,replace

//Append 3 files on age and gender
*2014 and 2015
use age_sex2014.dta, clear
append using age_sex2015.dta   //option (update replace) is not allowed
save age_sex1415.dta,replace

*append the rest of the data on age and gender

use age_sex1415.dta,clear
append using age_sex2016.dta
sort year statecode
save age_sex141516.dta,replace 


************
//Import dataset on household income by states

*2014
clear all
insheet using "/Users/AikerimOrken/Desktop/Term paper sample (DANAL)/income/ACSST1Y2014.S1901_data_with_overlays_2020-05-08T144746.csv",clear
save income14.dta,replace

use income14.dta,clear
keep v2 v26
rename v2 statecode
rename v26 income //median household income
drop if length(statecode)>2
gen year=2014

destring income,replace
sort statecode
order year statecode
save income14.dta,replace

*2015
clear all
insheet using "/Users/AikerimOrken/Desktop/Term paper sample (DANAL)/income/ACSST1Y2015.S1901_data_with_overlays_2020-05-08T144746.csv",clear
save income15.dta,replace

use income15.dta,clear
keep v2 v26
rename v2 statecode
rename v26 income //median household income
drop if length(statecode)>2
gen year=2015

destring income,replace
sort statecode
order year statecode
save income15.dta,replace

*2016
clear all
insheet using "/Users/AikerimOrken/Desktop/Term paper sample (DANAL)/income/ACSST1Y2016.S1901_data_with_overlays_2020-05-08T144746.csv",clear
save income16.dta,replace

use income16.dta,clear
keep v2 v26
rename v2 statecode
rename v26 income //median household income
drop if length(statecode)>2
gen year=2016

destring income,replace
sort statecode
order year statecode
save income16.dta,replace

//Append 3 files on income 
*2014 and 2015
use income14.dta, clear
append using income15.dta   //option (update replace) is not allowed
save income1415.dta,replace

*append the rest of the data 

use income1415.dta,clear
append using income16.dta
sort year statecode
save income141516.dta,replace 

******************************
*** Merge data on income to age and gender dataset
******************************
use age_sex141516.dta,clear
merge m:m year statecode using income141516,update replace
rename _merge merge_DEMO
save demographics.dta,replace

//Merge data on insurance plans and state ideology

use insurancemaster.dta, clear
order year statecode
sort year statecode
save insurancemaster.dta, replace
*
use stateideology.dta, clear
order year state
sort year statecode
save stateideology.dta, replace

**merge
use insurancemaster, clear
merge m:m year statecode using stateideology, update replace
rename _merge merge_STATEs
 
keep if mooptier1!=. & mooptier1!=0 & mooptier2!=0

bysort year statecode: egen avgmoopT1=mean(mooptier1)
bysort year statecode: egen avgmoopT2=mean(mooptier2)
order year statecode avgmoopT1 avgmoopT2 newplan citizen_ideology institute_ideology
save insurance_ideo.dta, replace

***************************************
* Merge demographic data and insurance plan and ideology dataset
***************************************
use demographics.dta,clear
order year statecode
sort year statecode
save demographics.dta,replace

use insurance_ideo.dta,clear
order year statecode
sort year statecode
save insurance_ideo.dta,replace

*merge
use demographics,clear
merge m:m year statecode using insurance_ideo,update replace
rename _merge merge_DATA
drop if merge_DATA ==1

drop merge_DATA merge_DEMO merge_STATE
sort year statecode
label variable name "State name"
label variable male_ratio "% of male population"
label variable age_median "Median age of the state"
label variable income "Median household income (2018 inflation adj.)"
label variable avgmoopT1 "Mean maximum individual out-of-pocket limits Tier 1"
label variable avgmoopT2 "Mean maximum individual out-of-pocket limits Tier 2"
label variable newplan "1=Is the New plan, 0=Existing plan"
label variable citizen_ideology "State Citizen Ideology"
label variable institute_ideology "State Government Ideology"
save usdata.dta,replace


*******************************************************************************
* Descriptive statistics on consolidated dataset
*******************************************************************************

use usdata,clear
* Descriptive statistics
asdoc sum male_ratio age_median income newplan citizen_ideology institute_ideology mooptier1,label replace
ssc inst rsource

// Model 1
eststo: reg avgmoopT1 male_ratio age_median income newplan institute_ideology
eststo: reg avgmoopT1 male_ratio age_median income newplan citizen_ideology

label variable _est_est1 "Model (1)"
label variable _est_est2 "Model (2)"

esttab using regression1.rtf,se label 
twoway (scatter  institute_ideology avgmoopT1,mlabel(statecode)) (lfit institute_ideology avgmoopT1) 
twoway (scatter  citizen_ideology avgmoopT1,mlabel(statecode)) (lfit citizen_ideology avgmoopT1) 
save usdata.dta,replace
log close

* Countdown to 2030 Data and Analysis Center for Effective Coverage *

* Analysis codes to generate ANC readiness estimates *
* Kenya HHFA 2019

** facility weights
gen wgt=wt
egen stratum= group(q150 facility_county)
svyset facility_id [pweight=wgt] , strata(stratum)  singleunit(centered) 

** drop facilities that did not complete the survey

** drop facilities that don't provide ANC or outpatient services
keep if q4250==1 & q500==1
 
**fac type
tab q150

** fac managing authority
tab q151

* facility type/managing authority for linking analysis
tab q150 q151
cap drop fac_link
gen fac_link=0
replace fac_link=1 if inlist(q150,1,2) & q151==1  // leve 4 & 5 public
replace fac_link=2 if inlist(q150,4) & q151==1  // level 3 public
replace fac_link=3 if inlist(q150,5,6) & q151==1  // level 2 public
replace fac_link=4 if inlist(q150,1,3) & q151!=1 // levels 4 & 5 private
replace fac_link=5 if inlist(q150,4,5,6) & q151!=1 // level 2&3 private
									
label define fac_link 1 "Public Hospital" 2"Public Health Center" 3 "Public Dispensary" 4 "Private Hospital" 5 "Private Health center/dispensary"
label values fac_link fac_link
tab fac_link, m

*region for linking // county var in khfa 2019
cap drop region
gen region_str=lower(facility_county)
tab region_str
rename region_str var2

merge  m:1 var2 using "kenya_region.dta"  // 100% merge
tab region 
rename var2 region_str

***************************************************************
*** ANC READINESS INDEX ***
***************************************************************

***************************************************************
*** EQUIPMENT AND SUPPLIES ***
***************************************************************
* blood pressure // digital , observed and functioning
cap drop bp
gen bp=0
replace bp=1 if q4254a_1==1 & q4254b_1==1
replace bp=. if q4254a_1==. & q4254b_1==.
tab bp, m

* stethoscope observed and functioning // NA in ANC area
// used general emergency area instead
gen steth=0
replace steth=1 if q4940a_2==1 & q4940b_2==1
replace steth=. if q4940a_2==.1 & q4940b_2==.
tab steth, m

* examination bed observed // NA in ANC area
/*
gen bed=0
replace bed=1 if inlist(v431m,1)
replace bed=. if v431m==. 
*/

* latex gloves //  general OPD 
tab1 q2270a_07 
gen gloves=0
replace gloves=1 if q2270a_07==1
replace gloves=. if q2270a_07==. 
tab gloves, m

* single use syringe // general OPD 
// used either auto-disable syringe OR disposable syringe with disposable needle
tab1 q2270a_14 q2270a_15 
gen syringe=0
replace syringe=1 if q2270a_14==1| q2270a_15==1
replace syringe=. if q2270a_14==. & q2270a_15==.
tab syringe, m

* soap and water, or alcohol-based hand rub // general outpatient area
gen soap=0
replace soap=1 if (q2270a_01==1 & q2270a_02==1) | (q2270a_03==1)	
replace soap=. if q2270a_01==. & q2270a_02==. & q2270a_03==.
tab soap, m

* disinfectant (ENVIRONMENTAL) 	// generap OPD 
gen disinf=0
replace disinf=1 if q2270a_13==1 
replace disinf=. if q2270a_13==.	
tab disinf, m
					
					
***************************************************************					
*** DIAGNOSTICS*** 
***************************************************************

*hb ; // observed and functional
cap drop hb
gen hb=0
replace hb=1 if (q6301a_1==1 & q6301b_2==1) | /// //facility conducts any tests of white/red cells + hematology analyzer observed functional
				(q6301a_3==1 & q6282a_1==1 & q6282a_2==1 & q6282a_3==1 & q6301b_4==1)  | /// // facility conducts any other tests of white/red cells onsite + light miscroscope + glass slides + cover slips + stains for full blood count differential
				(q6301a_6==1 & q6301b_7==1) | /// // other tests for anemia and pack cell volume
				q6279b_2==1 // hemocue
tab hb, m
				
* urine dipstick protein // anywhere in facility
gen ur_prot=0
replace ur_prot=1 if q4937a_1==1
*replace ur_prot=. if q4937a_1==.
tab ur_prot, m

* urine dipstick glucose // anywhere in facility
gen ur_glu=0
replace ur_glu=1 if q4937a_3==1 
*replace ur_glu=. if q4937a_3==. 
tab ur_glu, m

*Syphilis RDT / RPR or VDRL or FTA; 
gen syph=0
replace syph=1 if q6306a_1==1 &  ///  // test conducted onsite
				(q6306b_2==1 | ///  // RPR
				((q6306b_3==1 | q6306b_4==1) & q6282a_1==1 & q6282a_2==1 & q6282a_3==1 & q6282a_8==1))   // ((VDRL OR FTA/abs) AND (light miscrosope + glass slides + cover slips + incubator + shaker))
tab syph


*HIV RDT   
cap drop hiv
gen hiv=0
replace hiv=1 if (q6303a_1==1 & q6303b_2==1 & q6303b_3==1 & q6303b_4==1) | ///  //ELISA- elisa test conducted onsite + washer reader and assay kit available and functional
					q4937a_5==1  // rapid test available in emergency area
tab hiv, m		


***************************************************************
*** MEDICINES & COMMODITIES ***
***************************************************************
*Iron tablets or iron+folic acid tablets 
cap drop iron
gen iron=0
replace iron=1 if q6525a_13==1 | q6525a_14==1
*replace iron=. if q6525a_13==. & q6525a_14==.
tab iron, m

*Folid acid tablets or iron+folic acid tablets (variables for this combo are both above and repeated again here) ; fix here depending on above
cap drop folic
gen folic=0
replace folic=1 if q6525a_13==1 | q6525a_15==1
*replace folic=. if q6525a_13==. & q6525a_15==.
tab folic, m

*Tetanus toxoid vaccine
// VACCINES VARS NOT LABELLED IN KHFA DATASET; QUESTIONNAIRE NOT AVAILABLE IN REPORT. CAN'T COMPUTE. 


***************************************************************
*** BASIC AMENITIES ***
***************************************************************

* Improved water source
// Definition: water from the following sources and onsite or within 500m from facility: piped, public tap, protected well, tubewell/borehole, protected spring, rain, bottled
cap drop imp_water
gen imp_water=0
replace imp_water=1 if inlist(q2205,1,2) | (inlist(q2206,1,2) & inlist (q2205,3,4,5,7,9,10,12)) //Note- no bottled (32) for v123 and only yes (1) for v124, compared to code for other countries 
replace imp_water=. if q2205==. & q2206==.
tab imp_water, m

* Room with auditory and visual privacy			
// NOTE: included general OPD or ANC area
cap drop privacy
gen privacy=0
replace privacy=1 if q2230==3 
replace privacy=. if q2230==.
tab privacy, m 

* Sanitation facilities
// Definition: flush to piped, flush to tank, flush to latrine, flush to somewhere else, vip, pit latrine with slab, composting toilet. 
cap drop sanitation
gen sanitation=0
replace sanitation=1 if inlist(k2234,1,2,4,6) | inlist(k2231,1,2,4)
replace sanitation=. if k2234==. & k2231==.
tab sanitation

***************************************************************
*** HUMAN RESOURCES ***
***************************************************************

* Proportion of health facility staff providing ANC services trained in ANC in the last two years 
// Definition: n providers in service with training in past 2 years/n providers in service

// N/A in KHFA 2019

********************************************************************************
********************************************************************************
*********************** GENERATION OF SCORES **********************************

* overall score // ONLY 16 OUT OF 19 ITEMS COLLECTED IN KHFA2019
egen count_total=rowtotal (bp steth gloves syringe soap disinf hb ur_prot ur_glu syph hiv iron folic imp_water privacy sanitation), missing 
gen score_total=count_total/16   
replace score_total=. if count_total==. 
svy: mean score_total

* equiment and supplies score
egen count_equip=rowtotal (bp steth gloves syringe soap disinf), missing
gen score_equip= count_equip/6
replace score_equip=. if count_equip==.
svy: mean score_equip
* diagnostics score
egen count_diagn=rowtotal(hb ur_prot ur_glu syph hiv), missing
gen score_diagn= count_diagn/5
replace score_diagn=. if count_diagn==.
svy: mean score_diagn
* medicines & commodities score
egen count_meds=rowtotal (iron folic), missing
gen score_meds= count_meds/2
replace score_meds=. if count_meds==.
svy: mean score_meds
*basic amenities score
egen count_amen=rowtotal (imp_water privacy sanitation), missing
gen score_amen= count_amen/3
replace score_amen=. if count_amen==.
svy: mean score_amen

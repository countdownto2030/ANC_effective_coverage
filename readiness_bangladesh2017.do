* Countdown to 2030 Data and Analysis Center for Effective Coverage *

* Analysis codes to generate ANC readiness estimates *
*Bangladesh SPA 2017


** facility weights
gen wgt=facwt/1000000
egen stratum= group(factype region)
svyset facil [pweight=wgt] , strata(stratum)  singleunit(centered) 

** drop facilities that did not complete the survey
keep if result==1
** drop facilities that don't provide ANC services
keep if q102_05==1
 

* facility type/managing authority for linking analysis
gen fac_link=0
replace fac_link=1 if factype==1 & mga==1
replace fac_link=2 if factype==2 & mga==1
replace fac_link=3 if factype==3 & mga==1
replace fac_link=4 if inlist(factype,4,5,6) & mga==1  // included all 3 categories of union health and family welfare center - correction made July 21
replace fac_link=5 if factype==8 & mga==1
replace fac_link=6 if inlist(factype,9,11,12) & inlist(mga,2,3)  // Smiling sun as ngo clinic
replace fac_link=7 if factype==10 & mga==4

label define fac 1 "Public- Hospital" 2 "Public- Upazila Health Complex(UHC)" 3 "Public- Maternal and Child Welfare Center (MCFC)" ///
4 "Public- Union Health and Family Welfare Center (UnHFWC)" 5 "Public- Community Clinic" 6 "NGO- Hospital/Clinic" 7 "Private- Hospital" 0 "Non-appropriate facilities"
label values fac_link fac

*region for linking
gen region2= ""
replace region2= "barisal" if region==1
replace region2= "chittagong" if region==2
replace region2= "dhaka" if region==3
replace region2= "khulna" if region==4
replace region2= "rajshahi" if region==5
replace region2= "rangpur" if region==6
replace region2= "sylhet" if region==7
replace region2= "mymensingh" if region==8

***************************************************************
*** ANC READINESS INDEX ***
***************************************************************

***************************************************************
*** EQUIPMENT AND SUPPLIES ***
***************************************************************
* blood pressure // digital or manual (if manual, need stethoscope as well- corected July 21)
// in section: equipment and supplies for ANC: observed and functioning
// for ANC
gen bp=0
replace bp=1 if (q1421a_1==1 & q1421b_1==1) | (q1421a_2==1 & q1421b_2==1 & q1421a_3==1 & q1421b_3==1 )
replace bp=. if q1421a_1==. & q1421b_1==. & q1421a_2==. & q1421b_2==. & q1421a_3==. & q1421b_3==.


* stethoscope 
// in section: equipment and supplies for ANC: observed and functioning
// for ANC
gen steth=0
replace steth=1 if q1421a_3==1 & q1421b_3==1 // observed AND functioning
replace steth=. if q1421a_3==. & q1421b_3==.


* examination bed
gen bed=0
replace bed=1 if inlist(q1421a_7,1)  // observed 
replace bed=. if q1421a_7==.


* latex gloves, many // vars different from Ashley's code: general opd, blood draw room, minor surgery, delivery, anc. 
// used client examination room, ANC services, Family planning, MCH, child curative care, general medicines and supplies
gen gloves=0
replace gloves=1 if inlist(q1451_07,1)
replace gloves=. if q1451_07==. 

* single use syringe
gen syringe=0
replace syringe=1 if q1451_09==1  	//ANC standard precautions				 			 
replace syringe=. if q1451_09==. 

* soap and water, or alcohol based rub
gen soap=0
replace soap=1 if ((q1451_01==1 & q1451_02==1)| q1451_03==1) 		//ANC standard precautions  
replace soap=. if q1451_01==. & q1451_02==. & q1451_03==. 

			  
* disinfectant
gen disinf=0
replace disinf=1 if  q1451_08==1 	//ANC standard precautions
replace disinf=. if q1451_08==. 

					
***************************************************************					
*** DIAGNOSTICS*** used, observed and functioning 
***************************************************************

*hb // observed and functioning
gen hb=0
replace hb=1 if q1406_4==1 |			/// 	
				(q802a_1==1 & q802b_1==1 & q802c_1==1) | ///   // hematology analyzer     
				(q802a_4==1 & q802b_4==1 & q802c_4==1 & q802b_5==1 & q802a_6==1 & q802b_6==1) | /// 	//colorimeter or hemoglobinometer & drabkin's solution & pipette 
				(q802a_7==1 & q802b_7==1) |  /// 	//litmus paper for hb test
				(q802a_2==1 & q802b_2==1 & q802c_2==1 & q802b_3==1)   	//hemocue & microcuvette
replace hb=. if q1406_4==. & q802a_1==. & q802b_1==. & q802c_1==. & q802a_4==. & q802b_4==. & q802c_4==. & q802b_5==. & q802a_6==. & q802b_6==. & q802a_7==. & q802b_7==. & q802a_2==. & q802b_2==. & q802c_2==. & q802b_3==. 


			
* urine dipstick protein
gen ur_prot=0
replace ur_prot=1 if q1406_2==1 | (q837a_1==1 & q837b_1==1)   // anc and lab test items
replace ur_prot=. if q1406_2==. & q837a_1==. & q837b_1==.


* urine dipstick glucose
gen ur_glu=0
replace ur_glu=1 if q1406_3==1 | (q837a_2==1 & q837b_2==1)   // anc and lab test items
replace ur_glu=. if q1406_3==. & q837a_2==. & q837b_2==.


*Syphilis RDT / RPR 
gen syph=0
replace syph=1 if q1406_5==1 | q1406_6==1 |   			///     // RDT/VDRL observed & available in ANC section
			      q856==1|  							///  // RDT in syphilis section
                  (q858a_2==1 & q858b_2==1) | 							 ///   // PCR in syphilis section
				  (((q858a_4==1 & q858b_4==1)|(q858a_1==1 & q858b_1==1)) & (q858b_3==1 & q858c_3==1)) |  ///    // //RPR/VDRL + rotator  in syphilis section
				  (q858a_5==1 & q858b_5==1)  											 // other test: TPHA in syphilis section
				  
				  
replace syph=. if q1406_5==. & q1406_6==. & q856==. & q858a_2==. & q858b_2==. & q858a_4==. & q858b_4==. & q858a_1==. & q858b_1==. & q858b_3==. & q858c_3==. & q858a_5==. & q858b_5==. 


*HIV RDT  
// this item was dropped: HIV testing not routinely done as part of ANC in Bangladesh.

				 	 
***************************************************************
*** MEDICINES & COMMODITIES ***
***************************************************************
*Iron tablets 

gen iron=0
replace iron=1 if q906_03==1 | q906_04==1 | q1422_1==1 | q1422_3==1  // iron, iron/folic acid available in anc or mch medicines section
replace iron=. if q906_03==. & q906_04==. & q1422_1==. & q1422_3==.


*Folid acid tablets // 
gen folic=0
replace folic=1 if q906_02==1| q906_04==1| q906_13==1| q906_14==1| q1422_2==1| q1422_3==1   // folic acid, iron+folic acid, or ferrous fumerate/sulphate in anc section or mch medicines section
replace folic=. if q906_02==. & q906_04==. & q906_13==. & q906_14==. & q1422_2==. & q1422_3==. 


*Tetanus toxoid vaccine // 
gen tt=0
replace tt=1 if q906_08==1   // tt vaccine available and valid in mch medicines only 
replace tt=. if q906_08==.


***************************************************************
*** BASIC AMENITIES ***
***************************************************************

* Improved water source
// definition: water from the following sources and onsite of within 500m from facility: piped, public tap, protected well, tubewell/borehole, protected spring, rain, bottled
gen imp_water=0
replace imp_water=1 if inlist(q330,1,2,10) | (inlist(q330,3,4,5,7,9) & inlist(q331,1,2))
replace imp_water=. if q330==. & q331==.

* Room with auditory and visual privacy- included setting of anc services and setting of client examination room; 
// counted "private room" only
gen privacy=0
replace privacy=1 if q1452==1 | q711==1
replace privacy=. if q1452==. & q711==.

* Sanitation facilities: flush to piped, flush to tank, flush to latrine, flush to somewhere else, vip, pit latrine with slab, composting toilet. 
gen sanitation=0
replace sanitation=1 if inlist(q620,11,12,13,14,21,22)
replace sanitation=. if q620==. 

***************************************************************
*** HUMAN RESOURCES ***
***************************************************************

* Proportion of health facility staff providing ANC services trained in ANC in the last two years 
// n providers in service with 2 years training/n providers in service
** no vars on n of providers in ANC service- so used number of providers with any training at any time-- ASK

gen trained_anc=provanct/provanct1
replace trained_anc=0 if provanct1==0 & provanct==0
replace trained_anc=1 if trained_anc>1
replace trained_anc=. if provanct1==. & provanct==. 


********************************************************************************
********************************************************************************
*********************** GENERATION OF SCORES **********************************

* overall score

egen count_total=rowtotal (bp steth bed gloves syringe soap disinf hb ur_prot ur_glu syph iron folic tt imp_water privacy sanitation trained_anc), missing 
gen score_total=count_total/18                                        
replace score_total=. if count_total==. 

* equiment and supplies score
egen count_equip=rowtotal (bp steth bed gloves syringe soap disinf), missing
gen score_equip= count_equip/7
replace score_equip=. if count_equip==.

* diagnostics score
egen count_diagn=rowtotal(hb ur_prot ur_glu syph), missing 					
gen score_diagn= count_diagn/4										
replace score_diagn=. if count_diagn==.

* medicines & commodities score
egen count_meds=rowtotal (iron folic tt), missing
gen score_meds= count_meds/3
replace score_meds=. if count_meds==.

*basic amenities score
egen count_amen=rowtotal (imp_water privacy sanitation), missing
gen score_amen= count_amen/3
replace score_amen=. if count_amen==.

*human resources score
gen score_hr=trained_anc 


*********************************************************************************
* gen a separate dataset for linking analysis
preserve
collapse(mean) score_total score_equip score_diagn score_meds score_amen score_hr [pw=wgt], by(fac_link region)
save "scores_bgd_linking.dta", replace
restore

****************************************************************


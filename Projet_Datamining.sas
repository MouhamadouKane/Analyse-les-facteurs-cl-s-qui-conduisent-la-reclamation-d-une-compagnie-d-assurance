/*  Affichage des 17 premiers observation */ 
proc print data=MOUHAMED.ASSURANCE (firstobs=1 OBS=17)noobs; 
run; 
 /*  Affichage du contenu de notre base */ 
Proc CONTENTS DATA=mouhamed.assurance; 
 
RUN; 
/*Analyse descriptive*/ 
 
/* histogramme de la variable age */ 
proc univariate data=MOUHAMED.ASSURANCE; 
    var Age; 
    histogram Age / normal; 
run; 
/* boxplot de la variable age */ 
ods output sgplot=MOUHAMED.ASSURANCE.sgplotda; 
proc sgplot data=MOUHAMED.ASSURANCE; 
    vbox Age; 
run; 
 
 
/* Boxplot de la variable Annual_Kilometers */ 
 
ods output sgplot2=MOUHAMED.ASSURANCE; 
proc sgplot data=MOUHAMED.ASSURANCE; 
    vbox Annual_Kilometers; 
run; 
 
/* diagramme en secteur de la variable Gender */ 
Proc gchart data=MOUHAMED.ASSURANCE; 
	pie Gender / type=percent; 
run; 
 
/* diagramme en secteur de la variable Claim */ 
 
Proc gchart data=MOUHAMED.ASSURANCE; 
	pie Claim / type=percent; 
run; 
 
/* Tableau contingeance entre variable Gender et Claim  */ 
PROC FREQ DATA=MOUHAMED.ASSURANCE; 
	TABLES Gender*Claim ; 
RUN; 
 
/* Tableau contingeance entre variable Customer_Type et Claim  */ 
PROC FREQ DATA=MOUHAMED.ASSURANCE; 
	TABLES Customer_Type*Claim ; 
RUN; 
 
/* Tableau contingeance entre variable Children et Claim  */ 
PROC FREQ DATA=MOUHAMED.ASSURANCE; 
	TABLES Children*Claim ; 
RUN; 
 
/* Tableau contingeance entre variable Multiple_cars et Claim  */ 
PROC FREQ DATA=MOUHAMED.ASSURANCE; 
	TABLES Multiple_cars*Claim ; 
RUN; 
 
/* Tableau contingeance entre variable Profession et Claim  */ 
PROC FREQ DATA=MOUHAMED.ASSURANCE; 
	TABLES Profession*Claim ; 
RUN; 
 
/* Tableau contingeance entre variable Car_category et Claim  */ 
PROC FREQ DATA=MOUHAMED.ASSURANCE; 
	TABLES Car_category*Claim ; 
RUN; 
 
/* Tableau contingeance entre variable Gearbox et Claim  */ 
PROC FREQ DATA=MOUHAMED.ASSURANCE; 
	TABLES Gearbox*Claim ; 
RUN; 
/* Tableau contingeance entre variable Fuel et Claim  */ 
PROC FREQ DATA=MOUHAMED.ASSURANCE; 
	TABLES Fuel*Claim ; 
RUN; 
 
PROC FREQ DATA=MOUHAMED.ASSURANCE; 
	TABLES      Gearbox Fuel; 
	 
RUN; 
  
 
 
/* fin Analyse descriptive*/ 
 
/*********** 			Traitement des donnees		*******/ 
 
/* Recodage da la variable Claim par 0 et 1 */ 
 
DATA MOUHAMED.ASSURANCE ; 
	LENGTH ClaimNew$1; 
	SET MOUHAMED.ASSURANCE; 
	IF Claim='Ye' THEN ClaimNew='1'; 
	ELSE   ClaimNew='0'; 
RUN; 
DATA MOUHAMED.ASSURANCE ; 
	SET MOUHAMED.ASSURANCE; 
	DROP Claim; 
	RENAME ClaimNew= Claim; 
RUN; 
 
/* Recodage da la variable Children */ 
DATA MOUHAMED.ASSURANCE ; 
	LENGTH ChildrenNew$1; 
	SET MOUHAMED.ASSURANCE; 
	IF Children='1' THEN ChildrenNew='1'; 
	ELSE if Children='2' THEN ChildrenNew='2'; 
	ELSE if Children='3' THEN ChildrenNew='3'; 
	ELSE   ChildrenNew='4'; 
RUN; 
 
DATA MOUHAMED.ASSURANCE ; 
	SET MOUHAMED.ASSURANCE; 
	DROP Children; 
	RENAME ChildrenNew= Children; 
RUN; 
 
 
/* Discredisation la variables « Age » */ 
 
DATA MOUHAMED.ASSURANCE; 
	SET MOUHAMED.ASSURANCE; 
	IF Age <=35 THEN Age_Discretise = "1"; /* 1 = jeunes adultes */ /* Age_Discretise est la nvelle colonne créée pour stocker nos classes */ 
	IF 35<Age<=65 THEN Age_Discretise = "2"; /* 2 = adultes */ 
	IF Age>65 THEN Age_Discretise = "3"; /* 3 = vieux */ 
RUN; 
 
PROC FREQ DATA = MOUHAMED.ASSURANCE; 
	TABLES Age_Discretise / NOCOL NOROW NOCUM NOPERCENT; 
RUN; 
 
DATA MOUHAMED.ASSURANCE; 
	SET MOUHAMED.ASSURANCE; 
	DROP Age; 
	RENAME  Age_Discretise = Age; 
RUN; 
 
/******** Fin  Traitement des donnees ********/ 
 
 
PROC CONTENTS DATA=mouhamed.assurance; 
 
RUN; 
 
 
/******** 		Construction de model 	 ********/ 
 
/******** Regression Logistique binaire avec courbe de ROC ********/ 
PROC LOGISTIC DATA = MOUHAMED.ASSURANCE; 
              CLASS Gender Profession Customer_Type Age 
            Multiple_cars Children  Car_category Gearbox Fuel  ; 
        MODEL Claim (EVENT="1")=  Driving_Licence_Years  
                           Age Gender Profession Customer_Type 
                           Multiple_cars Car_category Gearbox Children Fuel /SELECTION = STEPWISE 
                           outroc=roc; 
RUN ; 
 
/******** 		Echantillonnage 		********/ 
 
 
DATA  MOUHAMED.ASSURANCE ; 
	SET	MOUHAMED.ASSURANCE ; 
	Echantillon = 1 ;	/* Initialisation de la variable Echantillon indiquant les deux échantillons */ 
	IF RANUNI (123) >=0.7 THEN Echantillon = 2 ;  
RUN; 
 
DATA MOUHAMED.ASSURANCE_Apprentissage ; 	/*  Echantillon D'Apprentissage */ 
	SET	MOUHAMED.ASSURANCE ; 
	WHERE Echantillon = 1 ; 
RUN; 
 
DATA MOUHAMED.ASSURANCE_Validation ; 	/*  Echantillon De Validation */ 
	SET	MOUHAMED.ASSURANCE ; 
	WHERE Echantillon = 2 ; 
RUN; 
 
PROC CONTENTS DATA = MOUHAMED.ASSURANCE_Apprentissage; 
RUN;  
/*  Affichage des 10 premiers observation  de la base de apprentissage*/ 
proc print data=MOUHAMED.ASSURANCE_Apprentissage (firstobs=1 OBS=10)noobs; 
run; 
 
PROC CONTENTS DATA = MOUHAMED.ASSURANCE_Validation; 
RUN;  
/*  Affichage des 10 premiers observation de la base de validation */ 
proc print data=MOUHAMED.ASSURANCE_Validation (firstobs=1 OBS=10)noobs; 
run; 
 
/*  Estimation du model */ 
PROC LOGISTIC DATA = MOUHAMED.ASSURANCE_Apprentissage OUTMODEL= MOUHAMED.ModelClaim   ; 
	 CLASS Age Gender Profession Customer_Type  
            Multiple_cars Car_category Gearbox Fuel  ;  
	MODEL Claim (EVENT="1") =   Driving_Licence_Years /      
                                         
	outroc=MOUHAMED.ROC; 
    output out= MOUHAMED.prevision_apprentissage 
    prob = proba_Claim; 
RUN; 
proc contents  
data =MOUHAMED.ROC; 
run; 
 
/* VALIDATION DU MODELE */ 
 
PROC LOGISTIC  INMODEL=  MOUHAMED.Model_Claim;  /* BD contenant le modèle */ 
  SCORE DATA = MOUHAMED.ASSURANCE_Validation;  /* BD Validation */ 
    
RUN; 
 
 
 
/***Verification de la performance***/ 
title 'Validation et verification de la performance de modèle'; 
proc logistic data = MOUHAMED.ASSURANCE_Validation; 
 
  CLASS Age Children Gender Profession Customer_Type 
       Multiple_cars Car_category Gearbox Fuel ; 
  model Claim  =  Driving_Licence_Years;  
run; 
title; 
 
 
 
/***recherche meilleur performance***/ 
title 'Validation et verification de la performance de modèle'; 
proc logistic data = MOUHAMED.assurance; 
 
  CLASS Age Gender Children Profession Customer_Type 
       Multiple_cars Car_category Gearbox Fuel ; 
  model Claim  =  Driving_Licence_Years;  
run; 
title; 
/********************************************************************* 
+++ 							VALIDATION DU MODELE	  	       +++ 
*********************************************************************/ 
PROC LOGISTIC  INMODEL= MOUHAMED.Model_Claim ; /* BD contenant le modèle */ 
	SCORE DATA = MOUHAMED.ASSURANCE_Validation  /* BD Validation */ 
	OUT =  MOUHAMED.Prevision_Claim  
	OUTROC= MOUHAMED.Performance_ROC_Claim ; 
RUN; 
 

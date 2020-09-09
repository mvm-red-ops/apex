public class BaUploadScheduleDiscrepencyCheck {

    //method accepts two args: list of schedules from SF , list of data from CSV
    //purpose is to compare the isci, 800#, show titles and rates to determine changes made to the BA
     public static List<Map<String, Map<String, List<String>>>> getChangedScheds(Map<String, Schedules__c> sfMap, Map<String, List<String>> csvMap, Integer rateIdx, Integer weekIdx, Integer phoneIdx,Integer isciIdx, Integer longformIdx, Integer showTitleIdx){
 		
         //return value of function
         //has id of sched as main key, value is {key =column name, val = row value (prev, current, changed(boolean))}
         List<Map<String, Map<String, List<String>>>> resultList = new List<Map<String, Map<String, List<String>>>>();
        

         //create map of schedules with changes 
         Map<String, Map<String, List<String>>> resultMap = new Map<String, Map<String, List<String>>>();
		
         Set<String> csvKeys = csvMap.keySet();
         Set<String> sfKeys = sfMap.keySet();
         
         Integer matchedCount = 0;
         Integer unmatchedCount = 0;
          for (String key : csvKeys) {

              	//sfMap formatted key
              	//01/14/2020 A-4:30 COURTTV Mystery PP
              	List<String> keyDates = key.left(10).trim().split('/');
              	String rDate = keyDates[2] + '-' + keyDates[0] + '-' + keyDates[1] +' 00:00:00';
              	String lForm = key.substring(10,17).trim();
              	String dProg = key.right(key.length() - 17).trim();
             	String sfKey = rDate + ' ' + lForm + ' ' + dProg;

                csvMap.get(key)[weekIdx] = rDate;
                  //formatted key
                  //2020-01-14 00:00:00 A-3:00  COURTTV Mystery PP
                  
                  //sf key
                  //2020-01-14 00:00:00 A-3:00 COURTTV Mystery PP
                  
              	//check for matching schedule from sf 
      
                if(sfMap.containsKey(sfKey)){
                    System.debug('sfMap contains sfKey');
					System.debug(sfKey);
                    //create value comparison map
                    Map<String, List<String>>  valMap = new Map<String, List<String>>();
                    
                    //set sf sched 
                    Schedules__c sfSched = sfMap.get(sfKey);
                  	System.debug('sfSched');
                  	System.debug(sfSched);
                    //set csv sched 
                    List<String> csvSched = csvMap.get(key);
                  	System.debug('csvSched');
                  	System.debug(csvSched);

                    //compare vals 
                    Map<String, Map<String, List<String>>> valComparison = compareMatchedVals(csvSched, sfSched, rateIdx, weekIdx, phoneIdx,isciIdx, longformIdx, showTitleIdx);
                                      	System.debug('compare matched');
                                      	System.debug(valComparison);

                    //remove key value from sf sched map
              		sfMap.remove(sfKey);
                    resultList.add(valComparison);
					matchedCount++;

                } else {
                    System.debug('sfMap does not contain sfKey');
                    System.debug(sfKey);
                    System.debug(sfMap);

           			//get key 
					List<String> csvUnmatched = csvMap.get(key);


                    //get vals
                    Map<String, Map<String, List<String>>> unmatchedVals = getUnmatchedVals(key, csvUnmatched, rateIdx, weekIdx, phoneIdx,isciIdx, longformIdx, showTitleIdx);
   
                    resultList.add(unmatchedVals);
                    unmatchedCount++;
              }
              
          }

         	  //iterate through remaining (unmatched) sfScheds and add to results
			  //there is a possiblity that there were more sf scheds in the range than defined in the BA
			  //So we will only add the unmatched sf scheds to the results if there are scheds in the unmatchedVals array 
			  //This is because if there are no scheds in the unmatched array, that means all of the BA schedules found matches		
         	  

         	  List<Schedules__c> unmatchedSFscheds = sfMap.values();
		
              If(unmatchedCount > 0){
                for(Integer i = 0; i < unmatchedSFscheds.size(); i++){
                  Map<String, Map<String, List<String>>> unmatchedSFresult = new Map<String, Map<String, List<String>>>();
                  
                  //List<Map<String, Map<String, List<String>>>> resultList
                  Map<String, List<String>> changeMap = new Map<String, List<String>>();

                  Schedules__c currentSched = unmatchedSFscheds[i];
                  //get id for main string key
                  
                  String idVal = String.valueOf(currentSched.Id);
                  //set map key values from sched
                  
                  
                  List<String> isciList = new List<String>();
                  if(String.isBlank(currentSched.ISCI_CODE__c)){
                     isciList = new List<String>{'blankIsci'};
                  } else {
                     isciList = new List<String>{currentSched.ISCI_CODE__c};
                  }
                  changeMap.put('isci', isciList);

                  List<String> phoneVals = new List<String>();
                  if(String.isBlank(currentSched.X800_Number__c)){
                     phoneVals = new List<String>{'blankPhone'};
                  } else {
                     phoneVals = new List<String>{currentSched.X800_Number__c};
                  }
               	  changeMap.put('phone', phoneVals);

                 List<String> rateVals = new List<String>{String.valueOf(currentSched.rate__c)};
                 changeMap.put('rate', rateVals);
                 
                 List<String> longformVals = new List<String>{currentSched.Long_Form__c};
                 changeMap.put('longform', longformVals);
            
                 List<String> matchedVals = new List<String>{'false'};
                 changeMap.put('matched', matchedVals);        
                  
                 List<String> weekVals = new List<String>{String.valueOf(currentSched.Week__c)};
                 changeMap.put('week', WeekVals);
           
                 List<String> dealprogVals = new List<String>{currentSched.Dealprogram__c};
                 changeMap.put('dealprog', dealprogVals);   
                 
                 List<String> showTitleVals = new List<string>{currentSched.LF_traffic__c};
                 changeMap.put('showtitle', showTitleVals);   
                     
                 unmatchedSFresult.put(idVal, changeMap); 
                 resultList.add(unmatchedSFresult);
             	}              
            }
              
         return resultList;
     }
    
    
    
    public static Map< String, Map<String, List<String>>> compareMatchedVals (List<String> current, Schedules__c currentSched, Integer rateIdx, Integer weekIdx, Integer phoneIdx,Integer isciIdx, Integer longformIdx, Integer showTitleIdx){
        Map< String, Map<String, List<String>>> result = new Map< String, Map<String, List<String>>>();
        Map<String, List<String>> changeMap = new Map<String, List<String>>();
        
                		//get required vals for comparison
                String isci;
                String rate;
                String longform;
                String phone;    
                String showTitle;    
        	try{
                        		//get required vals for comparison
                 isci = current[isciIdx].trim();
                 rate = formatRate(current[rateIdx]);
                 longform = String.valueOf(current[longformIdx]);
                if(longform.charAt(0) == 48){
                    longform = 'A-' + longform.substring(1);
                }
                 phone = current[phoneIdx];    
                 showTitle = current[showTitleIdx]; 
            } catch(Exception e){
             	System.debug('variables arent working in the compare matched vals function:');
                AuraHandledException ex = new AuraHandledException('During comparison we found an erro.');
                ex.setMessage('Setting variables trouble.');
                throw ex;            
            }


    
		     List<String> rateVals = new List<String>{String.valueOf(currentSched.rate__c), String.valueOf(rate), String.valueOf(String.valueOf(currentSched.rate__c)!= rate)};
             changeMap.put('rate', rateVals);
        
       		 List<String> phoneVals = new List<String>();
       		 List<String> isciList = new List<String>();
       		 List<String> showTitleList = new List<String>();
        
             if(currentSched.X800_Number__c == null || String.isBlank(currentSched.X800_Number__c)){
               phoneVals = new List<String>{phone, String.valueOf(currentSched.X800_Number__c != phone)};
                   System.debug('blank string');
             } else{
               phoneVals = new List<String>{currentSched.X800_Number__c, phone, String.valueOf(currentSched.X800_Number__c != phone)};
             }
             changeMap.put('phone', phoneVals);
             
             List<String> longformVals = new List<String>{currentSched.Long_Form__c, longform, String.valueOf(currentSched.Long_Form__c != longform)};
             changeMap.put('longform', longformVals);
        
        	 if(currentSched.ISCI_CODE__c == null || String.isBlank(currentSched.ISCI_CODE__c)){
                 System.debug('ISCI_CODE__c not on SF Schedule');
             	isciList = new List<String>{isci, 'true'};
             } else{
				System.debug(currentSched.ISCI_CODE__c.length());
				 System.debug(isci.length());
               isciList = new List<String>{currentSched.ISCI_CODE__c, isci, String.valueOf(currentSched.ISCI_CODE__c != isci)};
             }

        	changeMap.put('isci', isciList);
			
        	 if(currentSched.LF_traffic__c == null || String.isBlank(currentSched.LF_traffic__c)){
                 System.debug('LF_traffic__c, if');
             	showTitleList = new List<String>{showTitle, String.valueOf(currentSched.LF_traffic__c != showTitle)};
             } else{
				 System.debug(showTitle.length());
               showTitleList = new List<String>{currentSched.LF_traffic__c, showTitle, String.valueOf(currentSched.LF_traffic__c != showTitle)};
             }
     		 changeMap.put('showtitle', showTitleList);
        
       		 List<String> matchedVals = new List<String>{'true'};
        	 changeMap.put('matched', matchedVals);
                 
        	 List<String> weekVals = new List<String>{String.valueOf(currentSched.Week__c)};
             changeMap.put('week', WeekVals);
        
       		 List<String> dealprogVals = new List<String>{currentSched.Dealprogram__c};
             changeMap.put('dealprog', dealprogVals);       

            
             String id = currentSched.Id;
        	 result.put(id, changeMap);
                 System.debug('matched idVal and changemap');
                 System.debug(id);
                 System.debug(changeMap);
             return result;
    }
    
    public static String formatRate(String rate){
        List<String> rateVals = rate.split('\\$');

        if(rateVals.size() == 2){
            rate = rateVals[1];
        }
                

        return rate;
    }
    
    public static Map< String, Map<String, List<String>>> getUnmatchedVals(String key, List<String> current, Integer rateIdx, Integer weekIdx, Integer phoneIdx,Integer isciIdx, Integer longformIdx, Integer showTitleIdx){
            Map<String, Map<String, List<String>>> result = new Map< String, Map<String, List<String>>>();
            Map<String, List<String>> changeMap = new Map<String, List<String>>();    
           
            String isci = current[isciIdx];
            String rate = current[rateIdx];
        	String week = current[weekIdx];
        	String dealprog = current[3];
            String longform = String.valueOf(current[longformIdx]);
            if(longform.charAt(0) == 48){
                longform = 'A-' + longform.substring(1);
            }
            String phone = current[phoneIdx];    
            String showTitle = current[showTitleIdx];             

       		List<String> isciList = new List<String>{isci};
                 if(isciList.size() == 0){
                     System.debug('current record no iscis');
                       System.debug(current);

                 }
     		 changeMap.put('isci', isciList);
             
		     List<String> rateVals = new List<String>{String.valueOf(rate)};
             changeMap.put('rate', rateVals);
             
             List<String> phoneVals = new List<String>{phone};
             changeMap.put('phone', phoneVals);
             
             List<String> longformVals = new List<String>{longform};
             changeMap.put('longform', longformVals);
        
       		 List<String> matchedVals = new List<String>{'false'};
        	 changeMap.put('matched', matchedVals);   
        	 
             List<String> weekVals = new List<String>{week};
        	 changeMap.put('week', weekVals); 
                     
      		 List<String> showTitleVals = new List<String>{showTitle};
        	 changeMap.put('showtitle', showTitleVals); 

        
       		 List<String> dealprogVals = new List<String>{dealprog};
        	 changeMap.put('dealprog', dealprogVals);   

        	result.put(key, changeMap);
        return result;
    }
}

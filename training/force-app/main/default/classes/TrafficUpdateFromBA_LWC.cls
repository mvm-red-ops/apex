public with sharing class TrafficUpdateFromBA_LWC {
	@auraEnabled() 
    public static Map<Map<String,String>, List<Map<String, String>>> updateSchedules(List<List<Map<String, String>>> scheds){
        List<Map<String, String>> unmatchedJSON = scheds[0];        
        List<Map<String, String>> matchedJSON = scheds[1];

        Map<String,Schedules__c> matchedMap = getMatchedSchedules(matchedJSON);
		List<Schedules__c> updatedSchedules = new List<Schedules__c>();


        for(Integer i = 0; i < matchedJSON.size(); i++){
            
            //get current match sched obj from json
            Map<String, String> matchJSON = matchedJSON[i];
            String sId = matchJSON.get('Id');

            Schedules__c schedToUpdate = matchedMap.get(sId);
 
            //grab id and get schedule
            if(matchJSON.containsKey('Rate__c')){
                schedToUpdate.Rate__c = Integer.valueOf(matchJSON.get('Rate__c'));
            }
            if(matchJSON.containsKey('ISCI_CODE__c')){
                schedToUpdate.ISCI_CODE__c = matchJSON.get('ISCI_CODE__c');
            }
            if(matchJSON.containsKey('X800_Number__c')){
                schedToUpdate.X800_Number__c = matchJSON.get('X800_Number__c');
            }            
            if(matchJSON.containsKey('LF_traffic__c')){
                schedToUpdate.LF_traffic__c = matchJSON.get('LF_traffic__c');
            }
            
            System.debug(matchJSON);
            updatedSchedules.add(schedToUpdate);
        }
        System.debug('updatedSchedules');
        System.debug(updatedSchedules);

        //execute the DML update
        try{
           System.debug('updating..');
           update updatedSchedules ;
        }
        catch(Exception e){
            AuraHandledException ex = new AuraHandledException(' Schedule Update Failed.' + e.getMessage());
            ex.setMessage('The update for the schedules failed: ' + e.getMessage());
            throw ex;
        }
        
        //want to return non updated schedules
        //in the format that has the sf scheds that are likely matches
        //and the csv sched info 
        //List<Map<String, String>> 
        //[ {'id: '', 'Week__c': '01/25/2019'}  ]

        List<Map<String, String>> returnObjects = new List<Map<String, String>>();
        Map<Map<String,String>, List<Map<String, String>>> returnVals = new Map<Map<String,String>, List<Map<String, String>>>();
   		Map<String, String> status = new Map<String, String>();
        
        //would be ideal to return ba schedules that didn't match
      		System.debug('unmatched');
            System.debug(unmatchedJSON);
        if(unmatchedJSON.size() > 0){
           returnObjects = unmatchedJSON;
           status = new Map<String, String>{'updateStatus'=>'succesful','code'=> '202', 'matchStatus'=>'BA schedules not matched', 'count' => String.valueOf(unmatchedJSON.size())};
           returnVals.put(status, returnObjects);
        } else {
            status = new Map<String, String>{'updateStatus'=>'succesful','code' => '201', 'matchStatus'=>'every schedule matched'};
            returnVals.put(status, returnObjects);
        }
        
  	    return returnVals;
    }
    
    public static Map<String,Schedules__c> getMatchedSchedules(List<Map<String, String>> matched){
   		List<String> schedIds = new List<String>();
     	for(Integer i = 0; i < matched.size(); i++ ){
           //add each sched id to array;
           Map<String, String> curr = matched[i];
           schedIds.add(curr.get('Id'));
        }
      
        List<Schedules__c> scheds = [SELECT Id FROM Schedules__c WHERE Id IN :schedIds];
        
	    Map<String, Schedules__c> schedMap = new Map<String, Schedules__c>();

        for(Integer i = 0; i < scheds.size(); i++){
            Schedules__c curr = scheds[i];
            schedMap.put(String.valueOf(curr.Id), curr);
        }
        
        return schedMap;
    }
    
    public static List<Map<String, String>> formatUnmatchedJSON(List<Map<String, String>> unmatched){
        List<Map<String, String>> result = new List<Map<String, String>>();
            
        for(Integer i = 0; i < unmatched.size(); i++){
            Map<String, String> curr = unmatched[i];
            
            //if the id is an sf id, the split value will be 1
            if(curr.get('Id').split(' ').size() > 1){
                //object from csv data
                Map<String, String> formattedObj = new Map<String, String>();
            } else {
                //object is a sf sched
            }
            
        }
        
        return result;
    }
}

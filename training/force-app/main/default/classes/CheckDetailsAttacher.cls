public class CheckDetailsAttacher {
    
    
    public static List<CheckDetail__c> attachCheckDetails(List<CheckDetail__c> checkDetails, Date startDate, Date endDate, String network){
       //create variables for checks to update, schedules that match query, unmatched schedules, and a dictionary of schedules based on key
        List<CheckDetail__C> checkDetailsToUpdate = new List<CheckDetail__C>();        
        List<Schedules__C> schedulePool = getSchedules(startDate, endDate, network);
        List<Schedules__C> schedulesToUpdate = new List<Schedules__c>();
        Map<String, Integer> schedulePayments = new Map<String, Integer>();
  		List<CheckDetail__C> unmatchedCheckDetails = new List<CheckDetail__C>();
        Map<String, List<Schedules__c>> havasSchedMap = new Map<String,List<Schedules__c>>();
        Map<String, List<Schedules__c>> nonHavasSchedMap = new Map<String,List<Schedules__c>>();
        Schedules__c unmatchedCheckSchedule = [SELECT id FROM Schedules__c WHERE id = 'a08020000000WggAAE'];
        
        //iterate through schedules and create dictionary entries
        For(Integer i = 0; i < schedulePool.size(); i++){
            //get current schedule
            Schedules__c current = schedulePool[i];
            //8/12/2020 A-4:00
            String key = current.Week__c + '-' + current.long_form__c;

            //check if deal account is Havas
            if(current.DealAccount__c.contains('Havas')){
                if(havasSchedMap.containsKey(key)){
                    havasSchedMap.get(key).add(current);
                    //throw new applicationException('multiple schedules with same longform: ' +current.long_form__c + 'and week: ' +current.week__C);
                } else {
                    List<Schedules__C> sched = new List<Schedules__c>{current};
                    havasSchedMap.put(key, sched);
                    schedulePayments.put(key, 0);
                }
            } else {
                if(nonHavasSchedMap.containsKey(key)){
                    nonHavasSchedMap.get(key).add(current);
                    //throw new applicationException('multiple schedules with same longform: ' +current.long_form__c + 'and week: ' +current.week__C);
                } else {
                    List<Schedules__C> sched = new List<Schedules__c>{current};
                    nonHavasSchedMap.put(key, sched);
                }            
            }


        }

        Boolean matchFound = false;
        //iterate through check details
        For(Integer i = 0; i < checkDetails.size(); i++){
            //get check detail
            CheckDetail__c current = checkDetails[i];
            String key = current.Air_Date__c + '-' + current.air_Time__C;

            //check if havas sched map contains key matching schedules
            if(havasSchedMap.containsKey(key)){
                //get list of schedules with matching key
                List<Schedules__c> matchList = havasSchedMap.get(key);
				Schedules__C sched;
                
                if(matchList.size() > 1){
                    AuraHandledException keyFormatError = new AuraHandledException('Multiple matching schedules. There should only be one Sold Havas Schedule for this week/longform.');
                    keyFormatError.setMessage('Multiple matching Schedules.');
                    throw keyFormatError;    
                }

                
                /**For(Integer j = 0; j < matchList.size(); j++){
                    sched = matchList[j];
	                
                    //check if the rate matches
                    if(sched.rate__c != Math.abs(current.check_Amount__C)){
                        current.Unmatched_Reason__C = 'Mismatch rate on Schedule ';
                		current.Schedule__c = sched.id;
                        checkDetailsToUpdate.add(current);
                    }
                    //check if the traffic matches
                    else if (sched.lf_traffic__c != null && sched.lf_traffic__c.trim() != current.Item_Ad_ID__c.trim()){
                        current.Unmatched_Reason__C = 'Mismatch traffic on Schedule ';
                        current.Schedule__c = sched.id;
                        checkDetailsToUpdate.add(current);
                    } else {
                        //perfect match. associate the schedule and add to the update array
                        current.Schedule__c = sched.id;
                        current.unmatched__C = false;
                        checkDetailsToUpdate.add(current);
                        matchFound = true;
                        continue;
                    }
                }
                if(matchFound)continue;
                
                unmatchedCheckDetails.add(current);

               **/
                //below are the two conditions where no matching schedules was found (1. Only exists for non-havas accounts, 2. No schedule with matching week/longform)
            } else if(nonHavasSchedMap.containsKey(key)){
                current.Unmatched_Reason__C = 'Schedule only exists for Non-Havas DealAccount.';
                current.Schedule__c = unmatchedCheckSchedule.id;
                checkDetailsToUpdate.add(current);
                unmatchedCheckDetails.add(current);

            } else {
                current.Unmatched_Reason__c = 'No matching week/long form Schedule';
                current.Schedule__c = unmatchedCheckSchedule.id;
                checkDetailsToUpdate.add(current);
                unmatchedCheckDetails.add(current);
            }            
        }
        
 
        
    	System.debug('check detail obj to update start:');
        For(Integer i = 0; i <checkDetailsToUpdate.size();i++ ){
            System.debug(checkDetailsToUpdate[i]);
        }
        if(checkDetailsToUpdate.size() >= 1){
			insert checkDetailsToUpdate; 
        }

        
		return unmatchedCheckDetails;
    }
    
    public static List<Schedules__c> getSchedules(Date startDate, Date endDate, String network){
            List<Schedules__C> schedPool = [
                SELECT 
                id, 
                status__c, 
                long_form__c, 
                week__c,
                Check_Date__c,
                Check_Number__c,
                Check_Amount__c,
                Debit_Check__c,
                Debit_Date__c,
                Check_Id__c,
                lf_traffic__c,
                DealAccount__c,
                Sum_of_Check_Payments__c,
                rate__c
                FROM Schedules__c 
                WHERE Week__c >= :startDate 
                AND Week__c <= :endDate 
                AND DealProgram__c = :network 
                AND DealBrand__c != 'Availability'
                ORDER BY Week__c ASC
            ];
        

        return schedPool;
    }
}
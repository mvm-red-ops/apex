public class CheckDetailsAttacher {
    
   
    public static List<CheckDetail__c> attachCheckDetails(List<CheckDetail__c> checkDetails, Date startDate, Date endDate, String network){
        List<CheckDetail__C> checkDetailsToUpdate = new List<CheckDetail__C>();        
        List<Schedules__C> schedulePool = getSchedules(startDate, endDate, network);
  		List<CheckDetail__C> unmatchedCheckDetails = new List<CheckDetail__C>();

        Map<String, List<Schedules__c>> schedMap = new Map<String,List<Schedules__c>>();
        
        
        For(Integer i = 0; i < schedulePool.size(); i++){
            Schedules__c current = schedulePool[i];
            String key = current.Week__c + '-' + current.long_form__c;

            if(schedMap.containsKey(key)){
                schedMap.get(key).add(current);
                //throw new applicationException('multiple schedules with same lonform: ' +current.long_form__c + 'and week: ' +current.week__C);
            } else {
                List<Schedules__C> sched = new List<Schedules__c>{current};
                schedMap.put(key, sched);
            }
        }
        
        //iterate through check details
        For(Integer i = 0; i < checkDetails.size(); i++){
            //get check detail
            CheckDetail__c current = checkDetails[i];
            String key = current.Air_Date__c + '-' + current.air_Time__C;
            //find all matching schedules
            if(schedMap.containsKey(key)){
                List<Schedules__c> matchList = schedMap.get(key);
                System.debug('schedule, current ');
                For(Integer j = 0; j < matchList.size(); j++){
                    Schedules__C sched = matchList[j];
                    System.debug(sched);
					System.debug(current);
                      System.debug(sched.rate__c);
					System.debug(current.check_Amount__C);
                    current.Schedule__c = sched.id;
                    if(sched.rate__c == Math.abs(current.check_Amount__C)){
                        current.Unmatched_Reason__C = '';
                     	checkDetailsToUpdate.add(current);
                    } else {
                        current.Unmatched_Reason__C = 'Mismatch rate on Schedule ';
                        unmatchedCheckDetails.add(current);
                    }
                }
               
            } else {
                current.Unmatched_Reason__c = 'No matching week/long form Schedule';
                unmatchedCheckDetails.add(current);
            }            
        }
        
       System.debug('unmatchedCheckDetails');
       System.debug(unmatchedCheckDetails);
       System.debug('checkDetailsToUpdate');
       System.debug(checkDetailsToUpdate);
        
        For(Integer i = 0; i <checkDetailsToUpdate.size();i++ ){
            System.debug('check detail obj to update:');
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
                rate__c
                FROM Schedules__c 
                WHERE Week__c >= :startDate 
                AND Week__c <= :endDate 
                AND DealProgram__c = :network 
                AND DealAccount__c = 'Havas Edge' 
                AND DealBrand__c != 'Availability'
                ORDER BY Week__c ASC
            ];
        
        System.debug('start - end - network');
        System.debug(startDate);
        System.debug(endDate);
        System.debug(network);
        System.debug('schedule pool: ');
        System.debug(schedPool);
        return schedPool;
    }
}

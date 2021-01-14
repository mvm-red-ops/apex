public class CheckDetailsAttacher {
    
    public static CheckDetailScheduleOrganizerWrapper attachCheckDetails(List<CheckDetail__c> checkDetails, Date startDate, Date endDate, String network){
       
       //VARIABLE DEFINITION START
        //array for new check details 
        List<CheckDetail__C> checkDetailsToInsert = new List<CheckDetail__C>();  
        
        //array for new schedules with sums to update
        List<Schedules__c> schedulesToUpdate = new List<Schedules__c>();
      
        //queries for potential matching shcedules
        List<Schedules__C> schedulePool = getSchedules(startDate, endDate, network);

        //Keeps track of unique ids of Schedules (prevents duplicate accounting)
        Set<Id> scheduleIds = new Set<Id>();

        //Id of schedule and value of Sum_of_Check_Payments field (gets updated with matching Check Detail's Check Amount)
        Map<Id, Decimal> schedulePayments = new Map<Id, Decimal>();

        //Holds Check Detail objects did not have perfect match
        List<CheckDetail__C> unmatchedCheckDetailsMaster = new List<CheckDetail__C>();

        //holds full schedule object
        Map<Id, Schedules__C> scheduleRecords = new Map<Id, Schedules__C>();

        //Buckets sorted by agency 
        Map<String, List<Schedules__c>> havasSchedMap = new Map<String,List<Schedules__c>>();
        Map<String, List<Schedules__c>> nonHavasSchedMap = new Map<String,List<Schedules__c>>();

       //VARIABLE DEFINITION END

       //PROCESS START
        //organize schedules
        CheckDetailScheduleOrganizerWrapper organizedScheduleWrapper = organizeSchedules( schedulePool,scheduleIds, havasSchedMap, nonHavasSchedMap, scheduleRecords);
        scheduleIds = organizedScheduleWrapper.scheduleIds;
        havasSchedMap = organizedScheduleWrapper.havasSchedMap;
        nonHavasSchedMap = organizedScheduleWrapper.nonHavasSchedMap;
        //key '01/12/20 A-4:00': [{id: 1203, Week__C: '213'}]
        scheduleRecords = organizedScheduleWrapper.scheduleRecords;

        //sort and match check details
        CheckDetailScheduleOrganizerWrapper sortedCheckDetails = sortCheckDetails(checkDetails, checkDetailsToInsert,schedulePayments,havasSchedMap, nonHavasSchedMap, unmatchedCheckDetailsMaster);
        checkDetailsToInsert = sortedCheckDetails.checkDetailsToInsert;
        schedulePayments = sortedCheckDetails.schedulePayments;
        unmatchedCheckDetailsMaster = sortedCheckDetails.unmatchedCheckDetailsMaster;
		sortedCheckDetails.scheduleRecords = organizedScheduleWrapper.scheduleRecords;


        //update sum of check payments for each schedules
        schedulesToUpdate =  updateSchedulePayments(schedulesToUpdate, scheduleIds, scheduleRecords, schedulePayments);  
		
        System.debug('schedulesToUpdate');
        System.debug(schedulesToUpdate);
        
        CheckDetailQueue queueableCheckDetailHandler = new CheckDetailQueue(checkDetailsToInsert, schedulesToUpdate);
        
        ID jobID = System.enqueueJob(queueableCheckDetailHandler);
      	AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
		System.debug('job info:');
		System.debug(jobInfo);

        return sortedCheckDetails;
       //PROCESS END
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
                rate__c,
                Deal_Parent__r.Program__r.Lead__c,
                Deal_Parent__r.Program__r.Lead__r.email
                FROM Schedules__c 
                WHERE Week__c >= :startDate 
                AND Week__c <= :endDate 
                AND DealProgram__c = :network 
                AND DealBrand__c != 'Availability'
                AND Status__C = 'Sold'
                FOR UPDATE
            ];

        return schedPool;
    }

    public static CheckDetailScheduleOrganizerWrapper organizeSchedules(
        List<Schedules__C> schedulePool,
        Set<Id> scheduleIds,
        Map<String, List<Schedules__c>> havasSchedMap,
        Map<String, List<Schedules__c>> nonHavasSchedMap,
        Map<Id, Schedules__C> scheduleRecords
    ){
        CheckDetailScheduleOrganizerWrapper result = new CheckDetailScheduleOrganizerWrapper();
                
        //iterate through schedules and create dictionary entries
        For(Integer i = 0; i < schedulePool.size(); i++){

            //get current schedule
            Schedules__c current = schedulePool[i];
        
            //key format: 8/12/2020 - A-4:00 
            String key = current.Week__c + '-' + current.long_form__c;
			scheduleRecords.put(current.id, current);
            //check if deal account is Havas
            if(current.DealAccount__c.contains('Havas')){

                if(havasSchedMap.containsKey(key)){
                    havasSchedMap.get(key).add(current);
                    //throw new applicationException('multiple schedules with same longform: ' +current.long_form__c + 'and week: ' +current.week__C);
                } else {
                    List<Schedules__C> sched = new List<Schedules__c>{current};
                    scheduleIds.add(current.id);
                    havasSchedMap.put(key, sched);
                }
            } else {
                if(nonHavasSchedMap.containsKey(key)){
                    nonHavasSchedMap.get(key).add(current);
                    //throw new applicationException('multiple schedules with same longform: ' +current.long_form__c + 'and week: ' +current.week__C);
                } else {
                    List<Schedules__C> sched = new List<Schedules__c>{current};
                    scheduleIds.add(current.id);
                    nonHavasSchedMap.put(key, sched);
                }            
            }

        }
        result.scheduleIds = scheduleIds;
        result.havasSchedMap = havasSchedMap;
        result.nonHavasSchedMap = nonHavasSchedMap;
        result.scheduleRecords = scheduleRecords;
        return result;
    }


    public static CheckDetailScheduleOrganizerWrapper sortCheckDetails(
        List<CheckDetail__C> checkDetails,
        List<CheckDetail__C> checkDetailsToInsert,
        Map<Id, Decimal> schedulePayments,
        Map<String, List<Schedules__c>> havasSchedMap,
        Map<String, List<Schedules__c>> nonHavasSchedMap,
        List<CheckDetail__C> unmatchedCheckDetailsMaster
    ){
        CheckDetailScheduleOrganizerWrapper result = new CheckDetailScheduleOrganizerWrapper();
        Boolean isHavasSchedule;
        Boolean isNonHavasSchedule;
        
        //iterate through check details
        For(Integer i = 0; i < checkDetails.size(); i++){

            //get current check detail
            CheckDetail__c current = checkDetails[i];
            
            //create key
            String key = current.Air_Date__c + '-' + current.air_Time__C;

            //havas vs non havas
            isHavasSchedule = havasSchedMap.containsKey(key);
            isNonHavasSchedule = nonHavasSchedMap.containsKey(key);
            
            //check for multiple sold schedules (should never hit)
            if(isHavasSchedule && isNonHavasSchedule){
                AuraHandledException multipleMatches = new AuraHandledException('There is a match for both Havas and Non-Havas shcedules. There should only be one matching sold schedule with the key:' + key);
                multipleMatches.setMessage('There is a match for both Havas and Non-Havas shcedules. There should only be one matching sold schedule with the key:' + key);
                throw multipleMatches;    
            }
            
            //check if havas sched map contains key matching schedules
            if(isHavasSchedule){

                //get list of schedules with matching key
                List<Schedules__c> matchList = havasSchedMap.get(key);
				Schedules__C sched = matchList[0];

                //there should only be one match, so throw error if more
                if(matchList.size() > 1){
                    AuraHandledException keyFormatError = new AuraHandledException('Multiple matching schedules. There should only be one Sold Havas Schedule for this week/longform.');
                    keyFormatError.setMessage('Multiple matching Schedules.');
                    throw keyFormatError;    
                } else {
                    current.Schedule__c = sched.id;
                    performAccounting(current, sched, schedulePayments);

                    //check if the rate does not match
                    if(sched.rate__c != Math.abs(current.check_Amount__C)){
                        current.Unmatched_Reason__C = 'Mismatched rate on Schedule';
                        current.unmatched__C = true;
                        unmatchedCheckDetailsMaster.add(current);
                        checkDetailsToInsert.add(current);
                    }
                    //check if the traffic matches
                    else if (sched.lf_traffic__c != null && sched.lf_traffic__c.trim() != current.Item_Ad_ID__c.trim()){
                        current.Unmatched_Reason__C = 'Mismatched traffic on Schedule';
                        current.unmatched__C = true;
                        unmatchedCheckDetailsMaster.add(current);
                        checkDetailsToInsert.add(current);

                    } else {
                        //perfect match. associate the schedule and add to the update array
                        current.unmatched__C = false;
                        checkDetailsToInsert.add(current);
                    }
                    
                }


                //below are the two conditions where no matching schedules was found (1. Only exists for non-havas accounts, 2. No schedule with matching week/longform)
            } else if(isNonHavasSchedule){
                current.Unmatched_Reason__C = 'Schedule only exists for Non-Havas DealAccount.';
                current.unmatched__C = true;
                checkDetailsToInsert.add(current);
                unmatchedCheckDetailsMaster.add(current);

            } else {
                current.Unmatched_Reason__c = 'No matching week/long form Schedule';
               	current.unmatched__C = true;
                checkDetailsToInsert.add(current);
                unmatchedCheckDetailsMaster.add(current);

            }            
        }

        result.checkDetailsToInsert = checkDetailsToInsert;
        result.schedulePayments = schedulePayments;
        result.unmatchedCheckDetailsMaster = unmatchedCheckDetailsMaster;       
        
        return result;
    }

    public static list<Schedules__C> updateSchedulePayments(
        List<Schedules__C> schedulesToUpdate, 
        Set<Id> scheduleIds, 
        Map<Id, Schedules__C> scheduleRecords,
        Map<Id, Decimal> schedulePayments
    ){
        //accounting logic
             System.debug('accounting..');

         for(Id current : schedulePayments.keySet()){
                Decimal paymentSum = schedulePayments.get(current);
                Schedules__c sched = scheduleRecords.get(current);
                sched.Sum_of_Check_Payments__c = paymentSum;
                schedulesToUpdate.add(sched);
             System.debug('paymentSum');
             System.debug(paymentSum);
             System.debug('sched');
             System.debug(sched);
            }

        return schedulesToUpdate;
    }
    
    
    public static void performAccounting(CheckDetail__C current, Schedules__C sched, Map<Id, Decimal> schedulePayments ){
        //check if payment sum exists for current schedule, if it does update it
        if(schedulePayments.containsKey(sched.Id)){
            Decimal currentPayment = current.Check_Amount__c * .85;
            Decimal schedPaymentSum = schedulePayments.get(sched.Id);
            Decimal updatedSum = currentPayment + schedPaymentSum;
            schedulePayments.put(sched.Id, updatedSum);
        } else {              
            if(sched.Sum_of_Check_Payments__c != null ){
                Decimal newSum = sched.Sum_of_Check_Payments__c + (current.Check_Amount__c * .85);
                schedulePayments.put(sched.Id, newSum);
            } else {
                schedulePayments.put(sched.Id, current.Check_Amount__c * .85);
            }
        }
    }
}
public with sharing class PPScheduleFinderHelperLWC {
    
    public static Map<String, Schedules__c> getSFSchedules(Map<String, List<String>> CSVDataMap, String dealProgram, Integer dateIdx){
            Map<String, Schedules__c> sfScheds = new Map<String, Schedules__c>();
        
         	//grab the values from the csv data map
            List<List<String>> vals = CSVDataMap.values();
            
            //get earliest and latest dates,
            //iterate through csv values and update start and end date
            //these are used for the soql query 
			DateTime startDate = Date.newInstance(2021, 12, 14);
           	DateTime endDate = Date.newInstance(2019, 01, 15);
        	Date today = Date.today();
			applicationException appError = new applicationException();
        
            for(Integer i = 0; i < vals.size(); i++){
                List<String> curr = vals[i];

                List<String> split = curr[dateIdx].split('/');
                DateTime cdate = Datetime.newInstance(Integer.valueOf(split[2]), Integer.valueOf(split[0]),Integer.valueOf(split[1]));
                if(cdate <= today){
                   AuraHandledException pastSchedError = new AuraHandledException('Traffic can only be updated for future scheds. Check the CSV you are uplodaing for past schedules. Or contact Product Team.');
                   pastSchedError.setMessage('The sched you are trying to update is prior to today.');
                	throw pastSchedError;    
                }
                if(cdate < startDate){
                    startDate = cdate;
                } 
                if (cdate > endDate){
           			endDate = cdate;
                }
            }


            //get list of SF schedules in date range
			sfScheds = getSchedulesInRange(startDate, endDate, dealProgram);
        return sfScheds;
    }
           
    public static Map<String, Schedules__c> getSchedulesInRange(DateTime startDate, DateTime endDate, String dealProgram){
        String queryStartDate = startDate.format('yyyy-MM-dd');
        String queryEndDate =  endDate.format('yyyy-MM-dd');

      
          
        String query = 'SELECT Id, Week__c, LF_Daypart__c, Rate__c, Day_of_Week__c, LF_traffic__c, DealBrand__c,dealprogram__c, Long_Form__c, ISCI_CODE__c, X800_Number__c	 FROM Schedules__c WHERE dealprogram__c =\''+ String.escapeSingleQuotes(dealProgram) + '\'' + 
          ' AND DealBrand__c  !=\'' + String.escapeSingleQuotes('Availability')+ '\'' + ' AND Week__c >= ' + String.valueOf(queryStartDate) + ' AND week__c <= ' + String.valueOf(queryEndDate) +' AND DealAccount__c =\'' + String.escapeSingleQuotes('Havas Edge')+ '\'' +
          ' AND Status__c  =\'' + String.escapeSingleQuotes('Sold')+'\'' + ' ORDER BY Week__c ASC';
   			
		Map<String, Schedules__c> sfMap = new Map<String, Schedules__c>();

        List<Schedules__c> scheds = Database.query(query);
        
        for(Integer i = 0; i < scheds.size(); i++){
            Schedules__c curr = scheds[i];
            String key = curr.Week__c + ' ' + curr.Long_Form__c + ' ' + curr.dealProgram__c;
            sfMap.put(key, curr);
        }
        
        return sfMap;
	  }
    
    
}
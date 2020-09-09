public inherited sharing class PPTrafficUploader {
	
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Map<String, List<String>>>> readCSVFile(Id idContentDocument, String dealProgram){

        applicationException appError = new applicationException();
        
        //Variable declaration
        Map<String, Schedules__c> sfScheds = new Map<String, Schedules__c>();
		List<Map<String, Map<String, List<String>>>> changedScheds; 
        Integer rateIdx;
        Integer weekIdx;
        Integer phoneIdx;
        Integer isciIdx;
	    Integer longformIdx;
	    Integer showTitleIdx;

        if(idContentDocument != null) {
            // getting File Version  based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument LIMIT 1];

            // split the file data by rows
            List<String> CSVData = objVersion.VersionData.toString().split('\n');
            List<String> headers = CSVData[0].split(',');
 			System.debug('headers');
 			System.debug(headers);
            //Get indexes from headers 
            Map<String, Integer> idxMap = CSVUploadHelper.getBAIndexes(headers);
 			rateIdx = idxMap.get('rateIdx');
 			weekIdx = idxMap.get('weekIdx');
 			phoneIdx = idxMap.get('phoneIdx');
 			isciIdx = idxMap.get('isciIdx');
 			longformIdx = idxMap.get('longformIdx');
 			showTitleIdx = idxMap.get('showTitleIdx');

            //filters blank rows
		 	List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);

            //Split data into map with key and values
            Map<String, List<String>> CSVDataMap = new Map<String, List<String>>();

            //call formatting method on csv data, throw error if unformattable
            CSVDataMap  = CSVUploadHelper.BaCsvFormatCheck(cleanCSVData, rateIdx, weekIdx, phoneIdx, isciIdx, longformIdx, showTitleIdx, dealProgram); 
            System.debug('CSVDataMap');
 			System.debug(CSVDataMap); 			
 			System.debug(CSVDataMap.size());

            //get matching salesforce schedules
            sfScheds = PPScheduleFinderHelperLWC.getSFSchedules(CSVDataMap, dealProgram, weekIdx);
            System.debug('sfScheds');
 			System.debug(sfScheds);
 			System.debug(sfScheds.size());
            //compare the data from the csv to the matched schedules
            //determine those that have changes
			changedScheds =  BaUploadScheduleDiscrepencyCheck.getChangedScheds(sfScheds, CSVDataMap, rateIdx, weekIdx, phoneIdx,isciIdx, longformIdx, showTitleIdx);
            
			System.debug('changedScheds');
 			System.debug(changedScheds);
            //final format check, checks that value sets do not exceed expected length
            //throws formatting error
            CSVUploadHelper.finalFormatCheck(changedScheds);
            
        	return changedScheds;
            
        } else {
            appError.message = 'Sorry! Not sure what went wrong, reach out to your administrator for help!';
            appError.name = 'General Application error';
            appError.code = 199;
            throw appError;
        }

        
    }    
}
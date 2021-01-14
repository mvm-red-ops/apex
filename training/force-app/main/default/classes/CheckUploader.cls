public class CheckUploader {
    
    @AuraEnabled()
    public static List<CheckDetail__C> readCSV(Id idContentDocument){

        applicationException appError = new applicationException();
        List<CheckDetail__C> results = new List<CheckDetail__C>();
        Integer airDateIdx;
        Integer airTimeIdx;
        Integer adIdIdx;
        Integer checkNumIdx;
        Integer checkAmtIdx;
        Integer checkDateIdx;
        Integer debitIdx;
        Integer debitDateIdx;
        Integer idIdx;
        Integer stationIdx;
        Integer dbtDateIdx;
        Integer dbtChkIdx;

        //check if csv document was uploaded 
        if(idContentDocument != null) {        
            // getting File Version  based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument LIMIT 1];

                       System.debug('objVersion');
                       System.debug(objVersion);

            // split the file data by rows
            List<String> CSVData = objVersion.VersionData.toString().split('\n');
            List<String> headers = CSVData[0].split(',');
            Date queryStart = Date.newInstance(2020, 4, 20);
            Date queryEnd = Date.newInstance(2020, 4, 21);
            String network;
            String checkNumber;
            Date checkDate = null;
            
            //perform index check
            Map<String, Integer> idxMap = CSVUploadHelper.getCheckSheetIndexes(headers);

            airDateIdx = idxMap.get('airDateIdx');
            airTimeIdx = idxMap.get('airTimeIdx');
            adIdIdx = idxMap.get('adIdIdx');
            checkAmtIdx = idxMap.get('checkAmtIdx');
            checkDateIdx = idxMap.get('checkDateIdx');
            checkNumIdx = idxMap.get('checkNumIdx');
            idIdx = idxMap.get('idIdx');
            dbtDateIdx = idxMap.get('dbtDateIdx');
            dbtChkIdx = idxMap.get('dbtChkIdx');
            stationIdx = idxMap.get('stationIdx');
            System.debug('got indexes');

     
            //filters blank rows
            List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);
            System.debug('cleaned csv data');

            Map<String, List<List<String>>> csvDataMap = new Map<String, List<List<String>>>();

            CSVDataMap = CSVUploadHelper.CheckSheetCsvFormatCheck(
                cleanCSVData, 
                airDateIdx, 
                airTimeIdx, 
                adIdIdx, 
                checkNumIdx, 
                checkAmtIdx, 
                checkDateIdx, 
                idIdx,
                dbtDateIdx,
                dbtChkIdx
            ); 
            System.debug('formatted csv check sheet');
            
            for(String key : CSVDataMap.keyset()){
               List<List<String>>  recordData = CSVDataMap.get(key);
                checkDate = CSVUploadHelper.formatDate(recordData[0][checkDateIdx]);
                checkNumber = recordData[0][checkNumIdx];
                network = CSVUploadHelper.getStation(recordData[0][stationIdx]);
               break;
            }
            
    
            //create and insert Check object
            Check__c check = new Check__c();
            check.Program__c = [select id from programs__c where name = :network].id;
            check.CheckDate__c = checkDate; 
            check.Check_Number__c = checkNumber;
            insert check;
            
            //create list of check details
            List<CheckDetail__C> checkDetails = new List<CheckDetail__C>();
            
            For(Integer i = 0; i < cleanCSVData.size(); i++){
                List<String> current = cleanCSVData[i].split(',');
                CheckDetail__C cd = new CheckDetail__c();
                cd.Air_Date__c = CSVUploadHelper.formatDate(current[airDateIdx]);

                if(cd.Air_Date__c < queryStart){
                    queryStart = cd.Air_Date__c;
                }
                if(cd.Air_Date__c > queryEnd){
                    queryEnd = cd.Air_Date__c;
                }
                
                cd.Check_Amount__c = CSVUploadHelper.formatRate(current[checkAmtIdx]);
                cd.Item_Ad_ID__c = current[adIdIdx];
                cd.Air_Time__c = CSVUploadHelper.convertAirTimeToLongForm(current[airTimeIdx]);
                cd.Check__c = check.id;
                cd.CheckId__c = current[idIdx];

                String debitCheck = current[dbtChkIdx];
                if(debitCheck.length() > 2){
                    cd.Debit_Check__c = current[dbtChkIdx];
                    cd.Debit_Date__c = CSVUploadHelper.formatDate(current[dbtDateIdx]);
                }
                checkDetails.add(cd);
           }

            

            //start Check Details attaching 
            CheckDetailScheduleOrganizerWrapper processResults = CheckDetailsAttacher.attachCheckDetails(checkDetails, queryStart, queryEnd, network);            
           
            //create list for discrepant check details
            List<CheckDetail__C> checkDetailsNeedTasks = new List<CheckDetail__C>();

            //check if unmatched check detail has a schedule
            //if so add it to checkDetailsNeedTasks
            For(CheckDetail__C cd : processResults.unmatchedCheckDetailsMaster){
                if(cd.Schedule__C != null){
                    checkDetailsNeedTasks.add(cd);
                }
            }        
            
            results = processResults.unmatchedCheckDetailsMaster;
            If(results.size() > 0){
                //launch task creation class
               // CreateTasks taskCreator = new CreateTasks(processResults);
                //ID jobID = System.enqueueJob(taskCreator);
               // AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
            }
        }
           return results;

    }
        
    
    
    
    
}
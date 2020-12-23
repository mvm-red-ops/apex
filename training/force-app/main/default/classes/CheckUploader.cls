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
            String network = 'CourtTv Mystery PP';
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
    System.debug('indexes:');
    System.debug(airDateIdx);
    System.debug(airDateIdx);
     
            //filters blank rows
		 	List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);

            
            System.debug('cleanCSVData');
            System.debug(cleanCSVData);
            // to do figure out better way to get date
            // format 
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
            
            
            for(String key : CSVDataMap.keyset()){
               List<List<String>>  recordData = CSVDataMap.get(key);
               	checkDate = formatDate(recordData[0][checkDateIdx]);
                checkNumber = recordData[0][checkNumIdx];
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
                cd.Air_Date__c = formatDate(current[airDateIdx]);

                if(cd.Air_Date__c < queryStart){
                    queryStart = cd.Air_Date__c;
                }
                if(cd.Air_Date__c > queryEnd){
                    queryEnd = cd.Air_Date__c;
                }
				
                cd.Check_Amount__c = formatRate(current[checkAmtIdx]);
                cd.Item_Ad_ID__c = current[adIdIdx];
                cd.Air_Time__c = convertAirTimeToLongForm(current[airTimeIdx]);
                cd.Check__c = check.id;
                cd.CheckId__c = current[idIdx];

                String debitCheck = current[dbtChkIdx];
                if(debitCheck.length() > 2){
                    cd.Debit_Check__c = current[dbtChkIdx];
                    cd.Debit_Date__c = formatDate(current[dbtDateIdx]);
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
            
            //launch task creation class
            CreateTasks taskCreator = new CreateTasks(processResults);
            ID jobID = System.enqueueJob(taskCreator);
      	    AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
            System.debug('jobInfo');
            System.debug(jobInfo);

            results = processResults.unmatchedCheckDetailsMaster;
            //pass the unmatched check details to class that creates Tasks and sends email
            //what do we need for each check detail?
            //network, long form, week, rate, 
            //schedule/inv# if we have it, 
            //havas, contact(id, name, email) ,  
            //planner for network (id, name, email)
        }
           return results;

    }
    
    public static Date formatDate(String dateset){
        List<String> dateVals;
        String year;
        String month;
        String day;
        Map<String, String> monthDictionary = new Map<String, String>{
            	'Jan' => '01',
                'Feb' => '02', 
                'Mar' => '03',
                'Apr' => '04',
                'May'=> '05',
                'Jun'=> '06',
                'Jul' => '07',
                'Aug' => '08',
                'Sep' => '09',
                'Oct' => '10',
                'Nov'=> '11',
                'Dec'=> '12'
        };
        
        
        //check if date is - or / seperated
            if(dateset.contains('-')){
        		dateVals = dateset.split('-');
                
            } else {
              	dateVals = dateset.split('/');

            }
      
        if(dateVals[1].length() > 2){
            month = monthDictionary.get(dateVals[1]);
        	day = dateVals[0];
            
        } else {
            month = dateVals[0];
       		day = dateVals[1];
        }
        
        If(month.length() == 1){
            month = '0' + month;
        }
        If(day.length() == 1){
            day = '0' + day;
        }           
        

        if(dateVals[2].length() ==2){
            year = '20' + dateVals[2];
        } else{
            year = dateVals[2];
        }
        
        
        String strWeek = month.trim() + '/' + day.trim() + '/' + year.trim();
        String weekRegex = '^(0[1-9]|1[012])[/](0[1-9]|[12][0-9]|3[01])[/](2019||2020||2021)$';
        Pattern weekPattern = Pattern.compile(weekRegex);
        Matcher weekMatcher = weekPattern.matcher(strWeek);
        Boolean weekMatch = weekMatcher.matches();
       	Date result = Date.parse(strWeek);

        return result;
    }
    
    public static string convertAirTimeToLongForm(string airtime){
        	string longform = '';
            string basetime;
            string ampm;
        	airtime = airtime.trim();

        if(airtime.substring(0,1).contains('0')){
            basetime = airtime.substring(1,5);     
        } else {
            basetime = airtime.substring(0,5);    
        }
            if(airtime.contains('AM')){
                ampm = 'A-';
                    } else {
                        ampm = 'P-';
                    }


            longform = ampm + basetime;

            String longformRegex = '^[A,P]-[0-9]{1}[:.,-][0,3]{1}[0]{1}?$';
            Pattern LongformPattern = Pattern.compile(longformRegex);
            Matcher LongformMatcher = LongformPattern.matcher(longform);
            Boolean lfMatch = LongformMatcher.matches();
			airtime = longform;

        	if(!lfMatch){
                AuraHandledException ex = new AuraHandledException('The LongForm field could not be formatted correctly from the Time column. Please make sure the Time is formatted as 3:00, 3:30, etc.' );
                ex.setMessage('Unformattable longform/time field.');
                throw ex; 
            }           
        return longform;
    }
    
    private static Decimal formatRate(String rate){
        Decimal dRate;
        Boolean negative; 
        rate = rate.trim();

        //check for parentheses
        if(rate.contains('(')){
            rate = rate.substring(1, rate.length() - 1);
            negative = true;
        }
       
        //check for $ sign
        if(rate.contains('$')){
			dRate = Decimal.valueOf(rate.substring(1));
        } else {
			dRate = Decimal.valueOf(rate);
        }        
        
        if(negative == true){
            dRate = 0 - drate;
        }
        return dRate;
    }
    
    
    
    
    
}
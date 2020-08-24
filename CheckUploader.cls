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
            Date checkDate = null;
            
			//perform index check
			Map<String, Integer> idxMap = CSVUploadHelper.getCheckSheetIndexes(headers);

            airDateIdx = idxMap.get('airDateIdx');
            airTimeIdx = idxMap.get('airTimeIdx');
            adIdIdx = idxMap.get('adIdIdx');
            checkAmtIdx = idxMap.get('checkAmtIdx');
            checkDateIdx = idxMap.get('checkDateIdx');
            idIdx = idxMap.get('idIdx');
            dbtDateIdx = idxMap.get('dbtDateIdx');
            dbtChkIdx = idxMap.get('dbtChkIdx');
            stationIdx = idxMap.get('stationIdx');
    
     
            //filters blank rows
		 	List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);

            
            
            // to do figure out better way to get date
            // format 
			Map<String, List<List<String>>> csvDataMap = new Map<String, List<List<String>>>();
            System.debug('clean checks: ');
            System.debug(cleanCSVData);
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
            
            System.debug('formatted all checks');
            
            for(String key : CSVDataMap.keyset()){
 
               List<List<String>>  recordData = CSVDataMap.get(key);
                System.debug('recordData');
                System.debug(recordData);
                System.debug(recordData[0]);
                System.debug(recordData[0][checkDateIdx]);
               	checkDate = formatDate(recordData[0][checkDateIdx]);
                
               break;
            }
            
    
            
            //create check 
            	//check date
            	//network (station)
            	
            Check__c check = new Check__c();
            check.Program__c = [select id from programs__c where name = :network].id;
            check.CheckDate__c = checkDate; 
       
            insert check;
            
            //create list of check details
            List<CheckDetail__C> checkDetails = new List<CheckDetail__C>();
            
            For(Integer i = 0; i < cleanCSVData.size(); i++){
                List<String> current = cleanCSVData[i].split(',');
                CheckDetail__C cd = new CheckDetail__c();
                    System.debug('formatting air date...');
                cd.Air_Date__c = formatDate(current[airDateIdx]);
                	System.debug('check detail');
                if(cd.Air_Date__c < queryStart){
                    queryStart = cd.Air_Date__c;
                }
                if(cd.Air_Date__c > queryEnd){
                    queryEnd = cd.Air_Date__c;
                }
                                	System.debug(cd);

                cd.Check_Amount__c = Decimal.valueOf(current[checkAmtIdx]);
                cd.Item_Ad_ID__c = current[adIdIdx];
                //fix air time
                //should it be modeled after long form?
                cd.Air_Time__c = convertAirTimeToLongForm(current[airTimeIdx]);
                cd.Check__c = check.id;
                cd.CheckId__c = current[idIdx];
                                	System.debug(cd);

                String debitCheck = current[dbtChkIdx];
                if(debitCheck.length() > 2){
                    cd.Debit_Check__c = current[dbtChkIdx];
                    System.debug('formatting debit date...');
                    cd.Debit_Date__c = formatDate(current[dbtDateIdx]);
                }
                checkDetails.add(cd);
           }

            
            //start attaching Check_Details__c to Schedules__C
           results = CheckDetailsAttacher.attachCheckDetails(checkDetails, queryStart, queryEnd, network);            
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
    
    
    
    
    
}

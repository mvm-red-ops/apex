public with sharing class CSVUploadHelper {
    public CSVUploadHelper(){}
    
    public static Map<String, Integer> getBAIndexes(List<String> headers){
        Map<String, Integer> idxMap = new Map<String, Integer>();
        for(Integer i = 0; i < headers.size(); i++){
            String current = headers[i];
           
            if(current.indexOf('Show Title') != -1 ){
             idxMap.put('showTitleIdx', i);
             System.debug('put show');
            }            
            else if(current.indexOf('Gross') != -1 ){
             idxMap.put('rateIdx', i);
             System.debug('put rate');
            }            
            else if(current.indexOf('Phone #') != -1 ){
             idxMap.put('phoneIdx', i);
           	 System.debug('put phone');
            }            
            else if(current.indexOf('Date') != -1 ){
             idxMap.put('weekIdx', i);
           	 System.debug('put date');
            }            
            else if(current.indexOf('ISCI #') != -1 ){
             idxMap.put('isciIdx', i);
           	 System.debug('put isci');
            }            
            else if(current.indexOf('Time') != -1 ){
             idxMap.put('longformIdx', i);
           	 System.debug('put lf');
            } 
            else{
                System.debug('index not found');
            }
        }
        return idxMap;
    }
    
public static Map<String, Integer> getCheckSheetIndexes(List<String> headers){
        Map<String, Integer> idxMap = new Map<String, Integer>();
            

        //entit station	airdate	airtime	itemidadd	checkno	checkamt	checkdate	debit_chck	debit_date	vdrategr	id
        for(Integer i = 0; i < headers.size(); i++){
            String current = headers[i];
            
            if(current.indexOf('airdate') != -1 ){
             idxMap.put('airDateIdx', i);
            }            
            else if(current.indexOf('airtime') != -1 ){
             idxMap.put('airTimeIdx', i);
            }            
            else if(current.indexOf('itemidadd') != -1 ){
             idxMap.put('adIdIdx', i);
            }            
            else if(current.indexOf('checkno') != -1 ){
             idxMap.put('checkNumIdx', i);
            }            
            else if(current.indexOf('checkamt') != -1 ){
             idxMap.put('checkAmtIdx', i);
            }            
            else if(current.indexOf('checkdate') != -1 ){
             idxMap.put('checkDateIdx', i);
            } 
            else if(current.indexOf('vdrategr') != -1 ){
             idxMap.put('rateIdx', i);
            } 
            else if(current.indexOf('id') != -1 ){
             idxMap.put('idIdx', i);
            } 
			else if(current.indexOf('station') != -1 ){
             idxMap.put('stationIdx', i);
            } 
            else if(current.indexOf('debit_chck') != -1){
				idxMap.put('dbtChkIdx', i);                 	
            }
			else if(current.indexOf('debit_date') != -1){
				idxMap.put('dbtDateIdx', i);                 	
            }
            else{
                System.debug('index not found');
            }
        }

            Integer headersFound = idxMap.keySet().size();
			Boolean foundAllHeaders = headersFound == headers.size();
            return idxMap;
    }
    
    
   	//not a generalizable method
    public static Map<String, List<String>> BaCsvFormatCheck(list<String> csvData, Integer rateIdx, Integer weekIdx, Integer phoneIdx, Integer isciIdx, Integer longformIdx, Integer showTitleIdx, String dealProgram ){

        //declare map variable which holds unique key with list of record values
        Map<String, List<String>> csvMap = new Map<String, List<String>>();
        
       
        //row data
        List<List<String>> recordData = new List<List<String>>();
        
        //iterate through csv records
        for(Integer i = 0; i < CSVData.size(); i++){
             
            //set variable for current row
            List<String> current = CSVData[i].split(',');
   
            String year;
            String month;
            String day;
            
            //format the week field 
            try{
                List<String> dateVals = current[weekIdx].split('/');
                System.debug('date values: ');
                System.debug(dateVals);
                
                if(dateVals[2].length() ==2){
                	year = '20' + dateVals[2];
                } else{
                  	year = dateVals[2];
                }
                month = dateVals[0];
                day = dateVals[1];
                   
                if(month.length() == 1){
                    month = '0' + month;
                }
                if(day.length() == 1){
                    day = '0' + day;
                }            
            }
            catch(Exception e){
                AuraHandledException ex = new AuraHandledException('The date is not splitting properly. This could be because of commas in the cells. Or it could be that the date is not formatted as mm/dd/yyyy');
                ex.setMessage('Date incorrectly formatted or commas in cells. Should be mm/dd/yyyy.');
                throw ex; 
            }

            if(Integer.valueOf(year) < System.Today().year() - 1 || Integer.valueOf(year) > System.Today().year() + 1){
                AuraHandledException ex = new AuraHandledException('Date misformatted, should be mm-dd-yyyy. Check the year must be in between last year and next year. Please contact your admin.');
                ex.setMessage('The date is either incorrectly formatted or outside the acceptable date range.');
                throw ex; 
            }
            
			
            String strWeek = month.trim() + '/' + day.trim() + '/' + year.trim();
            String weekRegex = '^(0[1-9]|1[012])[/](0[1-9]|[12][0-9]|3[01])[/](2019||2020||2021)$';
            Pattern weekPattern = Pattern.compile(weekRegex);
            Matcher weekMatcher = weekPattern.matcher(strWeek);
            Boolean weekMatch = weekMatcher.matches();

            if(!weekMatch){
               	System.debug('week format error:');
                System.debug(strWeek);
                AuraHandledException ex = new AuraHandledException('The Week field could not be formatted correctly. Please make sure it is in mm/dd/yyyy format.');
                ex.setMessage('Unformattable week field.');
                throw ex; 
            }
            
            current[weekIdx] = strWeek;
            String isci = current[isciIdx];
            String rate = current[rateIdx];
            
            
            String longform = String.valueOf(current[longformIdx]).trim();
            String longformRegex = '^(10|11|12|[1-9])[:.,-][0,3]{1}[0]{1}?$';
            ///^(10|11|12|[1-9]):[0-5][0-9]$/

            Pattern LongformPattern = Pattern.compile(longformRegex);
            Matcher LongformMatcher = LongformPattern.matcher(longform);
            Boolean lfMatch = LongformMatcher.matches();

            if(!lfMatch){
              	longform = longform.substring(1);
                longformRegex = '^[0-9]{1}[:.,-][0,3]{1}[0]{1}?$';
                LongformPattern = Pattern.compile(longformRegex);
                LongformMatcher = LongformPattern.matcher(longform);
                lfMatch = LongformMatcher.matches();
                if(!lfMatch){
                    System.debug('longform format error:');
                    System.debug(longform);
                    AuraHandledException ex = new AuraHandledException('The LongForm field could not be formatted correctly from the Time column. Please make sure the Time is formatted as 3:00, 3:30, etc.' );
                    ex.setMessage('Unformattable longform/time field.');
                    throw ex; 
                }

            }           
            
            
            String hour = longform.split(':')[0];
            System.debug('hour/lf');
            System.debug(hour);
            System.debug(longform);

            if(hour.length() == 1){
                longform = 'A-' + longform;
            } else {
                if(hour == '12'){
                     longform ='P-' + longform;
                } else {
                    longform ='A-' + longform;
                }
            }
            
            System.debug(longform);
            
            String showtitle = current[showTitleIdx];
            String phone = current[phoneIdx];              
            
            String key = strWeek + ' ' + longform + ' ' + dealProgram;
            if(key.length() <= 17){
                System.debug('key format error:');
                System.debug(key);
                AuraHandledException keyFormatError = new AuraHandledException('The unique key could not be formatted correctly. Please contact your admin.');
                keyFormatError.setMessage('Unformattable key.');
                throw keyFormatError;    
            }
            
            //check for duplicate sched
            if(csvMap.keySet().contains(key)){
                System.debug('unique key already exists in map:');
                System.debug(key);
                AuraHandledException dupKeyError = new AuraHandledException('There are multiple schedules with the same week and longform values: '+  strWeek + ' , ' + longform + '. Please make sure there is only one schedule per week and time period, or contact your admin.');
                dupKeyError.setMessage('Duplicate key.');
                throw dupKeyError;     
            } else {
                csvMap.put(key, current);
                recordData.add(current);	   
            }
                
        }
        
        return csvMap;
    }
    
    //not a generalizable method
    public static Map<String, List<List<String>>> CheckSheetCsvFormatCheck(
        List<String> csvData, 
        Integer airDateIdx, 
        Integer airTimeIdx, 
        Integer adIdIdx, 
        Integer checkNumIdx, 
        Integer checkAmtIdx, 
        Integer checkDateIdx, 
        Integer idIdx,
        Integer dbtDateIdx,
        Integer dbtChkIdx
    ){
            
        //declare map variable which holds unique key with list of record values
        Map<String, List<List<String>>> csvMap = new Map<String, List<List<String>>>();
               
        //iterate through csv records
        for(Integer i = 0; i < CSVData.size(); i++){
            
            //set variable for current row
            List<String> current = CSVData[i].split(',');
   

            //format the week field 
            List<String> formattedDates =  dateParser(current[airDateIdx]);
            
            current[airDateIdx] = formattedDates[0];
            String strWeek = formattedDates[1];
            

            String rate = current[checkAmtIdx];

			string longform = '';
            string basetime = current[airTimeIdx].trim().substring(1,5);     
            string ampm;
            if(current[airTimeIdx].contains('AM')){
                ampm = 'A-';
                    } else {
                        ampm = 'P-';
                    }
        
            longform = ampm + basetime;
            String longformRegex = '^[A,P]-[0-9]{1}[:.,-][0,3]{1}[0]{1}?$';
            Pattern LongformPattern = Pattern.compile(longformRegex);
            Matcher LongformMatcher = LongformPattern.matcher(longform);
            Boolean lfMatch = LongformMatcher.matches();
			current[airTimeIdx] = longform;
            
            if(!lfMatch){
                System.debug('longform format error:');
                System.debug(longform);
                AuraHandledException ex = new AuraHandledException('The LongForm field could not be formatted correctly from the Time column. Please make sure the Time is formatted as 3:00, 3:30, etc.' );
                ex.setMessage('Unformattable longform/time field.');
                throw ex; 
            }           

            String fatKey = strWeek + '-' + longform;
            String key = fatKey.trim();
 
            if(key.length() != 17){
                System.debug('key format error:');
                System.debug(key);
                AuraHandledException keyFormatError = new AuraHandledException('The unique key could not be formatted correctly. Please contact your admin.');
                keyFormatError.setMessage('Unformattable key.');
                throw keyFormatError;    
            }
            
            //check for duplicate sched
            if(csvMap.keySet().contains(key)){
                csvMap.get(key).add(current);
            } else {
                List<List<String>> firstEntry = new List<List<String>>();
                firstEntry.add(current);
                csvMap.put(key, firstEntry);
            }
                
        }
 
        List<string> test = new List<String>(csvMap.keySet());
        return csvMap;
    }
        
    public static List<String> cleanBlanks(List<String> csvRows){
        
        List<String> cleanedRows = new List<String>();
         
		//check header
		String header = csvRows[0];
        List<String> valArray = header.split(',');
        String trueHeaderContent = String.join(valArray, '').trim();

        if(trueHeaderContent.length() <= 10){
         	FormattingException headerError = new FormattingException('Hey! Looks like the file you uploaded is missing headers (we expect them in the first row!) Please make sure the headers are the first line of Excel sheet. If they already are, please reach out to your admin!');
			throw headerError;
        }
            
        //check rows for data and commas
        for(Integer i = 1; i < csvRows.size(); i++){
			//get current row 
			String current = csvRows[i];
            
           	//control for quotation marks which indicates an extra comma
            String cleanCurrent = '';
            Boolean inQuote = false;
            List<string> currentVals = current.split('');
            For(String s : currentVals){
                if(s == '"'){
                    inQuote = !inQuote;
                    continue;
                }
                
                if(inQuote == true){
                    if(s == ','){
                        continue;
                    } else {
                        cleanCurrent += s;
                    }
                } else {
                    cleanCurrent += s;
                    
                }
            }


            List<String> currArray = cleanCurrent.split(',');
        	String currentContent = String.join(currArray, '').trim();

			//control for blanks
            if(currentContent.length() < 25){
              continue;
            } 
            else {
           	  cleanedRows.add(cleanCurrent);
            }
        }
        
        
        if(cleanedRows.size() == 0){
            FormattingException formattingError = new FormattingException('Hey! Looks like the file you uploaded doesnt contain any data! If this isnt true, please reach out to your admin!');
            throw formattingError;
        }
        return cleanedRows;
     }
                                                    
                                                    
    
    //not a generalizable method
    public static void finalFormatCheck(List<Map<String, Map<String, List<String>>>> scheds){
        FormattingException formattingError = new FormattingException();
            System.debug('final formatting check');

        for(Integer i = 0; i < scheds.size(); i++){
          	System.debug('current:');
          	System.debug(scheds[i]);

            Map<String, List<String>>vals = new  Map<String, List<String>>();

			System.debug('final format check: ');
            try{
            	vals = scheds[i].values()[0];
                System.debug('vals:');
                System.debug(vals);
            }
            catch(Exception e){
                AuraHandledException ex = new AuraHandledException('Sorry! There may be blank schedules in the BA that are messing up the program. If there are, please remove them and reupload. If not, contact your admin.' + e.getMessage());
                ex.setMessage('Values missing from scheds.' + e.getMessage());
                throw ex;
            }
            
            Integer isciValList = vals.get('isci').size();
         	Integer phoneValList = vals.get('phone').size();
            Integer rateValList = vals.get('rate').size();

            if(isciValList == 0){
             FormattingException isciError = new FormattingException('Sorry! We cant locate the ISCIs! Please contact your admin.');
             throw formattingError;
            }
            if(phoneValList == 0){
             FormattingException phoneError = new FormattingException('Sorry! The program broke!! We cant locate the 800 numbers! Please contact your admin.');
             throw formattingError;
            }
            if(rateValList == 0){
             FormattingException rateError = new FormattingException('Sorry! The program broke!! We cant locate the rates! Please contact your admin.');
             throw formattingError;
            }

        }
   
    }

                                                    
                                                    
    


                                                    
    public static List<String> dateParser(String dateString){
            String year;
            String month;
            String day;
            List<String> dateVals;
            List<String> results = new List<String>();

            try{
                //if date is formatted like 04-04-2020 or 04-04-20
                if(dateString.contains('-')){
                    //datevals becomes [04,04,2020] or [04,04,20]
                    dateVals = dateString.split('-');

                 //if date is formatted like 04/20/2020 or  4/20/20
                } else if (dateString.contains('/')){
                    dateVals = dateString.split('/');
                  
                } else {
                    FormattingException dateFormatError = new FormattingException('Sorry! The date is not formatted in a recognizable way.');
                     throw dateFormatError;
                }
                
                
                //convert 2 digit year to 4 digits
                if(dateVals[2].length() ==2){
                    year = '20' + dateVals[2];
                } else if(dateVals[2].length() == 4){
                    year = dateVals[2].trim();
                } else {
                    //year is neither 2 or 4 digits
                    FormattingException yearFormatError = new FormattingException('Sorry! The year in the date is not a 2 or 4 digit year.');
                    throw yearFormatError;
                }
                month = dateVals[0].trim();
                day = dateVals[1].trim();
                
                If(month.length() == 1){
                    month = '0' + month;
                }
                If(day.length() == 1){
                    day = '0' + day;
                }    
                
                //check date in acceptable range 
                if(Integer.valueOf(year) < System.Today().year() - 1 || Integer.valueOf(year) > System.Today().year() + 1){
                    System.debug('year out of range:');
                    System.debug(year);
                    AuraHandledException ex = new AuraHandledException('The date is either incorrectly formatted or outside the acceptable date range.');
                    ex.setMessage('The date is either incorrectly formatted or outside the acceptable date range.');
                    throw ex; 
                }

                
                //check week matches regular expression for SF dates
                String strWeek = month.trim() + '/' + day.trim() + '/' + year.trim();
                String weekRegex = '^(0[1-9]|1[012])[/](0[1-9]|[12][0-9]|3[01])[/](2019||2020||2021)$';
                Pattern weekPattern = Pattern.compile(weekRegex);
                Matcher weekMatcher = weekPattern.matcher(strWeek);
                Boolean weekMatch = weekMatcher.matches();
                if(!weekMatch){
                    AuraHandledException ex = new AuraHandledException('The Week field could not be formatted correctly. Please make sure it is in mm/dd/yyyy format.');
                    ex.setMessage('Unformattable week field.');
                    throw ex; 
                }
                
                String newDate = year + '-' + month + '-' + day;

                results.add(newDate);
                results.add(strWeek);
                return results;
            }
            
            catch(Exception e){
                AuraHandledException ex = new AuraHandledException('The indexes arent lining up properly. Please remove any commas in cell values of the CSV.');
                ex.setMessage('Likely commas in cells.');
                throw ex; 
            }        
        

    }
    
  
}
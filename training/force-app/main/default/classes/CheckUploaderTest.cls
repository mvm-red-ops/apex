@isTest 
public class CSVUploadHelperTest {
        
    @testSetup static void setup() {
        String str = 'Buyer,Show Title,Market,Station,Payee,Phone #,Day,Date,Time,Gross,PW Contact,ISCI #\n CH,KERANIQUE V119,DIGINET,MYSTERY,MARMYSTERY,800-460-7415,TU,5/1/20,3:00,1100,Brett LaFlamme,1003510197H';       
        String[] csvFileLines;
        Blob csvFileBody;
        
        //create working buy analysis
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Buy Analysis',
            PathOnClient = 'Test.csv',
            VersionData = csvFileBody,
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        
                
        //create bad format week buy analysis
        String strBadDate = 'Buyer,Show Title,Market,Station,Payee,Phone #,Day,Date,Time,Gross,PW Contact,ISCI #\n CH,KERANIQUE V119,DIGINET,MYSTERY,MARMYSTERY,800-460-7415,TU,2020/5/1,3:00,1100,Brett LaFlamme,1003510197H';       
        String[] csvFileLinesBadDate;
        Blob csvFileBodyBadDate;        
        
        csvFileBodyBadDate = Blob.valueOf(strBadDate);
        String csvAsStringBadDate = csvFileBodyBadDate.toString();
        csvFileLinesBadDate = csvAsStringBadDate.split('\n'); 
        ContentVersion badDate = new ContentVersion(
            Title = 'Bad Date',
            PathOnClient = 'Test.csv',
            VersionData = csvFileBodyBadDate,
            IsMajorVersion = true
        );
        insert badDate;
        
        
        //create bad format2 week buy analysis
        String strBadDate2 = 'Buyer,Show Title,Market,Station,Payee,Phone #,Day,Date,Time,Gross,PW Contact,ISCI #\n CH,KERANIQUE V119,DIGINET,MYSTERY,MARMYSTERY,800-460-7415,TU,5-1-20,3:00,1100,Brett LaFlamme,1003510197H';       
        String[] csvFileLinesBadDate2;
        Blob csvFileBodyBadDate2;        
        
        csvFileBodyBadDate2 = Blob.valueOf(strBadDate2);
        String csvAsStringBadDate2 = csvFileBodyBadDate2.toString();
        csvFileLinesBadDate2 = csvAsStringBadDate2.split('\n'); 
        ContentVersion badDate2 = new ContentVersion(
            Title = 'Bad Date2',
            PathOnClient = 'Test.csv',
            VersionData = csvFileBodyBadDate2,
            IsMajorVersion = true
        );
        insert badDate2;
        
                
        //create commas in cell buy analysis
        String strCommas = 'Buyer,Show Title,Market,Station,Payee,Phone #,Day,Date,Time,Gross,PW Contact,ISCI #\n CH,KER,ANIQUE V119,DIGINET,MYSTERY,MARMYSTERY,800-460-7415,TU,2020/5/1,3:00,1100,Brett LaFlamme,1003510197H';       
        String[] csvFileLinesCommas;
        Blob csvFileBodyCommas;        
        
        csvFileBodyCommas = Blob.valueOf(strCommas);
        String csvAsStringCommas = csvFileBodyCommas.toString();
        csvFileLinesCommas = csvAsStringCommas.split('\n'); 
        ContentVersion commasCSV = new ContentVersion(
            Title = 'Commas',
            PathOnClient = 'Test.csv',
            VersionData = csvFileBodyCommas,
            IsMajorVersion = true
        );
        insert commasCSV;
        
        
        //create check csv
        String checkStr = 'entity,refnum,station,airdate,airtime,itemidadd,checkno,checkamt,checkdate,debit_chck,debit_date,vdrategr,id\n MARMYSTERY,83017927,MYSTERY,5-1-20, 03:00 AM,BLINK A 199 V1,1024384,100,10-Apr-20,0, -   -,100,630324063';       
        String[] checkFileLines;
        Blob checkFileBody;
        
        //create csv
        checkFileBody = Blob.valueOf(checkStr);
        String checkCsvAsString = checkFileBody.toString();
        checkFileLines = checkCsvAsString.split('\n'); 
        ContentVersion checkContentInsert = new ContentVersion(
            Title = 'Check CSV',
            PathOnClient = 'Test.csv',
            VersionData = checkFileBody,
            IsMajorVersion = true
        );
        insert checkContentInsert;
        
        
        //create bad long form week buy analysis
        String badLongForm = 'Buyer,Show Title,Market,Station,Payee,Phone #,Day,Date,Time,Gross,PW Contact,ISCI #\n CH,KERANIQUE V119,DIGINET,MYSTERY,MARMYSTERY,800-460-7415,TU,05/01/20,13:10,1100,Brett LaFlamme,1003510197H';       
        String[] csvFileLinesBadLongForm;
        Blob csvFileBodyBadLongForm;        
        
        csvFileBodyBadLongForm = Blob.valueOf(BadLongForm);
        String csvAsStringBadLongForm = csvFileBodyBadLongForm.toString();
        csvFileLinesBadLongForm = csvAsStringBadLongForm.split('\n'); 
        ContentVersion BadLongFormContent = new ContentVersion(
            Title = 'Bad Long Form',
            PathOnClient = 'Test.csv',
            VersionData = csvFileBodyBadLongForm,
            IsMajorVersion = true
        );
        insert BadLongFormContent;
    }
     
    @isTest
    static void testBAHeaders() {
        ContentVersion document = [SELECT Id, VersionData FROM ContentVersion WHERE title = 'Buy Analysis' LIMIT 1];
        List<String> CSVData = document.VersionData.toString().split('\n');
        List<String> headers = CSVData[0].split(',');
        system.debug(CSVData);
        Map<String, Integer> idxMap = CSVUploadHelper.getBAIndexes(headers);
        //check that all headers are there
        try{ 
            Integer rateIdx = idxMap.get('rateIdx');
 			Integer weekIdx = idxMap.get('weekIdx');
 			Integer phoneIdx = idxMap.get('phoneIdx');
 			Integer isciIdx = idxMap.get('isciIdx');
 			Integer longformIdx = idxMap.get('longformIdx');
 			Integer showTitleIdx = idxMap.get('showTitleIdx');
        } catch(Exception e){
            throw(e);
        }
    }
    
    @isTest
    static void testCheckHeaders() {
        ContentVersion document = [SELECT Id, VersionData FROM ContentVersion WHERE title = 'Check CSV' LIMIT 1];
        List<String> CSVData = document.VersionData.toString().split('\n');
        List<String> headers = CSVData[0].split(',');

        Map<String, Integer> idxMap = CSVUploadHelper.getCheckSheetIndexes(headers);
        //check that all headers are there
        try{ 
			Integer airDateIdx = idxMap.get('airDateIdx');
            Integer airTimeIdx = idxMap.get('airTimeIdx');
            Integer adIdIdx = idxMap.get('adIdIdx');
            Integer checkAmtIdx = idxMap.get('checkAmtIdx');
            Integer checkDateIdx = idxMap.get('checkDateIdx');
            Integer idIdx = idxMap.get('idIdx');
            Integer dbtDateIdx = idxMap.get('dbtDateIdx');
            Integer dbtChkIdx = idxMap.get('dbtChkIdx');
            Integer stationIdx = idxMap.get('stationIdx');
            Integer checkNumIdx = idxMap.get('checkNumIdx');   
        } catch(Exception e){
            throw(e);
        }
    }
    
    @isTest
    static void testBAFormatter(){
        ContentVersion document = [SELECT Id, VersionData FROM ContentVersion WHERE title = 'Buy Analysis' LIMIT 1];
        List<String> CSVData = document.VersionData.toString().split('\n');
        List<String> headers = CSVData[0].split(',');
        Map<String, Integer> idxMap = CSVUploadHelper.getBAIndexes(headers);
        List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);
        Integer rateIdx = idxMap.get('rateIdx');
        Integer weekIdx = idxMap.get('weekIdx');
        Integer phoneIdx = idxMap.get('phoneIdx');
        Integer isciIdx = idxMap.get('isciIdx');
        Integer longformIdx = idxMap.get('longformIdx');
        Integer showTitleIdx = idxMap.get('showTitleIdx'); 
        String dealProgram = 'CourtTv Mystery PP';
        Map<String, List<String>> CSVDataMap = CSVUploadHelper.BaCsvFormatCheck(cleanCSVData, rateIdx, weekIdx, phoneIdx, isciIdx, longformIdx, showTitleIdx, dealProgram); 
    	System.assertEquals(1, CSVDataMap.keySet().size());
    }
    
    @isTest
    static void testCheckFormatter(){
        ContentVersion document = [SELECT Id, VersionData FROM ContentVersion WHERE title = 'Check CSV' LIMIT 1];
        List<String> CSVData = document.VersionData.toString().split('\n');
        List<String> headers = CSVData[0].split(',');
        Map<String, Integer> idxMap = CSVUploadHelper.getCheckSheetIndexes(headers);
        List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);
        Integer airDateIdx = idxMap.get('airDateIdx');
        Integer airTimeIdx = idxMap.get('airTimeIdx');
        Integer adIdIdx = idxMap.get('adIdIdx');
        Integer checkAmtIdx = idxMap.get('checkAmtIdx');
        Integer checkDateIdx = idxMap.get('checkDateIdx');
        Integer idIdx = idxMap.get('idIdx');
        Integer dbtDateIdx = idxMap.get('dbtDateIdx');
        Integer dbtChkIdx = idxMap.get('dbtChkIdx');
        Integer stationIdx = idxMap.get('stationIdx');
        Integer checkNumIdx = idxMap.get('checkNumIdx');   
        String dealProgram = 'CourtTv Mystery PP';
        Map<String, List<List<String>>> csvDataMap = CSVUploadHelper.CheckSheetCsvFormatCheck(
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
    	System.assertEquals(1, CSVDataMap.keySet().size());
    }
    
    @isTest static void testBadDateBA() {
      
        ContentVersion document = [SELECT Id, VersionData FROM ContentVersion WHERE title = 'Bad Date' LIMIT 1];
        List<String> CSVData = document.VersionData.toString().split('\n');
        List<String> headers = CSVData[0].split(',');
        Map<String, Integer> idxMap = CSVUploadHelper.getBAIndexes(headers);
        List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);
        Integer rateIdx = idxMap.get('rateIdx');
        Integer weekIdx = idxMap.get('weekIdx');
        Integer phoneIdx = idxMap.get('phoneIdx');
        Integer isciIdx = idxMap.get('isciIdx');
        Integer longformIdx = idxMap.get('longformIdx');
        Integer showTitleIdx = idxMap.get('showTitleIdx'); 
        String dealProgram = 'CourtTv Mystery PP';
        String exceptionReason;
        
        try {
        	Map<String, List<String>> CSVDataMap = CSVUploadHelper.BaCsvFormatCheck(cleanCSVData, rateIdx, weekIdx, phoneIdx, isciIdx, longformIdx, showTitleIdx, dealProgram);
        }
        catch (Exception e) {
            exceptionReason = e.getMessage();
            System.debug('exception: ');
            System.debug(e);
            System.debug(e.getMessage());
        }
        
		system.assertEquals('The date is either incorrectly formatted or outside the acceptable date range.', exceptionReason, 'exceptions handled by class.');
    }
    
    @isTest static void testBadDate2BA() {
      
        ContentVersion document = [SELECT Id, VersionData FROM ContentVersion WHERE title = 'Bad Date2' LIMIT 1];
        List<String> CSVData = document.VersionData.toString().split('\n');
        List<String> headers = CSVData[0].split(',');
        Map<String, Integer> idxMap = CSVUploadHelper.getBAIndexes(headers);
        List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);
        Integer rateIdx = idxMap.get('rateIdx');
        Integer weekIdx = idxMap.get('weekIdx');
        Integer phoneIdx = idxMap.get('phoneIdx');
        Integer isciIdx = idxMap.get('isciIdx');
        Integer longformIdx = idxMap.get('longformIdx');
        Integer showTitleIdx = idxMap.get('showTitleIdx'); 
        String dealProgram = 'CourtTv Mystery PP';
        String exceptionReason;
        
        try {
        	Map<String, List<String>> CSVDataMap = CSVUploadHelper.BaCsvFormatCheck(cleanCSVData, rateIdx, weekIdx, phoneIdx, isciIdx, longformIdx, showTitleIdx, dealProgram);
        }
        catch (Exception e) {
            exceptionReason = e.getMessage();
            System.debug('exception: ');
            System.debug(e);
            System.debug(e.getMessage());
        }
        
		system.assertEquals('Date incorrectly formatted or commas in cells. Should be mm/dd/yyyy.', exceptionReason, 'exceptions handled by class.');
    }   
        
    @isTest static void testCommasBA() {
       
        ContentVersion document = [SELECT Id, VersionData FROM ContentVersion WHERE title = 'Commas' LIMIT 1];
        List<String> CSVData = document.VersionData.toString().split('\n');
        List<String> headers = CSVData[0].split(',');
        Map<String, Integer> idxMap = CSVUploadHelper.getBAIndexes(headers);
        List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);
        Integer rateIdx = idxMap.get('rateIdx');
        Integer weekIdx = idxMap.get('weekIdx');
        Integer phoneIdx = idxMap.get('phoneIdx');
        Integer isciIdx = idxMap.get('isciIdx');
        Integer longformIdx = idxMap.get('longformIdx');
        Integer showTitleIdx = idxMap.get('showTitleIdx'); 
        String dealProgram = 'CourtTv Mystery PP';
        String exceptionReason;
         
        try {
        	Map<String, List<String>> CSVDataMap = CSVUploadHelper.BaCsvFormatCheck(cleanCSVData, rateIdx, weekIdx, phoneIdx, isciIdx, longformIdx, showTitleIdx, dealProgram);
        }
        catch (Exception e) {
            exceptionReason = e.getMessage();
            System.debug('exception: ');
            System.debug(e);
            System.debug(e.getMessage());
        }
        
		system.assertEquals('Date incorrectly formatted or commas in cells. Should be mm/dd/yyyy.', exceptionReason, 'exceptions handled by class.');
    }
    
    
    //long form 

    @isTest static void testBadLongForm() {
       
        ContentVersion document = [SELECT Id, VersionData FROM ContentVersion WHERE title = 'Bad Long Form' LIMIT 1];
        List<String> CSVData = document.VersionData.toString().split('\n');
        List<String> headers = CSVData[0].split(',');
        Map<String, Integer> idxMap = CSVUploadHelper.getBAIndexes(headers);
        List<String> cleanCSVData = CSVUploadHelper.cleanBlanks(CSVData);
        Integer rateIdx = idxMap.get('rateIdx');
        Integer weekIdx = idxMap.get('weekIdx');
        Integer phoneIdx = idxMap.get('phoneIdx');
        Integer isciIdx = idxMap.get('isciIdx');
        Integer longformIdx = idxMap.get('longformIdx');
        Integer showTitleIdx = idxMap.get('showTitleIdx'); 
        String dealProgram = 'CourtTv Mystery PP';
        String exceptionReason;
         
        try {
        	Map<String, List<String>> CSVDataMap = CSVUploadHelper.BaCsvFormatCheck(cleanCSVData, rateIdx, weekIdx, phoneIdx, isciIdx, longformIdx, showTitleIdx, dealProgram);
        }
        catch (Exception e) {
            exceptionReason = e.getMessage();
            System.debug('exception: ');
            System.debug(e);
            System.debug(e.getMessage());
        }
        
		system.assertEquals('Unformattable longform/time field.', exceptionReason, 'exceptions handled by class.');
    }
    
    
    //final format check
    @isTest static void testFinalFormattingCheck() {
        String schedId = '123abc';
       
		Map<String, List<String>> fieldMap = new Map<String, List<String>>();
        //make isci entry
        List<String> isciList = new List<String>{'1234'};
        fieldMap.put('isci', isciList);
        
        //make phone entry
        List<String> phoneList = new List<String>{'123-4213'};
        fieldMap.put('phone', phoneList);
         
        //make longform entry
        List<String> lfList = new List<String>{'a-3:00'};
        fieldMap.put('longform', lfList);
                       
        //make rate entry
        List<String> rateList = new List<String>{'400'};
        fieldMap.put('rate', rateList);
                        
        //make showtitle entry
        List<String> showtitleList = new List<String>{'ABC show'};
        fieldMap.put('showtitle', showtitleList);
                        
        //make week entry
        List<String> weekList = new List<String>{'03/12/1993'};
        fieldMap.put('week', weekList);
                        
        //make match entry
        List<String> matchList = new List<String>{'true'};
        fieldMap.put('matched', matchList);

        Map<String, Map<String, List<String>>> test = new Map<String, Map<String, List<String>>>();
        
        test.put(schedId, fieldMap);
        
        List<Map<String, Map<String, List<String>>>> scheds = new List<Map<String, Map<String, List<String>>>>();
        scheds.add(test);
        
        CSVUploadHelper.finalFormatCheck(scheds);
                         
    }
    
}
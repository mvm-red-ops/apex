@isTest 
public class CSVUploaderHelperTest {
        
    @testSetup static void setup() {
        String str = 'Buyer,Show Title,Market,Station,Payee,Phone #,Day,Date,Time,Gross,PW Contact,ISCI #\n CH,KERANIQUE V119,DIGINET,MYSTERY,MARMYSTERY,800-460-7415,TU,5/1/20,3:00,1100,Brett LaFlamme,1003510197H';       
        String[] csvFileLines;
        Blob csvFileBody;
        
        //create buy analysis
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
        system.debug(CSVData);
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
}

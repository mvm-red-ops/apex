@isTest 
public class InvoiceNumberSpotDataMatchBatchTest 
{
    static testMethod void testBatch() 
    {
        List<Spot_Data__c> spotList= new List<Spot_Data__c>();
        String spotdateString = '3/5/2020';
        date spotdate = date.parse(spotdateString);
         
        TestDataFactory.createSchedule(null, spotdate.addDays(-3), true);
        Schedules__c sched = [SELECT id FROM Schedules__c LIMIT 1][0];

        for(Integer i=0 ;i <100;i++)
        {
            Spot_Data__c spot = new Spot_Data__c();
            spot.Air_Date__c  = spotdate;
            spot.Raycom_Order_Number__c = '12345';
            spot.Schedule__c = sched.Id;
            spotList.add(spot);
        }
        
        insert spotList;
        
        Test.startTest();
        
            Date startDate = Date.parse('03/04/2020');
            Date endDate= Date.parse('03/06/2020');
            Map<String, String> flag = new Map<String, String>{'flag'=> '-3'};
            Map<String, String> order = new Map<String, String>{'order'=> '12345'};
            Map<String, String> invoice = new Map<String, String>{'invoice'=> '12345-3'};
			List<Map<String, String>> orderVals = new List<Map<String, String>>{flag, order, invoice};
        	Map<String, List<Map<String, String>>> orderMap = new Map<String, List<Map<String, String>>>();
        	List<String> orderNums = new List<String>{'12345'};
        	orderMap.put('12345', orderVals);
            String query = 'select id, Air_Date__c, Raycom_Order_Number__c, Raycom_Invoice_Number__c  FROM spot_data__c WHERE schedule__r.DealProgram__c LIKE \'%Gray%\' AND Air_Date__c >= 2020-02-01 AND Air_Date__c <= 2020-02-29 AND Raycom_Order_Number__c =\'12345\' ORDER BY Air_Date__c ASC ';
            InvoiceNumberSpotDataBatch invBatch = new InvoiceNumberSpotDataBatch(query, orderMap,orderNums, startDate, endDate);
			Database.executeBatch(invBatch);  
            
        Test.stopTest();
    }
}

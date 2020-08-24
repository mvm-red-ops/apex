@isTest
public class InvoiceSpotDataMatchUploaderTest {
    
    @isTest
      public static void testCreate() {
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
        ContentVersion cv = new ContentVersion();
          cv.Title = 'Test Data';
          cv.PathOnClient = 'test.csv';
          cv.VersionData = Blob.valueOf('Invoice Number, Start Date, End Date, Order Number \n 1494067-3, 3/4/20, 3/6/20, 1494067');
          cv.IsMajorVersion = true;
 
        insert cv;
		
		Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

        System.debug('conDocId:');
        System.debug(conDocId);

          InvoiceSpotDataMatchUploader.readCSVFile(conDocId, 'COURTTV Mystery PP');
      }
}

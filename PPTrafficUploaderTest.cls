@IsTest
public class PPTrafficUploaderTest {

    @IsTest
    static void testSingleScheduleMatch() {
        //need to create an existing schedule
        //need to create a csv / schedule with different traffic, rate , isci and phone
        //compare values of schedule after update
       	Date schedDate = Date.parse('05/01/2020');
        String longForm = 'A-3:00';
        String str = 'Buyer,Show Title,Market,Station,Payee,Phone #,Day,Date,Time,Gross,PW Contact,ISCI #\n CH,KERANIQUE V119,DIGINET,MYSTERY,MARMYSTERY,800-460-7415,TU,5/1/20,3:00,1100,Brett LaFlamme,1003510197H';       
        String[] csvFileLines;
        Blob csvFileBody;
        
        Test.startTest();
        	//create csv
            csvFileBody = Blob.valueOf(str);
            String csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n'); 
            ContentVersion contentVersionInsert = new ContentVersion(
                    Title = 'CSV Test',
                    PathOnClient = 'Test.csv',
                    VersionData = csvFileBody,
                    IsMajorVersion = true
            );
        	insert contentVersionInsert;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            Id csvId = documents[0].id;
            ContentVersion testDocId = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:documents[0].id][0];

        	//create program, deal and schedule
            Programs__c program = TestDataFactory.createProgram('CourtTv Mystery PP', true);
            Deal__c deal1 = createAvailableDeal(program.Id);
        	Account testAcc = createAccount();
        	Contact testCon = createContact(testAcc.Id);
            Schedules__c availabilitySchedule = createAvailabilitySchedule(deal1.Id, schedDate, longForm);
            insert availabilitySchedule;
            Deal__c deal2 = createAgencyDeal(program.Id);
       		deal2.Contact__c = testCon.id;
        	update deal2;
       
            Schedules__c soldSchedule = createSoldSchedule(deal2.Id, schedDate, longForm, 100);
            insert soldSchedule;
        	

            //run check uploader  
      		List<Map<String, Map<String, List<String>>>> results = PPTrafficUploader.readCSVFile(csvId, 'COURTTV Mystery PP');

			//System.assertEquals(1, results.size());
        Test.stopTest();
        
        //create test csv
    }

    private static Deal__c createAvailableDeal(Id programId) {
        Deal__c deal = TestDataFactory.createDeal('Availability', programId, 'Paid Programming', true);
        return deal;
    }

    private static Deal__c createAgencyDeal(Id programId) {
        Deal__c deal = TestDataFactory.createDeal('Long Form', programId, 'Paid Programming', true);
        return deal;
    }

    private static Schedules__c createAvailabilitySchedule(Id dealId, Date theDate, String longForm) {
        Schedules__c schedule1 = TestDataFactory.createSchedule(dealId, theDate, false);
        schedule1.Long_Form__c = longForm;
        schedule1.Status__c = 'Sold';
        return schedule1;
    }

    private static Schedules__c createSoldSchedule(Id dealId, Date theDate, String longForm, Integer rate) {
        Schedules__c schedule1 = TestDataFactory.createSchedule(dealId, theDate, false);
        schedule1.Long_Form__c = longForm;
        schedule1.Status__c = 'Sold';
        schedule1.Rate__c = rate;
        return schedule1;
    }

    private static Schedules__c getScheduleById(String scheduleId){
        return [SELECT Id, Rate__c, Status__c
                FROM Schedules__c
                WHERE Id = :scheduleId
                LIMIT 1];
    }
    

    public static Contact createContact(Id accountId) {
    
        if (accountId == null) {
            accountId = createAccount().Id;
        }

        Contact con = new Contact(
                LastName = 'test',
                Email = 'test@test.com',
                Phone = '8001234567',
                AccountId = accountId
        );

        insert con;
        return con;
    }



    public static Account createAccount() {
   
        Account acct = new Account(
                Name = 'Havas Edge'
        );

        insert acct;
        return acct;
    }    
}

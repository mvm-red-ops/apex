@isTest 
public class CheckUploaderTest {
    
    @IsTest
    static void testSingleScheduleMatch() {
       	Date schedDate = Date.parse('05/01/2020');
        String longForm = 'A-3:00';
        String str = 'entity,refnum,station,airdate,airtime,itemidadd,checkno,checkamt,checkdate,debit_chck,debit_date,vdrategr,id\n MARMYSTERY,83017927,MYSTERY,5-1-20, 03:00 AM,BLINK A 199 V1,1024384,100,10-Apr-20,0, -   -,100,630324063';       
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
            CheckUploader.readCSV(csvId);
        	List<CheckDetail__C> checkList = [SELECT id FROM CheckDetail__c WHERE Schedule__C != null];
			System.assertEquals(1, checkList.size());
        Test.stopTest();
        
        //create test csv
    }
    
    //test no match
    @IsTest
    static void testNoMatch() {
       	Date schedDate = Date.parse('05/03/2020');
        String longForm = 'A-3:00';
        String str = 'entity,refnum,station,airdate,airtime,itemidadd,checkno,checkamt,checkdate,debit_chck,debit_date,vdrategr,id\n MARMYSTERY,83017927,MYSTERY,5-1-20, 03:00 AM,BLINK A 199 V1,1024384,100,10-Apr-20,0, -   -,100,630324063';       
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
            CheckUploader.readCSV(csvId);
        	List<CheckDetail__C> checkList = [SELECT id FROM CheckDetail__c WHERE Schedule__C != null];
			System.assertEquals(0, checkList.size());
        Test.stopTest();
        
    }

        

    //test multiple matches
    @IsTest
    static void testMultipleMatches() {
       	Date schedDate = Date.parse('05/01/2020');
        String longForm = 'A-3:00';
        String str = 'entity,refnum,station,airdate,airtime,itemidadd,checkno,checkamt,checkdate,debit_chck,debit_date,vdrategr,id\n MARMYSTERY,83017927,MYSTERY,5-1-20, 03:00 AM,BLINK A 199 V1,1024384,100,10-Apr-20,0, -   -,100,630324063\n MARMYSTERY,83017927,MYSTERY,5-1-20, 03:00 AM,BLINK A 199 V1,1024384,-100,10-Apr-20,0, -   -,100,630324063';       
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
            CheckUploader.readCSV(csvId);
        	List<CheckDetail__C> checkList = [SELECT id FROM CheckDetail__c WHERE Schedule__C != null];
        System.debug('checkList');
        System.debug(checkList);
			System.assertEquals(2, checkList.size());
        Test.stopTest();
        
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

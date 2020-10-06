@isTest
public class PPScheduleFinderHelperLWCTest {

	@IsTest
    static void testSingleScheduleMatch() {
        String dealProgram = 'CourtTv Mystery PP';
        Integer dateIdx = 7;
        String key = '01/14/2020 A-4:30 COURTTV Mystery PP';
        List<String> vals = new List<String>{'CH','KERANIQUE V119', 'DIGINET', 'MYSTERY', 'MARMYSTERY', '800-460-7415', 'TU', '01/14/2020', '04:30', '1100.00', 'Brett LaFlamme', '1003510197H'};
       	Date schedDate = Date.parse('01/14/2020');
        String longForm = 'A-4:30';
        
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
        	

        Map<String, List<String>> CSVDataMap = new Map<String, List<String>>();
        CSVDataMap.put(key, vals);
        
        Map<String, Schedules__c> sfScheds = PPScheduleFinderHelperLWC.getSFSchedules(CSVDataMap, dealProgram, dateIdx);
        System.debug(sfScheds);
        System.assertEquals(1, sfScheds.keySet().size());
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
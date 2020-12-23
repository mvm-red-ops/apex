public class CreateTasks implements Queueable  {
    
    List<CheckDetail__c> discrepantCheckDetails;
    Map<Id, Schedules__C> schedMap;
    List<Task> tasksToInsert = new List<Task>(); 

    public CreateTasks(CheckDetailScheduleOrganizerWrapper processResults){
        this.discrepantCheckDetails = getDiscrepantChecks(processResults.unmatchedCheckDetailsMaster);
        this.schedMap = processResults.scheduleRecords;

    }

    public void execute(QueueableContext context) {

        For(CheckDetail__c cd : discrepantCheckDetails){
            System.debug(cd);
         	System.debug(cd.Schedule__c);

             //get schedule 
			System.debug('parentSched');
            Schedules__c parentSched = schedMap.get(cd.Schedule__C);
			System.debug(parentSched);
            //create Task
            Task t = new Task();
            t.OwnerId = parentSched.Deal_Parent__r.Program__r.Lead__c;
            t.Description =  'There is a payment discrepancy that needs attention. Please look into  the following Schedule: https://marathon--training.lightning.force.com/lightning/r/Schedules__c/' + cd.Schedule__C +
                ' . The payment details are as follows air date: ' + cd.Air_Date__c + ', ' + 
                ' air time: ' + cd.Air_Time__c + ', ' +
                ' amount: ' + cd.Check_Amount__c  + ', ' +
                ' check#: ' + cd.Check__c;
            t.RecordTypeId = '0123b000000IJvrAAG';
			tasksToInsert.add(t);
        }
        try{
            insert tasksToInsert;
        } catch(Exception e){
            System.debug(e);
        }
    }	

    public static List<CheckDetail__c> getDiscrepantChecks(List<CheckDetail__c> checkDetails){
        //create list for discrepant check details
        List<CheckDetail__C> checkDetailsNeedTasks = new List<CheckDetail__C>();

        //check if unmatched check detail has a schedule
        //if so add it to checkDetailsNeedTasks
        For(CheckDetail__C cd : checkDetails){
            if(cd.Schedule__C != null){
                checkDetailsNeedTasks.add(cd);
            }
        }        

        return checkDetailsNeedTasks;
    }
    
}
public class CheckDetailQueue implements Queueable  {
    
    List<CheckDetail__c> checkDetails;
    List<Schedules__C> schedules;

    public CheckDetailQueue(List<CheckDetail__c> checkDetailsToInsert, List<Schedules__C> schedulesToUpdate){
        this.checkDetails = checkDetailsToInsert;
        this.schedules = schedulesToUpdate;
    }

    public void execute(QueueableContext context) {
        insert checkDetails;
        update schedules;
    }
    
}

public class CheckDetailScheduleOrganizerWrapper {
    //Schedule organizer fields
    public Set<Id> scheduleIds								{ get; set; }
    public Map<String, List<Schedules__c>> havasSchedMap    { get; set; }
    public Map<String, List<Schedules__c>> nonHavasSchedMap { get; set; }
    public Map<Id, Schedules__C> scheduleRecords 			{ get; set; }
    
    //Check Detail organizer fields
    public List<CheckDetail__C> checkDetailsToInsert 				{ get; set; }
    public Map<Id, Decimal> schedulePayments						{ get; set; }
    public List<CheckDetail__C> unmatchedCheckDetailsMaster 		{ get; set; }
    public List<CheckDetail__C> unmatchedCheckDetailsRate 			{ get; set; }
    public List<CheckDetail__C> unmatchedCheckDetailsTraffic 		{ get; set; }
    public List<CheckDetail__C> unmatchedCheckDetailsSchedule 		{ get; set; }
    public List<CheckDetail__C> unmatchedCheckDetailsNoSchedule 	{ get; set; }

}


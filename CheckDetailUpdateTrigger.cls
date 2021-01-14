trigger CheckDetailUpdateTrigger on CheckDetail__c (before update, before delete) {
  
    
    Map<Id, Decimal> checkDetailOldAmount = new Map<Id, Decimal>();
    Map<Id, Decimal> checkDetailNewAmount = new Map<Id, Decimal>();
    Map<Id, Id> checkDetailOldSchedule = new Map<Id, Id>();
    Map<Id, Id> checkDetailNewSchedule = new Map<Id, Id>();
    Set<Id> schedIds = new Set<Id>();
    Map<Id, Schedules__c> schedMap = new Map<Id, Schedules__c>();
    List<Schedules__c> schedsToUpdate = new List<Schedules__c>();
    //Schedule field is not null in Trigger.Old
    Boolean cdHasOldSchedule;
    //Schedule field is not null in Trigger.Old
    Boolean cdHasNewSchedule;
    //cd old schedule different than cd new schedule
    Boolean cdScheduleChange;
    //Schedule field is not null in Trigger.Old and is null in Trigger.New , throw error
    Boolean cdDeleteSchedule;
    //(!cdHasSchedule && cdScheduleChange)
    Boolean cdNewScheduleFromNull;
    //No change in Check Amount 
    Boolean checkAmountChanged;
    //If old and new schedules are null no action can be taken
    Boolean skipSchedule;
    
    Set<id> cds = new Set<id>();
	    
    
    //get new values of rates and schedules from check details
    For (CheckDetail__c cd : Trigger.New){
        checkDetailNewSchedule.put(cd.Id, cd.Schedule__c);
        checkDetailNewAmount.put(cd.Id, cd.Check_Amount__C);
        cds.add(cd.Id);
        //for unmatched check details which are manually matched, the Schedule will be null
        if(cd.Schedule__c == null){
			continue;
        }
        else{
            //get schedule id for query
            schedIds.add(cd.Schedule__c);
        }
    }
   
    //get old values of rates,schedules and ids from check details
    For (CheckDetail__c cd : Trigger.Old){
        //add old check amount to map with key of id
        checkDetailOldAmount.put(cd.Id, cd.Check_Amount__C);
        checkDetailOldSchedule.put(cd.Id, cd.Schedule__c);
        cds.add(cd.Id);
        //for unmatched check details which are manually matched, the Schedule will be null
        if(cd.Schedule__c == null){
			continue;
        }
        else{
            //get schedule id for query
            schedIds.add(cd.Schedule__c);
        }
    }
    
    
    //get schedules
    List<Schedules__C> scheds = [SELECT id, Sum_of_Check_Payments__c FROM Schedules__C WHERE id IN :schedIds];
    
    For(Schedules__C s : scheds){
        schedMap.put(s.id, s);        
    }
    
    if(Trigger.isUpdate){
        System.debug('update trigger:');
        // old check detail schedule not null
        Boolean cdHasOldSchedule;
        // new check detail schedule not null
        Boolean cdHasNewSchedule;
        //cd old schedule different than cd new schedule
        Boolean cdScheduleChange;
        //Schedule field is not null in old check detail and is null in new check detial , throw error
        Boolean cdDeleteSchedule;
        //(!cdHasOldSchedule && cdHasNewSchedule)
        Boolean cdNewScheduleFromNull;
        //No change in Check Amount 
        Boolean checkAmountChanged;
        //If old and new schedules are null no action can be taken
        Boolean skipSchedule;
        For(Id cd : cds){
            Id oldSchedule = checkDetailOldSchedule.get(cd);
            Id newSchedule = checkDetailNewSchedule.get(cd);
            Decimal oldAmount = checkDetailOldAmount.get(cd);
            Decimal newAmount = checkDetailNewAmount.get(cd);
            cdHasOldSchedule = oldSchedule != null;
            cdHasNewSchedule = newSchedule != null;
            cdScheduleChange = cdHasOldSchedule != cdHasNewSchedule;
            cdDeleteSchedule = cdHasOldSchedule && !cdHasNewSchedule;
            cdNewScheduleFromNull = !cdHasOldSchedule && cdHasNewSchedule;

            
            //if removing schedule from check detail
            if(cdDeleteSchedule){
                //get old schedule 
                Schedules__c s = schedMap.get(oldSchedule);

                //get sum of payments
                Decimal oldVal = s.Sum_of_Check_Payments__c;
                
                //calc new amount 
                Decimal newSchedSum = oldVal - oldAmount;
                
                //set new amount
                s.Sum_of_Check_Payments__c = newSchedSum;
                
                //add updated sched to map
                schedMap.put(s.Id, s);
            }
            //if previously no sched attached to cd
            else if(cdNewScheduleFromNull){              
                 System.debug('new schedule from null ');
                //get schedule using new cd sched's Id
                Schedules__c s = schedMap.get(newSchedule);
                
                //add check detail amount to schedule
                If(s.sum_of_check_payments__C == null) s.sum_of_check_payments__C = 0;
                s.sum_of_check_payments__C  = s.sum_of_check_payments__C  + newAmount;
                
                //add updated sched to map
                schedMap.put(s.Id, s);
            }
            else if (!cdScheduleChange && checkAmountChanged){
                //get schedule using new cd sched's Id
                Schedules__c s = schedMap.get(newSchedule);

                //add difference of new check amount and old check amount to schedule	
                Decimal diff = newAmount - oldAmount;
                Decimal newSchedSum = s.sum_of_check_payments__C  + diff;
                schedMap.put(s.Id, s);
            }
            else if (cdScheduleChange){
                //get old and new schedules
                Schedules__c sOld = schedMap.get(oldSchedule);
                Schedules__c sNew = schedMap.get(newSchedule);
                
                //subtract old payment from old schedule 
               	If(sOld.sum_of_check_payments__C == null) sOld.sum_of_check_payments__C = 0;
				sOld.sum_of_check_payments__C = sOld.sum_of_check_payments__C - oldAmount;
                schedMap.put(sOld.Id, sOld);

                //add new payment to ne schedule 
               	If(sNew.sum_of_check_payments__C == null) sNew.sum_of_check_payments__C = 0;
				sNew.sum_of_check_payments__C = sNew.sum_of_check_payments__C - newAmount;
                schedMap.put(sNew.Id, sNew);
            }


        }
        
        For(Id key : schedMap.keySet()){
            Schedules__c current =  schedMap.get(key);
            schedsToUpdate.add(current);
        }
        System.debug('update try');
        try {
          update schedsToUpdate;
        } catch(DmlException e) {
           System.debug('The following exception has occurred: ' + e.getMessage());
        }

    } else if(Trigger.isDelete){
    System.debug('delete trigger:');
        
        For (CheckDetail__c cd : Trigger.Old){    
    		if(cd.Schedule__c == null){
                continue;
            } 
           
            //get id
            Id currId = cd.Id ;
            
            //Check detail sched parent 
            Schedules__C parent = schedMap.get(cd.Schedule__c);
            System.debug(parent);
            
            if(parent.Sum_of_Check_Payments__c == null){
                parent.Sum_of_Check_Payments__c = 0;
            }
            System.debug('check amount');
            System.debug(cd.Check_Amount__c);
            
            //update schedule sum
            Decimal updatedSum = parent.Sum_of_Check_Payments__c - cd.Check_Amount__c;
            System.debug('updated sum: ');
            System.debug(updatedSum);
            
            //update parent sum 
            parent.Sum_of_Check_Payments__c = updatedSum;
            
            //add to update list with new sum 
            schedMap.put(cd.Schedule__c, parent);
            
        }
        
        For(Id key : schedMap.keySet()){
            Schedules__c current =  schedMap.get(key);
            schedsToUpdate.add(current);
        }
        System.debug('update try');
        try {
          update schedsToUpdate;
        } catch(DmlException e) {
           System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    
    
    
}
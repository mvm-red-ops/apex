trigger CheckDetailUpdateTrigger on CheckDetail__c (before update, before delete) {
    
    Map<Id, Decimal> checkDetailOld = new Map<Id, Decimal>();
    Map<Id, Decimal> checkDetailNew = new Map<Id, Decimal>();
    Set<Id> schedIds = new Set<Id>();
    Map<Id, Schedules__c> schedMap = new Map<Id, Schedules__c>();
    List<Schedules__c> schedsToUpdate = new List<Schedules__c>();

    //need old check amount
    For (CheckDetail__c cd : Trigger.Old){  
        //add old check amount to map with key of id
        checkDetailOld.put(cd.Id, cd.Check_Amount__C);
        //get schedule id for query
        schedIds.add(cd.Schedule__c);
    }
    
    List<Schedules__C> scheds = [SELECT id, Sum_of_Check_Payments__c FROM Schedules__C WHERE id IN :schedIds];

    For(Schedules__C s : scheds){
        schedMap.put(s.id, s);
    }
    
    if(Trigger.isUpdate){
        For (CheckDetail__c cd : Trigger.New){    
            //get id
            Id currId = cd.Id ;
            
            //get new check amount
            Decimal newCA = cd.Check_Amount__C;
            
            //get old check amount
            Decimal oldCA = checkDetailOld.get(currId);
            
            //calculate difference
            Decimal checkAmountDif = newCA - oldCA;
            
            //Check detail sched parent 
            Schedules__C parent = schedMap.get(cd.Schedule__c);
            System.debug(cd.Schedule__c);
            
            //if field is null instantiate it
            if(parent.Sum_of_Check_Payments__c == null){
                parent.Sum_of_Check_Payments__c = 0;
            }
            
            //update schedule sum
            Decimal updatedSum = parent.Sum_of_Check_Payments__c + checkAmountDif;
            
            //update parent sum 
            parent.Sum_of_Check_Payments__c = updatedSum;
            
            //add to update list with new sum 
      		schedMap.put(cd.Schedule__c, parent);

        }
        
        For(Id key : schedMap.keySet()){
            Schedules__c current =  schedMap.get(key);
            schedsToUpdate.add(current);
        }
		update schedsToUpdate;

    } else if(Trigger.isDelete){
        For (CheckDetail__c cd : Trigger.Old){    
            //get id
            Id currId = cd.Id ;
            System.debug('current');
            //Check detail sched parent 
            Schedules__C parent = schedMap.get(cd.Schedule__c);
            System.debug(parent);
            
			if(parent.Sum_of_Check_Payments__c == null){
                parent.Sum_of_Check_Payments__c = 0;
            }
            
            //update schedule sum
            Decimal updatedSum = parent.Sum_of_Check_Payments__c - cd.Check_Amount__c;
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
                
        update schedsToUpdate;

    }
    
    
    
}
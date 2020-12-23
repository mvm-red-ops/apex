public class CreateTasks implements Queueable  {
    
    List<CheckDetail__c> discrepantCheckDetails;
    Map<Id, Schedules__C> schedMap;
    List<Task> tasksToInsert = new List<Task>(); 
            
    public CreateTasks(CheckDetailScheduleOrganizerWrapper processResults){
        this.discrepantCheckDetails = getDiscrepantChecks(processResults.unmatchedCheckDetailsMaster);
        this.schedMap = processResults.scheduleRecords;

    }

    public void execute(QueueableContext context) {
        String[] toAddresses = new String[]{'tayloryoung@mvmediasales.com'};
        System.debug('discrepant checks: ');
        System.debug(discrepantCheckDetails);
        
        For(CheckDetail__c cd : discrepantCheckDetails){
             //get schedule 
            Schedules__c parentSched = schedMap.get(cd.Schedule__C);
            System.debug('unmatched reason: ');
            System.debug(cd);
            System.debug(cd.Unmatched_Reason__c);
            if(cd.Unmatched_Reason__c != null && cd.Unmatched_Reason__c == 'Mismatched rate on Schedule'){
                //create Task
                Task t = new Task();
                t.OwnerId = parentSched.Deal_Parent__r.Program__r.Lead__c;
                //t.OwnerId ='0053b00000BACubAAH';
                t.Description =  'There is a payment discrepancy that needs attention. Please look into  the following Schedule: https://marathon--training.lightning.force.com/lightning/r/Schedules__c/' + cd.Schedule__C +
                    '/view . The payment details are as follows air date: ' + cd.Air_Date__c + ', ' + 
                    ' air time: ' + cd.Air_Time__c + ', ' +
                    ' amount: $' + String.valueOf(cd.Check_Amount__c.format()) + ', ' +
                    ' check#: ' + cd.Check__c + ', ' +
                    'schedule: ' + cd.Schedule__C; 
                t.RecordTypeId = '0123b000000IJvrAAG';
                //t.WhatId  = ;
                t.Subject = 'CheckDetail Payment Discrepancy';
                String toAddress = parentSched.Deal_Parent__r.Program__r.Lead__r.email;
                toAddresses.add(toAddress);
                t.CallObject = 'CheckDetail Payment Discrepancy';
                t.Status = 'Not Started';
                tasksToInsert.add(t);
            } else {
                continue;
            }

        }
        if(tasksToInsert.size() > 0){
            try{
                insert tasksToInsert;
                sendEmail(tasksToInsert, toAddresses);
            } catch(Exception e){
                System.debug(e);
            }
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
    
    public void sendEmail(List<Task> tasks, String[] toAddresses){
  		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Finance Alert');
		mail.setSubject('New Agency Discrepancy Tasks Created');
		Integer counter = 0;
        // Specify the text content of the email.
        mail.setPlainTextBody(tasks.size()  + ' payments had mismatched rates. Please look into the following Tasks:');
        String htmlListItems = '';
       
        For(Task t : tasks){
            counter++;
            htmlListItems = htmlListItems + '<li> <a href=https://marathon--training.lightning.force.com/lightning/r/Task/'+ t.id + '/view > Task '+counter+' </a> </li>';
        }
        
        String htmlList = '<ul>' + htmlListItems + '</ul>';
        String htmlText ='<h5> Paid Programming payment discrepancies have occurred. </br> The following Tasks have been created to address: </h3></br></br>' + htmlList;
    	String htmlBody = '<html> <body>'+htmlText + '</body></html>';

        mail.setHtmlBody(htmlBody);
        System.debug(mail);
        try{
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
}

global class PPTrafficLogEmailHandler implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){

      List<String> subjectDetails = email.subject.split('-');
      String program = subjectDetails[1];
      Date logDate = date.parse(subjectDetails[2].split(' ')[1]).toStartofWeek() + 1;
      String queryDate = String.valueOf(logDate).split(' ')[0];
 
      String schedQuery = 
          'SELECT id, Revision_Comments__c FROM Schedules__c ' +
          'WHERE Dealprogram__c = :program ' +
          'AND Week__c = :logDate ' +
          'AND Status__c = \'Sold\' ' +
          'AND DealBrand__c != \'Availability\' ' +
          'ORDER BY Week__c ASC, Long_Form__c ASC';
      
      String preemptedQuery = 
          'SELECT id, Preempted_and_Sent_To_Network__c FROM Schedules__c ' +
          'WHERE Dealprogram__c = :program ' +
          'AND Week__c = :logDate ' +
          'AND Status__c = \'Canceled\' ' +
          'AND DealBrand__c != \'Availability\' ' +
          'ORDER BY Week__c ASC, Long_Form__c ASC';      
      
      List<Schedules__c> scheds = Database.query(schedQuery);
      List<Schedules__c> preemptedScheds = Database.query(preemptedQuery);
     
      For(Schedules__c s : scheds){
          s.Revision_Comments__c = '';            
      }
      
      For(Schedules__c s : preemptedScheds){
          s.Preempted_and_Sent_To_Network__c = true;
      }
      
      update scheds;  
      update preemptedScheds;
      
      
      Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
      
      return result;
  }
}

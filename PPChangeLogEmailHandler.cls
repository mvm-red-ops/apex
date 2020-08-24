global class PPChangeLogEmailHandler implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){

      List<String> subjectDetails = email.subject.split('-');
             System.debug(' subjectDetails: ' +subjectDetails);

      String program = subjectDetails[1];
      Date logDate = date.parse(subjectDetails[2].split(' ')[1]).toStartofWeek() + 1;
      String queryDate = String.valueOf(logDate).split(' ')[0];
       System.debug(' program: ' + program);

      String query = 
          'SELECT id, PP_Revision__c FROM Programs__c ' +
          'WHERE Name = :program ';
      
      
      Programs__c prog = Database.query(query);
      System.debug('query program: ' + prog);
      
      prog.PP_Revision__c = prog.PP_Revision__c + 1;
      
      update prog;      
      
      Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
      
      return result;
  }
}

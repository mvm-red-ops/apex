global class InvoiceNumberSpotDataBatch implements Database.Batchable<sObject>{
    
    global final String query;
    global final Map<String, List<Map<String, String>>> orderMap;
    global final List<String> orderNums;
    global final Date queryStart;
    global final Date queryEnd;
    
   global InvoiceNumberSpotDataBatch(String query, Map<String, List<Map<String, String>>> orderMap, List<String> orderNums, Date queryStart, Date queryEnd ){
       	this.orderMap=orderMap;
       	this.orderNums=orderNums;
       	this.queryStart=queryStart;
       	this.queryEnd=queryEnd;
        this.query=query;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }


   global void execute(Database.BatchableContext BC, List<SObject> scope){                
       List<Spot_Data__c> spotDataToUpdate = new List<Spot_Data__c>();
  
       if(scope.size() == 0){
           System.debug('no results from query');
           return ;
       }
       
       
       system.debug('scope items: ');
       for(SObject s : scope){
           system.debug(s);

           String orderNum = (String)s.get('Raycom_Order_Number__c');
           Date airDate = (Date)s.get('Air_Date__c');
           List<Map<String, String>> invoiceMaps = orderMap.get(orderNum);
           System.debug('how many maps in invoiceMaps: ');
           System.debug(invoiceMaps.size());   
           
           For(Map<String, String> orderMap : invoiceMaps){
                 date recordStart = date.parse(orderMap.get('start'));
                 date recordEnd = date.parse(orderMap.get('end'));

               if( airDate >= recordStart &&  airDate <= recordEnd ){
                     Spot_Data__c spotToUpdate = (Spot_Data__c)s;
                     spotToUpdate.Raycom_Invoice_Number__c = orderMap.get('invoice');
                     spotDataToUpdate.add(spotToUpdate);
                 	break;
                }
             }
         }

       update spotDataToUpdate;
    }

   global void finish(Database.BatchableContext BC){
   }
}

public class InvoiceSpotDataMatchUploader {
    
    @AuraEnabled(cacheable=true)
    public static ID readCSVFile(Id idContentDocument, String dealProgram){

        applicationException appError = new applicationException();
        
        //Variable declaration
        List<Spot_Data__c> spotsToBeUpdated = new List<Spot_Data__c>();
        List<String> orderNums = new List<String>();
        List<Spot_Data__c> spots =new List<Spot_Data__c>();
        Map<String, List<Map<String, String>>> orderMap = new Map<String, List<Map<String, String>>>();

        if(idContentDocument != null) {
                    
            // getting File Version  based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument LIMIT 1];

            // split the file data by rows
            List<String> CSVData = objVersion.VersionData.toString().split('\n');
            List<String> headers = CSVData[0].split(',');
            Date queryStart = Date.newInstance(3000, 2, 17);
            Date queryEnd = Date.newInstance(1000, 2, 17);
 
            System.debug('CSVData: ');
            System.debug(CSVData);
            //iterate through rows, add deal num to orderNum and map
            for(integer i = 1; i < CSVData.size(); i++){
                String currentRowString = CSVData[i];
				Map<String, String> currVals = new Map<String, String>();
                List<String> currentRow = currentRowString.split(',');
				String invoice = currentRow[0].trim();             
                String flag = currentRow[0].split('-')[1].trim();             
                String startDate = currentRow[1].trim();    
                String endDate = currentRow[2].trim();   
                String orderNum = currentRow[0].split('-')[0].trim();             
                if(!orderNums.contains(orderNum)){
                    orderNums.add(orderNum);
                }

                if(date.parse(startDate) < queryStart){
                    queryStart = date.parse(startDate);
                }
                if(date.parse(endDate) > queryEnd){
                    queryEnd = date.parse(endDate);
                }
                
                currVals.put('flag', flag);
                currVals.put('start', startDate);
                currVals.put('end', endDate);
                currVals.put('invoice', invoice);
                currVals.put('order', orderNum);

                if(orderMap.containsKey(orderNum)){
                   	List<Map<String, String>> currentOrder = orderMap.get(orderNum);
                  	currentOrder.add(currVals);
                } else {
                    List<Map<String, String>> newOrderNumVals = new List<Map<String, String>>{currVals};
                    orderMap.put(orderNum, newOrderNumVals);
                }
            }
            
             
            System.debug('orderMap: ');
            System.debug(orderMap);
            System.debug('orderNums: ');
            System.debug(orderNums);            

            String schedQuery = 'select id FROM schedules__c ' + 
                'WHERE (DealProgram__c = \'Retro Gray Connect One\' OR DealProgram__c = \'Bounce Gray Connect\' OR ' +  
                'DealProgram__c = \'Retro Gray Connect Two\' OR DealProgram__c = \'Primary Gray Connect Extra\' OR ' +
                'DealProgram__c = \'Primary Gray Connect\') AND Week__c >= :queryStart AND Week__c <= :queryEnd';
            System.debug('schedQuery:');
            System.debug(schedQuery);            
            
           List<Schedules__C> schedules = Database.Query(schedQuery);

            
           	List<Id> schedIds = new List<Id>();
            For(Schedules__c s : schedules){
                schedIds.add(s.Id);
            }
			
            String idString = '\'' + String.join(schedIds,'\',\'') + '\'';
            
            String query = 'select id, Air_Date__c, Raycom_Order_Number__c, Raycom_Invoice_Number__c  FROM spot_data__c ' + 
                'WHERE schedule__c IN(' + idString + ') AND ' + 
                'Raycom_Order_Number__c IN :orderNums AND '+ 
                'Air_Date__c >= :queryStart AND Air_Date__c <= :queryEnd ' +
                'ORDER BY Air_Date__c ASC ';
            

            InvoiceNumberSpotDataBatch invBatch = new InvoiceNumberSpotDataBatch(query, orderMap, orderNums, queryStart, queryEnd);
			ID batchprocessid = Database.executeBatch(invBatch);
	
			return batchprocessid;
         } else {
            appError.message = 'Sorry! Not sure what went wrong, reach out to your administrator for help!';
            appError.name = 'File could not be uploaded properly.';
            appError.code = 199;
            throw appError;
        }

        
    }    
}

public with sharing class DealprogramDropdown {
	@auraEnabled(cacheable=true)
    
    //Class is responsible for getting the names of the deal programs in SF
    public static List<String> getFields(){
        
        //Queries for deals where brand = 'Long Form'
        List<Deal__c> deals = [SELECT Program__r.id FROM Deal__c WHERE Brands__c = 'a0780000004cJJj'];
        List<Id> programIds = new List<Id>();
        for(Deal__c d : deals){
            programIds.add(d.Program__c);
        }

     	//Query names from programs of above deals 
        List<Programs__c> programs = [SELECT Name FROM Programs__c WHERE Id IN :programIds];
        List<String> fields = new List<String>();
		for(Programs__c p : programs){
            fields.add(p.Name);
        }

        return fields;
    }
    
}
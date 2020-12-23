@isTest
public class OrderLineNumberTest {

// Test for Null Fields
// OrderLineNumber expected to return Null
    static testMethod void TestNullField() {
        Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1');
    	insert prg; 
        Deal__c newDeal = createProgram(prg);
        
        Test.startTest();
     		Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Tue; Wed; Thu; Fri; Sat; Sun', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold');
     		insert sch;
        Test.stopTest();
        
        Schedules__c mySchedule = [Select id, OrderLineNumber__c from Schedules__c where DealProgram__c = 'TestProg' ];

        System.assertEquals(mySchedule.OrderLineNumber__c, null); 
    }

// Test for Start End Time Line
// First 3 digits should be start time
// Second 3 digit should be end time 
    static testMethod void TestClockStartTimeOnInsert() {
        Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1', Clock_Start_Time__c = '6AM');
    	insert prg; 
        Deal__c newDeal = createProgram(prg);

        List<Schedules__C> schedulesToInsert = new List<Schedules__C>();

        //on insert
        Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Tue; Wed; Thu; Fri; Sat; Sun', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30P', End_Time__c='09:00P', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        schedulesToInsert.add(sch);
        //insert sch; 
        
        Schedules__c sch2 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969851',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Tue; Wed; Thu; Fri; Sat; Sun', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:00P', End_Time__c='09:30P', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        //insert sch2; 
        schedulesToInsert.add(sch2);
        
        Schedules__c sch3 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969852',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Tue; Wed; Thu; Fri; Sat; Sun', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:00A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
         //insert sch3; 
         schedulesToInsert.add(sch3);
        
        Schedules__c sch4 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969853',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Tue; Wed; Thu; Fri; Sat; Sun', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:30A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
         //insert sch4; 
         schedulesToInsert.add(sch4);

        //insert all schdules
        insert schedulesToInsert;

        Schedules__c mySchedule;
        Schedules__c mySchedule2;
        Schedules__c mySchedule3;
        Schedules__c mySchedule4;
        List<Schedules__c> mySchedules = [Select id, OrderLineNumber__c,X800_Number__c from Schedules__c where DealProgram__c = 'TestProg' AND X800_Number__c IN ('9658969856', '9658969851', '9658969852','9658969853') ];
        For(Schedules__C s : mySchedules){
            System.debug(s);
            System.debug(s.OrderLineNumber__c);
            if(s.X800_Number__c == '9658969856'){
                mySchedule = s;
            } else if(s.X800_Number__c == '9658969851'){
                mySchedule2 = s;
            } else if (s.X800_Number__c == '9658969852'){
                mySchedule3 = s;
            } else if (s.X800_Number__c == '9658969853'){
                mySchedule4 = s;
            }
        }



        System.assertEquals(mySchedule.OrderLineNumber__c, '1532107336000'); 
        System.assertEquals(mySchedule2.OrderLineNumber__c, '1502137336000');
        System.assertEquals(mySchedule3.OrderLineNumber__c, '0300907336000');
        System.assertEquals(mySchedule4.OrderLineNumber__c, '0330937336000'); 
    }
    
        // Test for Scripps Connect
    static testMethod void TestClockStartTimeOnUpdate() {
        Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1', Clock_Start_Time__c = '6AM');
    	insert prg; 
        Deal__c newDeal = createProgram(prg);
        //on insert
        Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Tue; Wed; Thu; Fri; Sat; Sun', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
     	insert sch; 
        
        Test.startTest();
        
        sch.Start_Time__c = '03:30P'; 
        sch.End_Time__c='09:00P';
        update sch;
		Test.stopTest(); 
        
        Schedules__c mySchedule = [Select id, OrderLineNumber__c from Schedules__c where X800_Number__c= '9658969856'];

       	System.assertEquals(mySchedule.OrderLineNumber__c, '1532107336000');
        
        sch.Start_Time__c = '03:00P'; 
        sch.End_Time__c='09:30P';
        update sch;
        
        mySchedule = [Select id, OrderLineNumber__c from Schedules__c where X800_Number__c= '9658969856'];

       	System.assertEquals(mySchedule.OrderLineNumber__c, '1502137336000');
        
        sch.Start_Time__c = '03:30A'; 
        sch.End_Time__c='09:00A';
        update sch;
        
        mySchedule = [Select id, OrderLineNumber__c from Schedules__c where X800_Number__c= '9658969856'];

       	System.assertEquals(mySchedule.OrderLineNumber__c, '0330907336000');
        
        sch.Start_Time__c = '03:00A'; 
        sch.End_Time__c='09:30A';
        update sch;
        
        mySchedule = [Select id, OrderLineNumber__c from Schedules__c where X800_Number__c= '9658969856'];

       	System.assertEquals(mySchedule.OrderLineNumber__c, '0300937336000');
        
    }
    
// Test for setting the Start and End Time when the daypart = ROS
    static testMethod void TestStartEndTimeSetROS() {
        List<Programs__c> programsToInsert = new  List<Programs__c>();
        List<Schedules__c> schedulesToInsert = new  List<Schedules__c>();
        
        Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1', Clock_Start_Time__c = '5AM');
        Programs__c prg2 = new Programs__c(Name = 'TestProg2', ClientCode__c = 'TC1', Clock_Start_Time__c = '4AM');
        programsToInsert.add(prg);
        programsToInsert.add(prg2);
        
        insert programsToInsert;

        Deal__c newDeal = createProgram(prg);
        Deal__c newDeal2 = createProgram(prg2);

        Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Tue; Wed; Thu; Fri; Sat; Sun', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '01:00A', End_Time__c='09:00A', MGM_HD_Daypart__c ='ROS-');
        Schedules__c sch2 = new Schedules__c(Deal_Parent__c=newDeal2.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Tue; Wed; Thu; Fri; Sat; Sun', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '01:00A', End_Time__c='09:00A', MGM_HD_Daypart__c ='ROS-');
        schedulesToInsert.add(sch);
        schedulesToInsert.add(sch2);



        insert schedulesToInsert;

        List<Schedules__C> mySchedules = [Select id, Start_Time__c, Deal_Parent__c from Schedules__c where DealProgram__c IN ('TestProg', 'TestProg2')];
        Schedules__c mySchedule;
        Schedules__c mySchedule2;

        For(Schedules__c s : mySchedules){
            if(s.Deal_Parent__c == newDeal.id){
                mySchedule = s;
            } else if (s.Deal_Parent__c  == newDeal2.id ){
                mySchedule2 = s;
            }
        }

        System.assertEquals(mySchedule2.Start_Time__c, '04:00A'); 
        System.assertEquals(mySchedule.Start_Time__c, '05:00A'); 
    }
    
    
     // Test for setting the Days Allowed based on the Day Part
    static testMethod void TestSetDaysAllowed() {
        List<Programs__c> programsToInsert = new List<Programs__c>();
        List<Schedules__c> schedulesToInsert = new List<Schedules__c>();

        Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1', Clock_Start_Time__c = '6AM');
        Programs__c prg2 = new Programs__c(Name = 'TestProg2', ClientCode__c = 'TC1', Clock_Start_Time__c = '6AM');
        Programs__c prg3 = new Programs__c(Name = 'TestProg3', ClientCode__c = 'TC1', Clock_Start_Time__c = '6AM');
        programsToInsert.add(prg); 
        programsToInsert.add(prg2); 
        programsToInsert.add(prg3); 

        insert programsToInsert;


        Deal__c newDeal = createProgram(prg);
        Deal__c newDeal2 = createProgram(prg2);
        Deal__c newDeal3 = createProgram(prg3);


        Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60, Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', MGM_HD_Daypart__c ='SS 12a-5a');
        Schedules__c sch2 = new Schedules__c(Deal_Parent__c=newDeal2.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60, Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        Schedules__c sch3 = new Schedules__c(Deal_Parent__c=newDeal3.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60, Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', MGM_HD_Daypart__c ='MF 6a-6p');
        schedulesToInsert.add(sch); 
        schedulesToInsert.add(sch2); 
        schedulesToInsert.add(sch3); 
        insert schedulesToInsert;

        List<Schedules__C> mySchedules = [Select id, Deal_Parent__c, Days_Allowed__c from Schedules__c];
        Schedules__c mySchedule;
        Schedules__c mySchedule2;
        Schedules__c mySchedule3;

        For(Schedules__c s : mySchedules){
            if(s.Deal_Parent__c == newDeal.id){
                mySchedule = s;
            } else if (s.Deal_Parent__c  == newDeal2.id ){
                mySchedule2 = s;
            } else if (s.Deal_Parent__c  == newDeal3.id){
                mySchedule3 = s;
            }
        }

        System.assertEquals(mySchedule.Days_Allowed__c, 'Sat;Sun'); 
        System.assertEquals(mySchedule2.Days_Allowed__c, 'Mon;Tue;Wed;Thu;Fri;Sat;Sun');        
        System.assertEquals(mySchedule3.Days_Allowed__c, 'Mon;Tue;Wed;Thu;Fri');          
    }
    

 // Test for Setting the DaysAllowed Digit based on the values in the field
    static testMethod void TestDaysAllowed() {
        
        List<Schedules__C> schedulestoInsert = new List<Schedules__C>();

        Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1', Clock_Start_Time__c = '6AM');
        insert prg; 
        
        Deal__c newDeal = createProgram(prg);
		Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Wed;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        Schedules__c sch2 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '1658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Tue; Wed;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        Schedules__c sch3 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '2658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon; Tue;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
		Schedules__c sch4 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '3658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Wed;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        Schedules__c sch5 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '4658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Tue;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
		Schedules__c sch6 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '5658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Mon;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        Schedules__c sch7 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '6658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Thu;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        Schedules__c sch8 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '7658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Fri;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        Schedules__c sch9 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '8658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Sat;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
		Schedules__c sch0 = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '0658969856',Units_Available__c= 4.0, Rate__c= 60,Days_Allowed__c = 'Sun;', Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', Start_Time__c = '03:30A', End_Time__c='09:00A', MGM_HD_Daypart__c ='DA - MS 9a-6p');
        schedulestoInsert.add(sch); 
        schedulestoInsert.add(sch2); 
        schedulestoInsert.add(sch3); 
        schedulestoInsert.add(sch4); 
        schedulestoInsert.add(sch5); 
        schedulestoInsert.add(sch6); 
        schedulestoInsert.add(sch7); 
        schedulestoInsert.add(sch8); 
        schedulestoInsert.add(sch9); 
        schedulestoInsert.add(sch0); 

        insert schedulestoInsert;
              
        List<Schedules__C> mySchedules = [Select id,X800_Number__c,Start_Time__c, Deal_Parent__c,OrderLineNumber__c, Days_Allowed__c from Schedules__c];
        Schedules__c mySchedule;
        Schedules__c mySchedule2;
        Schedules__c mySchedule3;
        Schedules__c mySchedule4;
        Schedules__c mySchedule5;
        Schedules__c mySchedule6;
        Schedules__c mySchedule7;
        Schedules__c mySchedule8;
        Schedules__c mySchedule9;
        Schedules__c mySchedule0;

               
        For(Schedules__c s : mySchedules){
            if(s.X800_Number__c== '9658969856'){
                mySchedule = s;
            } else if (s.X800_Number__c== '1658969856'){
                mySchedule2 = s;
            } else if (s.X800_Number__c== '2658969856'){
                mySchedule3 = s;
            } else if (s.X800_Number__c== '3658969856'){
                mySchedule4 = s;
            } else if (s.X800_Number__c== '4658969856'){
                mySchedule5 = s;
            } else if (s.X800_Number__c== '5658969856'){
                mySchedule6 = s;
            } else if (s.X800_Number__c== '6658969856'){
                mySchedule7 = s;
            } else if (s.X800_Number__c== '7658969856'){
                mySchedule8 = s;
            } else if (s.X800_Number__c== '8658969856'){
                mySchedule9 = s;
            } else if (s.X800_Number__c== '0658969856'){
                mySchedule0 = s;
            } 
        }


        //after insert assertions
        System.assertEquals(mySchedule.OrderLineNumber__c, '0330906006000');
       	System.assertEquals(mySchedule2.OrderLineNumber__c, '0330905006000');
        System.assertEquals(mySchedule3.OrderLineNumber__c, '0330904006000');
        System.assertEquals(mySchedule4.OrderLineNumber__c, '0330903006000');
        System.assertEquals(mySchedule5.OrderLineNumber__c, '0330902006000');
        System.assertEquals(mySchedule6.OrderLineNumber__c, '0330901006000');
        System.assertEquals(mySchedule7.OrderLineNumber__c, '0330900106000');
        System.assertEquals(mySchedule8.OrderLineNumber__c, '0330900206000');
        System.assertEquals(mySchedule9.OrderLineNumber__c, '0330900026000');
        System.assertEquals(mySchedule0.OrderLineNumber__c, '0330900016000');


           
        //updates
        List<Schedules__C> schedulestoUpdate = new List<Schedules__C>();

        For(Schedules__c s : mySchedules){
            s.Start_Time__c = '03:00A';
            schedulestoUpdate.add(s);
        }

        update schedulestoUpdate;
        
        List<Schedules__c> myUpdatedSchedule = [Select id, OrderLineNumber__c from Schedules__c];
        For(Schedules__c s : myUpdatedSchedule){
            if(s.X800_Number__c== '9658969856'){
                mySchedule = s;
            } else if (s.X800_Number__c== '1658969856'){
                mySchedule2 = s;
            } else if (s.X800_Number__c== '2658969856'){
                mySchedule3 = s;
            } else if (s.X800_Number__c== '3658969856'){
                mySchedule4 = s;
            } else if (s.X800_Number__c== '4658969856'){
                mySchedule5 = s;
            } else if (s.X800_Number__c== '5658969856'){
                mySchedule6 = s;
            } else if (s.X800_Number__c== '6658969856'){
                mySchedule7 = s;
            } else if (s.X800_Number__c== '7658969856'){
                mySchedule8 = s;
            } else if (s.X800_Number__c== '8658969856'){
                mySchedule9 = s;
            } else if (s.X800_Number__c== '0658969856'){
                mySchedule0 = s;
            } 
        }        
        System.assertEquals(mySchedule.OrderLineNumber__c, '0300906006000');
        System.assertEquals(mySchedule2.OrderLineNumber__c, '0300905006000');        
        System.assertEquals(mySchedule3.OrderLineNumber__c, '0300904006000');
        System.assertEquals(mySchedule4.OrderLineNumber__c, '0300903006000');
        System.assertEquals(mySchedule5.OrderLineNumber__c, '0300902006000');
        System.assertEquals(mySchedule6.OrderLineNumber__c, '0300901006000');
        System.assertEquals(mySchedule7.OrderLineNumber__c, '0300900106000');
        System.assertEquals(mySchedule8.OrderLineNumber__c, '0300900206000');
        System.assertEquals(mySchedule9.OrderLineNumber__c, '0300900026000');
        System.assertEquals(mySchedule0.OrderLineNumber__c, '0300900016000');
        }
    
    // Test for Updating Null Values
    static testMethod void TestNullValuesUpdate() {
        Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1', Clock_Start_Time__c = '6AM');
    	insert prg; 
        Deal__c newDeal = createProgram(prg);
        Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60, Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', MGM_HD_Daypart__c ='DA - MS 9a-6p');
     	insert sch; 
        
        sch.MGM_HD_Daypart__c ='ROS-';
        sch.Start_Time__c = null;
        sch.End_Time__c = null;
        sch.Days_Allowed__c= null;
        update sch;
            
        Schedules__c mySchedule = [Select id, Start_Time__c from Schedules__c where DealProgram__c = 'TestProg'];

        System.assertEquals(mySchedule.Start_Time__c, '06:00A');         
    }
    
//Test for time string
//On Update
//DayPart != ROS

    static testMethod void TestforTimeString(){
        Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1', Clock_Start_Time__c = '6AM');
    	insert prg; 
        Deal__c newDeal = createProgram(prg);
        Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60, Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', MGM_HD_Daypart__c ='ROS-');
     	insert sch; 
        
        sch.Start_Time__c = null;
        sch.End_Time__c = null;
        sch.MGM_HD_Daypart__c ='DA - MS 9a-6p';
        update sch;
               
        Schedules__c mySchedule = [Select id, OrderLineNumber__c from Schedules__c where X800_Number__c= '9658969856'];
        
        System.assertEquals(mySchedule.OrderLineNumber__c, '0901807336000'); 
    }
  
    //Test for Days Allowed Set
	//On Update
	//DayPart != ROS

    static testMethod void TestforDaysAllowedSet(){
    	Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1', Clock_Start_Time__c = '6AM');
    	insert prg; 
        Deal__c newDeal = createProgram(prg);
        Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60, Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', MGM_HD_Daypart__c ='ROS-');
     	insert sch; 
        
        sch.MGM_HD_Daypart__c ='SS 12a-5a';
        sch.Days_Allowed__c = null;
        update sch;
                
        Schedules__c mySchedule = [Select id, Days_Allowed__c from Schedules__c where X800_Number__c= '9658969856'];
        
        System.assertEquals(mySchedule.Days_Allowed__c, 'Sat;Sun');
        
       //MS 
        sch.MGM_HD_Daypart__c ='DA - MS 8a-8p';
        sch.Days_Allowed__c = null;
        update sch;
        
        mySchedule = [Select id, Days_Allowed__c from Schedules__c where X800_Number__c= '9658969856'];

        System.assertEquals(mySchedule.Days_Allowed__c, 'Mon;Tue;Wed;Thu;Fri;Sat;Sun');    
        
        //MF 
        sch.MGM_HD_Daypart__c ='MF 12a-5a';
        sch.Days_Allowed__c = null;
        update sch;
        
        mySchedule = [Select id, Days_Allowed__c from Schedules__c where X800_Number__c= '9658969856'];
       
        System.assertEquals(mySchedule.Days_Allowed__c, 'Mon;Tue;Wed;Thu;Fri');  
    }
    
    
        static testMethod void TestforstartTimeSetROS(){
        Programs__c prg = new Programs__c(Name = 'TestProg', ClientCode__c = 'TC1', Clock_Start_Time__c = '5AM');
    	insert prg; 
        Deal__c newDeal = createProgram(prg);
        Schedules__c sch = new Schedules__c(Deal_Parent__c=newDeal.id,X800_Number__c= '9658969856',Units_Available__c= 4.0, Rate__c= 60, Week__c=date.newinstance(2013, 6, 10),Status__c='Sold', MGM_HD_Daypart__c ='SS 12a-5a');
     	insert sch; 
        
        sch.MGM_HD_Daypart__c ='ROS-';
        update sch;
        
        Schedules__c mySchedule = [Select id, Start_Time__c from Schedules__c where X800_Number__c= '9658969856'];
       
        System.assertEquals(mySchedule.Start_Time__c, '05:00A');
        
    }
    
 // Data Factory   
    public static Deal__c createProgram(Programs__c prg) {
      
     Account act = new Account (name='test Act');
     insert act;
            
     Contact con = new Contact(LastName='TestCon',AccountId=act.id, email = 'j@g.com', Phone = '1234567891');
     insert con;
        
     Advertiser__c advertiser = new Advertiser__c(Duplicate_Approval__c = 'Approved');
     insert advertiser;
        
     Brands__c brand = new Brands__c();
     	brand.Name = 'Availability';
     	brand.Category__c = 'Other';
        brand.Advertiser__c = advertiser.id;
        brand.Approved_Duplicate__c = 'Approved' ;
     insert brand;
        
     Deal__c deal= new Deal__c(Length__c='120',Program__c = prg.id, Contact__c = con.id,Network_Deal_Number__c ='1420', Brands__c = brand.Id);
     insert deal;
        
     return deal;
    }
}

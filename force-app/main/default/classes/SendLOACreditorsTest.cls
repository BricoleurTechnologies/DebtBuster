/**
	Test class for SendLOACreditors    
**/
@isTest
public class SendLOACreditorsTest{
    
    static testMethod void withOpp()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];
         createDBSetting();
        //Test Data
         //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com';  
        acc.ABN__c = '12312312312';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.AccountId = a.Id;
        opp.StageName = 'Open';       
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Unit Test Attachment'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        insert db;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.listWrapper[0].checked=true;
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest();
    }
    
    static testMethod void withoutSelect()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];
        createDBSetting();
        //Test Data
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        insert opp;
        
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        insert db;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.listWrapper[0].checked=false; 
        uptopp.listWrapper[0].debt=db;
        uptopp.selectEmail();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest();  
    }
    
    static testMethod void withallBool()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        insert opp;
        
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        insert db;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
    
    //Coverage for trigger sendEmailTOCreditors
    static testMethod void updateOpportunity()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank'; 
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.Withdrawn_Reason__c='Sample';
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        insert db;
         
        Test.startTest();
        Opportunity oppUpdate = [Select id,StageName FROM Opportunity WHERE id =:opp.Id];
        oppUpdate.StageName ='WITHDRAWN - CANCELLED';
        update oppUpdate;
        Test.stopTest();    
    }
    
   
    /*
     * Opportunity REcord Type = Debt Agreement(DAP)
     */ 
    static testMethod void DAP_Opporunity_with_Secured_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
         
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
       
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Secured_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Secured_Debt'];
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        db.RecordTypeId = rt_Secured_Debt.id;
       	insert db;
        
        //Record Type
        RecordType rt_Not_to_be_paid_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Not_to_be_paid_Debt'];
        
        Debt__c db1 = new Debt__c();
        db1.Opportunity__c = opp.Id;
        db1.Send_DAP_to__c = acc.id;
        db1.RecordTypeId = rt_Not_to_be_paid_Debt.id;
        insert db1;
        
        
          
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
     /*
     * Opportunity REcord Type = Debt Agreement(DAP)
     */ 
    static testMethod void DAP_Opporunity_with_UnSecured_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Unsecured_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Unsecured_Debt'];
        
        Debt__c db2 = new Debt__c();
        db2.Opportunity__c = opp.Id;
        db2.Send_DAP_to__c = acc.id;
        db2.RecordTypeId = rt_Unsecured_Debt.id;
        insert db2;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
    /*
     * Opportunity REcord Type = Debt Agreement(DAP)
     */ 
    static testMethod void DAP_Opporunity_with_Not_to_be_paid_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Not_to_be_paid_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Not_to_be_paid_Debt'];
        
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        db.RecordTypeId = rt_Not_to_be_paid_Debt.id;
        insert db;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
     /*
     * Opportunity Record Type = Bankruptcy(BKR)
     */
    static testMethod void BKR_Opporunity_with_Secured_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        RecordType rt_Bankruptcy = [Select id,Name From RecordType Where SObjectType ='Opportunity' And DeveloperName ='Bankruptcy'];        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.RecordTypeId = rt_Bankruptcy.id;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Secured_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Secured_Debt'];
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        db.RecordTypeId = rt_Secured_Debt.id;
       	insert db;
        
        //Record Type
        RecordType rt_Not_to_be_paid_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Not_to_be_paid_Debt'];
        
        Debt__c db1 = new Debt__c();
        db1.Opportunity__c = opp.Id;
        db1.Send_DAP_to__c = acc.id;
        db1.RecordTypeId = rt_Not_to_be_paid_Debt.id;
        insert db1;
        
        
          
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    } 
    /*
     * Opportunity Record Type = Bankruptcy(BKR)
     */ 
    static testMethod void BKR_Opporunity_with_UnSecured_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        RecordType rt_Bankruptcy = [Select id,Name From RecordType Where SObjectType ='Opportunity' And DeveloperName ='Bankruptcy'];        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.RecordTypeId = rt_Bankruptcy.id;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Unsecured_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Unsecured_Debt'];
        
        Debt__c db2 = new Debt__c();
        db2.Opportunity__c = opp.Id;
        db2.Send_DAP_to__c = acc.id;
        db2.RecordTypeId = rt_Unsecured_Debt.id;
        insert db2;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
    /*
     * Opportunity Record Type = Bankruptcy(BKR)
     */
    static testMethod void BKR_Opporunity_with_Not_to_be_paid_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        RecordType rt_Bankruptcy = [Select id,Name From RecordType Where SObjectType ='Opportunity' And DeveloperName ='Bankruptcy'];        
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.RecordTypeId = rt_Bankruptcy.id;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Not_to_be_paid_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Not_to_be_paid_Debt'];
        
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        db.RecordTypeId = rt_Not_to_be_paid_Debt.id;
        insert db;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
    /*
     * Opportunity Record Type = Informal Payment Arrangement(IPA)
     */
    static testMethod void IPA_Opporunity_with_Secured_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        RecordType rt_Bankruptcy = [Select id,Name From RecordType Where SObjectType ='Opportunity' And DeveloperName ='Informal_Payment_Arrangement'];        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.RecordTypeId = rt_Bankruptcy.id;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Secured_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Secured_Debt'];
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        db.RecordTypeId = rt_Secured_Debt.id;
       	insert db;
        
        //Record Type
        RecordType rt_Not_to_be_paid_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Not_to_be_paid_Debt'];
        
        Debt__c db1 = new Debt__c();
        db1.Opportunity__c = opp.Id;
        db1.Send_DAP_to__c = acc.id;
        db1.RecordTypeId = rt_Not_to_be_paid_Debt.id;
        insert db1;
        
        
          
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    } 
    /*
     * Opportunity Record Type = Informal Payment Arrangement(IPA)
     */ 
    static testMethod void IPA_Opporunity_with_UnSecured_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        RecordType rt_Bankruptcy = [Select id,Name From RecordType Where SObjectType ='Opportunity' And DeveloperName ='Informal_Payment_Arrangement'];        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.RecordTypeId = rt_Bankruptcy.id;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Unsecured_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Unsecured_Debt'];
        
        Debt__c db2 = new Debt__c();
        db2.Opportunity__c = opp.Id;
        db2.Send_DAP_to__c = acc.id;
        db2.RecordTypeId = rt_Unsecured_Debt.id;
        insert db2;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
    /*
     * Opportunity Record Type = Informal Payment Arrangement(IPA)
     */
    static testMethod void IPA_Opporunity_with_Not_to_be_paid_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        RecordType rt_Bankruptcy = [Select id,Name From RecordType Where SObjectType ='Opportunity' And DeveloperName ='Informal_Payment_Arrangement'];        
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.RecordTypeId = rt_Bankruptcy.id;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Not_to_be_paid_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Not_to_be_paid_Debt'];
        
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        db.RecordTypeId = rt_Not_to_be_paid_Debt.id;
        insert db;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
    /*
     * Opportunity Record Type = Temporary Debt Protection(TDP)
     */
    static testMethod void TDP_Opporunity_with_Secured_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        RecordType rt_Bankruptcy = [Select id,Name From RecordType Where SObjectType ='Opportunity' And DeveloperName ='Informal_Payment_Arrangement'];        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.RecordTypeId = rt_Bankruptcy.id;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Secured_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Secured_Debt'];
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        db.RecordTypeId = rt_Secured_Debt.id;
       	insert db;
        
        //Record Type
        RecordType rt_Not_to_be_paid_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Not_to_be_paid_Debt'];
        
        Debt__c db1 = new Debt__c();
        db1.Opportunity__c = opp.Id;
        db1.Send_DAP_to__c = acc.id;
        db1.RecordTypeId = rt_Not_to_be_paid_Debt.id;
        insert db1;
        
        
          
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    } 
    /*
     * Opportunity Record Type = Temporary Debt Protection(TDP)
     */
    static testMethod void TDP_Opporunity_with_UnSecured_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        RecordType rt_Bankruptcy = [Select id,Name From RecordType Where SObjectType ='Opportunity' And DeveloperName ='Informal_Payment_Arrangement'];        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.RecordTypeId = rt_Bankruptcy.id;
        insert opp;
        
        Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        //Record Type
        RecordType rt_Unsecured_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Unsecured_Debt'];
        
        Debt__c db2 = new Debt__c();
        db2.Opportunity__c = opp.Id;
        db2.Send_DAP_to__c = acc.id;
        db2.RecordTypeId = rt_Unsecured_Debt.id;
        insert db2;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
    /*
     * Opportunity Record Type = Temporary Debt Protection(TDP)
     */
    static testMethod void TDP_Opporunity_with_Not_to_be_paid_Debt()
    {
        //Record Type
        RecordType rt = [Select id,Name From RecordType Where SObjectType ='Account' And Name ='Creditors'];        
        createDBSetting();
        //Test Data        
        //create person account
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',Home_Phone__c='0498979695',Work_Phone__c='0498979695',PersonMobilePhone='+61433186668',Fax='0423452345',Gender__c='Male');
        
        Insert a;
        
        Account acc = new Account(BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank');
        acc.Name = 'test';   
        acc.recordTypeId = rt.Id; 
        acc.Creditor_Type__c = 'Bank';
        acc.Creditor_Email__c = 'test@test.com';
        acc.Creditor_Email_1__c = 'test1@test.com';
        acc.Creditor_Email_2__c = 'test2@test.com';
        acc.Creditor_Email_3__c = 'test3@test.com';
        acc.Creditor_Email_4__c = 'test4@test.com'; 
        acc.Creditor_Email_5__c = 'test5@test.com'; 
        acc.ABN__c = '12312312312'; 
        insert acc;
        
        RecordType rt_Bankruptcy = [Select id,Name From RecordType Where SObjectType ='Opportunity' And DeveloperName ='Informal_Payment_Arrangement'];        
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.StageName = 'Open';       
        opp.AccountId = a.Id;
        opp.CloseDate = system.today(); 
        opp.Number_of_payments1__c=1;  
        opp.Number_of_payments2__c=2;  
        opp.Number_of_payments3__c=3;  
        opp.Number_of_payments4__c=4;  
        opp.Number_of_payments5__c=5;
        opp.RecordTypeId = rt_Bankruptcy.id;
        insert opp;
        
          
        /*ContentVersion contentVersion_1 = new ContentVersion(
            Title='Letter of Authority', 
           VersionData = Blob.valueOf('Letter of Authority'),
            origin = 'H'
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = opp.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; */
          Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='Letter of Authority', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = opp.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
        
     /*   Attachment attach=new Attachment(); 
        attach.Name='Letter of Authority'; 
        Blob bodyBlob=Blob.valueOf('Letter of Authority'); 
        attach.body=bodyBlob; 
        attach.parentId=opp.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;*/
        
        //Record Type
        RecordType rt_Not_to_be_paid_Debt = [Select id,Name From RecordType Where SObjectType ='Debt__c' And DeveloperName ='Not_to_be_paid_Debt'];
        
        Debt__c db = new Debt__c();
        db.Opportunity__c = opp.Id;
        db.Send_DAP_to__c = acc.id;
        db.RecordTypeId = rt_Not_to_be_paid_Debt.id;
        insert db;
         
        Test.startTest();
        PageReference pg = page.SendLOACreditors;        
        pg.getParameters().put('id', opp.Id);    
        Test.setCurrentPage(pg);
        SendLOACreditors uptopp = new SendLOACreditors(); 
        uptopp.allBool=true;          
        uptopp.selectAll(); 
        uptopp.selectEmail();
        uptopp.cancel();
        uptopp.revokeSelectEmail();
        uptopp.cancel();
        Test.stopTest(); 
    }
    public static void createDBSetting()
    {
        list<DB_Setting__c> listDBSetting = new list<DB_Setting__c>();
        for(Integer i=1;i<=16;i++){
            DB_Setting__c mycs1 = new DB_Setting__c();
            if(i==1){
               mycs1.Name = 'Record Type Name'; 
               mycs1.value__c= 'Creditors'; 
               listDBSetting.add(mycs1); 
            }
            if(i==2){
               mycs1.Name = 'Template Name'; 
               mycs1.value__c= 'LOA_HTML'; 
               listDBSetting.add(mycs1);
            }
            if(i==3){
               mycs1.Name = 'Attachment Name'; 
               mycs1.value__c= 'Letter of Authority'; 
               listDBSetting.add(mycs1);
            }
            if(i==4){
               mycs1.Name = 'Revoke Template Name'; 
               mycs1.value__c= 'Notice_to_Cancel_Authority'; 
               listDBSetting.add(mycs1);
            }
            if(i==5){
               mycs1.Name = 'DAP - Nottobepaid Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_DAP_Not_to_be_paid'; 
               listDBSetting.add(mycs1);
            }
            if(i==6){
               mycs1.Name = 'DAP - Secured Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_DAP_Secured_Debt'; 
               listDBSetting.add(mycs1);
            }
            if(i==7){
               mycs1.Name = 'DAP - Unsecured Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_DAP_Unsecured_Debt'; 
               listDBSetting.add(mycs1);
            }
            //
            if(i==8){
               mycs1.Name = 'BKR - Nottobepaid Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_BKR_Not_to_be_paid'; 
               listDBSetting.add(mycs1);
            }
            if(i==9){
               mycs1.Name = 'BKR - Secured Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_BKR_Secured_Debt'; 
               listDBSetting.add(mycs1);
            }
            if(i==10){
               mycs1.Name = 'BKR - Unsecured Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_BKR_Unsecured_Debt'; 
               listDBSetting.add(mycs1);
            }
            //
            if(i==11){
               mycs1.Name = 'IPA - Nottobepaid Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_IPA_Not_to_be_paid'; 
               listDBSetting.add(mycs1);
            }
            if(i==12){
               mycs1.Name = 'IPA - Secured Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_IPA_Secured_Debt'; 
               listDBSetting.add(mycs1);
            }
            if(i==13){
               mycs1.Name = 'IPA - Unsecured Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_IPA_Unsecured_Debt'; 
               listDBSetting.add(mycs1);
            }
            //
            if(i==14){
               mycs1.Name = 'TDP - Nottobepaid Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_TDP_Not_to_be_paid'; 
               listDBSetting.add(mycs1);
            }
            if(i==15){
               mycs1.Name = 'TDP - Secured Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_TDP_Secured_Debt'; 
               listDBSetting.add(mycs1);
            }
            if(i==16){
               mycs1.Name = 'TDP - Unsecured Debt Template Name'; 
               mycs1.value__c= 'LOA_HTML_TDP_Unsecured_Debt'; 
               listDBSetting.add(mycs1);
            }
        }
        insert listDBSetting;
            
    }    
}
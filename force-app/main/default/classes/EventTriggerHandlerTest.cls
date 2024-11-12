/**
 * Created by ersoz on 4/11/20.
 */

@isTest
public with sharing class EventTriggerHandlerTest {

    @IsTest
    static void validateBeforeInsertUpdate () {

        Pendula__Settings__c settings = Pendula__Settings__c.getOrgDefaults();

        settings.Pendula__Create_Event_Activity_Sync__c = true;
        settings.Pendula__Update_Original_Event_Activity__c = true;

        upsert settings;

        Contact testContact = PendulaTestData.createContact();
        insert testContact;

        //creating messages
        Pendula__Message__c testMessage1 = PendulaTestData.createMessage('Outbound', 'Email', '12345', testContact.Id, testContact, Datetime.now());
        Pendula__Message__c testMessage2 = PendulaTestData.createMessage('Outbound','Email', '12346', testContact.Id, testContact, Datetime.now().addSeconds(2));
        Pendula__Message__c testMessage3 = PendulaTestData.createMessage('Outbound','Email', '12347', testContact.Id, testContact, Datetime.now().addSeconds(1));
        insert new List<Pendula__Message__c>{testMessage1, testMessage2, testMessage3};

        //check the event creation for each message with the correct subject
        System.assertEquals(
                3,
        [SELECT COUNT() FROM Event WHERE WhoId =:testContact.Id AND Subject = 'Queued Email communication regarding PF-TEST'],
                'Failed to create Events with correct subject'
        );

        //updating event subjects for each message
        Event testEvent1 = [SELECT Id,Subject,WhatId FROM Event WHERE Pendula__Message__c =: testMessage2.Id];
        testEvent1.Subject = 'Delivered Email communication';

        Event testEvent2 = [SELECT Id,Subject,WhatId FROM Event WHERE Pendula__Message__c =: testMessage3.Id];
        testEvent2.Subject = 'Opened Email communication';

        Event testEvent3 = [SELECT Id,Subject,WhatId FROM Event WHERE Pendula__Message__c =: testMessage1.Id];
        testEvent3.Subject = 'Failed Email communication';

        List<Event> testEventsToUpdate = new List<Event>();
        testEventsToUpdate.addAll(new List<Event>{testEvent1, testEvent2, testEvent3});
        update testEventsToUpdate;

        System.assertEquals(
                'Failed Email communication regarding PF-TEST',
        [SELECT Id,Subject FROM Event WHERE Pendula__Message__c =:testMessage1.Id].Subject,
                'Failed to override the event subject for Failed communication'
        );

        System.assertEquals(
                'Delivered Email communication regarding PF-TEST',
                [SELECT Id,Subject FROM Event WHERE Pendula__Message__c =:testMessage2.Id].Subject,
                'Failed to override the event subject for Delivered communication'
        );

        System.assertEquals(
                'Opened Email communication regarding PF-TEST',
                [SELECT Id,Subject FROM Event WHERE Pendula__Message__c =:testMessage3.Id].Subject,
                'Failed to override the event subject for Opened communication'
        );
    }

    @IsTest
    static void validateAfterInsert () {

        Id recordTypeIdMessage = Schema.SObjectType.Zipline__Message__c.getRecordTypeInfosByName().get('Inbound SMS').getRecordTypeId();

        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        DB_Setting__c dbSetting1 = new DB_Setting__c();
        dbSetting1.Name = 'Record Type Name';
        dbSetting1.Value__c = 'Test';

        DB_Setting__c dbSetting2 = new DB_Setting__c();
        dbSetting2.Name = 'Template Name';
        dbSetting2.Value__c = 'Test';

        insert dbSetting1;
        insert dbSetting2;

        Account testAccount = new Account(
                LastName = 'Test Account',
                Creditor_Type__c = 'Bank',
                RecordTypeId = recordTypeIdAccount);
        insert testAccount;

        testAccount = [SELECT Id,PersonContactId from Account];

        List<Opportunity> testOpportunities = new List<Opportunity>();
        for (Integer i = 1; i < 6 ; i++) {

            testOpportunities.add(
                    new Opportunity(
                            CloseDate = Date.Today(),
                            ForecastCategoryName = 'Pipeline',
                            Name = 'Test Opportunity'+i,
                            Probability = 0.5,
                            StageName = 'HOLD',
                            Opportunity_Mobile_Phone__c = '+61415970967',
                            AccountId = testAccount.Id
                    )
            );
        }
        insert testOpportunities;

        Zipline__Message__c testMessage = new Zipline__Message__c(
                Zipline__Direction__c = 'Inbound',
                RecordTypeId = recordTypeIdMessage,
                Zipline__From_Number__c = '+61415970967',
                Zipline__Message_Date_Time__c = DateTime.now(),
                Zipline__SMS_Message__c = 'Foo Bar'
        );
        insert testMessage;

        Event testEvent = new Event(
                Subject = 'Received SMS Communication',
                WhoId = testAccount.PersonContactId,
                Description = testMessage.Zipline__SMS_Message__c,
                DurationInMinutes = 1,
                ActivityDateTime = Datetime.now(),
                RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Pendula_Communication_Activity').getRecordTypeId()
        );
        insert testEvent;

        System.debug('events ==> '+[SELECT Id,WhatId,WhoId,Pendula__Message__c,Message__c,DurationInMinutes,ActivityDateTime,RecordTypeId,Subject,Description
        from Event]);

        testOpportunities = [SELECT Id from Opportunity];

        System.debug('testOpportunities ==> '+testOpportunities);

        System.assertEquals(
                1,
        [SELECT COUNT() FROM Event
        WHERE WhoId =:testEvent.WhoId
        AND WhatId = :testOpportunities[0].Id
        AND Subject = 'Received SMS Communication'
                AND DurationInMinutes =:testEvent.DurationInMinutes
                AND ActivityDateTime = :testEvent.ActivityDateTime
                AND RecordTypeId = :Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Pendula_Communication_Activity').getRecordTypeId()
        ],
                'Failed to replicate inbound sms event on related opportunity'
        );

    }
}
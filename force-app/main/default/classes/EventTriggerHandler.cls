/**
 * Created by ersoz on 4/11/20.
 * Update event subjects with the relevant wording for Outbound(Pendula) and Inbound(Classic) messages
 */

public with sharing class EventTriggerHandler {

    public static void beforeInsert (List<Event> newEvents) {

        Set<Id> messageIds = new Set<Id>();

        for (Event newEvent : newEvents) {

            messageIds.add(newEvent.Pendula__Message__c);
        }

        setEventSubject(newEvents, messageIds);
    }

    public static void beforeUpdate (List<Event> newEvents, Map<Id,Event> oldMap) {

        Map<Id, Event> messageIdToEvent = new Map<Id, Event>();

        for (Event newEvent : newEvents) {

            Event oldEvent = oldMap.get(newEvent.Id);

            if(newEvent.Subject != oldEvent.Subject){

                messageIdToEvent.put(newEvent.Pendula__Message__c, newEvent);
            }
        }

        setEventSubject(messageIdToEvent.values(), messageIdToEvent.keySet());
    }

    public static void afterInsert(Map<Id,Event> newMap) {

        Map<Id,Event> eventsMap = new Map<Id, Event>();

        Set<Id> contactIds = new Set<Id>();

        //find events created against inbound messages and iterate over them
        for (Event newEvent : [
                SELECT Id,WhoId,Pendula__Message__c,Message__c,DurationInMinutes,ActivityDateTime,RecordTypeId,Subject,Description
                FROM Event WHERE Id IN :newMap.keySet()
                AND RecordTypeId = :Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Pendula_Communication_Activity').getRecordTypeId()
                AND Subject = 'Received SMS communication'
                AND WhatId = NULL
                AND WhoId != NULL
        ]){

            eventsMap.put(newEvent.Id, newEvent);
            contactIds.add(newEvent.WhoId);

            System.debug('eventsMap ===> '+eventsMap);
            System.debug('contactIds ===> '+contactIds);

        }

        Set<Id> accountIds = new Set<Id>();
        Map<Id,Id> contactIdToAccountId = new Map<Id, Id>();

        for (Contact newContact : [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds]){

            contactIdToAccountId.put(newContact.Id, newContact.AccountId);
            accountIds.add(newContact.AccountId);

            System.debug('contactIdToAccountId ===> '+contactIdToAccountId);
            System.debug('accountIds ===> '+accountIds);

        }

        //mapping accounts to their opportunities
        Map<Id,List<Opportunity>> accountIdToOpportunities  = new Map<Id, List<Opportunity>>();
        for(Opportunity newOpportunity : [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :accountIds ORDER BY CreatedDate DESC]){

            List<Opportunity> opportunities = accountIdToOpportunities.get(newOpportunity.AccountId);

            if(opportunities == null){

                opportunities = new List<Opportunity>();

                accountIdToOpportunities.put(newOpportunity.AccountId, opportunities);
            }
            opportunities.add(newOpportunity);
        }
        System.debug('accountIdToOpportunities ===> '+accountIdToOpportunities);

        List<Event> eventsToCreate = new List<Event>();
        for (Event newEvent : eventsMap.values()) {

            Id accountId = contactIdToAccountId.get(newEvent.WhoId);
            List<Opportunity> opportunities = accountIdToOpportunities.get(accountId);

            if(opportunities != null) {

                //creating events for the most recent opportunity of the contacts
                eventsToCreate.add(
                        new Event(
                                Subject = newEvent.Subject,
                                WhatId = opportunities[0].Id,
                                WhoId = newEvent.WhoId,
                                Description = newEvent.Description,
                                DurationInMinutes = newEvent.DurationInMinutes,
                                ActivityDateTime = newEvent.ActivityDateTime,
                                RecordTypeId = newEvent.RecordTypeId
                        )
                );
            }
        }
        System.debug('eventsToCreate ===> '+eventsToCreate);

        if(!eventsToCreate.isEmpty()){
            insert eventsToCreate;
        }
    }

    private static Map<Id,Pendula__Message__c> getPendulaMessageMap(Set<Id> messageIds){

        return new Map<Id, Pendula__Message__c>([
                SELECT Id,Pendula__Flow_Name__c
                FROM Pendula__Message__c
                WHERE Id IN :messageIds
        ]
        );
    }

    private static void setEventSubject( List<Event> events, Set<Id> messageIds){

        Map<Id,Pendula__Message__c> messageMap = getPendulaMessageMap(messageIds);

        System.debug('messageMap =====> ' + messageMap);

        if(messageMap != null) {

            for (Event newEvent : events) {

                if (messageMap.get(newEvent.Pendula__Message__c) != null) {

                    Pendula__Message__c newMessage = messageMap.get(newEvent.Pendula__Message__c);

                    newEvent.Subject += ' regarding ' + newMessage.Pendula__Flow_Name__c;
                }
            }
        }
    }
}
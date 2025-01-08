@isTest
public with sharing class LeadTriggerHandlerTest {
    
    @isTest
    static void leadTriggerHandler_handleTitleNormalization_titleUpdate() {
        List<Lead> leads = new List<Lead>();
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Test', Title = 'vp', Company = 'Test');
        leads.add(lead);
        leads.add(new Lead(FirstName = 'Test', LastName = 'Test', Title = 'mgr', Company = 'Test'));
        leads.add(new Lead(FirstName = 'Test', LastName = 'Test', Title = 'exec', Company = 'Test'));
        leads.add(new Lead(FirstName = 'Test', LastName = 'Test', Title = 'deputy', Company = 'Test'));
        leads.add(new Lead(FirstName = 'Test', LastName = 'Test', Title = '', Company = 'Test'));
        leads.add(new Lead(FirstName = 'Test', LastName = 'Test', Title = null, Company = 'Test'));
        leads.add(new Lead(FirstName = 'Test', LastName = 'Test', Title = '@!$#', Company = 'Test'));

        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leads);
        Test.stopTest();

        Lead updatedLead = leads[0];

        Assert.areEqual('Vice President', updatedLead.Title, 'Title should be updated to Vice President');
        Assert.areEqual('Manager', leads[1].Title, 'Title should be updated to Manager');
        Assert.areEqual('Executive', leads[2].Title, 'Title should be updated to Executive');
        Assert.areEqual('Assistant', leads[3].Title, 'Title should be updated to Assistant');
    }

    @TestSetup
    static void setup(){
        Account acc = new Account(Name = 'Test');
        insert acc;
        insert new Contact(FirstName = 'Test', LastName = 'Test', AccountId = acc.Id, Email = 'test@email.com');

        List<Lead> leads = new List<Lead>();
        Integer numberOfLeads = 2;
        for (Integer i = 0; i < numberOfLeads; i++){
            leads.add(new Lead(FirstName = 'Test' + i, LastName = 'Test' + i, Company = 'Test' + i));
        }
        insert leads;
    }

    @isTest
    static void leadTriggerHandler_handleAutoLeadScoring() {
        List<Lead> leads = [SELECT Id, FirstName, LastName, Company, Title, Lead_Score__c, LeadSource, Phone, Email, Industry FROM Lead];
        
        Lead ld1 = Leads[0];

        for (Lead lead : leads){
            Integer count = 0;

            if (Math.mod(count, 4) == 0) {
                ld1.FirstName = '3';
                ld1.LeadSource = 'Web';
                ld1.Email = 'kim@cloudcodeacademy.com';
            } else if (Math.mod(count, 4)  == 1) {
                lead.FirstName = '5';
                lead.Phone = '6095556742';
            } else if (Math.mod(count, 4)  == 2) {
                lead.FirstName = '10';
                lead.Industry = 'Technology';
            } else if (Math.mod(count, 4) == 3) {
                lead.FirstName = '18';
                ld1.LeadSource = 'Web';
                ld1.Email = 'kim@cloudcodeacademy.com';
                lead.Phone = '6095556742';
                lead.Industry = 'Technology';
            }
            count++;
        }

        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leads);
        Test.stopTest();

        Lead firstLead = leads[0];
        for (Lead lead : leads){
            Assert.areEqual(Integer.valueOf(firstLead.firstName), firstLead.Lead_Score__c, 'Lead score should be updated');
        }
    }

    @isTest
    static void leadTriggerHandler_handleLeadAutoConvert(){
        List<Lead> leads = new List<Lead>();
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test', Email = 'test@email.com');
        leads.add(lead);

        Test.startTest();
        insert leads;
        Test.stopTest();

        Lead updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :lead.Id];
        Assert.isTrue(updatedLead.IsConverted, 'Lead should be converted');
    }
}
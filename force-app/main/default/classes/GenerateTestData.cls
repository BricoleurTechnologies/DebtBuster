@isTest
public class GenerateTestData {
  public static List<Account> generateAccounts(Integer amt){
    List<Account> accList = new List<Account>();
    for(Integer i=0 ; i<amt ; i++) {
      Account acc = new Account();
      acc.Salutation = 'Mr.';  
      acc.PersonTitle = 'Mr.';
      acc.FirstName = 'firstname'+i;
      acc.LastName = 'lastname'+i;
      acc.PersonEmail = 'teser_'+i+'@speedyfinance.com';
      acc.BillingStreet = 'ARTHUR';
      acc.BillingCity = 'NORTH SYDNEY';
      acc.BillingState = 'NSW';
      acc.BillingCountry = 'Australia';
      acc.PersonBirthdate = date.today();
      acc.PersonMobilePhone = '09254454'+i; 
      acc.Phone = '0922518580';
      acc.Fax = '0874451478';  
      acc.Creditor_Email__c = acc.PersonEmail;
      acc.Creditor_Email_1__c = acc.PersonEmail;
      acc.Creditor_Email_2__c = acc.PersonEmail;
      acc.Creditor_Email_3__c = acc.PersonEmail;
      acc.Creditor_Email_4__c = acc.PersonEmail;
      acc.Creditor_Email_5__c = acc.PersonEmail;
      accList.add(acc);
    }
    return accList;
  }
  
  public static List<Contact> generateContacts(Integer amt){
    List<Contact> conList = new List<Contact>();
    for(Integer i=0 ; i<amt ; i++) {
      Contact con = new Contact();
      con.Title = 'Mr.';
      con.FirstName = 'firstname'+i;
      con.LastName = 'lastname'+i;
      con.Email = 'teser_'+i+'@speedyfinance.com';
      con.MailingStreet = 'ARTHUR';
      con.MailingCity = 'NORTH SYDNEY';
      con.MailingState = 'New South Wales';
      con.MailingCountry = 'Australia';
      con.Birthdate = date.today();
      conList.add(con);
    }
    return conList;
  }
  
  public static List<Opportunity> generateOpportunities(Integer amt, Id accountId){
    List<Opportunity> oppList = new List<Opportunity>();
    for(Integer i=0 ; i<amt ; i++) {
      Opportunity opp = new Opportunity();
      opp.Name = 'TestOpp'+i;
      opp.AccountId = accountId;
      opp.CloseDate = date.today();
      opp.StageName = '9- Compliance Completed';
      opp.Amount = 5000000;
      opp.AFSA_Number__c = '123456';
      opp.Date_Accepted_For_Processing__c = system.today();
      opp.Final_Date_For_Voting__c = system.today().addDays(1);
      oppList.add(opp);
    }
    return oppList;
  }

  public static List<Debt__c> generateDebt(Integer amt, Id oppId, Id accountId){
    List<Debt__c> debtList = new List<Debt__c>();
    for(Integer i=0 ; i<amt ; i++) {
      Debt__c debt = new Debt__c();
      debt.Opportunity__c = oppId;
      debt.Send_DAP_to__c = accountId;
      debtList.add(debt);
    }
    return debtList;
  }
}
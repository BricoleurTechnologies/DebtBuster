@isTest
public class TestCreateAndDownloadJson {
    public static Debt__c testCreateDebt(string NatureOfDebt,string oppID, string accID) {
        Id devRecordTypeId = Schema.SObjectType.Debt__c.getRecordTypeInfosByName().get('3. Not to be paid Debt').getRecordTypeId();
        
        Debt__c debt = new Debt__C(Send_DAP_to__c = accID, Opportunity__c = oppID,Account_Reference_Number__c='1234121111111234',
                                   Asset_Type_AFSA__c = 'Book Debt',Asset_Description__c='Sample',Asset_Value__c=1200,Percentage_Owned__c='100',
                                   Amount_Owing__c=5000,Account_Status__c = 'Up to Date',Related_If_Yes__c=true,
                                   If_related_then_Relationship_to_you_pick__c='Other',Required_Repayment__c=500,If_related_then_Amount_paid_for_debt__c=2500,
                                   Participating_in_Dividends__c = 'Yes',RecordTypeId = devRecordTypeId,Nature_of_Debt__c=NatureOfDebt);
        return debt;
    }
    static testMethod void testMethodIPA() {
        List<Debt__c> debtList = new list<Debt__c>();
        list<Payment_Bric__c> paymentList = new list<Payment_Bric__c>();
        DB_Setting__c db1 = new DB_Setting__c(Name = 'Attachment Name' , Value__c = 'Letter of Authority' );
        Insert db1;
        DB_Setting__c db2 = new DB_Setting__c(Name = 'Record Type Name' , Value__c = 'Creditors' );
        Insert db2;
        DB_Setting__c db3 = new DB_Setting__c(Name = 'Template Name' , Value__c = 'LOA_HTML' );
        Insert db3;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        //Phone number with '+61'
        //with no id in Debtware
        Account a = new Account(Salutation='Mr',LastName='Marshall',Firstname='Marvin',MiddleName='M',Other_Given_Name_s__pc='Martin',
                                RecordTypeId = recordTypeIdAccount,Date_of_Birth__c=system.today(),PersonEmail='devteam@voltum.com.au',PersonMobilePhone='0433184445');
        
        Insert a;
        Account b1 = new Account(Name='ABC & Co',BillingStreet='100 Market Street',BillingCity='Sydney',BillingCountryCode='AU',
                                 BillingStateCode='NSW',BillingPostalCode='2000',ShippingStreet='100 Market Street',ShippingCity='Sydney',ShippingCountryCode='AU',
                                 ShippingStateCode='NSW',ShippingPostalCode='2000',Creditor_Type__c='Bank',ABN__c = '12345678910',Creditor_Email__c='devteam@voltum.com.au');
        
        Insert b1;
        list<Opportunity> opplIst= new list<Opportunity>();
        Id ipaOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Informal Payment Arrangement').getRecordTypeId();
        Id DebtAgreementoppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Agreement').getRecordTypeId();
        Opportunity ipaOpportunity = new Opportunity();
        ipaOpportunity.CloseDate = Date.Today();
        ipaOpportunity.ForecastCategoryName = 'Pipeline';
        ipaOpportunity.Name = 'Test Opportunity';
        ipaOpportunity.Probability = 0.5;
        ipaOpportunity.StageName = 'Outstanding Requested';
        ipaOpportunity.Opportunity_Mobile_Phone__c = '+61415970967';
        ipaOpportunity.AccountId = a.Id;
        ipaOpportunity.Do_you_own__c = true;
        ipaOpportunity.Are_you_renting_boarding__c = FALSE;
        ipaOpportunity.Are_you_buying__c = FALSE;
        ipaOpportunity.Receiving_free_accommodation__c = FALSE;
        ipaOpportunity.Have_interes_in_property_under_l_t_lease__c = FALSE;
        
        ipaOpportunity.address1__c='test';
        ipaOpportunity.suburb1__c='test'; 
        ipaOpportunity.State1__c='QLD';
        ipaOpportunity.Postcode1__c='4870';
        ipaOpportunity.Year__c=2000;
        ipaOpportunity.Month__c=01;
        ipaOpportunity.Number_of_payments1__c=12;
        ipaOpportunity.Weekly_fortnightly_monthly1__c='Weekly'; 
        ipaOpportunity.Amount_of_each_payment1__c=85;
        ipaOpportunity.Number_of_payments2__c=12;
        ipaOpportunity.Weekly_fortnightly_monthly2__c='Weekly'; 
        ipaOpportunity.Amount_of_each_payment2__c=85;
        ipaOpportunity.Number_of_payments3__c=12;
        ipaOpportunity.Weekly_fortnightly_monthly3__c='Weekly'; 
        ipaOpportunity.Amount_of_each_payment3__c=85;
        ipaOpportunity.Number_of_payments4__c=12;
        ipaOpportunity.Weekly_fortnightly_monthly4__c='Weekly'; 
        ipaOpportunity.Amount_of_each_payment4__c=85;
        ipaOpportunity.Number_of_payments5__c=12;
        ipaOpportunity.Weekly_fortnightly_monthly5__c='Weekly'; 
        ipaOpportunity.Amount_of_each_payment5__c=85;
        ipaOpportunity.RecordTypeid=ipaOppRecordTypeId;
        ipaOpportunity.Employed_as1__c='Actor'; 
        ipaOpportunity.Occupations_Code_ANZSCO1__c='899415';
        ipaOpportunity.Employer_Name1__c='test744';
        ipaOpportunity.Employed_as2__c='Actor';
        ipaOpportunity.Occupations_Code_ANZSCO2__c='253312'; 
        ipaOpportunity.Employer_Name2__c='empTest45';
        opplIst.add(ipaOpportunity); 
        
        Opportunity daOpportunity = new Opportunity();
        daOpportunity.CloseDate = Date.Today();
        daOpportunity.ForecastCategoryName = 'Pipeline';
        daOpportunity.Name = 'Test Opportunity';
        daOpportunity.Probability = 0.5;
        daOpportunity.StageName = 'Outstanding Requested';
        daOpportunity.Opportunity_Mobile_Phone__c = '+61415970967';
        daOpportunity.AccountId = a.Id;
        daOpportunity.Do_you_own__c = true;
        daOpportunity.Are_you_renting_boarding__c = FALSE;
        daOpportunity.Are_you_buying__c = FALSE;
        daOpportunity.Receiving_free_accommodation__c = FALSE;
        daOpportunity.Have_interes_in_property_under_l_t_lease__c = FALSE;
        daOpportunity.RecordTypeid= DebtAgreementoppRecordTypeId;
        daOpportunity.address1__c='test';
        daOpportunity.suburb1__c='test'; 
        daOpportunity.State1__c='QLD';
        daOpportunity.Postcode1__c='4870';
        daOpportunity.Year__c=2000;
        daOpportunity.Month__c=01;
        daOpportunity.Yes_Are_you_currentl_in_business_as_sol__c='Yes';
        daOpportunity.Business_Partner_s_Name_if_applicable__c='test';
        daOpportunity.What_is_the_nature_of_this_business__c='test';
        daOpportunity.Yes_have_you_been_a_unit_holder_in__c='Yes';
        daOpportunity.Wages_after_tax__c=23; 
        daOpportunity.Allowances_overtime_fringe_benefits__c=23;
        daOpportunity.Taxable_centrelink_benefits__c=252;
        daOpportunity.Non_taxable_centrelink_benefits__c=55;
        daOpportunity.Regular_income_from_tenants_for_rent__c=5645;
        daOpportunity.After_tax_income_from_second_jobs__c=85;
        daOpportunity.Child_spouse_maintenance_received__c=855;
        daOpportunity.Other_Income__c=855;
        daOpportunity.Type_of_Industry1__c='Accommodation and Food Services';
         daOpportunity.Employer_Address__c='164 Hogg Street';
        
        daOpportunity.Employed_as2__c='Vehicle Body Builder';
        daOpportunity.Occupations_Code_ANZSCO2__c='342211';
        daOpportunity.Employer_Name2__c='TEST';
        
            daOpportunity.Date_sold_if_applicable4__c=date.today();
            daOpportunity.Date_sold_if_applicable3__c=date.today();
        daOpportunity.Rent_for_Accomodation__c=55;
        daOpportunity.Board__c= 44;
        daOpportunity.Mortgage_payment__c=44;
        daOpportunity.Rates__c=823;
        daOpportunity.Home_maintenance__c=55;
        daOpportunity.Food_including_groceries_and_take_away__c=828;
        daOpportunity.Phone_mobile_internet__c=828; 
        daOpportunity.Entertainment_pay_TV__c=82;
        daOpportunity.Electricity_gas_water__c=85; 
        daOpportunity.Health_insurance__c=82 ;
        daOpportunity.Medical_chemist__c=82;
        daOpportunity.Car_payments_to_secured_creditor__c=82 ;
        daOpportunity.Car_fuel_registration_insurance_maint__c=82; 
        daOpportunity.Transport__c=82;
        daOpportunity.Other_insurance__c=82;
        daOpportunity.School_fees_and_expenses__c=82;
        daOpportunity.Child_care__c=82;
        daOpportunity.Child_support_and_maintenance__c=82;
        daOpportunity.Other_expenses_for_children_eg_sport_mu__c=82 ;
        daOpportunity.Clothes_shoes_hairdressing__c=82;
        daOpportunity.Incidentals_e_g_cigarettes_books_mag__c=82;
        daOpportunity.Payments_to_creditors_not_receiving_a__c=8 ;
        daOpportunity.Other_payments_to_secured_creditors__c=85;
        daOpportunity.Rental_payments_for_household_goods__c=82;
        daOpportunity.Other_household_expenses__c=82;
        daOpportunity.Employed_as1__c='Tyre Fitter'; 
        daOpportunity.Occupations_Code_ANZSCO1__c='899415';
        daOpportunity.Employer_Name1__c='Greenes Tyre & Brake Service';
        daOpportunity.Employed_as2__c='Cardiologist';
        daOpportunity.Occupations_Code_ANZSCO2__c='253312'; 
        daOpportunity.Unsecured_Assets_Description1__c='Furniture'; 
        daOpportunity.Estimated_Total_Value1__c=5000; 
        daOpportunity.Percentage_Owned1__c=100;
        daOpportunity.Unsecured_Assets_Description2__c='Furniture'; 
        daOpportunity.Estimated_Total_Value2__c=5000; 
        daOpportunity.Percentage_Owned2__c=100;
        daOpportunity.Unsecured_Assets_Description3__c='Furniture'; 
        daOpportunity.Estimated_Total_Value3__c=5000; 
        daOpportunity.Percentage_Owned3__c=100;
        daOpportunity.Unsecured_Assets_SubClassification1__c='Book Debt';
        daOpportunity.address2__c='test'; 
        daOpportunity.suburb2__c='test'; 
        daOpportunity.State2__c='QLD';
        daOpportunity.Postcode2__c='4870';
        daOpportunity.Did_Do_you_own1__c='No';
        daOpportunity.Domestic_discord_relationship_breakdowns__c=true;
        daOpportunity.ill_health_absence_of_health_insurance__c=true;
        daOpportunity.Other_please_specify2__c='Test';
        daOpportunity.Weekly_fortnightly_monthly1__c='Weekly'; 
        daOpportunity.Amount_of_each_payment1__c=52; 
        daOpportunity.Unsecured_Assets_Description4__c='test'; 
        daOpportunity.Estimated_Total_Value4__c=5454; 
        daOpportunity.Percentage_Owned4__c=35;
        daOpportunity.Debtors_expense_for_supporting_partner__c=522;	
        daOpportunity.Source_of_lump_sum_payment_or_details_of__c=null;
        daOpportunity.If_yes_provide_details__c='true';
        daOpportunity.Gambling_or_speculation__c=true;
        
        daOpportunity.Weekly_fortnightly_monthly2__c='Weekly'; 
        daOpportunity.Amount_of_each_payment2__c=52; 
        daOpportunity.Weekly_fortnightly_monthly3__c='Weekly'; 
        daOpportunity.Amount_of_each_payment3__c=52; 
        daOpportunity.Weekly_fortnightly_monthly4__c='Weekly'; 
        daOpportunity.Amount_of_each_payment4__c=52; 
        daOpportunity.Weekly_fortnightly_monthly5__c='Weekly'; 
        daOpportunity.Amount_of_each_payment5__c=52; 
        daOpportunity.address4__c='878 Old Cooma Road'; 
        daOpportunity.suburb4__c='Queanbeyan'; 
        daOpportunity.State4__c='NSW'; 
        daOpportunity.Postcode4__c='NSW';
         daOpportunity.address3__c='878 Old Cooma Road'; 
        daOpportunity.suburb3__c='Queanbeyan'; 
        daOpportunity.State3__c='NSW'; 
        daOpportunity.Postcode3__c='NSW';
        
        
        
        opplIst.add(daOpportunity);
        
        Insert opplIst;
        
        system.debug('@@'+opplIst[1].Employed_as1__c+'@@'+opplIst[1].Occupations_Code_ANZSCO1__c+'@@'+opplIst[1].Employer_Name1__c);
        
        
        Id devRecordTypeId = Schema.SObjectType.Debt__c.getRecordTypeInfosByName().get('1. Secured Debt').getRecordTypeId();
        Id notToBePaidDebtId = Schema.SObjectType.Debt__c.getRecordTypeInfosByName().get('3. Not to be paid Debt').getRecordTypeId();
        Debt__c d1 = new Debt__C(Send_DAP_to__c = b1.Id, Opportunity__c = ipaOpportunity.Id,Account_Reference_Number__c='1234121111111234',
                                 Asset_Type_AFSA__c = 'Book Debt',Asset_Description__c='Sample',Asset_Value__c=1200,Percentage_Owned__c='100',
                                 Amount_Owing__c=5000,Nature_of_Debt__c = 'House Mortgage',Account_Status__c = 'Up to Date',Related_If_Yes__c=true,
                                 If_related_then_Relationship_to_you_pick__c='Other',Required_Repayment__c=500,If_related_then_Amount_paid_for_debt__c=2500,
                                 Participating_in_Dividends__c = 'Yes',RecordTypeId = devRecordTypeId);
        debtList.add(d1);
        
        
        Debt__c d2 = new Debt__C(Send_DAP_to__c = b1.Id, Opportunity__c = daOpportunity.Id,Account_Reference_Number__c='1234121111111234',
                                 Asset_Type_AFSA__c = 'Book Debt',Asset_Description__c='Sample',Asset_Value__c=1200,Percentage_Owned__c='100',
                                 Amount_Owing__c=5000,Account_Status__c = 'Up to Date',Related_If_Yes__c=true,
                                 If_related_then_Relationship_to_you_pick__c='Other',Required_Repayment__c=500,If_related_then_Amount_paid_for_debt__c=2500,
                                 Participating_in_Dividends__c = 'Yes',RecordTypeId = devRecordTypeId,Nature_of_Debt__c='Other');
        debtList.add(d2);
        
        Debt__c d3 = new Debt__C(Send_DAP_to__c = b1.Id, Opportunity__c = daOpportunity.Id,Account_Reference_Number__c='1234121111111234',
                                 Asset_Type_AFSA__c = 'Book Debt',Asset_Description__c='Sample',Asset_Value__c=1200,Percentage_Owned__c='100',
                                 Amount_Owing__c=5000,Nature_of_Debt__c = 'House Mortgage',Account_Status__c = 'Up to Date',Related_If_Yes__c=true,
                                 If_related_then_Relationship_to_you_pick__c='Other',Required_Repayment__c=500,If_related_then_Amount_paid_for_debt__c=2500,
                                 Participating_in_Dividends__c = 'Yes',RecordTypeId = notToBePaidDebtId);
        debtList.add(d3);
        
        
        debtList.add(testCreateDebt('Credit Card',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Store Card',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Personal Loan',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Motor Vehicle Security',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('House Mortgage',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Chattel Mortgage',daOpportunity.id,b1.id));
       // debtList.add(testCreateDebt('Overdraft Account',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Overdrawn Accounts',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Business Security',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Bill of Sale',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Charge',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Hire Purchase',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Lease',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Lien',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Other',daOpportunity.id,b1.id));
        debtList.add(testCreateDebt('Not applicable',daOpportunity.id,b1.id));
        
        insert debtList;         
        
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Image ';
        cv.PathOnClient = 'TestImage.JSON';
string data='[{\"Reference\":5789,\"Title\":\"Mr\",\"FirstName\":\"Test\",\"MiddleNames\":\"Roy\",\"LastName\":\"Person\",\"DateOfBirth\":\"1955-02-01\",\"Address1\":\"Level1SuiteA,99GeorgeStreet\",\"Address2\":\"\",\"City\":\"LAUNCESTON\",\"State\":\"TAS\",\"CountryCode\":\"AU\",\"Postcode\":\"7250\",\"PostalAddressLine1\":\"POBox388\",\"PostalAddressLine2\":\"\",\"PostalAddressSuburb\":\"LAUNCESTON\",\"PostalAddressState\":\"TAS\",\"PostalAddressPostcode\":\"7250\",\"PostalAddressCountryCode\":\"AU\",\"MobilePhone\":\"0438111111\",\"HomePhone\":\"\",\"WorkPhone\":\"0363230028\",\"Email\":\"info@datalive.com.au\",\"AfsaNumber\":\"QLD12345/05/7\",\"WarningNote\":\"\",\"DateAcceptedNpii\":\"2022-05-05\",\"LeadSource\":\"Newspaper\",\"AutomateRepayments\":false,\"AdminFeeCalculatedOnDividends\":false,\"ApplyExpenseMaterialityPaymentLimit\":false,\"AgreementType\":\"D\",\"AccountManager\":\"Team2\",\"Consultant\":\"Team1\",\"Debts\":[{\"CreditorName\":\"AustraliaandNewZealandBankingGroupLimited(ANZ)\",\"DepositReference\":\"Z333\",\"OnSoldHistory\":[],\"JointNotSharedPaidAmount\":0.0,\"Amount\":12000.0000,\"Reference\":\"Z333233355353\",\"DateJoined\":\"2021-03-14\",\"IsParticipating\":false,\"DividendPayments\":[{\"CreditorName\":\"AustraliaandNewZealandBankingGroupLimited(ANZ)\",\"PaymentMethod\":\"DirectDeposit\",\"Reference\":\"Z333\",\"DatePaid\":\"2022-03-28\",\"DateReconciled\":\"2023-03-14\",\"DateDisbursed\":\"2023-03-14\",\"Amount\":286.9800},{\"CreditorName\":\"AustraliaandNewZealandBankingGroupLimited(ANZ)\",\"PaymentMethod\":\"DirectDeposit\",\"Reference\":\"Z333\",\"DatePaid\":\"2022-09-28\",\"Amount\":50.6500}],\"AdministratorRate\":0.0},{\"CreditorName\":\"NationalAustraliaBankLimited\",\"OnSoldHistory\":[{\"CreditorName\":\"CommonwealthBankofAustralia\",\"DateOnsold\":\"2023-03-14\",\"Amount\":15000.0000,\"Reference\":\"4125xxxxxxxx4447\",\"DateJoined\":\"2021-03-14\",\"IsParticipating\":false,\"DividendPayments\":[],\"AdministratorRate\":0.0}],\"JointNotSharedPaidAmount\":0.0,\"Amount\":15000.0000,\"Reference\":\"4125xxxxxxxx4447\",\"DateJoined\":\"2023-03-14\",\"IsParticipating\":false,\"DebtNature\":\"CC\",\"IsOriginal\":false,\"DividendPayments\":[{\"CreditorName\":\"NationalAustraliaBankLimited\",\"PaymentMethod\":\"Cheque\",\"Reference\":\"8001\",\"DatePaid\":\"2022-03-28\",\"DateReconciled\":\"2023-03-14\",\"DateDisbursed\":\"2023-03-14\",\"Amount\":358.7300},{\"CreditorName\":\"NationalAustraliaBankLimited\",\"PaymentMethod\":\"Cheque\",\"Reference\":\"9000\",\"DatePaid\":\"2022-09-28\",\"Amount\":63.3000}],\"AdministratorRate\":0.0},{\"CreditorName\":\"WestpacBankingCorporation\",\"OnSoldHistory\":[],\"JointNotSharedPaidAmount\":0.0,\"Amount\":2500.0000,\"Reference\":\"889977\",\"DateJoined\":\"2021-03-14\",\"IsParticipating\":false,\"DebtNature\":\"HP\",\"DividendPayments\":[{\"CreditorName\":\"WestpacBankingCorporation\",\"PaymentMethod\":\"DirectDeposit\",\"Reference\":\"ADAMSMar2022\",\"DatePaid\":\"2022-03-28\",\"DateReconciled\":\"2023-03-14\",\"DateDisbursed\":\"2023-03-14\",\"Amount\":59.7900}],\"AdministratorRate\":0.0}],\"DebtAgreements\":[{\"DateLodged\":\"2021-12-17\",\"DeadlineDate\":\"2021-03-05\",\"DateCommenced\":\"2021-05-14\",\"Offer\":20000.0000,\"AdministratorRate\":0.10000000,\"AdministratorAdjustment\":0.0,\"RealisationAdjustment\":0.0,\"EqualisationDate\":\"2023-03-14\",\"OriginalDebtTotal\":29500.00,\"ProposalExpensesBankingFeesAmount\":0.0,\"ProposalExpensesValuatingAssetsAmount\":0.0,\"ProposalExpensesEligibilityDebtorAmount\":0.0,\"ProposalExpensesOtherAmount\":0.0,\"FirstPaymentDate\":\"2022-03-01\",\"RepaymentSchedule\":[{\"Count\":50,\"Frequency\":\"Weekly\",\"Amount\":150.00},{\"Count\":50,\"Frequency\":\"Weekly\",\"Amount\":200.00},{\"Count\":5,\"Frequency\":\"Weekly\",\"Amount\":500.00}],\"Expenses\":[],\"Repayments\":[{\"DatePaid\":\"2022-03-08\",\"DateReconciled\":\"2023-03-14\",\"AmountPaid\":150.0000,\"Reference\":\"DD45443\",\"RealisationsComponent\":10.5000,\"AdminComponent\":15.0000,\"RealisationsRate\":0.0700,\"AdminRate\":0.1000}]},{\"DateLodged\":\"2022-09-01\",\"DeadlineDate\":\"2022-09-28\",\"DateCommenced\":\"2022-10-14\",\"Offer\":18000.0000,\"AdministratorRate\":0.10000000,\"AdministratorAdjustment\":0.0,\"RealisationAdjustment\":0.0,\"EqualisationDate\":\"2021-05-14\",\"DividendsFirstPaymentDate\":\"2022-06-01\",\"DividendsFrequency\":3,\"ProposalExpensesBankingFeesAmount\":0.0,\"ProposalExpensesValuatingAssetsAmount\":0.0,\"ProposalExpensesEligibilityDebtorAmount\":0.0,\"ProposalExpensesOtherAmount\":0.0,\"FirstPaymentDate\":\"2022-03-14\",\"RepaymentSchedule\":[{\"Count\":60,\"Frequency\":\"Weekly\",\"Amount\":200.00},{\"Count\":50,\"Frequency\":\"Weekly\",\"Amount\":100.00}],\"Expenses\":[{\"Date\":\"2023-03-14\",\"Amount\":200.00,\"Type\":\"Eligibility\",\"Description\":\"Reports\"}],\"Repayments\":[]}],\"ArrearsPeriods\":[{\"DefaultDate\":\"2022-06-16\",\"ReportSent\":\"2022-06-17\"},{\"DefaultDate\":\"2022-09-22\",\"ReportSent\":\"2022-09-25\"}],\"AdminPayments\":[{\"Amount\":85.0000,\"PaymentMethod\":\"DirectDeposit\",\"Reference\":\"ADAMSMar2022\",\"DatePaid\":\"2022-03-28\",\"DateReconciled\":\"2023-03-14\",\"ChargePeriodTo\":\"2022-03-28\",\"DateDisbursed\":\"2023-03-14\"}],\"AfsaPayments\":[{\"Amount\":59.5000,\"PaymentMethod\":\"Cheque\",\"Reference\":\"8000\",\"DatePaid\":\"2022-03-28\",\"DateReconciled\":\"2023-03-14\",\"ChargePeriodTo\":\"2022-03-28\",\"DateDisbursed\":\"2023-03-14\"}],\"Tags\":[\"Confidential\"],\"Notes\":[{\"Note\":\"\",\"Date\":\"2023-03-14\",\"ReminderDate\":\"2022-03-14\",\"ReminderUserGroup\":\"Team1\",\"ReminderComment\":\"123\"}]}]';
        cv.VersionData = Blob.valueOf(data);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion cversion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = ipaOpportunity.id;
        cdl.ContentDocumentId = cversion.ContentDocumentId;
        cdl.shareType = 'V';
        insert cdl;
        
        Repayment__c repaymentObj= new Repayment__c();
        repaymentObj.Date_Paid_Bric__c=system.today();
        repaymentObj.Date_Reconciled_Bric__c=system.today();
        repaymentObj.Amount_Paid_Bric__c=55;
        repaymentObj.Reference_Bric__c='3541';
        repaymentObj.Realisations_Component_Bric__c=12;
        repaymentObj.Admin_Component_Bric__c=55;
        repaymentObj.Realisations_Rate_Bric__c=55;
        repaymentObj.Admin_Rate_Bric__c=35;
        repaymentObj.Opportunity_Bric__c=ipaOpportunity.id;
        insert repaymentObj;
        
        Payment_Bric__c paymentOBJ1= new Payment_Bric__c();
        paymentOBJ1.Payment_Type_Bric__c='AFSA Payment';
        paymentOBJ1.Reference_Bric__c='55151';
        paymentOBJ1.Date_Paid_Bric__c=system.today();
        paymentOBJ1.Date_Reconciled_Bric__c=system.today();
        paymentOBJ1.Payment_Method_Bric__c='Direct Deposit';
        paymentOBJ1.Date_Disbursed_Bric__c=system.today();
        paymentOBJ1.Amount_Bric__c=54;
        paymentOBJ1.Charge_Period_To_Bric__c=system.today();
        paymentOBJ1.Opportunity_Bric__c=ipaOpportunity.id;
        paymentList.add(paymentOBJ1);
        
        Payment_Bric__c paymentOBJ2= new Payment_Bric__c();
        paymentOBJ2.Payment_Type_Bric__c='Admin Payment';
        paymentOBJ2.Reference_Bric__c='55151';
        paymentOBJ2.Date_Paid_Bric__c=system.today();
        paymentOBJ2.Date_Reconciled_Bric__c=system.today();
        paymentOBJ2.Payment_Method_Bric__c='Direct Deposit';
        paymentOBJ2.Date_Disbursed_Bric__c=system.today();
        paymentOBJ2.Amount_Bric__c=54;
        paymentOBJ2.Charge_Period_To_Bric__c=system.today();
        paymentOBJ2.Opportunity_Bric__c=ipaOpportunity.id;
        paymentList.add(paymentOBJ2);
        
        insert paymentList;
        
        Test.startTest();
        CreateAndDownloadJson.getRelatedFilesByRecordId(ipaOpportunity.Id);	
        CreateAndDownloadJson.getRelatedFilesByRecordId(daOpportunity.Id);
        ImportJSON.createSFRecordFromJson(cversion.id);
        ImportJSON.createSFRecordFromJson(cversion.id);
        Test.stopTest();
        
        
        
    }
}
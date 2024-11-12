public class CreateAndDownloadJson {
    @AuraEnabled
    public static Void saveJsonAsFile(String obj,ID recordID){
        String Title='';
        Opportunity oppForRecordtype=[Select id,name,recordtype.name from Opportunity where id=:recordID];
        Title='Application '+oppForRecordtype.name;
        List<ContentDocumentLink>  cdlOnOppOldList=[SELECT Id, LinkedEntityId, ContentDocumentId,Visibility, IsDeleted, ShareType,ContentDocument.Title,ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId =:recordID AND ContentDocument.Title=:Title];
        if(cdlOnOppOldList.size()>0){
            Delete cdlOnOppOldList;
            
        }
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; 
        if(oppForRecordtype.recordtype.name=='Debt Agreement'){
            conVer.PathOnClient = 'testing.XML';
            conVer.Title = 'Application '+oppForRecordtype.name; 
        }
        else if(oppForRecordtype.recordtype.name=='Informal Payment Arrangement'){
            conVer.PathOnClient = 'testing.JSON';
            conVer.Title = 'Application '+oppForRecordtype.name;
        }
        conVer.VersionData = Blob.valueOf(obj);
        insert conVer;
        
        
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = recordId; 
        conDocLink.ContentDocumentId = conDoc; 
        conDocLink.shareType = 'V';
        insert conDocLink;          
    }
    @AuraEnabled
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        System.debug('@@@'+recordId);
        String StringObj;
        Opportunity OpprecordType=[Select id, RecordType.Name from Opportunity where id=:recordId];
        IF(OpprecordType.RecordType.Name=='Informal Payment Arrangement'){
            StringObj=jSONConversion(recordId);
        }
        else if(OpprecordType.RecordType.Name=='Debt Agreement'){
            StringObj=xmlGenerator(recordId);
        }
        if(StringObj!=null){
            saveJsonAsFile(StringObj,recordId);  
        }
        
        
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                     FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }
    
    public static String jSONConversion(String recordId) {
        String jsonString='';
        WrapperImport jwr = new WrapperImport();
        jwr=createWrapper(recordId);
        jsonString=JSON.serialize(jwr,true);
        
        
        return jsonString;
    }
    public static WrapperImport createWrapper(String recordId){
        WrapperImport wrapperObj=new WrapperImport();
        WrapperImport.Debts[] debtList= new WrapperImport.Debts[]{};
            List<WrapperImport.RepaymentSchedule> repaymentScheduleInnerList=new List<WrapperImport.RepaymentSchedule>();
        List<WrapperImport.DebtAgreements> debtAgreementsInnerList=new List<WrapperImport.DebtAgreements>();
        List<wrapperImport.Repayments> repaymentList= new List<wrapperImport.Repayments>();
        
        List<WrapperImport.DividendPayments> dividentPaymentslist= new List<WrapperImport.DividendPayments>();
        List<WrapperImport.AdminPayments> adminPaymentslist= new List<WrapperImport.AdminPayments>();
        List<WrapperImport.AfsaPayments> afsaPaymentslist= new List<WrapperImport.AfsaPayments>();
        Opportunity opp=[select id,Reference__c,Ezidebit__c,Account.Salutation,account.FirstName,account.MiddleName,Expense_Eligibility_Amount_Per__c,
                         account.LastName,account.Date_of_Birth__c,account.PersonMailingCity,Equalisation_Date_Bric__c,
                         account.PersonMailingState,account.PersonMailingCountryCode,account.PersonMailingPostalCode,
                         account.PersonMailingStreet,DA_Amount__c,Fees_for_administrator_to_administer_deb__c,Expense_Other_Amount_Per__c,
                         account.Mobile_Phone__c,Submitted_to_AFSA_Date__c,Final_Date_For_Voting__c,Expense_Banking_Fees_Amount_Per__c,
                         account.Home_Phone__c,account.Work_Phone__c,account.PersonEmail,AFSA_Number__c,
                         Date_Accepted_For_Processing__c,LeadSource,Number_of_payments1__c,Expense_Valuating_Amount_Per__c,
                         Number_of_payments2__c,Number_of_payments3__c,Number_of_payments4__c,Number_of_payments5__c,
                         Date_of_debtor_s_rst_payment_to_adminis__c,
                         Weekly_fortnightly_monthly1__c,Amount_of_each_payment1__c,
                         Weekly_fortnightly_monthly2__c,Amount_of_each_payment2__c,
                         Weekly_fortnightly_monthly3__c,Amount_of_each_payment3__c,
                         Weekly_fortnightly_monthly4__c,Amount_of_each_payment4__c,
                         Weekly_fortnightly_monthly5__c,Amount_of_each_payment5__c from Opportunity where Opportunity.ID=:recordId];
        
        wrapperObj.Reference=opp.Ezidebit__c==null?0:Integer.valueOf(opp.Ezidebit__c);
        wrapperObj.Title=opp.Account.Salutation==null?'':opp.Account.Salutation;
        wrapperObj.FirstName=opp.account.FirstName==null?'':opp.account.FirstName;
        wrapperObj.MiddleNames=opp.account.MiddleName==null?'':opp.account.MiddleName;
        wrapperObj.LastName=opp.account.LastName==null?'':opp.account.LastName;
        if(opp.account.Date_of_Birth__c!=null){
            wrapperObj.DateOfBirth=convertToDateTime(opp.account.Date_of_Birth__c);	   
        }
        wrapperObj.PostalAddressLine1=opp.account.PersonMailingStreet==null?'':opp.account.PersonMailingStreet;
        wrapperObj.City=opp.account.PersonMailingCity==null?'':opp.account.PersonMailingCity;                   
        wrapperObj.State=opp.account.PersonMailingState==null?'':opp.account.PersonMailingState;
        wrapperObj.CountryCode=opp.account.PersonMailingCountryCode==null?'':opp.account.PersonMailingCountryCode;
        wrapperObj.Postcode=opp.account.PersonMailingPostalCode==null?'':opp.account.PersonMailingPostalCode;
        wrapperObj.MobilePhone=opp.account.Mobile_Phone__c==null?'':opp.account.Mobile_Phone__c;
        wrapperObj.HomePhone= opp.account.Home_Phone__c==null?'':opp.account.Home_Phone__c;
        wrapperObj.WorkPhone= opp.account.Work_Phone__c==null?'':opp.account.Work_Phone__c;
        wrapperObj.Email= opp.account.PersonEmail==null?'':opp.account.PersonEmail;
        wrapperObj.AfsaNumber= opp.AFSA_Number__c==null?'':opp.AFSA_Number__c;
        if(opp.Date_Accepted_For_Processing__c!=null){
            //wrapperObj.DateAcceptedNpii= opp.Date_Accepted_For_Processing__c; 
        }
        wrapperObj.LeadSource=opp.LeadSource!=null?opp.LeadSource:'';
        WrapperImport.DebtAgreements debtAgreementsInner=new  WrapperImport.DebtAgreements();
        debtAgreementsInner.FirstPaymentDate=opp.Date_of_debtor_s_rst_payment_to_adminis__c==null?'':convertToDateTime(opp.Date_of_debtor_s_rst_payment_to_adminis__c);
        if(opp.Submitted_to_AFSA_Date__c!=null){
            debtAgreementsInner.DateLodged=convertToDateTime(opp.Submitted_to_AFSA_Date__c);  
        }
        if(opp.Final_Date_For_Voting__c!=null){
            debtAgreementsInner.DeadlineDate=convertToDateTime(opp.Final_Date_For_Voting__c);
        }
        
        debtAgreementsInner.Offer=opp.DA_Amount__c!=null?opp.DA_Amount__c:integer.valueof(0);
        debtAgreementsInner.AdministratorRate=opp.Fees_for_administrator_to_administer_deb__c;
        if(opp.Equalisation_Date_Bric__c!=null){
            debtAgreementsInner.EqualisationDate=convertToDateTime(opp.Equalisation_Date_Bric__c);
        }
        
        debtAgreementsInner.ProposalExpensesBankingFeesAmount=opp.Expense_Banking_Fees_Amount_Per__c!=null?opp.Expense_Banking_Fees_Amount_Per__c:Double.valueof(0);
        debtAgreementsInner.ProposalExpensesValuatingAssetsAmount=opp.Expense_Valuating_Amount_Per__c!=null?opp.Expense_Valuating_Amount_Per__c:Double.valueof(0);
        debtAgreementsInner.ProposalExpensesEligibilityDebtorAmount=opp.Expense_Eligibility_Amount_Per__c!=null?opp.Expense_Eligibility_Amount_Per__c:Double.valueof(0);
        debtAgreementsInner.ProposalExpensesOtherAmount=opp.Expense_Other_Amount_Per__c!=null?opp.Expense_Other_Amount_Per__c:Double.valueof(0);
        
        if(opp.Number_of_payments1__c!=null && opp.Weekly_fortnightly_monthly1__c!=null && opp.Amount_of_each_payment1__c!=null){
            
            WrapperImport.RepaymentSchedule repaymentScheduleInner1=new  WrapperImport.RepaymentSchedule();
            repaymentScheduleInner1.Count=Integer.valueof(opp.Number_of_payments1__c);
            repaymentScheduleInner1.Frequency=opp.Weekly_fortnightly_monthly1__c;
            repaymentScheduleInner1.Amount=opp.Amount_of_each_payment1__c;
            repaymentScheduleInnerList.add(repaymentScheduleInner1);
        }
        
        if(opp.Number_of_payments2__c!=null && opp.Weekly_fortnightly_monthly2__c!=null && opp.Amount_of_each_payment2__c!=null){
            
            WrapperImport.RepaymentSchedule repaymentScheduleInner2=new  WrapperImport.RepaymentSchedule();
            repaymentScheduleInner2.Count=Integer.valueof(opp.Number_of_payments2__c);
            repaymentScheduleInner2.Frequency=opp.Weekly_fortnightly_monthly2__c;
            repaymentScheduleInner2.Amount=opp.Amount_of_each_payment2__c;
            repaymentScheduleInnerList.add(repaymentScheduleInner2);
        }
        if(opp.Number_of_payments3__c!=null && opp.Weekly_fortnightly_monthly3__c!=null && opp.Amount_of_each_payment3__c!=null){
            
            WrapperImport.RepaymentSchedule repaymentScheduleInner3=new  WrapperImport.RepaymentSchedule();
            repaymentScheduleInner3.Count=Integer.valueof(opp.Number_of_payments3__c);
            repaymentScheduleInner3.Frequency=opp.Weekly_fortnightly_monthly3__c;
            repaymentScheduleInner3.Amount=opp.Amount_of_each_payment3__c;
            repaymentScheduleInnerList.add(repaymentScheduleInner3);
        }
        
        if(opp.Number_of_payments4__c!=null && opp.Weekly_fortnightly_monthly4__c!=null && opp.Amount_of_each_payment4__c!=null){
            WrapperImport.RepaymentSchedule repaymentScheduleInner4=new  WrapperImport.RepaymentSchedule();
            repaymentScheduleInner4.Count=Integer.valueof(opp.Number_of_payments4__c);
            repaymentScheduleInner4.Frequency=opp.Weekly_fortnightly_monthly4__c;
            repaymentScheduleInner4.Amount=opp.Amount_of_each_payment4__c;
            repaymentScheduleInnerList.add(repaymentScheduleInner4);
        }
        if(opp.Number_of_payments5__c!=null && opp.Weekly_fortnightly_monthly5__c!=null && opp.Amount_of_each_payment5__c!=null){
            WrapperImport.RepaymentSchedule repaymentScheduleInner5=new  WrapperImport.RepaymentSchedule();
            repaymentScheduleInner5.Count=Integer.valueof(opp.Number_of_payments5__c);
            repaymentScheduleInner5.Frequency=opp.Weekly_fortnightly_monthly5__c;
            repaymentScheduleInner5.Amount=opp.Amount_of_each_payment5__c;
            repaymentScheduleInnerList.add(repaymentScheduleInner5);
        }
        For(Repayment__c repaymentsInner:[select id, Date_Paid_Bric__c,Date_Reconciled_Bric__c,Amount_Paid_Bric__c,Reference_Bric__c,
                                          Realisations_Component_Bric__c,Admin_Component_Bric__c,Realisations_Rate_Bric__c,Admin_Rate_Bric__c
                                          from Repayment__c where Opportunity_Bric__c=:opp.id]){
                                              wrapperImport.Repayments wrapperRepaymentObj = new wrapperImport.Repayments();
                                              if(repaymentsInner.Date_Paid_Bric__c!=null){
                                                  wrapperRepaymentObj.DatePaid=convertToDateTime(repaymentsInner.Date_Paid_Bric__c);  
                                              }
                                              if(repaymentsInner.Date_Reconciled_Bric__c!=null){
                                                  wrapperRepaymentObj.DateReconciled=convertToDateTime(repaymentsInner.Date_Reconciled_Bric__c);  
                                              }
                                              
                                              wrapperRepaymentObj.AmountPaid=repaymentsInner.Amount_Paid_Bric__c!=null?repaymentsInner.Amount_Paid_Bric__c:Double.valueof('');
                                              wrapperRepaymentObj.Reference=repaymentsInner.Reference_Bric__c!=null?repaymentsInner.Reference_Bric__c:'';
                                              wrapperRepaymentObj.RealisationsComponent=repaymentsInner.Realisations_Component_Bric__c!=null?repaymentsInner.Realisations_Component_Bric__c:0;
                                              wrapperRepaymentObj.AdminComponent=repaymentsInner.Admin_Component_Bric__c!=null?repaymentsInner.Admin_Component_Bric__c:0;
                                              wrapperRepaymentObj.RealisationsRate=repaymentsInner.Realisations_Rate_Bric__c!=null?repaymentsInner.Realisations_Rate_Bric__c:0;
                                              wrapperRepaymentObj.AdminRate=repaymentsInner.Admin_Rate_Bric__c!=null?repaymentsInner.Admin_Rate_Bric__c:0;
                                              repaymentList.add(wrapperRepaymentObj);
                                              debtAgreementsInner.Repayments=repaymentList;
                                              
                                          }
        for(Payment_Bric__c paymentObj:[select id,Payment_Type_Bric__c,Reference_Bric__c,Date_Paid_Bric__c,
                                        Date_Reconciled_Bric__c,Payment_Method_Bric__c,Date_Disbursed_Bric__c,Amount_Bric__c,Charge_Period_To_Bric__c
                                        from Payment_Bric__c where Opportunity_Bric__c=:opp.id]){
                                            WrapperImport.DividendPayments wrapperDividentPaymentObj=new  WrapperImport.DividendPayments();
                                            WrapperImport.AdminPayments wrapperAdminPaymentObj=new  WrapperImport.AdminPayments();
                                            WrapperImport.AfsaPayments wrapperAfsaPaymentObj=new  WrapperImport.AfsaPayments();
                                            if(paymentObj.Payment_Type_Bric__c=='Admin Payment'){
                                                wrapperAdminPaymentObj.PaymentMethod=paymentObj.Payment_Method_Bric__c;
                                                wrapperAdminPaymentObj.Reference=paymentObj.Reference_Bric__c;
                                                if(paymentObj.Date_Paid_Bric__c!=null){
                                                    wrapperAdminPaymentObj.DatePaid=convertToDateTime(paymentObj.Date_Paid_Bric__c);  
                                                }
                                                if(paymentObj.Date_Reconciled_Bric__c!=null){
                                                    wrapperAdminPaymentObj.DateReconciled=convertToDateTime(paymentObj.Date_Reconciled_Bric__c);  
                                                }
                                                if(paymentObj.Date_Disbursed_Bric__c!=null){
                                                    wrapperAdminPaymentObj.DateDisbursed=convertToDateTime(paymentObj.Date_Disbursed_Bric__c);
                                                }
                                                wrapperAdminPaymentObj.Amount=paymentObj.Amount_Bric__c;
                                                if(paymentObj.Charge_Period_To_Bric__c!=null){
                                                    wrapperAdminPaymentObj.ChargePeriodTo=convertToDateTime(paymentObj.Charge_Period_To_Bric__c); 
                                                }
                                                
                                                adminpaymentslist.add(wrapperAdminPaymentObj);
                                            }
                                            if(paymentObj.Payment_Type_Bric__c=='AFSA Payment'){
                                                wrapperAfsaPaymentObj.PaymentMethod=paymentObj.Payment_Method_Bric__c!=null?paymentObj.Payment_Method_Bric__c:'';
                                                wrapperAfsaPaymentObj.Reference=paymentObj.Reference_Bric__c!=null?paymentObj.Reference_Bric__c:'';
                                                if(paymentObj.Date_Paid_Bric__c!=null){
                                                    wrapperAfsaPaymentObj.DatePaid=convertToDateTime(paymentObj.Date_Paid_Bric__c);  
                                                }
                                                if(paymentObj.Date_Reconciled_Bric__c!=null){
                                                    wrapperAfsaPaymentObj.DateReconciled=convertToDateTime(paymentObj.Date_Reconciled_Bric__c);
                                                }
                                                if(paymentObj.Date_Disbursed_Bric__c!=null){
                                                    wrapperAfsaPaymentObj.DateDisbursed=convertToDateTime(paymentObj.Date_Disbursed_Bric__c);  
                                                }
                                                wrapperAfsaPaymentObj.Amount=paymentObj.Amount_Bric__c;
                                                if(paymentObj.Charge_Period_To_Bric__c!=null){
                                                    wrapperAfsaPaymentObj.ChargePeriodTo=convertToDateTime(paymentObj.Charge_Period_To_Bric__c); 
                                                }
                                                afsapaymentslist.add(wrapperAfsaPaymentObj);
                                            }
                                            
                                            
                                            
                                            wrapperObj.AdminPayments=adminPaymentslist;
                                            wrapperObj.AfsaPayments=afsaPaymentslist;
                                            
                                            
                                            
                                        }
        for(Debt__c debtobj:[select id,New_Debt__c,Name,Amount_Owing__c,Date_Joined_bric__c,Is_Participating_Bric__c,Send_DAP_to__r.name,Account_Reference_Number__c,Send_DAP_to__r.IPAid__c from Debt__c where Opportunity__c=:opp.id]){
            WrapperImport.Debts wrapperdebtObj=new  WrapperImport.Debts();
            
            wrapperdebtObj.CreditorId=debtobj.Send_DAP_to__r.IPAid__c==null?0:Integer.valueof(debtobj.Send_DAP_to__r.IPAid__c);
            wrapperdebtObj.Reference=debtobj.Account_Reference_Number__c==null?'':debtobj.Account_Reference_Number__c;
            wrapperdebtObj.CreditorName=debtobj.Send_DAP_to__r.name==null?'':debtobj.Send_DAP_to__r.name;
            wrapperdebtObj.Amount=debtobj.New_Debt__c==null?0:debtobj.New_Debt__c;
            wrapperdebtObj.NewDebt=debtobj.New_Debt__c==null?0:debtobj.New_Debt__c;
            
            
            wrapperdebtObj.DateJoined=debtobj.Date_Joined_bric__c!=null?convertToDateTime(debtobj.Date_Joined_bric__c):string.valueof(date.today());
            
            wrapperdebtObj.IsParticipating=!debtobj.Is_Participating_Bric__c?false:debtobj.Is_Participating_Bric__c;
            debtList.add(wrapperdebtObj); 
        }
        
        
        wrapperObj.Debts =debtList;
        
        WrapperImport.DebtAgreements[] debtAgreementInner2= new WrapperImport.DebtAgreements[]{};
            WrapperImport.DebtAgreements debtAgreementInner2Obj= new WrapperImport.DebtAgreements();   
        debtAgreementsInner.RepaymentSchedule=repaymentScheduleInnerList;
        debtAgreementsInnerList.add(debtAgreementsInner);
        wrapperObj.DebtAgreements=debtAgreementsInnerList;
        return wrapperObj;
        
    }
    
    
    /*-------------------------------------------------XML Generator Part------------------------------------------------*/
    
    
    public static String xmlGenerator(String recordId){
        String xmlstring = '';
        dom.XmlNode body2;
        dom.XmlNode body12;
        dom.XmlNode body20;
        dom.XmlNode body44;
        dom.XmlNode body15;
        dom.XmlNode body54;
        dom.XmlNode body100;
        boolean flag=true;
        boolean flag2=true;
        boolean flag3=true;
        list<Debt__c> Is_Admin_Related_Creditor_Debts = new list<Debt__c>();
        
        Opportunity opp=[select id,Reference__c,Account.gender__c,Account.Salutation,account.FirstName,account.MiddleName,Account.Drivers_License__c,Account.PersonOtherCountryCode,Expense_Eligibility_Amount_Per__c,
                         Account.Reference__c,account.LastName,account.Date_of_Birth__c,account.PersonMailingCity,Equalisation_Date_Bric__c,
                         account.PersonMailingState,account.PersonMailingCountryCode,account.PersonMailingCountry,account.PersonMailingPostalCode,
                         account.PersonMailingStreet,DA_Amount__c,Fees_for_administrator_to_administer_deb__c,Expense_Other_Amount_Per__c,
                         account.Mobile_Phone__c,Submitted_to_AFSA_Date__c,Final_Date_For_Voting__c,Expense_Banking_Fees_Amount_Per__c,
                         account.Home_Phone__c,account.Work_Phone__c,account.PersonEmail,AFSA_Number__c,Were_you_born_overseas__c,What_languages_do_you_speak_at_home__c,
                         Employment_Status__c,Employed_as1__c,Occupations_Code_ANZSCO1__c,Employer_Name1__c,
                         Do_you_expect_a_substantial_change_to__c,Previously_been_bankrupt_debt_agreement__c,
                         Employed_as2__c,Occupations_Code_ANZSCO2__c, Employer_Address2__c,Employer_Address2_Suburb_State_Zip__c,
                         Employer_State2__c,Employer_Postcode2__c,Pay_Period2__c,Hours_worked_per_week2__c,
                         Residential_Status__c,Years2__c,Months2__c,Address1__c,Address2__c,Account.Other_Given_Name_s__pc,Account.Other_Surname__pc,
                         Suburb1__c,Suburb2__c,State1__c,State2__c,Postcode1__c,Postcode2__c,
                         Are_you_insolvent__c,Are_you_currently_up_to_date_with_paymen__c,Business_Address__c,Business_Suburb__c,Business_State__c,Business_PostCode__c,
                         Employer_Address__c,Employer_Address_Suburb_State_Zip__c,Employer_State1__c,Employer_Postcode1__c,
                         how_many_people_are_dependent_on_you_for__c,Do_you_have_a_spouse_or_partner__c,Your_partner_s_separate_gross_IN_p_a__c,Your_spouse_or_partner_s_full_name__c,
                         account.PersonOtherStreet,account.PersonOtherCity,account.PersonOtherState,account.PersonOtherPostalCode,
                         account.PersonOtherCountry,account.PersonMobilePhone,Are_you_of_Aboriginal_or_Torres_Strait_I__c,
                         Date_Accepted_For_Processing__c,LeadSource,Number_of_payments1__c,Expense_Valuating_Amount_Per__c,
                         Number_of_payments2__c,Number_of_payments3__c,Number_of_payments4__c,Number_of_payments5__c,
                         Total_value_of_payments1__c,Total_value_of_payments2__c,Total_value_of_payments3__c,
                         Total_value_of_payments4__c,Total_value_of_payments5__c,Type_of_Industry1__c,Type_of_Industry2__c,  
                         Yes_Are_you_currentl_in_business_as_sol__c,Yes_Have_you_been_a_director__c,
                         Have_you_transferred_any_assets_to_a_tru__c,What_is_the_nature_of_this_business__c,
                         Total_amount_offered_in_the_proposal__c,Employer_Name2__c,
                         Realisations_charge_payable_to_Aus_Sum__c,When_did_the_business_start_operating__c,
                         Fees_for_administrator_to_admin_deb_Sum__c,If_so_what_country_1__c,
                         Casual__c, Contract__c ,Full_time__c ,Part_time__c, Seasonal__c ,Self_employed__c,  
                         Expense_Banking_Fees_Amount_Sum__c,Business_Partner_s_Name_if_applicable__c,
                         Expense_Valuating_Amount_Sum__c,Yes_Are_all_your_business_assets_shown__c,
                         Expense_Eligibility_Amount_Sum__c,suburb3__c,Postcode3__c,State3__c,
                         Expense_Other_Amount_Sum__c,Other__c,suburb4__c,Postcode4__c,State4__c,
                         Allowable_expenses_payable_to_third_Sum__c,Loss_of_employment__c ,Relationship_breakdown__c,Death_of_a_relative__c,Birth_of_child__c,
                         Illness__c,Reduction_of_overtime__c,Lost_second_job__c,Over_commitment_of_credit__c,Loss_of_employment_by_partner__c,Other_unable_to_pay_your_debts__c,  
                         TOTAL_amount_to_be_distributed_proportio__c,Did_Do_you_own1__c,Did_Do_you_own2__c,
                         Date_of_debtor_s_rst_payment_to_adminis__c,
                         Unsecured_Assets_SubClassification1__c,Unsecured_Assets_SubClassification2__c,Unsecured_Assets_SubClassification3__c,Unsecured_Assets_SubClassification4__c,
                         Unsecured_Assets_Description1__c,Unsecured_Assets_Description2__c,Unsecured_Assets_Description3__c,Unsecured_Assets_Description4__c,
                         Estimated_Total_Value1__c,Estimated_Total_Value2__c,Estimated_Total_Value3__c,Estimated_Total_Value4__c,
                         Percentage_Owned1__c,Percentage_Owned2__c,Percentage_Owned3__c,Percentage_Owned4__c,	
                         Debtor_s_Taxable_Income__c,Wages_after_tax__c,
                         Non_taxable_centrelink_benefits__c,Other_Income__c,Taxable_centrelink_benefits__c,Allowances_overtime_fringe_benefits__c,
                         Regular_income_from_tenants_for_rent__c,After_tax_income_from_second_jobs__c,Child_spouse_maintenance_received__c,
                         Total_Income__c, Total_Support__c,Please_specify__c,  Rent_for_Accomodation__c,Opportunity.Pay_Period__c,Hours_worked_per_week__c,Year__c,
                         Rates__c,Home_maintenance__c,Mortgage_payment__c,Board__c,
                         Electricity_gas_water__c,Health_insurance__c,Entertainment_pay_TV__c,Phone_mobile_internet__c,Food_including_groceries_and_take_away__c,
                         Car_payments_to_secured_creditor__c,Medical_chemist__c,Month__c,
                         School_fees_and_expenses__c,Child_care__c,Other_insurance__c,Transport__c,Car_fuel_registration_insurance_maint__c,
                         Clothes_shoes_hairdressing__c,Incidentals_e_g_cigarettes_books_mag__c,Other_expenses_for_children_eg_sport_mu__c,Child_support_and_maintenance__c,
                         Rental_payments_for_household_goods__c,Other_household_expenses__c,Other_payments_to_secured_creditors__c,Payments_to_creditors_not_receiving_a__c,
                         Total_household_expenses_sum__c,Debtor_Supporting_Statement__c,Total_uncommitted_income__c,Debtors_expense_for_supporting_partner__c,                
                         Unemployment_or_loss_of_income__c,Liabilities_due_to_guarantees__c,Excessive_use_of_credit_facilities__c,Adverse_legal_action__c,
                         Domestic_discord_relationship_breakdowns__c,Gambling_speculation_extravagance__c,ill_health_absence_of_health_insurance__c,
                         Dividend_Frequency__c,Source_of_lump_sum_payment_or_details_of__c,
                         Yes__c,No__c,If_yes_provide_details__c,Realisations_charge_payable_to_Australia__c,
                         Applied_for_refinancing__c,Contacted_your_major_creditors_to__c,Spoken_with_debt_agreement_administrator__c,
                         Spoken_with_nancial_counsellor__c,Total_household_expenses__c,
                         Weekly_fortnightly_monthly1__c,Amount_of_each_payment1__c,
                         Weekly_fortnightly_monthly2__c,Amount_of_each_payment2__c,
                         Weekly_fortnightly_monthly3__c,Amount_of_each_payment3__c,
                         Weekly_fortnightly_monthly4__c,Amount_of_each_payment4__c,
                         Weekly_fortnightly_monthly5__c,Amount_of_each_payment5__c,
                         Year_if_Yes__c,Did_Do_you_own3__c,Did_Do_you_own4__c,Date_sold_if_applicable3__c,Date_sold_if_applicable4__c,Address4__c,
                         Are_you_buying__c,Receiving_free_accommodation__c ,Do_you_own__c,Are_you_renting_boarding__c,
                         Debt_Agreement_Administrator__c,
                         Other_please_specify2__c,Address3__c,
                         Date_first_dividend_be_paid_to_cred_Sun__c,Estimated_dividend_based_on_deb_list_Sum__c,Date_debtor_will_complete_debt_agr_Sum__c,Estimated_dividend_excluding_sec_cre_Sum__c,
                         Set_up_fees_paid_or_payable__c,Debtor_s_contribution_towards__c,Debtor_s_eql_share_of_household_expenses__c,OwnerId,  
                         Business_Name__c,Yes_have_you_been_a_unit_holder_in__c,Economic_conditions_affecting_industry__c,
                         Lack_of_business_ability_including__c,Excessive_interest_payments_Capital_loss__c,Excessive_drawings_including__c,Inability_to_collect_debts_due_to__c,
                         Failure_to_keep_proper_books_of_ac_cost__c,Lack_of_sufficient_initial_working_capit__c,Gambling_or_speculation__c,
                         Seasonal_conditions_including__c,If_other_reason_not_listed_please_specif__c,
                         Years__c,Months__c
                         from Opportunity where Opportunity.ID=:recordId];
        
        DOM.Document doc = new DOM.Document();
        
        dom.XmlNode body1 = doc.createRootElement('SubmitDebtAgreementProposalRequest', 'http://afsa.gov.au/DebtAgreementService/SubmitDebtAgreementProposal.1', '');
        
        //  body1.addChildElement('FormId', null, null).addTextNode('DAP23042399');
        body1.addChildElement('FormExternalReference', null, null).addTextNode(opp.Account.Reference__c!=null?opp.Account.Reference__c:'');
        body2 = body1.addChildElement('DebtAgreementProposal', null, null);
        dom.XmlNode body3 = body2.addChildElement('DebtorSection', null, null);
        
        
        dom.XmlNode body5 = body3.addChildElement('Name', null, null);
        
        if(opp.Account.Salutation!=null){
            body5.addChildElement('Title', null, null).addTextNode(opp.Account.Salutation==null?'':opp.Account.Salutation.toUppercase());  
            
        }
        body5.addChildElement('GivenName', null, null).addTextNode(opp.account.FirstName==null?'':opp.account.FirstName); 
        if(opp.Account.MiddleName!=null){
            body5.addChildElement('MiddleNames', null, null).addTextNode(opp.Account.MiddleName==null?'':opp.Account.MiddleName);   
            
        }
        body5.addChildElement('Surname', null, null).addTextNode(opp.Account.LastName==null?'':opp.Account.LastName);  
        if(opp.Account.Other_Given_Name_s__pc!=null || opp.Account.Other_Surname__pc!=null){
            body3.addChildElement('OtherNamesIndicator', null, null).addTextNode('true'); 
            dom.XmlNode body135= body3.addChildElement('OtherNames', null, null); 
            dom.XmlNode body136= body135.addChildElement('Item', null, null);  
            body136.addChildElement('Title', null, null).addTextNode('MRS');
            body136.addChildElement('GivenName', null, null).addTextNode(opp.Account.Other_Given_Name_s__pc!=null?opp.Account.Other_Given_Name_s__pc:'');
            body136.addChildElement('Surname', null, null).addTextNode(opp.Account.Other_Surname__pc!=null?opp.Account.Other_Surname__pc:'');
        }else {
            body3.addChildElement('OtherNamesIndicator', null, null).addTextNode('false');  
            
        }
        
        body3.addChildElement('BirthDate', null, null).addTextNode(String.valueOf((opp.account.Date_of_Birth__c != null) ? String.valueOf(opp.account.Date_of_Birth__c) : '')); 
        if(opp.account.gender__c=='Male' || opp.account.gender__c==null ){
            body3.addChildElement('GenderType', null, null).addTextNode('M'); 
        }
        if(opp.account.gender__c=='Female'){
            body3.addChildElement('GenderType', null, null).addTextNode('F'); 
        }
        if(opp.Account.Drivers_License__c!=null){
            body3.addChildElement('DriversLicence', null, null).addTextNode(opp.Account.Drivers_License__c==null?'':opp.Account.Drivers_License__c); 
            
        }
        
        dom.XmlNode bod92 = body3.addChildElement('ResidentialAddress', null, null);
        
        bod92.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode(opp.Account.PersonOtherStreet==null?'':opp.Account.PersonOtherStreet);
        
        
        bod92.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode(opp.Account.PersonOtherCity==null?'':opp.Account.PersonOtherCity);
        
        
        bod92.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode(opp.Account.PersonOtherState==null?'':opp.Account.PersonOtherState); 
        
        bod92.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode(opp.Account.PersonOtherPostalCode==null?'':opp.Account.PersonOtherPostalCode);  
        
        bod92.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode(opp.Account.PersonOtherCountry==null?'':opp.Account.PersonOtherCountryCode);
        dom.XmlNode body89 = body3.addChildElement('PostalAddressSameAsResidentialAddressIndicator', null, null).addTextNode('true');
        if(opp.account.PersonMailingStreet!=null || opp.account.PersonMailingState!=null || opp.account.PersonMailingCity!=null || opp.account.PersonMailingPostalCode!=null || opp.account.PersonMailingCountryCode!=null ){
            dom.XmlNode body6 = body3.addChildElement('PostalAddress', null, null);  
            body6.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMailingStreet==null?'':opp.account.PersonMailingStreet);
            body6.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMailingCity==null?'':opp.account.PersonMailingCity);
            body6.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMailingState==null?'':opp.account.PersonMailingState);
            body6.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMailingPostalCode==null?'':opp.account.PersonMailingPostalCode);
            body6.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMailingCountryCode==null?'':opp.account.PersonMailingCountryCode);
        }
        
        
        if(opp.account.PersonMailingCountryCode!=null && opp.account.PersonMailingPostalCode!=null && opp.account.PersonMobilePhone!=null){
            dom.XmlNode body7 = body3.addChildElement('MobilePhoneNumber', null, null);
            body7.addChildElement('CountryCode', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMailingCountryCode==null?'':opp.account.PersonMailingCountryCode);
            //body7.addChildElement('AreaCode', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMailingPostalCode==null?'':opp.account.PersonMailingPostalCode);
            body7.addChildElement('Number', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMobilePhone==null?'':opp.account.PersonMobilePhone);
            
        }  
        body3.addChildElement('EmailAddress', null, null).addTextNode(opp.account.PersonEmail==null?'':opp.account.PersonEmail);
        
        
        dom.XmlNode body8 = body2.addChildElement('OriginSection', null, null);
        if(opp.Are_you_of_Aboriginal_or_Torres_Strait_I__c=='No'){
            body8.addChildElement('AboriginalAboriginalTorresIndicator', null, null).addTextNode('false');  
        }else{
            body8.addChildElement('AboriginalAboriginalTorresIndicator', null, null).addTextNode('true');   
        }
        if(opp.Were_you_born_overseas__c=='No'){
            body8.addChildElement('BornOverseasIndicator', null, null).addTextNode('false');    
        }else{
            body8.addChildElement('BornOverseasIndicator', null, null).addTextNode('true'); 
        
        if(opp.If_so_what_country_1__c!=null){
            Integer lastIndex = opp.If_so_what_country_1__c.lastIndexOf('_');
            if (lastIndex != -1 && lastIndex < opp.If_so_what_country_1__c.length() - 2) {
               String lastTwoChars = opp.If_so_what_country_1__c.substring(lastIndex + 1, lastIndex + 3);
                body8.addChildElement('BirthCountryType', null, null).addTextNode(lastTwoChars);  
            } else {
                body8.addChildElement('BirthCountryType', null, null).addTextNode('');
            }
        }else{
          body8.addChildElement('BirthCountryType', null, null).addTextNode('');  
        }
        }
        if(opp.What_languages_do_you_speak_at_home__c!=null){
            dom.XmlNode body9 = body8.addChildElement('HomeLanguageTypes', null, null);
            body9.addChildElement('Item', null, null).addTextNode(opp.What_languages_do_you_speak_at_home__c==null?'':opp.What_languages_do_you_speak_at_home__c.toUppercase());
            
            
        }
        
        dom.XmlNode body10 = body2.addChildElement('FamilySection', null, null);
        body10.addChildElement('DependentCount', null, null).addTextNode(string.valueOf(opp.how_many_people_are_dependent_on_you_for__c)!=null?string.valueOf(opp.how_many_people_are_dependent_on_you_for__c):'0');
        if(opp.Do_you_have_a_spouse_or_partner__c=='No'){
            body10.addChildElement('SpouseIndicator', null, null).addTextNode('false');  
        }else{
            body10.addChildElement('SpouseIndicator', null, null).addTextNode('true');    
        }
        if(opp.Your_partner_s_separate_gross_IN_p_a__c!=null){
            body10.addChildElement('SpouseIncomeAmount', null, null).addTextNode(string.valueof((opp.Your_partner_s_separate_gross_IN_p_a__c!=null) ? string.valueof(opp.Your_partner_s_separate_gross_IN_p_a__c) : ''));
            
        }
        if(opp.Your_spouse_or_partner_s_full_name__c!=null){
            body10.addChildElement('SpouseName', null, null).addTextNode(opp.Your_spouse_or_partner_s_full_name__c==null?'':opp.Your_spouse_or_partner_s_full_name__c);
            
        }
        
        dom.XmlNode body11 = body2.addChildElement('EmploymentSection', null, null);
        if(opp.Employed_as1__c==null){
            body11.addChildElement('EmployedIndicator', null, null).addTextNode('false');
            body11.addChildElement('UnemployedType', null, null).addTextNode('UNEMPLOYED');
            body11.addChildElement('UnemployedYears', null, null).addTextNode(opp.Years__c!=null?String.valueof(opp.Years__c):'0');
            body11.addChildElement('UnemployedMonths', null, null).addTextNode(opp.Months__c!=null?String.valueof(opp.Months__c):'0');
            
            
        }else{
            body11.addChildElement('EmployedIndicator', null, null).addTextNode('true');
        }
        system.debug('@@'+opp.Employed_as1__c+opp.Occupations_Code_ANZSCO1__c+opp.Employer_Name1__c);
        system.debug('@@'+opp.Employed_as2__c+opp.Occupations_Code_ANZSCO2__c+opp.Employer_Name2__c);
        
        if((opp.Employed_as1__c!=null && opp.Occupations_Code_ANZSCO1__c!=null && opp.Employer_Name1__c!=null) || (opp.Employed_as2__c!=null && opp.Employer_Name2__c!=null)){
            body12 = body11.addChildElement('Jobs', null, null);
            if(opp.Employed_as1__c!=null && opp.Employer_Name1__c!=null){
                dom.XmlNode body13 = body12.addChildElement('Item', null, null);
                if(opp.Type_of_Industry1__c =='Accommodation and Food Services'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('108'));
                }
                else if(opp.Type_of_Industry1__c =='Administrative and Support Services'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('114'));  
                }
                else if(opp.Type_of_Industry1__c =='Agriculture, Forestry and Fishing'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('101'));  
                }else if(opp.Type_of_Industry1__c =='Arts and Recreation Services'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('118'));  
                }
                else if(opp.Type_of_Industry1__c =='Construction'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('102'));  
                }
                else if(opp.Type_of_Industry1__c =='Education and Training'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('116'));  
                }
                else if(opp.Type_of_Industry1__c =='Electricity, Gas, Water and Waste Service'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('105'));  
                }
                else if(opp.Type_of_Industry1__c =='Financial and Insurance Services'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('111'));  
                }
                else if(opp.Type_of_Industry1__c =='Health Care and Social Assistance'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('117'));  
                }
                else if(opp.Type_of_Industry1__c =='Information Media and Telecommunications'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('110'));  
                }
                else if(opp.Type_of_Industry1__c =='Manufacturing'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('104'));  
                }
                else if(opp.Type_of_Industry1__c =='Mining'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('103'));  
                }
                else if(opp.Type_of_Industry1__c =='Professional, Scientific and Technical Services'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('113'));  
                }
                else if(opp.Type_of_Industry1__c =='Public Administration and Safety'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('115'));  
                }
                else if(opp.Type_of_Industry1__c =='Rental, Hiring and Real Estate Services'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('112'));  
                }
                else if(opp.Type_of_Industry1__c =='Retail Trade'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('107'));  
                }
                else if(opp.Type_of_Industry1__c =='Transport, Postal and Warehousing'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('109'));  
                }
                else if(opp.Type_of_Industry1__c =='Wholesale Trade'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('106'));  
                }
                else if(opp.Type_of_Industry1__c =='Other Services'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('119'));  
                }
                else if(opp.Type_of_Industry1__c =='Never Employed'){
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('120'));  
                }else{
                    body13.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('119'));  
                }
                
                
                body13.addChildElement('EmployedAs', null, null).addTextNode(opp.Employed_as1__c==null?'':opp.Employed_as1__c);
                if(opp.Occupations_Code_ANZSCO1__c!=null){
                    body13.addChildElement('AnzscoOccupationCode', null, null).addTextNode(opp.Occupations_Code_ANZSCO1__c==null?'':opp.Occupations_Code_ANZSCO1__c);
                }
                body13.addChildElement('EmployerName', null, null).addTextNode(opp.Employer_Name1__c==null?'':opp.Employer_Name1__c);
                
                dom.XmlNode body14 = body13.addChildElement('EmployerAddress', null, null);
                body14.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode(opp.Employer_Address__c==null?'':opp.Employer_Address__c);
                body14.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode(opp.Employer_Address_Suburb_State_Zip__c==null?'':opp.Employer_Address_Suburb_State_Zip__c);
                body14.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode(opp.Employer_State1__c==null?'':opp.Employer_State1__c);
                body14.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode(opp.Employer_Postcode1__c==null?'':opp.Employer_Postcode1__c);
                body14.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMailingCountryCode==null?'':opp.account.PersonMailingCountryCode); 
                
                body13.addChildElement('PayPeriodType', null, null).addTextNode(setPayPeriodType(opp.Pay_Period__c));
                body13.addChildElement('Hours', null, null).addTextNode(string.valueOf((opp.Hours_worked_per_week__c != null) ? string.valueOf(opp.Hours_worked_per_week__c) : '38'));
                
                if(opp.Casual__c){
                    body13.addChildElement('StatusType', null, null).addTextNode('CASUAL');
                }
                else if(opp.Contract__c){
                    body13.addChildElement('StatusType', null, null).addTextNode('CONTRACT');
                }
                else if(opp.Full_time__c){
                    body13.addChildElement('StatusType', null, null).addTextNode('FULLTIME');
                }
                else if(opp.Part_time__c){
                    body13.addChildElement('StatusType', null, null).addTextNode('PARTTIME');
                }
                else if(opp.Seasonal__c){
                    body13.addChildElement('StatusType', null, null).addTextNode('SEASONAL');
                }
                else if(opp.Self_employed__c){
                    body13.addChildElement('StatusType', null, null).addTextNode('SELF_EMPLOYED');
                }
                
                
            }
            
            if(opp.Employed_as2__c!=null && opp.Employer_Name2__c!=null){
                body15 = body12.addChildElement('Item', null, null);
                //  body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('107'));
                
                
                // dom.XmlNode body175 = body12.addChildElement('Item', null, null);
                if(opp.Type_of_Industry2__c =='Accommodation and Food Services'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('108'));
                }
                else if(opp.Type_of_Industry2__c =='Administrative and Support Services'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('114'));  
                }
                else if(opp.Type_of_Industry2__c =='Agriculture, Forestry and Fishing'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('101'));  
                }else if(opp.Type_of_Industry2__c =='Arts and Recreation Services'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('118'));  
                }
                else if(opp.Type_of_Industry2__c =='Construction'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('102'));  
                }
                else if(opp.Type_of_Industry2__c =='Education and Training'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('116'));  
                }
                else if(opp.Type_of_Industry2__c =='Electricity, Gas, Water and Waste Service'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('105'));  
                }
                else if(opp.Type_of_Industry2__c =='Financial and Insurance Services'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('111'));  
                }
                else if(opp.Type_of_Industry2__c =='Health Care and Social Assistance'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('117'));  
                }
                else if(opp.Type_of_Industry2__c =='Information Media and Telecommunications'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('110'));  
                }
                else if(opp.Type_of_Industry2__c =='Manufacturing'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('104'));  
                }
                else if(opp.Type_of_Industry2__c =='Mining'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('103'));  
                }
                else if(opp.Type_of_Industry2__c =='Professional, Scientific and Technical Services'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('113'));  
                }
                else if(opp.Type_of_Industry2__c =='Public Administration and Safety'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('115'));  
                }
                else if(opp.Type_of_Industry2__c =='Rental, Hiring and Real Estate Services'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('112'));  
                }
                else if(opp.Type_of_Industry2__c =='Retail Trade'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('107'));  
                }
                else if(opp.Type_of_Industry2__c =='Transport, Postal and Warehousing'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('109'));  
                }
                else if(opp.Type_of_Industry2__c =='Wholesale Trade'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('106'));  
                }
                else if(opp.Type_of_Industry2__c =='Other Services'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('119'));  
                }
                else if(opp.Type_of_Industry2__c =='Never Employed'){
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('120'));  
                }else{
                    body15.addChildElement('IndustryCodeType', null, null).addTextNode(string.valueof('119'));  
                }
                
                body15.addChildElement('EmployedAs', null, null).addTextNode(opp.Employed_as2__c==null?'':opp.Employed_as2__c);
                if(opp.Occupations_Code_ANZSCO2__c!=null){
                    body15.addChildElement('AnzscoOccupationCode', null, null).addTextNode(opp.Occupations_Code_ANZSCO2__c==null?'':opp.Occupations_Code_ANZSCO2__c);
                }
                body15.addChildElement('EmployerName', null, null).addTextNode(opp.Employer_Name2__c==null?'':opp.Employer_Name2__c);
                
                dom.XmlNode body16 = body15.addChildElement('EmployerAddress', null, null);
                body16.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode(opp.Employer_Address2__c==null?'':opp.Employer_Address2__c);
                body16.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode(opp.Employer_Address2_Suburb_State_Zip__c==null?'':opp.Employer_Address2_Suburb_State_Zip__c);
                body16.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode(opp.Employer_State2__c==null?'':opp.Employer_State2__c);
                body16.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode(opp.Employer_Postcode2__c==null?'':opp.Employer_Postcode2__c);
                body16.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode(opp.account.PersonMailingCountryCode==null?'':opp.account.PersonMailingCountryCode);//needs to be changed
                
                body15.addChildElement('PayPeriodType', null, null).addTextNode(setPayPeriodType(opp.Pay_period2__c));
                body15.addChildElement('Hours', null, null).addTextNode(string.valueof((opp.Hours_worked_per_week2__c!=null) ? string.valueof(opp.Hours_worked_per_week2__c) : '38'));
                
                
                if(opp.Casual__c){
                    body15.addChildElement('StatusType', null, null).addTextNode('CASUAL');
                }
                else if(opp.Contract__c){
                    body15.addChildElement('StatusType', null, null).addTextNode('CONTRACT');
                }
                else if(opp.Full_time__c){
                    body15.addChildElement('StatusType', null, null).addTextNode('FULLTIME');
                }
                else if(opp.Part_time__c){
                    body15.addChildElement('StatusType', null, null).addTextNode('PARTTIME');
                }
                else if(opp.Seasonal__c){
                    body15.addChildElement('StatusType', null, null).addTextNode('SEASONAL');
                }
                else if(opp.Self_employed__c){
                    body15.addChildElement('StatusType', null, null).addTextNode('SELF_EMPLOYED');
                }
            }	
            
        }
        dom.XmlNode body17 = body2.addChildElement('PropertySection', null, null);
        if(opp.Are_you_buying__c==true){
            body17.addChildElement('ResidentialAddressType', null, null).addTextNode('BUYING');
        }
        else if(opp.Receiving_free_accommodation__c==true){
            body17.addChildElement('ResidentialAddressType', null, null).addTextNode('FREE');
        }
        else if(opp.Do_you_own__c==true){
            body17.addChildElement('ResidentialAddressType', null, null).addTextNode('OWN');
        }
        else if(opp.Are_you_renting_boarding__c==true){
            body17.addChildElement('ResidentialAddressType', null, null).addTextNode('RENTING');
        }   
        else{
            body17.addChildElement('ResidentialAddressType', null, null).addTextNode('OWN');
        }
        body17.addChildElement('ResidentialAddressYears', null, null).addTextNode(string.valueof(opp.Years2__c!=null ? opp.Years2__c : 0));
        body17.addChildElement('ResidentialAddressMonths', null, null).addTextNode(string.valueof(opp.Months2__c!=null ? opp.Months2__c : 0));
        
        if(opp.Address1__c!=null || opp.Address2__c!=null){
            body17.addChildElement('PreviousPropertiesIndicator', null, null).addTextNode('true');
            dom.XmlNode body18 = body17.addChildElement('PreviousProperties', null, null);  
            
            if(opp.address1__c!=null && opp.suburb1__c!=null && opp.State1__c!=null && opp.Postcode1__c!=null){
                body20 = body18.addChildElement('Item', null, null);
                
                dom.XmlNode body21 = body20.addChildElement('Address', null, null);
                
                
                body21.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode(opp.address1__c!=null?opp.address1__c:'');
                body21.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode(opp.suburb1__c!=null?opp.suburb1__c:'');
                body21.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode(opp.State1__c!=null?opp.State1__c:'');
                body21.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode(opp.Postcode1__c!=null?opp.Postcode1__c:'');
                body21.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode('AU');
                
                if(opp.Did_Do_you_own1__c=='No' || opp.Did_Do_you_own1__c==null){
                    body20.addChildElement('OwnIndicator', null, null).addTextNode('false');
                }else{
                    body20.addChildElement('OwnIndicator', null, null).addTextNode('true');   
                }
            }
            if(opp.address2__c!=null && opp.suburb2__c!=null && opp.State2__c!=null && opp.Postcode2__c!=null){
                body20 = body18.addChildElement('Item', null, null);
                
                dom.XmlNode body21 = body20.addChildElement('Address', null, null);
                
                
                body21.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode(opp.address2__c!=null?opp.address2__c:'');
                body21.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode(opp.suburb2__c!=null?opp.suburb2__c:'');
                body21.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode(opp.State2__c!=null?opp.State2__c:'');
                body21.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode(opp.Postcode2__c!=null?opp.Postcode2__c:'');
                body21.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode('AU');
                
                
                if(opp.Did_Do_you_own2__c=='No' || opp.Did_Do_you_own2__c==null){
                    body20.addChildElement('OwnIndicator', null, null).addTextNode('false');
                }else{
                    body20.addChildElement('OwnIndicator', null, null).addTextNode('true');   
                }
            }
        }else{
            body17.addChildElement('PreviousPropertiesIndicator', null, null).addTextNode('false');
        }
        
        
        if(opp.address3__c!=null && opp.suburb3__c!=null && opp.State3__c!=null && opp.Postcode3__c!=null){
            dom.XmlNode body132 = body17.addChildElement('OtherPropertiesIndicator', null, null).addTextNode('true'); 
            dom.XmlNode body133= body17.addChildElement('OtherProperties', null, null);
            dom.XmlNode body134= body133.addChildElement('Item', null, null);
            dom.XmlNode body136= body134.addChildElement('Address', null, null);
            
            body136.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode(opp.address3__c!=null?opp.address3__c:'');
            body136.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode(opp.suburb3__c!=null?opp.suburb3__c:'');
            body136.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode(opp.State3__c!=null?opp.State3__c:'');
            body136.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode(opp.Postcode3__c!=null?opp.Postcode3__c:'');
            body136.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode('AU');
            
            body134.addChildElement('SoldIndicator', null, null).addTextNode(opp.Did_Do_you_own3__c=='Yes'?'true':'false');
            if(opp.Date_sold_if_applicable3__c!=null){
                body134.addChildElement('SoldDate', null, null).addTextNode(string.valueof(opp.Date_sold_if_applicable3__c));
            }
            if(opp.address4__c!=null && opp.suburb4__c!=null && opp.State4__c!=null && opp.Postcode4__c!=null){
                dom.XmlNode body135= body133.addChildElement('Item', null, null);
                dom.XmlNode body137= body135.addChildElement('Address', null, null);
                body137.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode(opp.address4__c!=null?opp.address4__c:'');
                body137.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode(opp.suburb4__c!=null?opp.suburb4__c:'');
                body137.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode(opp.State4__c!=null?opp.State4__c:'');
                body137.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode(opp.Postcode4__c!=null?opp.Postcode4__c:'');
                body137.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode('AU');
                body135.addChildElement('SoldIndicator', null, null).addTextNode(opp.Did_Do_you_own4__c=='Yes'?'true':'false');
                if(opp.Date_sold_if_applicable4__c!=null){
                    body135.addChildElement('SoldDate', null, null).addTextNode(string.valueof(opp.Date_sold_if_applicable4__c));
                }
                
            }
            
        }else{
            dom.XmlNode body132 = body17.addChildElement('OtherPropertiesIndicator', null, null).addTextNode('false');
        }        
        
        dom.XmlNode body22 = body2.addChildElement('InsolvencySection', null, null);   
        if(opp.Are_you_insolvent__c==null||opp.Are_you_insolvent__c=='No'){
            body22.addChildElement('InsolventIndicator', null, null).addTextNode('false');
        }else{
            body22.addChildElement('InsolventIndicator', null, null).addTextNode('true');
        }
        if(opp.Are_you_currently_up_to_date_with_paymen__c==null||opp.Are_you_currently_up_to_date_with_paymen__c=='No'){
            body22.addChildElement('PaymentsUpToDateIndicator', null, null).addTextNode('false'); 
        }else{
            body22.addChildElement('PaymentsUpToDateIndicator', null, null).addTextNode('true');
        }
        dom.XmlNode body90=body22.addChildElement('ManageDebtStepTakenTypes', null, null);
        
        if(opp.Applied_for_refinancing__c==true){
            dom.XmlNode body91=body90.addChildElement('Item', null, null).addTextNode('APPLIED_FOR_REFINANCING');   
        }
        if(opp.Contacted_your_major_creditors_to__c==true){
            dom.XmlNode body91=body90.addChildElement('Item', null, null).addTextNode('CONTACTED_MAJOR_CREDITORS');   
        }
        if(opp.Spoken_with_debt_agreement_administrator__c==true){
            dom.XmlNode body91=body90.addChildElement('Item', null, null).addTextNode('SPOKEN_DEBT_AGREE_ADMINISTRATOR');   
        }
        if(opp.Spoken_with_nancial_counsellor__c==true){
            dom.XmlNode body91=body90.addChildElement('Item', null, null).addTextNode('SPOKEN_FINANCIAL_COUNSELOR');   
        }
        // when to put 'OTHER' and when to put 'NONE'
        if(opp.Are_you_currently_up_to_date_with_paymen__c==null||opp.Do_you_expect_a_substantial_change_to__c=='No'){
            body22.addChildElement('ExpectIncomeChangeIndicator', null, null).addTextNode('false');
        }else{
            body22.addChildElement('ExpectIncomeChangeIndicator', null, null).addTextNode('true');
        }
        dom.XmlNode body83= body22.addChildElement('ObtainInformationTypes', null, null);
        if(opp.Debt_Agreement_Administrator__c==true){
            body83.addChildElement('Item', null, null).addTextNode('DEBT_AGREEMENT_ADMINISTRATOR');
        }
        if(opp.Other__c==true){
            body83.addChildElement('Item', null, null).addTextNode('OTHER');  
        }
        
        
        if(opp.Previously_been_bankrupt_debt_agreement__c==null||opp.Previously_been_bankrupt_debt_agreement__c=='No'){
            body22.addChildElement('PreviousBankruptcyIndicator', null, null).addTextNode('false'); 
        }else{
            body22.addChildElement('PreviousBankruptcyIndicator', null, null).addTextNode('true');
        }
        if(opp.Year_if_Yes__c!=null){
            body22.addChildElement('PreviousBankruptcyYear', null, null).addTextNode(string.valueof(opp.Year_if_Yes__c));   
        }
        
        dom.XmlNode body23 = body2.addChildElement('FinancialDifficultySection', null, null);
        
        body23.addChildElement('PaymentTroubleStartedYear', null, null).addTextNode(opp.Year__c!=null?string.valueof(opp.Year__c):'');
        body23.addChildElement('PaymentTroubleStartedMonth', null, null).addTextNode(opp.Month__c!=null?string.valueof(opp.Month__c):'');
        dom.XmlNode body24=body23.addChildElement('CircumstanceCauseTypes', null, null);
        
        /* if(opp.Unemployment_or_loss_of_income__c==true){
body24.addChildElement('Item', null, null).addTextNode('LOST_EMPLOYMENT');  
}*/
        if(opp.Loss_of_employment__c==true){
            body24.addChildElement('Item', null, null).addTextNode('LOST_EMPLOYMENT');  
        }
        /* if(opp.Domestic_discord_relationship_breakdowns__c==true){
body24.addChildElement('Item', null, null).addTextNode('RELATIONSHIP_BREAKDOWN');  
}*/
        if(opp.Relationship_breakdown__c==true){
            body24.addChildElement('Item', null, null).addTextNode('RELATIONSHIP_BREAKDOWN');  
        }
        if(opp.Death_of_a_relative__c==true){
            body24.addChildElement('Item', null, null).addTextNode('RELATIVE_DEATH');  
        }
        if(opp.Birth_of_child__c==true){
            body24.addChildElement('Item', null, null).addTextNode('BIRTH_OF_CHILD');  
        }
        /* if(opp.ill_health_absence_of_health_insurance__c==true){
body24.addChildElement('Item', null, null).addTextNode('ILLNESS');  
}*/
        if(opp.Illness__c==true){
            body24.addChildElement('Item', null, null).addTextNode('ILLNESS');  
        }
        if(opp.Reduction_of_overtime__c==true){
            body24.addChildElement('Item', null, null).addTextNode('REDUCTION_OF_OVERTIME');  
        }
        if(opp.Lost_second_job__c==true){
            body24.addChildElement('Item', null, null).addTextNode('LOST_SECOND_JOB');  
        }
        /* if(opp.Excessive_use_of_credit_facilities__c==true){
body24.addChildElement('Item', null, null).addTextNode('CREDIT_OVER_COMMITTED');  
}*/
        if(opp.Over_commitment_of_credit__c==true){
            body24.addChildElement('Item', null, null).addTextNode('CREDIT_OVER_COMMITTED');  
        }
        if(opp.Loss_of_employment_by_partner__c==true){
            body24.addChildElement('Item', null, null).addTextNode('PARTNER_LOST_EMPLOYMENT');  
        }       
        /* if(opp.Adverse_legal_action__c==true){
body24.addChildElement('Item', null, null).addTextNode('LEGAL_ACTION');   
} 
if(opp.Liabilities_due_to_guarantees__c ==true){
body24.addChildElement('Item', null, null).addTextNode('GUARANTEE_LIABILITIES'); 
}
if(opp.Gambling_speculation_extravagance__c){
body24.addChildElement('Item', null, null).addTextNode('GAMBLING_SPECULATION_EXTRAVAGANCE');  
}*/
        if(opp.Other_unable_to_pay_your_debts__c){
            body24.addChildElement('Item', null, null).addTextNode('OTHER');  
        }
        
        if(opp.Other_please_specify2__c!=null){
            body23.addChildElement('CircumstanceCauseOtherText', null, null).addTextNode(string.valueof(opp.Other_please_specify2__c));
        }
        
        if(opp.Unemployment_or_loss_of_income__c==true){
            body23.addChildElement('MainNonBusinessCauseType', null, null).addTextNode('LOSS_OF_INCOME');   
        }
        else if(opp.Excessive_use_of_credit_facilities__c==true){
            body23.addChildElement('MainNonBusinessCauseType', null, null).addTextNode('EXCESSIVE_CREDIT_FACILITIES');   
        }
        else if(opp.Liabilities_due_to_guarantees__c==true){
            body23.addChildElement('MainNonBusinessCauseType', null, null).addTextNode('GUARANTEE_LIABILITIES');   
        }
        else if(opp.Adverse_legal_action__c==true){
            body23.addChildElement('MainNonBusinessCauseType', null, null).addTextNode('LEGAL_ACTION');   
        }
        else if(opp.Gambling_speculation_extravagance__c==true){
            body23.addChildElement('MainNonBusinessCauseType', null, null).addTextNode('GAMBLING_SPECULATION_EXTRAVAGANCE');   
        }
        else if(opp.Domestic_discord_relationship_breakdowns__c==true){
            body23.addChildElement('MainNonBusinessCauseType', null, null).addTextNode('RELATIONSHIP_BREAKDOWN');   
        }
        else if(opp.ill_health_absence_of_health_insurance__c==true){
            body23.addChildElement('MainNonBusinessCauseType', null, null).addTextNode('ILL_HEALTH');   
        }
        else {
            body23.addChildElement('MainNonBusinessCauseType', null, null).addTextNode('OTHER_NON_BUSINESS');  
        }
        if(opp.Economic_conditions_affecting_industry__c || opp.Lack_of_business_ability_including__c || opp.Excessive_interest_payments_Capital_loss__c ||
           opp.Excessive_drawings_including__c || opp.Inability_to_collect_debts_due_to__c || opp.Failure_to_keep_proper_books_of_ac_cost__c ||
           opp.Lack_of_sufficient_initial_working_capit__c ||
           opp.Gambling_or_speculation__c || opp.Seasonal_conditions_including__c  || opp.If_other_reason_not_listed_please_specif__c!=null){
               //dom.XmlNode body136 =body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('ECONOMIC_CONDITIONS'); //items to be added
               ////dom.XmlNode body136 =body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('ECONOMIC_CONDITIONS');
               ////dom.XmlNode body136 =body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('ECONOMIC_CONDITIONS');
               if(opp.Economic_conditions_affecting_industry__c){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('ECONOMIC_CONDITIONS');
               }
               if(opp.Lack_of_business_ability_including__c){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('LACK_OF_BUSINESS_ABILITY');
               }
               if(opp.Excessive_interest_payments_Capital_loss__c){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('EXCESSIVE_INTEREST');
               }
               if(opp.Excessive_drawings_including__c){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('EXCESSIVE_DRAWINGS');
               }
               if(opp.Inability_to_collect_debts_due_to__c){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('INABILITY_TO_COLLECT_DEBTS');
               }
               if(opp.Failure_to_keep_proper_books_of_ac_cost__c){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('NO_PROPER_BOOKS');
               }
               if(opp.Lack_of_sufficient_initial_working_capit__c){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('LACK_OF_INITIAL_CAPITAL');
               }
               if(opp.Gambling_or_speculation__c){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('GAMBLING_SPECULATION');
               }
               if(opp.Seasonal_conditions_including__c){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('SEASONAL_CONDITIONS');
               }
               if(opp.If_other_reason_not_listed_please_specif__c!=null){
                   body23.addChildElement('MainBusinessCauseType', null, null).addTextNode('OTHER_BUSINESS');
               }
           }
        
        dom.XmlNode body25=body2.addChildElement('BusinessSection', null, null);
        if(opp.Yes_Are_you_currentl_in_business_as_sol__c==null || opp.Yes_Are_you_currentl_in_business_as_sol__c=='No'){
            body25.addChildElement('BusinessIndicator', null, null).addTextNode('false');
        }else{
            body25.addChildElement('BusinessIndicator', null, null).addTextNode('true');
            dom.XmlNode body135= body25.addChildElement('Businesses', null, null);
            dom.XmlNode body136= body135.addChildElement('Item', null, null);
            body136.addChildElement('Name', null, null).addTextNode(opp.Business_Name__c!=null?opp.Business_Name__c:'');
            dom.XmlNode body190 = body136.addChildElement('Address', null, null);
            
            body190.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode(opp.Business_Address__c!=null?opp.Business_Address__c:'');
            body190.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode(opp.Business_Suburb__c!=null?opp.Business_Suburb__c:'');
            body190.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode(opp.Business_State__c!=null?opp.Business_State__c:'');
            body190.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode(opp.Business_PostCode__c!=null?opp.Business_PostCode__c:'');
            body190.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode('AU');
            
            
            if(opp.Business_Partner_s_Name_if_applicable__c!=null){
                body136.addChildElement('PartnersName', null, null).addTextNode(opp.Business_Partner_s_Name_if_applicable__c); 
            }
            body136.addChildElement('Nature', null, null).addTextNode(opp.What_is_the_nature_of_this_business__c!=null?opp.What_is_the_nature_of_this_business__c:''); 
            body136.addChildElement('OperatingStartDate', null, null).addTextNode(opp.When_did_the_business_start_operating__c!=null?string.valueof(opp.When_did_the_business_start_operating__c):''); 
            
            
            
            
            if(opp.Yes_Are_all_your_business_assets_shown__c=false){
                body136.addChildElement('AssetDisclosedIndicator', null, null).addTextNode('false');
            }else{
                body136.addChildElement('AssetDisclosedIndicator', null, null).addTextNode('true');
                
            }
        }
        
        dom.XmlNode body26=body2.addChildElement('CompanySection', null, null);
        if(opp.Yes_Have_you_been_a_director__c==null || opp.Yes_Have_you_been_a_director__c=='No'){
            body26.addChildElement('CompanyIndicator', null, null).addTextNode('false'); 
        }else{
            body26.addChildElement('CompanyIndicator', null, null).addTextNode('true');
        }
        
        dom.XmlNode body27=body2.addChildElement('TrustSection', null, null);
        if(opp.Yes_have_you_been_a_unit_holder_in__c==null || opp.Yes_have_you_been_a_unit_holder_in__c=='No'){
            body27.addChildElement('HolderIndicator', null, null).addTextNode('false');
        }else{
            body27.addChildElement('HolderIndicator', null, null).addTextNode('true');
        }
        if(opp.Have_you_transferred_any_assets_to_a_tru__c==null || opp.Have_you_transferred_any_assets_to_a_tru__c=='No'){
            body27.addChildElement('TransferredIndicator', null, null).addTextNode('false');
        }else{
            body27.addChildElement('TransferredIndicator', null, null).addTextNode('true');
        }
        dom.XmlNode body28=body2.addChildElement('ProposalSection', null, null);
        dom.XmlNode body29=body28.addChildElement('Payments', null, null);
        
        if(opp.Weekly_fortnightly_monthly1__c!=null && opp.Amount_of_each_payment1__c!=null && opp.Total_value_of_payments1__c!=null ){
            
            
            dom.XmlNode body30=body29.addChildElement('Item', null, null);
            body30.addChildElement('Count', null, null).addTextNode(string.valueof((opp.Number_of_payments1__c!=null) ? string.valueof(opp.Number_of_payments1__c) : ''));
            if(opp.Weekly_fortnightly_monthly1__c=='6 Monthly'){
                body30.addChildElement('FrequencyType', null, null).addTextNode('SIX_MONTHLY');
            }else{
                body30.addChildElement('FrequencyType', null, null).addTextNode(opp.Weekly_fortnightly_monthly1__c!=null ? opp.Weekly_fortnightly_monthly1__c.toUpperCase():'');
            }
            
            body30.addChildElement('Amount', null, null).addTextNode(opp.Amount_of_each_payment1__c!=null ? string.valueof(opp.Amount_of_each_payment1__c) : '');
            body30.addChildElement('TotalAmount', null, null).addTextNode(string.valueof((opp.Total_value_of_payments1__c!=null) ? string.valueof(opp.Total_value_of_payments1__c) : ''));
            
        }
        if(opp.Weekly_fortnightly_monthly2__c!=null && opp.Amount_of_each_payment2__c!=null && opp.Total_value_of_payments2__c!=null ){
            dom.XmlNode body31=body29.addChildElement('Item', null, null);
            body31.addChildElement('Count', null, null).addTextNode(opp.Number_of_payments2__c!=null ? string.valueof(opp.Number_of_payments2__c) : '');
            if(opp.Weekly_fortnightly_monthly2__c=='6 Monthly'){
                body31.addChildElement('FrequencyType', null, null).addTextNode('SIX_MONTHLY');
            }else{
                body31.addChildElement('FrequencyType', null, null).addTextNode(opp.Weekly_fortnightly_monthly2__c!=null ? opp.Weekly_fortnightly_monthly2__c.toUpperCase():'');
            }
            body31.addChildElement('Amount', null, null).addTextNode(String.valueof(opp.Amount_of_each_payment2__c!=null ? string.valueof(opp.Amount_of_each_payment2__c) : ''));
            body31.addChildElement('TotalAmount', null, null).addTextNode(string.valueof((opp.Total_value_of_payments2__c!=null) ? string.valueof(opp.Total_value_of_payments2__c) : ''));
        }
        if(opp.Weekly_fortnightly_monthly3__c!=null && opp.Amount_of_each_payment3__c!=null && opp.Total_value_of_payments3__c!=null ){
            dom.XmlNode body32=body29.addChildElement('Item', null, null);
            body32.addChildElement('Count', null, null).addTextNode(string.valueof((opp.Number_of_payments3__c!=null) ? string.valueof(opp.Number_of_payments3__c) : ''));
            
            if(opp.Weekly_fortnightly_monthly3__c=='6 Monthly'){
                body32.addChildElement('FrequencyType', null, null).addTextNode('SIX_MONTHLY');
            }else{
                body32.addChildElement('FrequencyType', null, null).addTextNode(opp.Weekly_fortnightly_monthly3__c!=null ? opp.Weekly_fortnightly_monthly3__c.toUpperCase():'');
            }
            body32.addChildElement('Amount', null, null).addTextNode(String.valueof(opp.Amount_of_each_payment3__c!=null ? string.valueof(opp.Amount_of_each_payment3__c) : ''));
            body32.addChildElement('TotalAmount', null, null).addTextNode(string.valueof((opp.Total_value_of_payments3__c!=null) ? string.valueof(opp.Total_value_of_payments3__c) : ''));
        }
        
        if(opp.Weekly_fortnightly_monthly4__c!=null && opp.Amount_of_each_payment4__c!=null && opp.Total_value_of_payments4__c!=null ){
            dom.XmlNode body33=body29.addChildElement('Item', null, null);
            body33.addChildElement('Count', null, null).addTextNode(string.valueof((opp.Number_of_payments4__c!=null) ? string.valueof(opp.Number_of_payments4__c) : ''));
            if(opp.Weekly_fortnightly_monthly4__c=='6 Monthly'){
                body33.addChildElement('FrequencyType', null, null).addTextNode('SIX_MONTHLY');
            }else{
                body33.addChildElement('FrequencyType', null, null).addTextNode(opp.Weekly_fortnightly_monthly4__c!=null ? opp.Weekly_fortnightly_monthly4__c.toUpperCase():'');
            }
            body33.addChildElement('Amount', null, null).addTextNode(String.valueof(string.valueof((opp.Amount_of_each_payment4__c!=null) ? string.valueof(opp.Amount_of_each_payment4__c) : '')));
            body33.addChildElement('TotalAmount', null, null).addTextNode(string.valueof((opp.Total_value_of_payments4__c!=null) ? string.valueof(opp.Total_value_of_payments4__c) : ''));
        }
        
        if(opp.Weekly_fortnightly_monthly5__c!=null && opp.Amount_of_each_payment5__c!=null && opp.Total_value_of_payments5__c!=null ){
            dom.XmlNode body81=body29.addChildElement('Item', null, null);
            body81.addChildElement('Count', null, null).addTextNode(string.valueof((opp.Number_of_payments5__c!=null) ? string.valueof(opp.Number_of_payments5__c) : ''));
            if(opp.Weekly_fortnightly_monthly5__c=='6 Monthly'){
                body81.addChildElement('FrequencyType', null, null).addTextNode('SIX_MONTHLY');
            }else{
                body81.addChildElement('FrequencyType', null, null).addTextNode(opp.Weekly_fortnightly_monthly5__c!=null ? opp.Weekly_fortnightly_monthly5__c.toUpperCase():'');
            }
            body81.addChildElement('Amount', null, null).addTextNode(String.valueof(string.valueof((opp.Amount_of_each_payment5__c!=null) ? string.valueof(opp.Amount_of_each_payment5__c) : '')));
            body81.addChildElement('TotalAmount', null, null).addTextNode(string.valueof((opp.Total_value_of_payments5__c!=null) ? string.valueof(opp.Total_value_of_payments5__c) : ''));
        }
        body28.addChildElement('TotalPaymentAmount', null, null).addTextNode(string.valueof((opp.Total_amount_offered_in_the_proposal__c!=null) ? string.valueof(opp.Total_amount_offered_in_the_proposal__c) : ''));
        // body28.addChildElement('RealisationChargePercentage', null, null).addTextNode(string.valueof(opp.Realisations_charge_payable_to_Australia__c));
        
        body28.addChildElement('RealisationChargePercentage', null, null).addTextNode(string.valueof((opp.Realisations_charge_payable_to_Australia__c!=null) ? string.valueof(opp.Realisations_charge_payable_to_Australia__c/100) : '0'));
        body28.addChildElement('RealisationChargeAmount', null, null).addTextNode(string.valueof((opp.Realisations_charge_payable_to_Aus_Sum__c!=null) ? string.valueof(opp.Realisations_charge_payable_to_Aus_Sum__c) : ''));
        body28.addChildElement('AdministratorFeeAmount', null, null).addTextNode(string.valueof((opp.Fees_for_administrator_to_admin_deb_Sum__c!=null) ? string.valueof(opp.Fees_for_administrator_to_admin_deb_Sum__c) : ''));
        if(opp.Expense_Banking_Fees_Amount_Sum__c!=null){
            body28.addChildElement('ExpensesBankingFeesAmount', null, null).addTextNode(string.valueof((opp.Expense_Banking_Fees_Amount_Sum__c!=null) ? string.valueof(opp.Expense_Banking_Fees_Amount_Sum__c) : ''));
        }
        if(opp.Expense_Valuating_Amount_Sum__c!=null){
            body28.addChildElement('ExpensesValuatingAssetsAmount', null, null).addTextNode(string.valueof((opp.Expense_Valuating_Amount_Sum__c!=null) ? string.valueof(opp.Expense_Valuating_Amount_Sum__c) : ''));
            
        }
        if(opp.Expense_Eligibility_Amount_Sum__c!=null){
            body28.addChildElement('ExpensesEligibilityDebtorAmount', null, null).addTextNode(string.valueof((opp.Expense_Eligibility_Amount_Sum__c!=null) ? string.valueof(opp.Expense_Eligibility_Amount_Sum__c) : ''));
            
        }
        if(opp.Expense_Other_Amount_Sum__c!=null){
            body28.addChildElement('ExpensesOtherAmount', null, null).addTextNode(string.valueof((opp.Expense_Other_Amount_Sum__c!=null) ? string.valueof(opp.Expense_Other_Amount_Sum__c) : ''));
        }
        body28.addChildElement('AllowableExpenseAmount', null, null).addTextNode(string.valueof((opp.Allowable_expenses_payable_to_third_Sum__c!=null) ? string.valueof(opp.Allowable_expenses_payable_to_third_Sum__c) : ''));
        body28.addChildElement('TotalDistributedAmount', null, null).addTextNode(string.valueof((opp.TOTAL_amount_to_be_distributed_proportio__c!=null) ? string.valueof(opp.TOTAL_amount_to_be_distributed_proportio__c) : ''));
        body28.addChildElement('FirstPaymentDate', null, null).addTextNode(String.valueof(opp.Date_of_debtor_s_rst_payment_to_adminis__c)!=null?String.valueof(opp.Date_of_debtor_s_rst_payment_to_adminis__c):'');
        body28.addChildElement('FirstDividendDate', null, null).addTextNode(String.valueof(opp.Date_first_dividend_be_paid_to_cred_Sun__c)!=null?String.valueof(opp.Date_first_dividend_be_paid_to_cred_Sun__c):'');
        body28.addChildElement('DividendFrequency', null, null).addTextNode(opp.Dividend_Frequency__c!=null?opp.Dividend_Frequency__c.toUpperCase().replaceAll('(\\s+)', '_'):'');
        body28.addChildElement('AgreementCompletionDate', null, null).addTextNode(String.valueof(opp.Date_debtor_will_complete_debt_agr_Sum__c)!=null?String.valueof(opp.Date_debtor_will_complete_debt_agr_Sum__c):'');
        body28.addChildElement('EstimatedDividendPercentage', null, null).addTextNode(string.valueof(opp.Estimated_dividend_based_on_deb_list_Sum__c!=null? string.valueof(opp.Estimated_dividend_based_on_deb_list_Sum__c/100) : '0'));
        body28.addChildElement('ParticipatingDividendPercentage', null, null).addTextNode(string.valueof(opp.Estimated_dividend_excluding_sec_cre_Sum__c!=null?string.valueof(opp.Estimated_dividend_excluding_sec_cre_Sum__c/100):'0'));
        body28.addChildElement('LumpSumPaymentSourceText', null, null).addTextNode(opp.Source_of_lump_sum_payment_or_details_of__c!=null?opp.Source_of_lump_sum_payment_or_details_of__c :'Nil');
        if(opp.yes__c==true){
            body28.addChildElement('SubjectToConditionsIndicator', null, null).addTextNode(string.valueof(opp.yes__c));
        }
        if(opp.No__c==true){
            body28.addChildElement('SubjectToConditionsIndicator', null, null).addTextNode('false');
        }
        if(opp.If_yes_provide_details__c!=null){
            body28.addChildElement('SubjectToConditionsText', null, null).addTextNode(opp.If_yes_provide_details__c);
        }
        body28.addChildElement('DaaSetupFeeAmount', null, null).addTextNode(string.valueof(opp.Set_up_fees_paid_or_payable__c)!=null?string.valueof(opp.Set_up_fees_paid_or_payable__c):'');
        
        
        dom.XmlNode body34=body2.addChildElement('AssetSection', null, null);
        dom.XmlNode body86=body34.addChildElement('OwnIndicator', null, null).addTextNode('true');
        if((opp.Unsecured_Assets_Description1__c!=null && opp.Estimated_Total_Value1__c!=null && opp.Percentage_Owned1__c!=null)
           ||(opp.Unsecured_Assets_Description2__c!=null && opp.Estimated_Total_Value2__c!=null && opp.Percentage_Owned2__c!=null)
           ||(opp.Unsecured_Assets_Description3__c!=null && opp.Estimated_Total_Value3__c!=null && opp.Percentage_Owned3__c!=null)){
               
               
               dom.XmlNode body35=body34.addChildElement('Assets', null, null);
               
               if(opp.Unsecured_Assets_Description1__c!=null && opp.Estimated_Total_Value1__c!=null && opp.Percentage_Owned1__c!=null){
                   dom.XmlNode body36=body35.addChildElement('Item', null, null);
                   if(opp.Unsecured_Assets_SubClassification1__c=='Book Debt'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('BD');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Business Asset'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('BA');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification1__c=='Commercial Real Estate'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('CR');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Funds in Bank Account and Cash'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('AC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Household Goods and Personal Effects'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('HG');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Interest in Deceased Estate'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('DE');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Jewelry Collectables and Antiques'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('JC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Livestock and crops'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('LC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Marine Vessel'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('BO');  //Value not Known
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Other'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('OT');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Residential Real Estate'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('RR');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Shares'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('SH');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification1__c=='Superannuation and Life Insurance Policies'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('IS');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Tax Refunds and Other Refunds or Rebates'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('TR');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Timeshare'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('TP');  // value not known
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Tools of Trade'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('TT');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Vacant Land'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('VL');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification1__c=='Vehicles Including Trailers'){
                       body36.addChildElement('ClassificationType', null, null).addTextNode('VE');  
                   }else {
                       body36.addChildElement('ClassificationType', null, null).addTextNode('BD');
                   }
                   
                   //body36.addChildElement('ClassificationType', null, null).addTextNode(opp.Unsecured_Assets_SubClassification1__c==null?'':opp.Unsecured_Assets_SubClassification1__c);
                   body36.addChildElement('Description', null, null).addTextNode(opp.Unsecured_Assets_Description1__c==null?'':opp.Unsecured_Assets_Description1__c);
                   body36.addChildElement('EstimatedValueAmount', null, null).addTextNode(string.valueof((opp.Estimated_Total_Value1__c!=null) ? string.valueof(opp.Estimated_Total_Value1__c) : ''));
                   body36.addChildElement('OwnedPercentage', null, null).addTextNode(string.valueof((opp.Percentage_Owned1__c!=null) ? string.valueof(opp.Percentage_Owned1__c/100) : '0'));
                   
                   body36.addChildElement('SurplusAmount', null, null).addTextNode(string.valueof('0'));
                   body36.addChildElement('OwnedSurplusAmount', null, null).addTextNode(string.valueof('0'));
               }
               if(opp.Unsecured_Assets_Description2__c!=null && opp.Estimated_Total_Value2__c!=null && opp.Percentage_Owned2__c!=null){
                   dom.XmlNode body37=body35.addChildElement('Item', null, null);
                   
                   if(opp.Unsecured_Assets_SubClassification2__c=='Book Debt'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('BD');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Business Asset'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('BA');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Commercial Real Estate'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('CR');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Funds in Bank Account and Cash'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('AC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Household Goods and Personal Effects'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('HG');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Interest in Deceased Estate'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('DE');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification2__c=='Jewelry Collectables and Antiques'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('JC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Livestock and crops'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('LC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Marine Vessel'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('BO');  //Value not Known
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Other'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('OT');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Residential Real Estate'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('RR');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification2__c=='Shares'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('SH');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Superannuation and Life Insurance Policies'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('IS');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Tax Refunds and Other Refunds or Rebates'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('TR');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification2__c=='Timeshare'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('TP');  // value not known
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Tools of Trade'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('TT');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification2__c=='Vacant Land'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('VL');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification2__c=='Vehicles Including Trailers'){
                       body37.addChildElement('ClassificationType', null, null).addTextNode('VE');  
                   } else{
                       body37.addChildElement('ClassificationType', null, null).addTextNode('BD');
                   }
                   
                   // body37.addChildElement('ClassificationType', null, null).addTextNode('BD');
                   //    body37.addChildElement('ClassificationType', null, null).addTextNode(opp.Unsecured_Assets_SubClassification2__c==null?'':opp.Unsecured_Assets_SubClassification2__c);
                   body37.addChildElement('Description', null, null).addTextNode(opp.Unsecured_Assets_Description2__c==null?'':opp.Unsecured_Assets_Description2__c);
                   body37.addChildElement('EstimatedValueAmount', null, null).addTextNode(string.valueof((opp.Estimated_Total_Value2__c!=null) ? string.valueof(opp.Estimated_Total_Value2__c) : ''));
                   body37.addChildElement('OwnedPercentage', null, null).addTextNode(string.valueof((opp.Percentage_Owned2__c!=null) ? string.valueof(opp.Percentage_Owned2__c/100) : ''));
                   body37.addChildElement('SurplusAmount', null, null).addTextNode(string.valueof('0'));
                   body37.addChildElement('OwnedSurplusAmount', null, null).addTextNode(string.valueof('0'));
               }
               if(opp.Unsecured_Assets_Description3__c!=null && opp.Estimated_Total_Value3__c!=null && opp.Percentage_Owned3__c!=null){
                   dom.XmlNode body38=body35.addChildElement('Item', null, null);
                   
                   if(opp.Unsecured_Assets_SubClassification3__c=='Book Debt'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('BD');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Business Asset'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('BA');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Commercial Real Estate'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('CR');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Funds in Bank Account and Cash'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('AC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Household Goods and Personal Effects'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('HG');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Interest in Deceased Estate'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('DE');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification3__c=='Jewelry Collectables and Antiques'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('JC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Livestock and crops'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('LC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Marine Vessel'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('BO');  //Value not Known
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Other'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('OT');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Residential Real Estate'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('RR');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification3__c=='Shares'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('SH');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Superannuation and Life Insurance Policies'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('IS');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Tax Refunds and Other Refunds or Rebates'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('TR');  
                   }	
                   else  if(opp.Unsecured_Assets_SubClassification3__c=='Timeshare'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('TP');  // value not known
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Tools of Trade'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('TT');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification3__c=='Vacant Land'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('VL');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification3__c=='Vehicles Including Trailers'){
                       body38.addChildElement('ClassificationType', null, null).addTextNode('VE');  
                   } else{
                       body38.addChildElement('ClassificationType', null, null).addTextNode('BD');
                   }
                   
                   //   body38.addChildElement('ClassificationType', null, null).addTextNode('BD');
                   
                   // body38.addChildElement('ClassificationType', null, null).addTextNode(opp.Unsecured_Assets_SubClassification3__c==null?'':opp.Unsecured_Assets_SubClassification3__c);
                   body38.addChildElement('Description', null, null).addTextNode(opp.Unsecured_Assets_Description3__c==null?'':opp.Unsecured_Assets_Description3__c);
                   body38.addChildElement('EstimatedValueAmount', null, null).addTextNode(string.valueof((opp.Estimated_Total_Value3__c!=null) ? string.valueof(opp.Estimated_Total_Value3__c) : ''));
                   body38.addChildElement('OwnedPercentage', null, null).addTextNode(string.valueof((opp.Percentage_Owned3__c!=null) ? string.valueof(opp.Percentage_Owned3__c/100) : ''));
                   body38.addChildElement('SurplusAmount', null, null).addTextNode(string.valueof('0'));
                   body38.addChildElement('OwnedSurplusAmount', null, null).addTextNode(string.valueof('0'));
               }
               if(opp.Unsecured_Assets_Description4__c!=null && opp.Estimated_Total_Value4__c!=null && opp.Percentage_Owned4__c!=null){
                   dom.XmlNode body39=body35.addChildElement('Item', null, null);
                   
                   if(opp.Unsecured_Assets_SubClassification4__c=='Book Debt'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('BD');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Business Asset'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('BA');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Commercial Real Estate'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('CR');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Funds in Bank Account and Cash'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('AC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Household Goods and Personal Effects'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('HG');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Interest in Deceased Estate'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('DE');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification4__c=='Jewelry Collectables and Antiques'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('JC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Livestock and crops'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('LC');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Marine Vessel'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('BO');  //Value not Known
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Other'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('OT');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Residential Real Estate'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('RR');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification4__c=='Shares'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('SH');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Superannuation and Life Insurance Policies'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('IS');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Tax Refunds and Other Refunds or Rebates'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('TR');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification4__c=='Timeshare'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('TP');  // value not known
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Tools of Trade'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('TT');  
                   }
                   else if(opp.Unsecured_Assets_SubClassification4__c=='Vacant Land'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('VL');  
                   }
                   else  if(opp.Unsecured_Assets_SubClassification4__c=='Vehicles Including Trailers'){
                       body39.addChildElement('ClassificationType', null, null).addTextNode('VE');  
                   } else{
                       body39.addChildElement('ClassificationType', null, null).addTextNode('BD');
                   }
                   
                   
                   // body39.addChildElement('ClassificationType', null, null).addTextNode('BD');
                   
                   //  body39.addChildElement('ClassificationType', null, null).addTextNode(opp.Unsecured_Assets_SubClassification4__c==null?'':opp.Unsecured_Assets_SubClassification4__c);
                   body39.addChildElement('Description', null, null).addTextNode(opp.Unsecured_Assets_Description4__c==null?'':opp.Unsecured_Assets_Description4__c);
                   body39.addChildElement('EstimatedValueAmount', null, null).addTextNode(string.valueof((opp.Estimated_Total_Value4__c!=null) ? string.valueof(opp.Estimated_Total_Value4__c) : ''));
                   body39.addChildElement('OwnedPercentage', null, null).addTextNode(string.valueof((opp.Percentage_Owned4__c!=null) ? string.valueof(opp.Percentage_Owned4__c/100) : ''));
                   body39.addChildElement('SurplusAmount', null, null).addTextNode(string.valueof('0'));
                   body39.addChildElement('OwnedSurplusAmount', null, null).addTextNode(string.valueof('0'));
               }
           }
        dom.XmlNode body40=body2.addChildElement('LiabilitySection', null, null);
        dom.XmlNode body41=body40.addChildElement('Liabilities', null, null);
        
        
        
        Decimal sumOfAmountOwing=0;
        List<Debt__c> novDivDebtList=[select id from debt__c where recordtype.name=:'3. Not to be paid Debt' AND Opportunity__c=:opp.id];
        for(Debt__c debtobj:[select id,Name,Amount_Owing__c,Send_DAP_to__r.name,Account_Reference_Number__c,Is_Participating_Bric__c,
                             Related_If_Yes__c,Creditor_Type__c,Nature_of_Debt__c,Account_Status__c,Joint__c,RecordType.name,
                             Surplus_Shortfall__c,Send_DAP_to__r.DAPid__c,Send_DAP_to__r.Reference__c,Send_DAP_to__r.Creditor_Type__c,
                             Asset_Description__c,Send_DAP_to__r.Is_Admin_Related_Creditor__c,
                             Send_DAP_to__r.Admin_Related_Creditor_Relationship_Type__c ,If_related_then_Relationship_to_you_pick__c
                             // Send_DAP_to__r.Nature_of_Debt__c 
                             from Debt__c where Opportunity__c=:opp.id]){
                                 if(debtobj.Send_DAP_to__r.Is_Admin_Related_Creditor__c=='Yes'){
                                     Is_Admin_Related_Creditor_Debts.add(debtobj); 
                                 }
                                 
                                 if(debtobj.RecordType.name!='3. Not to be paid Debt'){
                                     dom.XmlNode body42=body41.addChildElement('Item', null, null);
                                     body42.addChildElement('CreditorId', null, null).addTextNode(debtobj.Send_DAP_to__r.DAPid__c==null?'':String.valueof((debtobj.Send_DAP_to__r.DAPid__c)).replaceAll('(\\s+)', ''));
                                     body42.addChildElement('CreditorReference', null, null).addTextNode(debtobj.Account_Reference_Number__c==null?'':String.valueof(debtobj.Account_Reference_Number__c));
                                     
                                     body42.addChildElement('RelatedIndicator', null, null).addTextNode(string.valueof(debtobj.Related_If_Yes__c==null ?false:debtobj.Related_If_Yes__c));
                                     if(debtobj.Related_If_Yes__c){
                                         body42.addChildElement('RelatedType', null, null).addTextNode(string.valueof(debtobj.If_related_then_Relationship_to_you_pick__c==null ?'':debtobj.If_related_then_Relationship_to_you_pick__c));
                                     }
                                     
                                     body42.addChildElement('CreditorType', null, null).addTextNode(debtobj.Send_DAP_to__r.Creditor_Type__c==null?'':(debtobj.Send_DAP_to__r.Creditor_Type__c.toUpperCase()).replaceAll('\\s+', '_'));
                                     //body42.addChildElement('DebtNatureType', null, null).addTextNode(debtobj.Nature_of_Debt__c==null?'':debtobj.Nature_of_Debt__c);
                                     if(debtobj.Nature_of_Debt__c=='Credit Card'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('CC');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Store Card'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('SC');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Personal Loan'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('PL');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Motor Vehicle Security'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('MV');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='House Mortgage'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('HM');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Chattel Mortgage'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('CM');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Overdraft Account'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('OT'); 
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Overdrawn Accounts'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('OA');    
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Business Security'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('BS');  
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Bill of Sale'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('BA');    
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Charge'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('CG');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Hire Purchase'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('HP');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Lease'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('LS');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Lien'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('LI');
                                     }
                                     
                                     else if(debtobj.Nature_of_Debt__c=='Not applicable'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('NA');
                                     }else if(debtobj.Nature_of_Debt__c=='Other'){
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('OT');
                                     }else{
                                         body42.addChildElement('DebtNatureType', null, null).addTextNode('OT');
                                     }
                                     
                                     
                                     if(debtobj.Account_Status__c!=null){
                                         body42.addChildElement('StatusType', null, null).addTextNode(debtobj.Account_Status__c==null?'':(debtobj.Account_Status__c).toUpperCase().replaceAll('(\\s+)', '_'));
                                         
                                     }
                                     if(debtobj.Joint__c==null || debtobj.Joint__c=='No' ){
                                         body42.addChildElement('JointDebtIndicator', null, null).addTextNode('false');
                                     }else{
                                         body42.addChildElement('JointDebtIndicator', null, null).addTextNode('true');
                                     }
                                     
                                     body42.addChildElement('OwedAmount', null, null).addTextNode (string.valueof((debtobj.Amount_Owing__c!=null) ? string.valueof(debtobj.Amount_Owing__c) : ''));
                                     if(debtobj.Amount_Owing__c!=null){
                                         sumOfAmountOwing+=debtobj.Amount_Owing__c;
                                     }
                                     if(debtobj.RecordType.name=='1. Secured Debt'){
                                         dom.XmlNode  body110=body42.addChildElement('SecuredIndicator', null, null).addTextNode('true');
                                         dom.XmlNode body111=body42.addChildElement('Securities', null, null);
                                         dom.XmlNode body112=body111.addChildElement('Item', null, null);
                                         body112.addChildElement('AssetDescription', null, null).addTextNode(debtobj.Asset_Description__c!=null?debtobj.Asset_Description__c:'');
                                         body112.addChildElement('Priority', null, null).addTextNode('1');
                                         
                                     }
                                     else {
                                         body42.addChildElement('SecuredIndicator', null, null).addTextNode('false');
                                     }
                                     
                                     body42.addChildElement('ShortfallAmount', null, null).addTextNode(string.valueof(debtobj.Surplus_Shortfall__c!=null ? debtobj.Surplus_Shortfall__c: 0));
                                 }
                                 if(novDivDebtList.size()==0){
                                     if(flag2){
                                         dom.XmlNode body130=body2.addChildElement('NonDividendLiabilities', null, null);
                                         body130.addChildElement('LiabilityNonDividendIndicator', null, null).addTextNode('false');
                                         flag2=false;
                                     }
                                 }
                                 if(debtobj.RecordType.name=='3. Not to be paid Debt'){
                                     if(flag3){
                                         dom.XmlNode body87=body2.addChildElement('NonDividendLiabilities', null, null);
                                         body87.addChildElement('LiabilityNonDividendIndicator', null, null).addTextNode('true');
                                         body100=body87.addChildElement('NonDividendLiabilities', null, null);
                                         flag3=false;
                                     }
                                     
                                     dom.XmlNode body101=body100.addChildElement('Item', null, null);
                                     body101.addChildElement('CreditorId', null, null).addTextNode(debtobj.Send_DAP_to__r.DAPid__c==null?'':String.valueof((debtobj.Send_DAP_to__r.DAPid__c)).replaceAll('(\\s+)', ''));
                                     body101.addChildElement('CreditorReference', null, null).addTextNode(debtobj.Account_Reference_Number__c==null?'':String.valueof(debtobj.Account_Reference_Number__c));
                                     body101.addChildElement('RelatedIndicator', null, null).addTextNode(string.valueof(debtobj.Related_If_Yes__c));
                                     if(debtobj.Related_If_Yes__c){
                                         body101.addChildElement('RelatedType', null, null).addTextNode(string.valueof(debtobj.If_related_then_Relationship_to_you_pick__c==null ?'':debtobj.If_related_then_Relationship_to_you_pick__c));
                                     }
                                     body101.addChildElement('CreditorType', null, null).addTextNode(debtobj.Send_DAP_to__r.Creditor_Type__c==null?'':(debtobj.Send_DAP_to__r.Creditor_Type__c.toUpperCase()).replaceAll('\\s+', '_'));
                                     // body42.addChildElement('DebtNatureType', null, null).addTextNode(debt
                                     if(debtobj.Nature_of_Debt__c=='Credit Card'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('CC');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Store Card'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('SC');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Personal Loan'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('PL');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Motor Vehicle Security'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('MV');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='House Mortgage'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('HM');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Chattel Mortgage'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('CM');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Overdraft Account'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('CC');  
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Overdrawn Accounts'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('OA');    
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Business Security'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('BS');   
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Bill of Sale'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('BA');   
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Charge'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('CG');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Hire Purchase'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('HP');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Lease'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('LS');
                                     }
                                     else if(debtobj.Nature_of_Debt__c=='Lien'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('LI');
                                     }
                                     
                                     else if(debtobj.Nature_of_Debt__c=='Not applicable'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('NA');
                                     }else if(debtobj.Nature_of_Debt__c=='Other'){
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('OT');
                                     }else{
                                         body101.addChildElement('DebtNatureType', null, null).addTextNode('OT');
                                     }
                                     body101.addChildElement('OwedAmount', null, null).addTextNode (string.valueof((debtobj.Amount_Owing__c!=null) ? string.valueof(debtobj.Amount_Owing__c) : ''));
                                 }
                             }
        dom.XmlNode body82=body2.addChildElement('AssetLiabilitySummarySection', null, null);
        
        
        
        body82.addChildElement('TotalNonDividendDebtAmount', null, null).addTextNode(string.valueof('0'));
        body82.addChildElement('TotalSecuredShortfallAmount', null, null).addTextNode(string.valueof('0'));
        body82.addChildElement('TotalUnsecuredDebtAmount', null, null).addTextNode(string.valueof('0'));
        body82.addChildElement('TotalDebtAmount', null, null).addTextNode(string.valueof((sumOfAmountOwing!=null) ? string.valueof(sumOfAmountOwing) : ''));
        body82.addChildElement('TotalUnsecuredAssetAmount', null, null).addTextNode(string.valueof('0'));
        body82.addChildElement('TotalSecuredAssetSurplusAmount', null, null).addTextNode(string.valueof('0'));
        body82.addChildElement('TotalAssetAmount', null, null).addTextNode(string.valueof('0'));
        
        dom.XmlNode body92=body2.addChildElement('IncomeExpenseFrequencyType', null, null).addTextNode('WEEKLY');   
        dom.XmlNode body43=body2.addChildElement('IncomeSection', null, null);
        body43.addChildElement('TaxableIncomeAmount', null, null).addTextNode(string.valueof((opp.Debtor_s_Taxable_Income__c!=null) ? string.valueof(opp.Debtor_s_Taxable_Income__c) : '0'));
        
        if(opp.Wages_after_tax__c!=null || opp.Allowances_overtime_fringe_benefits__c!=null || opp.Taxable_centrelink_benefits__c!=null 
           || opp.Non_taxable_centrelink_benefits__c!=null || opp.Regular_income_from_tenants_for_rent__c!=null
           || opp.After_tax_income_from_second_jobs__c!=null || opp.Child_spouse_maintenance_received__c!=null || opp.Other_Income__c!=null){
               body44=body43.addChildElement('Items', null, null);
               if(opp.Wages_after_tax__c!=null){
                   dom.XmlNode body45=body44.addChildElement('Item', null, null);//Add Null Check
                   body45.addChildElement('Type', null, null).addTextNode('WAGES_AFTER_TAX');
                   body45.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Wages_after_tax__c!=null) ? string.valueof(opp.Wages_after_tax__c) : '0'));
                   
               }
               
               if(opp.Allowances_overtime_fringe_benefits__c!=null){
                   dom.XmlNode body46=body44.addChildElement('Item', null, null);	
                   body46.addChildElement('Type', null, null).addTextNode('ALLOWANCES');
                   body46.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Allowances_overtime_fringe_benefits__c!=null) ? string.valueof(opp.Allowances_overtime_fringe_benefits__c) : '0'));
                   
               }
               
               if(opp.Taxable_centrelink_benefits__c!=null){
                   dom.XmlNode body47=body44.addChildElement('Item', null, null);	
                   body47.addChildElement('Type', null, null).addTextNode('TAXABLE_CENTRELINK_BENEFITS');
                   body47.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Taxable_centrelink_benefits__c!=null) ? string.valueof(opp.Taxable_centrelink_benefits__c) : '0'));
                   
               }
               
               if(opp.Non_taxable_centrelink_benefits__c!=null){
                   dom.XmlNode body48=body44.addChildElement('Item', null, null);	
                   body48.addChildElement('Type', null, null).addTextNode('NON_TAXABLE_CENTRELINK_BENEFITS');
                   body48.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Non_taxable_centrelink_benefits__c!=null) ? string.valueof(opp.Non_taxable_centrelink_benefits__c) : '0'));
                   
               }
               
               if(opp.Regular_income_from_tenants_for_rent__c!=null){
                   dom.XmlNode body49=body44.addChildElement('Item', null, null);	
                   body49.addChildElement('Type', null, null).addTextNode('REGULAR_INCOME_FROM_INVESTMENTS');
                   body49.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Regular_income_from_tenants_for_rent__c!=null) ? string.valueof(opp.Regular_income_from_tenants_for_rent__c) : '0'));
                   
               }
               
               if(opp.After_tax_income_from_second_jobs__c!=null){
                   dom.XmlNode body50=body44.addChildElement('Item', null, null);	
                   body50.addChildElement('Type', null, null).addTextNode('AFTER_TAX_INCOME_ADDITIONAL_JOBS');
                   body50.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.After_tax_income_from_second_jobs__c!=null) ? string.valueof(opp.After_tax_income_from_second_jobs__c) : '0'));
                   
               }
               
               if(opp.Child_spouse_maintenance_received__c!=null){
                   dom.XmlNode body51=body44.addChildElement('Item', null, null);	
                   body51.addChildElement('Type', null, null).addTextNode('MAINTENANCE');
                   body51.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Child_spouse_maintenance_received__c!=null) ? string.valueof(opp.Child_spouse_maintenance_received__c) : '0'));
                   
               }
               
               if(opp.Other_Income__c!=null){
                   dom.XmlNode body52=body44.addChildElement('Item', null, null);	
                   body52.addChildElement('Type', null, null).addTextNode('OTHER');
                   body52.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Other_Income__c!=null) ? string.valueof(opp.Other_Income__c) : '0'));
                   
               }
               
           }
        body43.addChildElement('TotalAmount', null, null).addTextNode
            (string.valueof(opp.Total_Income__c!=null ? opp.Total_Income__c : 0));
        
        if(opp.Total_Support__c!=null){
            body43.addChildElement('ReceivingSupportIndicator', null, null).addTextNode('true');
        }else{
            body43.addChildElement('ReceivingSupportIndicator', null, null).addTextNode('true');  
        }
        body43.addChildElement('ReceivingSupportText', null, null).addTextNode(string.valueof(opp.Please_specify__c==null?'Nil':opp.Please_specify__c));
        if(opp.Total_Support__c!=null){
            body43.addChildElement('ReceivingSupportTotalAmount', null, null).addTextNode(string.valueof((opp.Total_Support__c!=null) ? string.valueof(opp.Total_Support__c) : ''));
            
        }
        
        dom.XmlNode body53=body2.addChildElement('ExpenseSection', null, null);
        if(opp.Total_household_expenses__c){
            dom.XmlNode body88=body53.addChildElement('DistributionType', null, null).addTextNode('TOTAL');
        }
        else if(opp.Debtor_s_eql_share_of_household_expenses__c){
            dom.XmlNode body88=body53.addChildElement('DistributionType', null, null).addTextNode('EQUAL_SHARE');
        }
        else if(opp.Debtor_s_contribution_towards__c){
            dom.XmlNode body88=body53.addChildElement('DistributionType', null, null).addTextNode('CONTRIBUTION');
        }
        
        
        
        
        if(opp.Rent_for_Accomodation__c!=null || opp.Board__c!=null || opp.Mortgage_payment__c!=null || opp.Rates__c!=null  || opp.Home_maintenance__c!=null ||
           opp.Food_including_groceries_and_take_away__c!=null || opp.Phone_mobile_internet__c!=null || opp.Entertainment_pay_TV__c!=null
           || opp.Electricity_gas_water__c!=null || opp.Health_insurance__c!=null || opp.Medical_chemist__c!=null
           || opp.Car_payments_to_secured_creditor__c!=null || opp.Car_fuel_registration_insurance_maint__c!=null || opp.Transport__c!=null
           || opp.Other_insurance__c!=null || opp.School_fees_and_expenses__c!=null || opp.Child_care__c!=null || opp.Child_support_and_maintenance__c!=null
           || opp.Other_expenses_for_children_eg_sport_mu__c!=null || opp.Clothes_shoes_hairdressing__c!=null || opp.Incidentals_e_g_cigarettes_books_mag__c!=null
           || opp.Payments_to_creditors_not_receiving_a__c!=null || opp.Other_payments_to_secured_creditors__c!=null || opp.Rental_payments_for_household_goods__c!=null
           || opp.Other_household_expenses__c!=null){
               body54=body53.addChildElement('Items', null, null);
               if(opp.Rent_for_Accomodation__c!=null){
                   dom.XmlNode body55=body54.addChildElement('Item', null, null);
                   body55.addChildElement('Type', null, null).addTextNode('RENT');
                   body55.addChildElement('Amount', null, null).addTextNode(string.valueof(opp.Rent_for_Accomodation__c!=null ? opp.Rent_for_Accomodation__c : 0));
                   
               }
               
               if(opp.Board__c!=null){
                   dom.XmlNode body56=body54.addChildElement('Item', null, null);
                   body56.addChildElement('Type', null, null).addTextNode('BOARD');
                   body56.addChildElement('Amount', null, null).addTextNode(string.valueof(opp.Board__c!=null ? opp.Board__c : 0));
                   
               }
               
               if(opp.Mortgage_payment__c!=null){
                   dom.XmlNode body57=body54.addChildElement('Item', null, null);
                   body57.addChildElement('Type', null, null).addTextNode('MORTGAGE');
                   body57.addChildElement('Amount', null, null).addTextNode(string.valueof(opp.Mortgage_payment__c!=null ?opp.Mortgage_payment__c : 0));
                   
               }
               
               if(opp.Rates__c!=null){
                   dom.XmlNode body58=body54.addChildElement('Item', null, null);
                   body58.addChildElement('Type', null, null).addTextNode('RATES');
                   body58.addChildElement('Amount', null, null).addTextNode(string.valueof(opp.Rates__c!=null? opp.Rates__c : 0));
                   
               }
               
               if(opp.Home_maintenance__c!=null){
                   dom.XmlNode body59=body54.addChildElement('Item', null, null);
                   body59.addChildElement('Type', null, null).addTextNode('HOME_MAINTENANCE');
                   body59.addChildElement('Amount', null, null).addTextNode(string.valueof(opp.Home_maintenance__c!=null ? opp.Home_maintenance__c : 0));
                   
               }
               
               if(opp.Food_including_groceries_and_take_away__c!=null){
                   dom.XmlNode body60=body54.addChildElement('Item', null, null);
                   body60.addChildElement('Type', null, null).addTextNode('FOOD');
                   body60.addChildElement('Amount', null, null).addTextNode(string.valueof(opp.Food_including_groceries_and_take_away__c!=null ?opp.Food_including_groceries_and_take_away__c : 0));
                   
               }
               if(opp.Phone_mobile_internet__c!=null){
                   dom.XmlNode body61=body54.addChildElement('Item', null, null);
                   body61.addChildElement('Type', null, null).addTextNode('PHONE');
                   body61.addChildElement('Amount', null, null).addTextNode(string.valueof(opp.Phone_mobile_internet__c!=null ? opp.Phone_mobile_internet__c : 0));
                   
               }
               
               if(opp.Entertainment_pay_TV__c!=null){
                   dom.XmlNode body62=body54.addChildElement('Item', null, null);
                   body62.addChildElement('Type', null, null).addTextNode('ENTERTAINMENT');
                   body62.addChildElement('Amount', null, null).addTextNode(string.valueof(opp.Entertainment_pay_TV__c!=null ? opp.Entertainment_pay_TV__c : 0));
                   
               }
               
               if(opp.Electricity_gas_water__c!=null){
                   dom.XmlNode body63=body54.addChildElement('Item', null, null);
                   body63.addChildElement('Type', null, null).addTextNode('UTILITIES');
                   body63.addChildElement('Amount', null, null).addTextNode(string.valueof(opp.Electricity_gas_water__c!=null ? opp.Electricity_gas_water__c : 0));
                   
               }
               
               if(opp.Health_insurance__c!=null){
                   dom.XmlNode body64=body54.addChildElement('Item', null, null);
                   body64.addChildElement('Type', null, null).addTextNode('HEALTH_INSURANCE');
                   body64.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Health_insurance__c!=null) ? string.valueof(opp.Health_insurance__c) : '0'));
                   
               }
               
               if(opp.Medical_chemist__c!=null){
                   dom.XmlNode body65=body54.addChildElement('Item', null, null);
                   body65.addChildElement('Type', null, null).addTextNode('MEDICAL');
                   body65.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Medical_chemist__c!=null) ? string.valueof(opp.Medical_chemist__c) : '0'));
                   
               }
               
               if(opp.Car_payments_to_secured_creditor__c!=null){
                   dom.XmlNode body66=body54.addChildElement('Item', null, null);
                   body66.addChildElement('Type', null, null).addTextNode('CAR_PAYMENTS');
                   body66.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Car_payments_to_secured_creditor__c!=null) ? string.valueof(opp.Car_payments_to_secured_creditor__c) : '0'));
                   
               }
               
               if(opp.Car_fuel_registration_insurance_maint__c!=null){
                   dom.XmlNode body67=body54.addChildElement('Item', null, null);
                   body67.addChildElement('Type', null, null).addTextNode('CAR_EXPENSES');
                   body67.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Car_fuel_registration_insurance_maint__c!=null) ? string.valueof(opp.Car_fuel_registration_insurance_maint__c) : '0'));
                   
               }
               
               if(opp.Transport__c!=null){
                   dom.XmlNode body68=body54.addChildElement('Item', null, null);
                   body68.addChildElement('Type', null, null).addTextNode('TRANSPORT');
                   body68.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Transport__c!=null) ? string.valueof(opp.Transport__c) : '0'));
                   
               } 
               
               if(opp.Other_insurance__c!=null){
                   dom.XmlNode body69=body54.addChildElement('Item', null, null);
                   body69.addChildElement('Type', null, null).addTextNode('OTHER_INSURANCE');
                   body69.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Other_insurance__c!=null) ? string.valueof(opp.Other_insurance__c) : '0'));
                   
               }
               
               if(opp.School_fees_and_expenses__c!=null){
                   dom.XmlNode body70=body54.addChildElement('Item', null, null);
                   body70.addChildElement('Type', null, null).addTextNode('SCHOOL_COSTS');
                   body70.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.School_fees_and_expenses__c!=null) ? string.valueof(opp.School_fees_and_expenses__c) : '0'));
                   
               }
               
               if(opp.Child_care__c!=null){
                   dom.XmlNode body71=body54.addChildElement('Item', null, null);
                   body71.addChildElement('Type', null, null).addTextNode('CHILD_CARE');
                   body71.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Child_care__c!=null) ? string.valueof(opp.Child_care__c) : '0'));
                   
               }
               
               if(opp.Child_support_and_maintenance__c!=null){
                   dom.XmlNode body72=body54.addChildElement('Item', null, null);
                   body72.addChildElement('Type', null, null).addTextNode('CHILD_SUPPORT');
                   body72.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Child_support_and_maintenance__c!=null) ? string.valueof(opp.Child_support_and_maintenance__c) : '0'));
                   
               }
               
               if(opp.Other_expenses_for_children_eg_sport_mu__c!=null){
                   dom.XmlNode body73=body54.addChildElement('Item', null, null);
                   body73.addChildElement('Type', null, null).addTextNode('CHILD_EXPENSES');
                   body73.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Other_expenses_for_children_eg_sport_mu__c!=null) ? string.valueof(opp.Other_expenses_for_children_eg_sport_mu__c) : '0'));
                   
               }
               
               if(opp.Clothes_shoes_hairdressing__c!=null){
                   dom.XmlNode body74=body54.addChildElement('Item', null, null);
                   body74.addChildElement('Type', null, null).addTextNode('CLOTHES');
                   body74.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Clothes_shoes_hairdressing__c!=null) ? string.valueof(opp.Clothes_shoes_hairdressing__c) : '0'));
                   
               }
               
               if(opp.Incidentals_e_g_cigarettes_books_mag__c!=null){
                   dom.XmlNode body75=body54.addChildElement('Item', null, null);
                   body75.addChildElement('Type', null, null).addTextNode('INCIDENTALS');
                   body75.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Incidentals_e_g_cigarettes_books_mag__c!=null) ? string.valueof(opp.Incidentals_e_g_cigarettes_books_mag__c) : '0'));
                   
               }
               
               if(opp.Payments_to_creditors_not_receiving_a__c!=null){
                   dom.XmlNode body76=body54.addChildElement('Item', null, null);
                   body76.addChildElement('Type', null, null).addTextNode('PAYMENT_CREDITORS_NOT_DEBT_AGREEMENT');
                   body76.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Payments_to_creditors_not_receiving_a__c!=null) ? string.valueof(opp.Payments_to_creditors_not_receiving_a__c) : '0'));
                   
               }
               
               if(opp.Other_payments_to_secured_creditors__c!=null){
                   dom.XmlNode body77=body54.addChildElement('Item', null, null);
                   body77.addChildElement('Type', null, null).addTextNode('PAYMENT_SECURED_CREDITORS');
                   body77.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Other_payments_to_secured_creditors__c!=null) ? string.valueof(opp.Other_payments_to_secured_creditors__c) : '0'));
                   
               }
               
               if(opp.Rental_payments_for_household_goods__c!=null){
                   dom.XmlNode body78=body54.addChildElement('Item', null, null);
                   body78.addChildElement('Type', null, null).addTextNode('HOUSEHOLD_GOODS_RENTAL');
                   body78.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Rental_payments_for_household_goods__c!=null) ? string.valueof(opp.Rental_payments_for_household_goods__c) : '0'));
               }
               if(opp.Other_household_expenses__c!=null){
                   dom.XmlNode body79=body54.addChildElement('Item', null, null);
                   body79.addChildElement('Type', null, null).addTextNode('HOUSEHOLD_EXPENSES');
                   body79.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Other_household_expenses__c!=null) ? string.valueof(opp.Other_household_expenses__c) : '0'));
                   
               }
               if(opp.Debtors_expense_for_supporting_partner__c!=null){
                   dom.XmlNode body80=body54.addChildElement('Item', null, null);
                   body80.addChildElement('Type', null, null).addTextNode('SUPPORT_FOR_PARTNERS_DEBT_AGREEMENT');
                   body80.addChildElement('Amount', null, null).addTextNode(string.valueof((opp.Debtors_expense_for_supporting_partner__c!=null) ? string.valueof(opp.Debtors_expense_for_supporting_partner__c) : '0'));
               }
           }
        body53.addChildElement('TotalAmount', null, null).addTextNode(string.valueof((opp.Total_household_expenses_sum__c!=null) ? string.valueof(opp.Total_household_expenses_sum__c) : ''));
        
        body53.addChildElement('TotalUncommittedIncomeAmount', null, null).addTextNode(string.valueof((opp.Total_uncommitted_income__c!=null) ? string.valueof(opp.Total_uncommitted_income__c) : ''));
        
        body92=body2.addChildElement('DeclarationSection', null, null);
        
        body92.addChildElement('DebtAgreementProposalDeclarationIndicator', null, null).addTextNode('false');
        body92.addChildElement('ExplanatoryStatementDeclarationIndicator', null, null).addTextNode('false');
        body92.addChildElement('DebtAgreementProposalDeclarationDate', null, null).addTextNode(String.valueof(Date.newInstance(2000, 01, 01)));
        body92.addChildElement('DebtAgreementProposalCertificateSignedDate', null, null).addTextNode(String.valueof(Date.newInstance(2000, 01, 01)));
        body92.addChildElement('DebtAgreementProposalCertificate4CSignedDate', null, null).addTextNode(String.valueof(Date.newInstance(2000, 01, 01)));
        
        
        
        string name =opp.Account.FirstName+' '+opp.Account.LastName;
        body2.addChildElement('DebtorSupportingStatement', null, null).addTextNode(opp.Debtor_Supporting_Statement__c!=null?opp.Debtor_Supporting_Statement__c:'');
        
        
        dom.XmlNode body107 = body2.addChildElement('AdministratorRelatedEntitiesSection', null, null);
        dom.XmlNode body108 = body107.addChildElement('BrokerOrReferrerSection', 'http://afsa.gov.au/DebtAgreementService.1', '');
        body108.addChildElement('BrokerOrReferrerUsedIndicator',null, null).addTextNode('true');
        dom.XmlNode body109 = body108.addChildElement('BrokerOrReferrer', null, null);
        body109.addChildElement('BrokerReferrerName', null, null).addTextNode('DEBT BUSTERS (ABN 87 122 628 086)');
        body109.addChildElement('BrokerReferrerRelationshipType', null, null).addTextNode('BROKER');
        body109.addChildElement('BrokerReferrerPaymentAmount', null, null).addTextNode('0');
        body107.addChildElement('AdministratorIsCreditorIndicator', 'http://afsa.gov.au/DebtAgreementService.1', '').addTextNode('false');
        dom.XmlNode body131 = body107.addChildElement('RelatedCreditorsSection', 'http://afsa.gov.au/DebtAgreementService.1', '');
        if(Is_Admin_Related_Creditor_Debts.size()>0){
            body131.addChildElement('AdminRelatedCreditorIndicator', null,null).addTextNode('true');  
            dom.XmlNode body132=body131.addChildElement('AdminRelatedCreditors', null,null);
            for(Debt__c adminRelatedDebts : Is_Admin_Related_Creditor_Debts){
                dom.XmlNode body133=body132.addChildElement('Item', null,null);
                body133.addChildElement('AdminRelatedCreditorId', null,null).addTextNode(string.valueof(adminRelatedDebts.Send_DAP_to__r.DAPID__c));
                body133.addChildElement('AdminRelatedCreditorRelationshipType', null,null).addTextNode(adminRelatedDebts.Send_DAP_to__r.Admin_Related_Creditor_Relationship_Type__c.SubStringBefore(':'));
            }
            
            
        }else{
            body131.addChildElement('AdminRelatedCreditorIndicator', null,null).addTextNode('false');  
        }
        
        
        
        
        dom.XmlNode body105 = body2.addChildElement('AssistedSection', null, null);
        body105.addChildElement('Indicator', null, null).addTextNode('true');
        body105.addChildElement('Name', null, null).addTextNode(name!=null?name:'');
        dom.XmlNode body106 = body105.addChildElement('Address', null, null);
        body106.addChildElement('Line1', 'http://afsa.gov.au.1', '').addTextNode('Level 26, 44 Market Street');
        body106.addChildElement('Suburb', 'http://afsa.gov.au.1', '').addTextNode('Sydney');
        body106.addChildElement('State', 'http://afsa.gov.au.1', '').addTextNode('NSW');
        body106.addChildElement('PostCode', 'http://afsa.gov.au.1', '').addTextNode('2000');
        body106.addChildElement('Country', 'http://afsa.gov.au.1', '').addTextNode('AU');
        body105.addChildElement('Reason', null, null).addTextNode('Explanation of consequences, benefits and costs associated with a Debt Agreement and the alternatives applicable to their current financial situation.'); 
        
        
        
        
        
        xmlstring = doc.toXmlString();
        return xmlstring;
    }
    public static String convertToDateTime(date d){
        Integer dat = d.day();
        Integer mo = d.month();
        Integer yr = d.year();
        DateTime DT = DateTime.newInstance(yr, mo, dat, 11, 59, 59);
        String GMTdatetime=DT.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        return GMTdatetime;
    }
    public static String setPayPeriodType(string payPeriod){
        if(payPeriod=='Weekly'){
            return 'WEEK';
            
        }
        else if(payPeriod=='Monthly'){
            return 'MONTH';
            
        }
        else if(payPeriod=='Fortnightly'){
            return 'FORTNIGHT';
        }
        else{
            return 'FORTNIGHT';
        }
        
    }
}
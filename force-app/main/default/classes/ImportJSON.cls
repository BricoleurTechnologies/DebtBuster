public class ImportJSON {
    public static void createSFRecordFromJson(String id){
       List<ContentVersion> oldConDataList=[select id,Title,VersionData from ContentVersion where id=:id limit 1];
       // system.debug('@@oldConDataList'+oldConDataList);
      Blob fileBody = oldConDataList[0].VersionData;
      String myBlobAsBase64 = EncodingUtil.base64Encode(fileBody); 
        String myblob = fileBody.toString();
        String str = JSON.serialize(myblob);
        System.debug('My str: ' + myblob);
        if(!myblob.startsWith('[')){
            myblob='['+myblob+']';
        }
        // WrapperImport wrapperObj = new WrapperImport();
        List<WrapperImport> wrapperObjList=(List<WrapperImport>)JSON.deserialize(myblob,List<WrapperImport>.class);
        System.debug('My js wrapperObj: ' + wrapperObjList);
        list<Account> accList= new List<Account>();
        list<Account> newAndUpdatAccList= new List<Account>();
        list<Account> updateAccList= new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Debt__c> updatedDebtList = new List<Debt__c>();
        list<Payment_Bric__c> paymentListNew= new List<Payment_Bric__c>();
        list<Payment_Bric__c> paymentListOld= new List<Payment_Bric__c>();
        map<id,Payment_Bric__c> mapOFUpdatedPayments=new map<id,Payment_Bric__c>();
       	map<id,Repayment__c> mapOFUpdatedRePayments=new map<id,Repayment__c>();
        list<Repayment__c> rePaymentObjListNew=new list<Repayment__c>();
        list<Repayment__c> rePaymentObjListOld=new list<Repayment__c>();
        Set<String> accRefNumber= new Set<String>();
        Set<String> dividentRepaymentRefNumber = new Set<String>();
        Map<Integer, WrapperImport> mapOfRefNumAndWrapper= new Map<Integer, WrapperImport>();
        Map<Integer, WrapperImport> mapOfOppNameAndWrapper= new Map<Integer, WrapperImport>();
        Map<String, String> extAccountMap= new Map<String, String>(); 
        Map<String, Opportunity> extOppMap= new Map<String, Opportunity>();
        Map<String, List<Debt__c>> extDebtMap = new Map<String, List<Debt__c>>();
        Map<String, String> extDebtRefIDMap = new Map<String, String>();
        Map<String, String> extDividentPaymentsMap = new Map<String, String>();
        Map<String, Repayment__c> extRepaymentMap = new Map<String, Repayment__c>(); 
        Map<String, String> businessAccountMap = new Map<String,String>();
        Map<Integer, date> mapLatestDateRepaymentRef = new Map<Integer,date>();
        Map<Integer, Set<Date>> mapOFRefANDDateSET = new Map<Integer, Set<Date>>();
        
        
        Map<Date, WrapperImport.DebtAgreements> mapOFDateANDDebtAgreement = new Map<Date,WrapperImport.DebtAgreements>();
        Set<date> dateSet=new Set<Date>();
        Set<date> latestDateSet=new Set<Date>();
        // WrapperImport.cls_0[] firstMethodList1= new WrapperImport.cls_0[]{};
        set<String> refString=new Set<String>();
        set<String> creditorNameset=new Set<String>();
        set<String> repaymentRefStringset=new Set<String>();
        set <string> accName= new set<string>();
        List<Debt__c> debtList = new List<Debt__c>();
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        date MaxDate;
        
        for(WrapperImport firstMethod1 :wrapperObjList){
            
            string fullName=firstMethod1.firstname+' '+firstMethod1.MiddleNames+' '+firstMethod1.lastname;
            accName.add(fullName);
            mapOfRefNumAndWrapper.put(firstMethod1.Reference,firstMethod1);
            
            if(firstMethod1.AdminPayments!=null){
              for(WrapperImport.AdminPayments adminPaymentRef:firstMethod1.AdminPayments){
                dividentRepaymentRefNumber.add(adminPaymentRef.Reference);
            }  
            }
            if(firstMethod1.AfsaPayments!=null){
                for(WrapperImport.AfsaPayments afsaPaymentRef:firstMethod1.AfsaPayments){
                dividentRepaymentRefNumber.add(afsaPaymentRef.Reference);
            } 
            }
           
            if(firstMethod1.Debts!=null){
                 for(WrapperImport.Debts debtCreditor:firstMethod1.Debts){
                creditorNameset.add(debtCreditor.CreditorName);  
                if(debtCreditor.DividendPayments!=null){
                    for(WrapperImport.DividendPayments divRepayment:debtCreditor.DividendPayments){
                    dividentRepaymentRefNumber.add(divRepayment.Reference);
                    
                }
                }
                
                
            } 
            }
            if(firstMethod1.DebtAgreements!=null){
             for(WrapperImport.DebtAgreements debtSetObj:firstMethod1.DebtAgreements){
                // dateSet.add(date.valueOf(debtSetObj.DateLodged))
                 if(debtSetObj.DateLodged!=null){
                     if(mapOFRefANDDateSET.containsKey(firstMethod1.Reference)){
                    mapOFRefANDDateSET.get(firstMethod1.Reference).add(date.valueOf(debtSetObj.DateLodged));
                }
                else{
                    mapOFRefANDDateSET.put(firstMethod1.Reference, new Set<date>{date.valueOf(debtSetObj.DateLodged)});
                }  
                 }
              
                
                
                system.debug('@mapOFRefANDDateSET'+mapOFRefANDDateSET);
                list<date> AllDates = new list<date>(); 
                if(mapOFRefANDDateSET.containsKey(firstMethod1.Reference)){
                    AllDates.AddAll(mapOFRefANDDateSET.get(firstMethod1.Reference)); 
                    AllDates.sort(); 
                    MaxDate = allDates[Alldates.size()-1];
                    mapLatestDateRepaymentRef.put(firstMethod1.Reference,MaxDate);
                    if(MaxDate==Date.valueOf(debtSetObj.DateLodged)){
                        mapOFDateANDDebtAgreement.put(MaxDate,debtSetObj);
                    }
                    
                }
                
                if(debtSetObj.Repayments!=null){
                  for(WrapperImport.Repayments repaymentSetObj:debtSetObj.Repayments){
                    repaymentRefStringset.add(repaymentSetObj.Reference);
                }  
                }
                
                
            }   
            }
            
            accRefNumber.add(String.valueof(firstMethod1.Reference));
            mapOfOppNameAndWrapper.put(firstMethod1.Reference,firstMethod1);
            for(WrapperImport.Debts debtObj:firstMethod1.debts){
                refString.add(debtObj.Reference);
            }
        }
        for(Account businessAccount:[select id, name from account where name IN:creditorNameset]){
            businessAccountMap.put(businessAccount.name,businessAccount.Id);
        }
        for(Account extAcc:[select ID,Reference__c,name,(select id from opportunities LIMIT 1) from Account where recordTypeId=:personAccountRecordTypeId AND Reference__c In:accRefNumber]){
            extAccountMap.put(extAcc.Reference__c,extAcc.ID);
            if(extAcc.opportunities.size()>0){
                extOppMap.put(extAcc.Reference__c,extAcc.opportunities);
                for(Debt__c extDebt:[select id,Opportunity__c,Account_Reference_Number__c from Debt__c where Account_Reference_Number__c IN:refString AND Opportunity__r.AccountReference__c IN:accRefNumber  ]){
                    extDebtRefIDMap.put(extDebt.Account_Reference_Number__c,extDebt.id);
                    if(extDebtMap.containsKey(extDebt.Account_Reference_Number__c)){
                        extDebtMap.get(extDebt.Account_Reference_Number__c).add(extDebt);
                    }
                    else{
                        extDebtMap.put(extDebt.Account_Reference_Number__c, new List<Debt__c>{extDebt});
                    }
                }
            }
        }
        for(Payment_Bric__c existingDivRepayment:[select id,Reference_Bric__c,Opportunity_Bric__c from Payment_Bric__c where Reference_Bric__c IN:dividentRepaymentRefNumber AND Opportunity_Bric__r.AccountReference__c IN:accRefNumber ]){
            extDividentPaymentsMap.put(existingDivRepayment.Reference_Bric__c, existingDivRepayment.id);
        }
        for(Repayment__c extRepaymentobj:[select id,Reference_Bric__c,Opportunity_Bric__c from Repayment__c where Reference_Bric__c IN:repaymentRefStringset AND Opportunity_Bric__r.AccountReference__c IN:accRefNumber]){
            extRepaymentMap.put(extRepaymentobj.Reference_Bric__c,extRepaymentobj);
        }
        for(WrapperImport firstMethod :wrapperObjList){
            
            Account acc= new Account();
            acc.Reference__c=String.Valueof(firstMethod.Reference)!=null?String.Valueof(firstMethod.Reference): '';
            acc.Salutation=firstMethod.Title!=null?firstMethod.Title:'';
            acc.FirstName=firstMethod.FirstName!=null?firstMethod.FirstName:'';
            acc.MiddleName=firstMethod.MiddleNames!=null?firstMethod.MiddleNames:''; 
            acc.LastName=firstMethod.LastName!=null?firstMethod.LastName:'';
            if(firstMethod.DateOfBirth!=null){
              acc.Date_of_Birth__c=Date.valueof(firstMethod.DateOfBirth);	  
            }
            acc.PersonMailingCity=firstMethod.City!=null?firstMethod.City:'';                  
            acc.PersonMailingState=firstMethod.State!=null?firstMethod.State:'';
            acc.PersonMailingCountryCode=firstMethod.CountryCode!=null?firstMethod.CountryCode:'';
            acc.PersonMailingPostalCode=firstMethod.Postcode!=null?firstMethod.Postcode:'';
            acc.PersonMailingStreet=firstMethod.PostalAddressLine1!=null?firstMethod.PostalAddressLine1:'';
            acc.Mobile_Phone__c=firstMethod.MobilePhone!=null?firstMethod.MobilePhone:'';
            acc.Home_Phone__c=firstMethod.HomePhone!=null?firstMethod.HomePhone:'';
            acc.Work_Phone__c=firstMethod.WorkPhone!=null?firstMethod.WorkPhone:'';
            acc.PersonEmail=firstMethod.Email!=null?firstMethod.Email:'';
            acc.RecordTypeId=personAccountRecordTypeId;
            if(extAccountMap.containsKey(String.valueof(firstMethod.Reference))){
                acc.id=extAccountMap.get(String.valueof(firstMethod.Reference));  
                updateAccList.add(acc);
            }else{
                accList.add(acc); 
            }
                    
        }
        
        if(accList.size()>0){
            insert accList;
            System.debug('acclist After insert'+accList);
        }
        if(updateAccList.size()>0){
            update updateAccList;
            System.debug('acclist After Update'+updateAccList);
        }
        newAndUpdatAccList.addall(accList);  
        newAndUpdatAccList.addall(updateAccList);  
        
        for(Account acc:newAndUpdatAccList){
            WrapperImport.DebtAgreements latestDebtAgreementobj;
            system.debug('Account reference'+acc.Reference__c);
            Opportunity opp = new Opportunity();
            if(mapOfRefNumAndWrapper.containsKey(Integer.valueof(acc.Reference__c))){
                system.debug('opp block');
                opp.AccountId=acc.id;
                opp.AccountReference__c=acc.Reference__c;
                opp.StageName='Open';
                opp.Name='Opp-'+acc.name;
                opp.CloseDate=date.Today();
                // opp.AFSA_Number__c=mapOfRefNumAndWrapper.get(acc.Reference__c).AfsaNumber;
                if(mapOfRefNumAndWrapper.get(Integer.valueof(acc.Reference__c)).DateAcceptedNpii!=null){
           //  opp.Date_Accepted_For_Processing__c=mapOfRefNumAndWrapper.get(Integer.valueof(acc.Reference__c)).DateAcceptedNpii!=null?mapOfRefNumAndWrapper.get(Integer.valueof(acc.Reference__c)).DateAcceptedNpii:date.valueof(01-01-1001);
                }
                opp.LeadSource=mapOfRefNumAndWrapper.get(Integer.valueof(acc.Reference__c)).LeadSource!=null?mapOfRefNumAndWrapper.get(Integer.valueof(acc.Reference__c)).LeadSource:'';
                // DebtAgreement
                //  start
                if(mapLatestDateRepaymentRef.get(Integer.valueof(acc.Reference__c))!=null){
                  Date maxDateTemp=mapLatestDateRepaymentRef.get(Integer.valueof(acc.Reference__c));
                latestDebtAgreementobj= mapOFDateANDDebtAgreement.get(maxDateTemp);  
                
               
                if(latestDebtAgreementobj.DateLodged!=null){
                 opp.Submitted_to_AFSA_Date__c=date.valueof(latestDebtAgreementobj.DateLodged);    
                }
                if(latestDebtAgreementobj.DeadlineDate!=null){
                   opp.Final_Date_For_Voting__c=date.valueof(latestDebtAgreementobj.DeadlineDate); 
                }
                if(latestDebtAgreementobj.DeadlineDate!=null
                  ){
                  opp.Final_Date_For_Voting__c=date.valueof(latestDebtAgreementobj.DeadlineDate);  
                }
                
                opp.DA_Amount__c=latestDebtAgreementobj.Offer!=null?latestDebtAgreementobj.Offer:integer.valueof(0);
                opp.Fees_for_administrator_to_administer_deb__c=latestDebtAgreementobj.AdministratorRate!=null?latestDebtAgreementobj.AdministratorRate:double.valueof(0);
                if(latestDebtAgreementobj.EqualisationDate!=null){
                  opp.Equalisation_Date_Bric__c=date.valueof(latestDebtAgreementobj.EqualisationDate);  
                }
                
                opp.Expense_Banking_Fees_Amount_Per__c=latestDebtAgreementobj.ProposalExpensesBankingFeesAmount!=null?latestDebtAgreementobj.ProposalExpensesBankingFeesAmount:double.valueof(0);
                opp.Expense_Valuating_Amount_Per__c=latestDebtAgreementobj.ProposalExpensesValuatingAssetsAmount!=null?latestDebtAgreementobj.ProposalExpensesValuatingAssetsAmount:double.valueof(0);
                opp.Expense_Eligibility_Amount_Per__c=latestDebtAgreementobj.ProposalExpensesEligibilityDebtorAmount!=null?latestDebtAgreementobj.ProposalExpensesEligibilityDebtorAmount:double.valueof(0);
                opp.Expense_Other_Amount_Per__c=latestDebtAgreementobj.ProposalExpensesOtherAmount!=null?latestDebtAgreementobj.ProposalExpensesOtherAmount:double.valueof(0);          
                //  }
                      }
                for(WrapperImport.DebtAgreements debtAgreementforRepaymentSchedule: mapOfOppNameAndWrapper.get(Integer.valueof(acc.Reference__c)).DebtAgreements){
                    for(WrapperImport.RepaymentSchedule repaymentScheduleInner: debtAgreementforRepaymentSchedule.RepaymentSchedule){ 
                        if( opp.Number_of_payments1__c==null && opp.Weekly_fortnightly_monthly1__c==null && opp.Amount_of_each_payment1__c==null) {
                            opp.Number_of_payments1__c=repaymentScheduleInner.Count;
                            opp.Weekly_fortnightly_monthly1__c=repaymentScheduleInner.Frequency;
                            opp.Amount_of_each_payment1__c=repaymentScheduleInner.Amount;
                        }
                        if( opp.Number_of_payments1__c!=null && opp.Weekly_fortnightly_monthly1__c!=null && opp.Amount_of_each_payment1__c!=null) {
                            opp.Number_of_payments2__c=repaymentScheduleInner.Count;
                            opp.Weekly_fortnightly_monthly2__c=repaymentScheduleInner.Frequency;
                            opp.Amount_of_each_payment2__c=repaymentScheduleInner.Amount;
                        }
                        if( opp.Number_of_payments1__c!=null && opp.Number_of_payments2__c!=null && opp.Weekly_fortnightly_monthly1__c!=null && opp.Weekly_fortnightly_monthly2__c!=null && opp.Amount_of_each_payment1__c!=null && opp.Amount_of_each_payment2__c!=null) {
                            opp.Number_of_payments3__c=repaymentScheduleInner.Count;
                            opp.Weekly_fortnightly_monthly3__c=repaymentScheduleInner.Frequency;
                            opp.Amount_of_each_payment3__c=repaymentScheduleInner.Amount;
                        }
                        if( opp.Number_of_payments1__c!=null && opp.Number_of_payments2__c!=null && opp.Number_of_payments3__c!=null && opp.Weekly_fortnightly_monthly1__c!=null && opp.Weekly_fortnightly_monthly2__c!=null && opp.Weekly_fortnightly_monthly3__c!=null &&  opp.Amount_of_each_payment1__c!=null && opp.Amount_of_each_payment2__c!=null && opp.Amount_of_each_payment3__c!=null) {
                            opp.Number_of_payments4__c=repaymentScheduleInner.Count;
                            opp.Weekly_fortnightly_monthly4__c=repaymentScheduleInner.Frequency;
                            opp.Amount_of_each_payment4__c=repaymentScheduleInner.Amount;
                        }
                        if( opp.Number_of_payments1__c!=null && opp.Number_of_payments2__c!=null && opp.Number_of_payments3__c!=null && opp.Number_of_payments4__c!=null &&  opp.Weekly_fortnightly_monthly1__c!=null && opp.Weekly_fortnightly_monthly2__c!=null && opp.Weekly_fortnightly_monthly3__c!=null &&  opp.Weekly_fortnightly_monthly4__c!=null &&   opp.Amount_of_each_payment1__c!=null && opp.Amount_of_each_payment2__c!=null && opp.Amount_of_each_payment3__c!=null && opp.Amount_of_each_payment4__c!=null) {
                            opp.Number_of_payments5__c=repaymentScheduleInner.Count;
                            opp.Weekly_fortnightly_monthly5__c=repaymentScheduleInner.Frequency;
                            opp.Amount_of_each_payment5__c=repaymentScheduleInner.Amount;
                        }
                    } 
                }
            }

            if(extOppMap.containsKey(acc.Reference__c)){
                opp.id=extOppMap.get(acc.Reference__c).id;
            }
            oppList.add(opp);
            
        }
        if(oppList.size()>0){
            upsert oppList;
            
         
        }
        
                    Map<String,String> mapOFOppIdANDRefrence=new Map<String,String>();

        for(opportunity opp:oppList){
               if(!extOppMap.containskey(opp.AccountReference__c)){
            extOppMap.put(opp.AccountReference__c,opp);
        }
            WrapperImport.DebtAgreements latestDebtAgreementobj;
            if(mapLatestDateRepaymentRef.ContainsKey(Integer.valueof(opp.AccountReference__c))){
              Date maxDateTemp=mapLatestDateRepaymentRef.get(Integer.valueof(opp.AccountReference__c));
                if(mapOFDateANDDebtAgreement.containskey(maxDateTemp)){
                 latestDebtAgreementobj= mapOFDateANDDebtAgreement.get(maxDateTemp);   
                }
                
            }
           
            
            if(latestDebtAgreementobj!=null && latestDebtAgreementobj.Repayments!=null){
                for(WrapperImport.Repayments repaymentmentsInner: latestDebtAgreementobj.Repayments){
                mapOFOppIdANDRefrence.put(repaymentmentsInner.Reference,opp.AccountReference__c);
				system.debug('mapOFOppIdANDRefrence'+mapOFOppIdANDRefrence);
                if(!extRepaymentMap.containskey(repaymentmentsInner.Reference)){
                    system.debug('reference of repayment0'+repaymentmentsInner.Reference);
                    Repayment__c rePaymentObj= new Repayment__c(); 
                    if(repaymentmentsInner.DatePaid!=null){
                        rePaymentObj.Date_Paid_Bric__c=date.valueof(repaymentmentsInner.DatePaid);
                    }
                    if(repaymentmentsInner.DateReconciled!=null){
                        rePaymentObj.Date_Reconciled_Bric__c=date.valueof(repaymentmentsInner.DateReconciled); 
                    }
                   
                    rePaymentObj.Amount_Paid_Bric__c=repaymentmentsInner.AmountPaid!=null?repaymentmentsInner.AmountPaid:integer.valueof(0);
                    rePaymentObj.Reference_Bric__c=repaymentmentsInner.Reference!=null?repaymentmentsInner.Reference:'';
                    rePaymentObj.Realisations_Component_Bric__c=repaymentmentsInner.RealisationsComponent;
                    rePaymentObj.Admin_Component_Bric__c=repaymentmentsInner.AdminComponent!=null?repaymentmentsInner.AdminComponent:Integer.valueof(0);
                    rePaymentObj.Realisations_Rate_Bric__c=repaymentmentsInner.RealisationsRate!=null?repaymentmentsInner.RealisationsRate:Integer.valueof(0);
                    rePaymentObj.Admin_Rate_Bric__c=repaymentmentsInner.AdminRate!=null?repaymentmentsInner.AdminRate:Integer.valueof(0);
                    system.debug('opportunity id'+mapOFOppIdANDRefrence.get(repaymentmentsInner.Reference));
                    
                    if(extOppMap.containsKey(mapOFOppIdANDRefrence.get(repaymentmentsInner.Reference))){
                    rePaymentObj.Opportunity_Bric__c=extOppMap.get(mapOFOppIdANDRefrence.get(repaymentmentsInner.Reference)).id;
                    system.debug('opportunity id'+extOppMap.get(mapOFOppIdANDRefrence.get(repaymentmentsInner.Reference)).id);  
                    }

                    rePaymentObjListNew.add(rePaymentObj);
                    system.debug('Insert repayment list'+extRepaymentMap);
                }
                else{
                    Repayment__c rePaymentObjold= new Repayment__c(); 
                    if(repaymentmentsInner.DatePaid!=null){
                          rePaymentObjold.Date_Paid_Bric__c=date.valueof(repaymentmentsInner.DatePaid);
                    }
                    if(repaymentmentsInner.DateReconciled!=null){
                      rePaymentObjold.Date_Reconciled_Bric__c=date.valueof(repaymentmentsInner.DateReconciled);  
                    }
                    
                    rePaymentObjold.Amount_Paid_Bric__c=repaymentmentsInner.AmountPaid!=null?repaymentmentsInner.AmountPaid:Integer.valueof(0);
                    rePaymentObjold.Reference_Bric__c=repaymentmentsInner.Reference!=null?repaymentmentsInner.Reference:string.valueof('');
                    rePaymentObjold.Realisations_Component_Bric__c=repaymentmentsInner.RealisationsComponent!=null?repaymentmentsInner.RealisationsComponent:Integer.valueof(0);
                    rePaymentObjold.Admin_Component_Bric__c=repaymentmentsInner.AdminComponent!=null?repaymentmentsInner.AdminComponent:Integer.valueof(0);
                    rePaymentObjold.Realisations_Rate_Bric__c=repaymentmentsInner.RealisationsRate!=null?repaymentmentsInner.RealisationsRate:Integer.valueof(0);
                    rePaymentObjold.Admin_Rate_Bric__c=repaymentmentsInner.AdminRate!=null?repaymentmentsInner.AdminRate:Integer.valueof(0);
                    rePaymentObjold.Opportunity_Bric__c=extRepaymentMap.get(repaymentmentsInner.Reference).Opportunity_Bric__c;
                    system.debug('opportynity for repayment'+extRepaymentMap.get(repaymentmentsInner.Reference).Opportunity_Bric__c);
                    rePaymentObjold.id=extRepaymentMap.get(repaymentmentsInner.Reference).id;    
                    rePaymentObjListOld.add(rePaymentObjold); 
                    mapOFUpdatedRePayments.putall(rePaymentObjListOld);
                    system.debug('opp repayment id'+opp.id);
                    
                }
                
            }
            }
            
            if(mapOfOppNameAndWrapper.get(Integer.valueof(opp.AccountReference__c)).debts!=null && mapOfOppNameAndWrapper.containsKey(Integer.valueof(opp.AccountReference__c))){
                for(WrapperImport.Debts debtObj:mapOfOppNameAndWrapper.get(Integer.valueof(opp.AccountReference__c)).debts){  
                    if(!extDebtRefIDMap.containsKey(debtObj.Reference)){  //new debts inserts
                        Debt__c newdebtobj= new Debt__c();
                        if(debtObj.Reference!=Null){
                            newdebtobj.Account_Reference_Number__c=debtObj.Reference;
                        }
                        newdebtobj.Opportunity__c=opp.id;
                        if(businessAccountMap.containsKey(debtObj.CreditorName)){
                            newdebtobj.Send_DAP_to__c=businessAccountMap.get(debtObj.CreditorName);   
							}
                        
                        newdebtobj.Amount_Owing__c=debtObj.Amount!=null?debtObj.Amount:0;
                        if(debtObj.IsParticipating!=null){
                        newdebtobj.Is_Participating_Bric__c=debtObj.IsParticipating;    
                        }
                        debtList.add(newdebtobj);
                    }
                    else{	
                        Debt__c olddebtobj= new Debt__c();
                        olddebtobj.Opportunity__c=opp.id;
                        if(businessAccountMap.containskey(debtObj.CreditorName)){
                            olddebtobj.Send_DAP_to__c=businessAccountMap.get(debtObj.CreditorName);
								}
                        
                        olddebtobj.Amount_Owing__c=debtObj.Amount!=null?debtObj.Amount:0;
                        olddebtobj.id=extDebtRefIDMap.get(debtObj.Reference);
                        updatedDebtList.add(olddebtobj); 
                        
                        
                    }
                    if(debtObj.DividendPayments!=null){
                         for(WrapperImport.DividendPayments dividentPayObjinner: debtObj.DividendPayments){
                        system.debug('ext div payment ref'+extDividentPaymentsMap.containskey(dividentPayObjinner.Reference));
                        if(!extDividentPaymentsMap.containskey(dividentPayObjinner.Reference)){
                            Payment_Bric__c paymentObj= new Payment_Bric__c(); 
                            paymentObj.Payment_Type_Bric__c='Dividend Payment';
                            paymentObj.Payment_Method_Bric__c=dividentPayObjinner.PaymentMethod; 
                            paymentObj.Reference_Bric__c=dividentPayObjinner.Reference;
                            if(dividentPayObjinner.DatePaid!=null){
                              paymentObj.Date_Paid_Bric__c=date.valueof(dividentPayObjinner.DatePaid);  
                            }
                            
                            if(dividentPayObjinner.DateReconciled!=Null){
                                paymentObj.Date_Reconciled_Bric__c=date.valueof(dividentPayObjinner.DateReconciled);
                            }
                            if(dividentPayObjinner.DateDisbursed!=null){
                                paymentObj.Date_Disbursed_Bric__c=date.valueof(dividentPayObjinner.DateDisbursed);
                            }
                            paymentObj.Amount_Bric__c=dividentPayObjinner.Amount!=null?dividentPayObjinner.Amount:0;
                            paymentObj.Opportunity_Bric__c=opp.id;
                            paymentListNew.add(paymentObj);
                            system.debug('inside new list'+paymentListNew);
                        }else{
                            Payment_Bric__c paymentObjOld= new Payment_Bric__c(); 
                            paymentObjOld.Payment_Type_Bric__c='Dividend Payment';
                            paymentObjOld.Payment_Method_Bric__c=dividentPayObjinner.PaymentMethod; 
                            paymentObjOld.Reference_Bric__c=dividentPayObjinner.Reference;
                            if(dividentPayObjinner.DatePaid!=null){
                              paymentObjOld.Date_Paid_Bric__c=date.valueof(dividentPayObjinner.DatePaid);  
                            }
                            
                            if(dividentPayObjinner.DateReconciled!=null){
                                paymentObjOld.Date_Reconciled_Bric__c=date.valueof(dividentPayObjinner.DateReconciled);
                            }
                            if(dividentPayObjinner.DateDisbursed!=null){
                                paymentObjOld.Date_Disbursed_Bric__c=date.valueof(dividentPayObjinner.DateDisbursed);
                                
                            }
                            paymentObjOld.Amount_Bric__c=dividentPayObjinner.Amount!=null?dividentPayObjinner.Amount:0;
                            paymentObjOld.Opportunity_Bric__c=opp.id;
                            paymentObjOld.id=extDividentPaymentsMap.get(dividentPayObjinner.Reference);
                            paymentListOld.add(paymentObjOld);
                            mapOFUpdatedPayments.putall(paymentListOld);
                            
                            
                        }
                        
                    }
                        
                    }
                   
                    
                }
                
            }
            if(mapOfOppNameAndWrapper.get(integer.valueof(opp.AccountReference__c)).AdminPayments!=null){
                
            
            for(WrapperImport.AdminPayments adminPayObjinner: mapOfOppNameAndWrapper.get(integer.valueof(opp.AccountReference__c)).AdminPayments){
                if(!extDividentPaymentsMap.containskey(adminPayObjinner.Reference)){
                    Payment_Bric__c adminPaymentObj= new Payment_Bric__c(); 
                    adminPaymentObj.Payment_Type_Bric__c='Admin Payment';	
                    adminPaymentObj.Amount_Bric__c=   adminPayObjinner.Amount!=null?adminPayObjinner.Amount:0;
                    adminPaymentObj.Payment_Method_Bric__c=   adminPayObjinner.PaymentMethod;
                    adminPaymentObj.Reference_Bric__c=  adminPayObjinner.Reference;
                    IF(adminPayObjinner.DatePaid!=null){
                      adminPaymentObj.Date_Paid_Bric__c=  date.valueof(adminPayObjinner.DatePaid);  
                    }
                    
                    if(adminPayObjinner.DateReconciled!=null){
                        adminPaymentObj.Date_Reconciled_Bric__c=  date.valueof(adminPayObjinner.DateReconciled);
                    }
                    if(adminPayObjinner.ChargePeriodTo!=null){
                      adminPaymentObj.Charge_Period_To_Bric__c=date.valueof(adminPayObjinner.ChargePeriodTo);  
                    }
                    
                    IF(adminPayObjinner.DateDisbursed!=null){
                        adminPaymentObj.Date_Disbursed_Bric__c=date.valueof(adminPayObjinner.DateDisbursed);
                    }
                    adminPaymentObj.Opportunity_Bric__c=opp.id;	
                    paymentListNew.add(adminPaymentObj);
                    
                }else{
                    Payment_Bric__c adminPaymentObjOld= new Payment_Bric__c(); 
                    adminPaymentObjOld.Payment_Type_Bric__c='Admin Payment';	
                    adminPaymentObjOld.Amount_Bric__c=   adminPayObjinner.Amount!=null?adminPayObjinner.Amount:0;
                    adminPaymentObjOld.Payment_Method_Bric__c=   adminPayObjinner.PaymentMethod;
                    adminPaymentObjOld.Reference_Bric__c=  adminPayObjinner.Reference;
                    if(adminPayObjinner.DatePaid!=null){
                      adminPaymentObjOld.Date_Paid_Bric__c=  date.valueof(adminPayObjinner.DatePaid);  
                    }
                    
                    IF(adminPayObjinner.DateReconciled!=null){
                        adminPaymentObjOld.Date_Reconciled_Bric__c=  date.valueof(adminPayObjinner.DateReconciled);
                    }
                    if(adminPayObjinner.ChargePeriodTo!=null){
                        adminPaymentObjOld.Charge_Period_To_Bric__c=date.valueof(adminPayObjinner.ChargePeriodTo);
                    }
                    
                    if(adminPayObjinner.DateDisbursed!=null){
                        adminPaymentObjOld.Date_Disbursed_Bric__c=date.valueof(adminPayObjinner.DateDisbursed);
                    }
                    adminPaymentObjOld.Opportunity_Bric__c=opp.id;
                    adminPaymentObjOld.id=extDividentPaymentsMap.get(adminPayObjinner.Reference);  
                    paymentListOld.add(adminPaymentObjOld);
                    mapOFUpdatedPayments.putall(paymentListOld);
                    
                }
            }
                
                
                
                
                
           
            }
            if(mapOfOppNameAndWrapper.get(integer.valueof(opp.AccountReference__c)).AFSAPayments!=null){
                for(WrapperImport.AFSAPayments afsaPayObjinner: mapOfOppNameAndWrapper.get(Integer.valueof(opp.AccountReference__c)).AFSAPayments){
                if(!extDividentPaymentsMap.containskey(afsaPayObjinner.Reference)){
                    Payment_Bric__c afsaPaymentObj= new Payment_Bric__c(); 
                    afsaPaymentObj.Payment_Type_Bric__c='AFSA Payment';	
                    afsaPaymentObj.Amount_Bric__c=afsaPayObjinner.Amount!=null?afsaPayObjinner.Amount:0;
                    afsaPaymentObj.Payment_Method_Bric__c=afsaPayObjinner.PaymentMethod;
                    afsaPaymentObj.Reference_Bric__c=afsaPayObjinner.Reference;
                    if(afsaPayObjinner.DatePaid!=null){
                      afsaPaymentObj.Date_Paid_Bric__c=date.valueof(afsaPayObjinner.DatePaid);  
                    }
                    
                    if(afsaPayObjinner.DateReconciled!=null){
                        afsaPaymentObj.Date_Reconciled_Bric__c=date.valueof(afsaPayObjinner.DateReconciled);
                    }
                    if(afsaPayObjinner.ChargePeriodTo!=null){
                      afsaPaymentObj.Charge_Period_To_Bric__c=date.valueof(afsaPayObjinner.ChargePeriodTo);  
                    }
                    
                    if(afsaPayObjinner.DateDisbursed!=null){
                        afsaPaymentObj.Date_Disbursed_Bric__c=date.valueof(afsaPayObjinner.DateDisbursed);
                    }
                    afsaPaymentObj.Opportunity_Bric__c=opp.id;
                    paymentListNew.add(afsaPaymentObj);
                    system.debug('Insert payment list'+paymentListNew);
                    
                }else{
                    Payment_Bric__c afsaPaymentObjOld= new Payment_Bric__c(); 
                    afsaPaymentObjOld.Payment_Type_Bric__c='AFSA Payment';	
                    afsaPaymentObjOld.Amount_Bric__c=afsaPayObjinner.Amount!=null?afsaPayObjinner.Amount:0;
                    afsaPaymentObjOld.Payment_Method_Bric__c=afsaPayObjinner.PaymentMethod;
                    afsaPaymentObjOld.Reference_Bric__c=afsaPayObjinner.Reference;
                    if(afsaPayObjinner.DatePaid!=null){
                       afsaPaymentObjOld.Date_Paid_Bric__c=date.valueof(afsaPayObjinner.DatePaid); 
                    }
                    
                    if(afsaPayObjinner.DateReconciled!=null){
                        afsaPaymentObjOld.Date_Reconciled_Bric__c=date.valueof(afsaPayObjinner.DateReconciled);
                    }
                    if(afsaPayObjinner.ChargePeriodTo!=null){
                      afsaPaymentObjOld.Charge_Period_To_Bric__c=date.valueof(afsaPayObjinner.ChargePeriodTo);   
                    }
                   
                    if(afsaPayObjinner.DateDisbursed!=null){
                        afsaPaymentObjOld.Date_Disbursed_Bric__c=date.valueof(afsaPayObjinner.DateDisbursed);
                    }
                    afsaPaymentObjOld.id=extDividentPaymentsMap.get(afsaPayObjinner.Reference);
                    afsaPaymentObjOld.Opportunity_Bric__c=opp.id;
                    paymentListOld.add(afsaPaymentObjOld);
                    mapOFUpdatedPayments.putall(paymentListOld);
                    system.debug('update payment list'+paymentListold);
                }
            }
            } 
        }
        
     
        if(debtList.size()>0){
            database.insert(debtList,true);   
        }
        if(updatedDebtList.size()>0){
            database.update(updatedDebtList,true);
         
        }
        if(paymentListNew.size()>0){
            database.Insert(paymentListNew,true);    
        }
        if(paymentListOld.size()>0){
            database.update(mapOFUpdatedPayments.values(),true);    
        }
        if(rePaymentObjListNew.size()>0){
            database.insert(rePaymentObjListNew,true);   
        }
        if(rePaymentObjListOld.size()>0){
            database.update(mapOFUpdatedRePayments.values(),true);   
        }
        
    }
}
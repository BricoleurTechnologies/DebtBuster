/**
**Send LOA to Creditors
**Display all the Send DAP to (Account - Record Type - Creditor) from the Debt object.
**Automatically include attachments starting with Name Letter of Authority from Opportunity Notes & Attachments
**/

public class SendLOACreditors{
    
    public String recordID {get;set;}
    public List<WrapperClass> listWrapper {get;set;}
    public Boolean allBool {get;set;}
    public List<ContentDocumentLink> lstAttach{get;set;}
        public List<attachment> realAttach{get;set;}

    public String attachName{get;set;}
    public opportunity oppDetails {get;set;}
    public static boolean firstRun = true;
    public map<Id,list<Debt__c>> mapCreditor = new map<Id,list<Debt__c>>();
    
    public SendLOACreditors( ){
        attachName = DB_Setting__c.getValues('Attachment Name').Value__c;
        oppDetails = new Opportunity();
        recordID = ApexPages.currentPage().getParameters().get('id');
        oppDetails = [Select Name,Owner.Email,Owner.Name FRom Opportunity where id =:recordID];
        QueryDebts();
        QueryAttachment();
        QueryAttachment1();
        
    }
    /*public RevokeLOACreditors( ){
        oppDetails = new Opportunity();
        recordID = ApexPages.currentPage().getParameters().get('id');
        oppDetails = [Select Name,Owner.Email,Owner.Name FRom Opportunity where id =:recordID];
        QueryDebts();    
    }*/
    public void QueryAttachment1(){
        realAttach = new List<attachment>();
        for(attachment att : [SELECT id,name  FROM attachment WHERE parentId = :recordID 
                              AND name LIKE :'%'+attachName +'%' ]){
                                  realAttach.add(att);                     
                              }
    }
    //Query attachments starting with Name Letter of "Authority" from Opportunity Notes & Attachments
    public void QueryAttachment(){
        lstAttach = new List<ContentDocumentLink>();
        for(ContentDocumentLink att : [SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :recordID 
                              AND ContentDocument.Title LIKE :'%'+attachName +'%' ]){
                                  lstAttach.add(att);                     
                              }   
    }
    public void QueryDebts(){
        system.debug('!!!recordID'+recordID);
        String recordtypeName = DB_Setting__c.getValues('Record Type Name').Value__c;
        map<String, Debt__c> mapDebt = new map<String, Debt__c>();
        listWrapper = new List<WrapperClass>();
        List <Debt__c> lstDebt = [Select ID,Send_DAP_to__r.Name,
                                  Send_DAP_to__r.Id,  
                                  Send_DAP_to__r.Creditor_Email__c,
                                  Send_DAP_to__r.Creditor_Email_1__c,
                                  Send_DAP_to__r.Creditor_Email_2__c,
                                  Send_DAP_to__r.Creditor_Email_3__c,
                                  Send_DAP_to__r.Creditor_Email_4__c,
                                  Send_DAP_to__r.Creditor_Email_5__c,
                                  Send_DAP_to__r.Hardship_Email__c,
                                  Send_DAP_to__c,
                                  Opportunity__r.RecordType.DeveloperName,
                                  RecordType.DeveloperName
                                  From Debt__c 
                                  WHERE Opportunity__r.Id =:recordID 
                                  AND Send_DAP_to__r.RecordType.Name =:recordtypeName
                                  AND (Send_DAP_to__r.Creditor_Email__c !=null OR
                                       Send_DAP_to__r.Creditor_Email_1__c!=null OR
                                       Send_DAP_to__r.Creditor_Email_2__c !=null OR
                                       Send_DAP_to__r.Creditor_Email_3__c !=null OR
                                       Send_DAP_to__r.Creditor_Email_4__c !=null OR
                                       Send_DAP_to__r.Creditor_Email_5__c!=null )];
        
        //system.debug('!!!lstDebt '+lstDebt[0].Send_DAP_to__r.Name);
        if(lstDebt.size() > 0) {
            system.debug('!!!lstDebt 11');
            for(Debt__c debt : lstDebt) {                
                
                if(!mapDebt.containsKey(debt.Send_DAP_to__r.Name) ){
                    mapDebt.put(debt.Send_DAP_to__r.Name, debt);
                    system.debug('!!!mapDebt11'+mapDebt);         
                    listWrapper.add(new WrapperClass(debt));
                }
                if(!mapCreditor.containsKey(debt.Send_DAP_to__c))
                {
                  mapCreditor.put(debt.Send_DAP_to__c, new List<Debt__c> {debt});  
                }               
                else if(mapCreditor.containsKey(debt.Send_DAP_to__c) && mapCreditor.get(debt.Send_DAP_to__c) != null)
                {
                    List<Debt__c> lstGetDebt = mapCreditor.get(debt.Send_DAP_to__c);
                    lstGetDebt.add(debt);
                    mapCreditor.put(debt.Send_DAP_to__c, lstGetDebt); 
                }
                //listWrapper=mapDebt.values();
            }
            system.debug('!!!listWrapper11size'+listWrapper.size());
            system.debug('!!!listWrapper11'+listWrapper);
            system.debug('!!!&&&mapCreditor'+mapCreditor.size());
            system.debug('!!!&&&mapCreditor'+mapCreditor);
        }
    }
    
    public PageReference selectEmail() {
        
        List<Debt__c > listEmpForDel = new List<Debt__c >();
        List<WrapperClass> listTempWrapper = new List<WrapperClass>();
        String[] setEmails = new List<String>();
        Set<Id> setAccountId = new Set<Id>();
        String templateName = DB_Setting__c.getValues('Template Name').Value__c;        
        Id template_id =  [SELECT id, name 
                           FROM EmailTemplate 
                           WHERE developername =:templateName].Id;
        User theUser = [SELECT Id,email, firstName, lastName FROM User WHERE id =:UserInfo.getUserId()];
        SendLOAEmails sloa = new SendLOAEmails(); 
        Map<Id,Integer> mapEmailMessage = new Map<Id,Integer>();
        Map<Id,list<Integer>> mapEmailMessage1 = new Map<Id,list<Integer>>();
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[]{};
            
        /* 
        * Start [3/11/2020] -- Send LOA Email template changes
        */ 
        map<String, Id> mapEmailTemplate =  getDebtTemplate();
        /* End [3/11/2020]*/
        Integer i=0;
        system.debug('!!!&&&mapCreditor1'+mapCreditor.size());
        if(lstAttach.size() >0 || realAttach.size()>0){
            system.debug('&& listWrapper'+listWrapper);
            for(WrapperClass w : listWrapper) {
                if(w.checked != null && w.checked== true ) {
                    listEmpForDel.add(w.debt);
                    if(w.debt.Send_DAP_to__r.Creditor_Email__c !=null){
                        setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email__c);
                        setAccountId.add(w.debt.Send_DAP_to__r.Id);
                    }
                    if(w.debt.Send_DAP_to__r.Creditor_Email_1__c !=null){
                        setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_1__c);
                        setAccountId.add(w.debt.Send_DAP_to__r.Id);
                    }
                    if(w.debt.Send_DAP_to__r.Creditor_Email_2__c !=null){
                        setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_2__c);
                        setAccountId.add(w.debt.Send_DAP_to__r.Id);
                    }
                    if(w.debt.Send_DAP_to__r.Creditor_Email_3__c !=null){
                        setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_3__c);
                        setAccountId.add(w.debt.Send_DAP_to__r.Id);
                    }
                    if(w.debt.Send_DAP_to__r.Creditor_Email_4__c !=null){
                        setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_4__c);
                        setAccountId.add(w.debt.Send_DAP_to__r.Id);
                    }
                    if(w.debt.Send_DAP_to__r.Creditor_Email_5__c !=null){
                        setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_5__c);
                        setAccountId.add(w.debt.Send_DAP_to__r.Id);
                    }
                    /*
                     * Start [10/12/2020] ---- Send LOA Email template changes
                     * An additional request – To amend the lookup the email address when the opportunity record type 
                     * is Informal Payment Arrangement (IPA) and we click revoke LOA &Sond LOA  
                     *  
                     */ 
                    system.debug('!!!&&&mapCreditor'+mapCreditor.get(w.debt.Send_DAP_to__r.id));
                    if(w.debt.Send_DAP_to__r.Hardship_Email__c !=null
                      && w.debt.Opportunity__r.RecordType.DeveloperName == 'Informal_Payment_Arrangement'){
                        setEmails.add(w.debt.Send_DAP_to__r.Hardship_Email__c);
                    }    
                    
                    /*
                    * Start [3/11/2020] -- Send LOA Email template changes
                    */
                    if(mapCreditor.containsKey(w.debt.Send_DAP_to__r.id)){
                        List<Debt__c> lstDebtRecords = mapCreditor.get(w.debt.Send_DAP_to__r.id);
                        set<String> setDebtRT = new set<String>();
                        for(Debt__c debtrec:lstDebtRecords)
                        {
                        	/*
                             * Start[17/12/2020]
                             * send only 1 LOA per debt type
                            */	
                        	String recordTypeIdentifier = debtrec.Opportunity__r.RecordType.DeveloperName+debtrec.RecordType.DeveloperName;
                           	if(!setDebtRT.contains(recordTypeIdentifier))
                           	{    
                                if(debtrec.Opportunity__r.RecordType.DeveloperName == 'Debt_Agreement')
                                {
                                    if((debtrec.RecordType.DeveloperName == 'Secured_Debt') && mapEmailTemplate.containsKey('DAP_SecuredDebt'))                                    
                                        template_id = mapEmailTemplate.get('DAP_SecuredDebt'); 
                                    if((debtrec.RecordType.DeveloperName == 'Unsecured_Debt') && mapEmailTemplate.containsKey('DAP_UnsecuredDebt'))
                                        template_id = mapEmailTemplate.get('DAP_UnsecuredDebt');
                                    if((debtrec.RecordType.DeveloperName == 'Not_to_be_paid_Debt') && mapEmailTemplate.containsKey('DAP_NotToBePaidDebt'))
                                        template_id = mapEmailTemplate.get('DAP_NotToBePaidDebt');
                                }
                                //Opportunity RecordType = BKR --> Bankruptcy
                                else if(debtrec.Opportunity__r.RecordType.DeveloperName == 'Bankruptcy')
                                {
                                    if((debtrec.RecordType.DeveloperName == 'Secured_Debt') && mapEmailTemplate.containsKey('BKR_SecuredDebt'))
                                        template_id = mapEmailTemplate.get('BKR_SecuredDebt');
                                    if((debtrec.RecordType.DeveloperName == 'Unsecured_Debt') && mapEmailTemplate.containsKey('BKR_UnsecuredDebt'))
                                   		template_id = mapEmailTemplate.get('BKR_UnsecuredDebt');
                                    if((debtrec.RecordType.DeveloperName == 'Not_to_be_paid_Debt') && mapEmailTemplate.containsKey('BKR_NotToBePaidDebt'))
                                        template_id = mapEmailTemplate.get('BKR_NotToBePaidDebt'); 
                                }
                                //Opportunity RecordType = IPA --> Informal Payment Arrangement
                                else if(debtrec.Opportunity__r.RecordType.DeveloperName == 'Informal_Payment_Arrangement'){                        
                                    if((debtrec.RecordType.DeveloperName == 'Secured_Debt') && mapEmailTemplate.containsKey('IPA_SecuredDebt'))
                                        template_id = mapEmailTemplate.get('IPA_SecuredDebt');
                                    if((debtrec.RecordType.DeveloperName == 'Unsecured_Debt') && mapEmailTemplate.containsKey('IPA_UnsecuredDebt'))
                                    	template_id = mapEmailTemplate.get('IPA_UnsecuredDebt');
                                    if((debtrec.RecordType.DeveloperName == 'Not_to_be_paid_Debt') && mapEmailTemplate.containsKey('IPA_NotToBePaidDebt'))
                                    	template_id = mapEmailTemplate.get('IPA_NotToBePaidDebt');
                                }
                                //Opportunity RecordType = TDP --> Temporary Debt Protection
                                else if(debtrec.Opportunity__r.RecordType.DeveloperName == 'Temporary_Debt_Protection'){
                                    if((debtrec.RecordType.DeveloperName == 'Secured_Debt') && mapEmailTemplate.containsKey('TDP_SecuredDebt'))
                                    	template_id = mapEmailTemplate.get('TDP_SecuredDebt');
                                    if((debtrec.RecordType.DeveloperName == 'Unsecured_Debt') && mapEmailTemplate.containsKey('TDP_UnsecuredDebt'))
                                        template_id = mapEmailTemplate.get('TDP_UnsecuredDebt');
                                    if((debtrec.RecordType.DeveloperName == 'Not_to_be_paid_Debt') && mapEmailTemplate.containsKey('TDP_NotToBePaidDebt'))
                                        template_id = mapEmailTemplate.get('TDP_NotToBePaidDebt');
                                } 
                                /* End [3/11/2020]*/
                                
                                String creditorsName = w.debt.Send_DAP_to__r.Name;
                                system.debug('!!!creditorsName '+creditorsName );
                                Id creditoraccountId = new List<Id> (setAccountId).get(0); //returns account id
                                mapEmailMessage.put(creditoraccountId,i);
                                if(!mapEmailMessage1.containsKey(creditoraccountId))
                                {
                                     mapEmailMessage1.put(creditoraccountId, new List<Integer> {i});  
                                }  
                                else if(mapEmailMessage1.containsKey(creditoraccountId) && mapEmailMessage1.get(creditoraccountId) != null)
                                {
                                    List<Integer> lstCount = mapEmailMessage1.get(creditoraccountId);
                                    lstCount.add(i);
                                    mapEmailMessage1.put(creditoraccountId, lstCount); 
                                }
                                Messaging.SingleEmailMessage email = sloa.SendEmails(setEmails,creditoraccountId,template_id,recordID);
                                emailList.add(email);
                                
                            	i++;
                                setDebtRT.add(recordTypeIdentifier); 
                            } 
                            /*
                             * End [17/12/2020]
                             * send only 1 LOA per debt type
                            */	
                            
                    	}
                        setEmails.clear();
                        setAccountId.clear();
                        setDebtRT.clear();
                    }
                } 
                else {
                    listTempWrapper.add(w);
                }
                
            }
            //Email outside the loop as a collection
            if(emailList.size()>0){
                sloa.dispatch1(emailList,mapEmailMessage1,template_id,recordID);
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select atleast one record to Send Email'));
                return null;
            }    
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please attach LOA to proceed.')); 
            return null;
        }
        system.debug('!!!listEmpForDel'+listEmpForDel);
        system.debug('!!!listTempWrapper'+listTempWrapper);
        if(listEmpForDel.size() > 0) {
            //delete listEmpForDel;
            //listWrapper = listTempWrapper;
        } 
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select atleast one record to Send Email'));
        }
        
        PageReference page = new PageReference('/'+recordID);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference revokeSelectEmail() {
        
        List<Debt__c > listEmpForDel = new List<Debt__c >();
        List<WrapperClass> listTempWrapper = new List<WrapperClass>();
        String[] setEmails = new List<String>();
        Set<Id> setAccountId = new Set<Id>();
        String templateName = DB_Setting__c.getValues('Revoke Template Name').Value__c;
        Id template_id =  [SELECT id, name 
                           FROM EmailTemplate 
                           WHERE developername =:templateName].Id;
        User theUser = [SELECT Id,email, firstName, lastName FROM User WHERE id =:UserInfo.getUserId()];
        RevokeLOAEmails rloa = new RevokeLOAEmails(); 
        Map<Id,Integer> mapEmailMessage = new Map<Id,Integer>();
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[]{};
            
        Integer i=0;    
        for(WrapperClass w : listWrapper) {
            if(w.checked != null && w.checked== true ) {
                
                listEmpForDel.add(w.debt);
                if(w.debt.Send_DAP_to__r.Creditor_Email__c !=null){
                    setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email__c);
                    setAccountId.add(w.debt.Send_DAP_to__r.Id);
                }
                if(w.debt.Send_DAP_to__r.Creditor_Email_1__c !=null){
                    setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_1__c);
                    setAccountId.add(w.debt.Send_DAP_to__r.Id);
                }
                if(w.debt.Send_DAP_to__r.Creditor_Email_2__c !=null){
                    setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_2__c);
                    setAccountId.add(w.debt.Send_DAP_to__r.Id);
                }
                if(w.debt.Send_DAP_to__r.Creditor_Email_3__c !=null){
                    setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_3__c);
                    setAccountId.add(w.debt.Send_DAP_to__r.Id);
                }
                if(w.debt.Send_DAP_to__r.Creditor_Email_4__c !=null){
                    setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_4__c);
                    setAccountId.add(w.debt.Send_DAP_to__r.Id);
                }
                if(w.debt.Send_DAP_to__r.Creditor_Email_5__c !=null){
                    setEmails.add(w.debt.Send_DAP_to__r.Creditor_Email_5__c);
                    setAccountId.add(w.debt.Send_DAP_to__r.Id);
                }
                /*
                 * Start [10/12/2020] ---- Send LOA Email template changes
                 * An additional request – To amend the lookup the email address when the opportunity record type 
                 * is Informal Payment Arrangement (IPA) and we click revoke LOA &Sond LOA  
                 *  
                 */ 
                if(w.debt.Send_DAP_to__r.Hardship_Email__c !=null
                      && w.debt.Opportunity__r.RecordType.DeveloperName == 'Informal_Payment_Arrangement')
                {
                    setEmails.add(w.debt.Send_DAP_to__r.Hardship_Email__c);
                } 
                
                String creditorsName = w.debt.Send_DAP_to__r.Name;
                system.debug('!!!creditorsName '+creditorsName );
                Id creditoraccountId = new List<Id> (setAccountId).get(0); //returns account id
                mapEmailMessage.put(creditoraccountId,i);
                
                Messaging.SingleEmailMessage email = rloa.SendEmails(setEmails,creditoraccountId,template_id,recordID);                
                emailList.add(email);
              
               
                system.debug('!!!emailList add single'+emailList);
                system.debug('!!!setAccountId out for'+setAccountId);
                setEmails.clear();
                setAccountId.clear(); 
                i++;
                
            } 
            else {
                listTempWrapper.add(w); 
                
            }
        }
        //Email outside the loop as a collection
        if(emailList.size()>0){
            rloa.dispatch(emailList,mapEmailMessage,template_id,recordID);
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select atleast one record to Send Email'));
            return null;
        }   
        
        system.debug('!!!listEmpForDel'+listEmpForDel);
        system.debug('!!!listTempWrapper'+listTempWrapper);
        if(listEmpForDel.size() > 0) {
            //delete listEmpForDel;
            //listWrapper = listTempWrapper;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select atleast one record to Send Email'));
        }
        PageReference page = new PageReference('/'+recordID);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference cancel()
    {
        PageReference page = new PageReference('/'+recordID);
        page.setRedirect(true);
        return page;
    }

    
    public void selectAll() {
        if(allBool) {
            for(WrapperClass w : listWrapper) {
                w.checked = true;
            }
        } else {
            for(WrapperClass w : listWrapper) {
                w.checked = false;
            }
        }
    }
    /*
    * Start [3/11/2020] -- Send LOA Email template changes
    * To get Email Template Name from custom settings
    */
    public map<String,Id> getDebtTemplate(){
        String DAP_SecuredDebt = DB_Setting__c.getValues('DAP - Secured Debt Template Name').Value__c;
        String DAP_UnsecuredDebt = DB_Setting__c.getValues('DAP - Unsecured Debt Template Name').Value__c;
        String DAP_NotToBePaidDebt = DB_Setting__c.getValues('DAP - Nottobepaid Debt Template Name').Value__c;
        
        String BKR_SecuredDebt = DB_Setting__c.getValues('BKR - Secured Debt Template Name').Value__c;
        String BKR_UnsecuredDebt = DB_Setting__c.getValues('BKR - Unsecured Debt Template Name').Value__c;
        String BKR_NotToBePaidDebt = DB_Setting__c.getValues('BKR - Nottobepaid Debt Template Name').Value__c;
        
        String IPA_SecuredDebt = DB_Setting__c.getValues('IPA - Secured Debt Template Name').Value__c;
        String IPA_UnsecuredDebt = DB_Setting__c.getValues('IPA - Unsecured Debt Template Name').Value__c;
        String IPA_NotToBePaidDebt = DB_Setting__c.getValues('IPA - Nottobepaid Debt Template Name').Value__c;
        
        String TDP_SecuredDebt = DB_Setting__c.getValues('TDP - Secured Debt Template Name').Value__c;
        String TDP_UnsecuredDebt = DB_Setting__c.getValues('TDP - Unsecured Debt Template Name').Value__c;
        String TDP_NotToBePaidDebt = DB_Setting__c.getValues('TDP - Nottobepaid Debt Template Name').Value__c;
        
        set<String> setTemplate = new set<String>();
        setTemplate.add(DAP_SecuredDebt);
        setTemplate.add(DAP_UnsecuredDebt);
        setTemplate.add(DAP_NotToBePaidDebt);
		
		setTemplate.add(BKR_SecuredDebt);
        setTemplate.add(BKR_UnsecuredDebt);
        setTemplate.add(BKR_NotToBePaidDebt);
		
		setTemplate.add(IPA_SecuredDebt);
        setTemplate.add(IPA_UnsecuredDebt);
        setTemplate.add(IPA_NotToBePaidDebt);
		
		setTemplate.add(TDP_SecuredDebt);
        setTemplate.add(TDP_UnsecuredDebt);
        setTemplate.add(TDP_NotToBePaidDebt);
        map<String, Id> mapEmailTemplate = new map<String,Id>();
        if(setTemplate.size() >0){
            for(EmailTemplate et:[SELECT id, name,developername 
                                  FROM EmailTemplate 
                                  WHERE developername =:setTemplate])
            {
                 //Opportunity RecordType = DAP --> Debt Agreement
                if(et.developername == DAP_SecuredDebt)
                    mapEmailTemplate.put('DAP_SecuredDebt', et.id);
                if(et.developername == DAP_UnsecuredDebt)
                    mapEmailTemplate.put('DAP_UnsecuredDebt', et.id);
                if(et.developername == DAP_NotToBePaidDebt)
                    mapEmailTemplate.put('DAP_NotToBePaidDebt', et.id);
                
                 //Opportunity RecordType = BKR --> Bankruptcy
                if(et.developername == BKR_SecuredDebt)                    
                    mapEmailTemplate.put('BKR_SecuredDebt', et.id);
                if(et.developername == BKR_UnsecuredDebt)
                    mapEmailTemplate.put('BKR_UnsecuredDebt', et.id);
                if(et.developername == BKR_NotToBePaidDebt)
                    mapEmailTemplate.put('BKR_NotToBePaidDebt', et.id);
                
                 //Opportunity RecordType = IPA --> Informal Payment Arrangement
                if(et.developername == IPA_SecuredDebt)                    
                    mapEmailTemplate.put('IPA_SecuredDebt', et.id);
                if(et.developername == IPA_UnsecuredDebt)
                    mapEmailTemplate.put('IPA_UnsecuredDebt', et.id);
                if(et.developername == IPA_NotToBePaidDebt)
                    mapEmailTemplate.put('IPA_NotToBePaidDebt', et.id);
                
                //Opportunity RecordType = TDP --> Temporary Debt Protection 
                if(et.developername == TDP_SecuredDebt)                    
                    mapEmailTemplate.put('TDP_SecuredDebt', et.id);
                if(et.developername == TDP_UnsecuredDebt)
                    mapEmailTemplate.put('TDP_UnsecuredDebt', et.id);
                if(et.developername == TDP_NotToBePaidDebt)
                    mapEmailTemplate.put('TDP_NotToBePaidDebt', et.id);
            }       
        } 
        return mapEmailTemplate;
    }
    /* End [3/11/2020]*/
    
        
    //Wrapper Class
    public class WrapperClass{
        public Boolean checked {get;set;}
        public Debt__c debt {get;set;}
        public WrapperClass(Debt__c debt) {
            this.debt = debt;
        }
    }
    
    
}
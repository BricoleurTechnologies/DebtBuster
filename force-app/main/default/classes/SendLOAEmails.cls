public class SendLOAEmails{
    Contact tempContact = new Contact();
    OrgWideEmailAddress[] owea = new OrgWideEmailAddress[]{};
    Opportunity oppDetails; 
    
    //Add SingleEmailMessage
    public Messaging.SingleEmailMessage SendEmails(String[] arrayEmail,Id creditoraccountId,Id template_id,Id recordId){
        
        oppDetails = [Select Name,Owner.Email,Owner.Name, Account.PersonContact.Id FRom Opportunity where id =:recordID];
        String attachName = DB_Setting__c.getValues('Attachment Name').Value__c;
        User theUser = [SELECT Id,email, firstName, lastName FROM User WHERE id =:UserInfo.getUserId()];
        
        //Send Attachment only LOA_HTML
        List<EmailTemplate>  lsttemplateid =  [SELECT id, name,developername  
                           FROM EmailTemplate 
                           WHERE id =:template_id];
        
        system.debug('!!!lsttemplateid= '+lsttemplateid );
               
        String templateLOAName;
        if(lsttemplateid.size()>0){
            templateLOAName = lsttemplateid[0].developername;
        }
        system.debug('!!!templateLOAName ='+templateLOAName );
        
        
        List<Attachment> attachments = [Select id,Name,Body,ContentType from Attachment WHERE ParentId =:
                                        recordID AND Name Like :'%'+attachName +'%'];
        List<Messaging.EmailFileAttachment> email_attachments = new List<Messaging.EmailFileAttachment>();
        for(Attachment att : attachments){
            Messaging.EmailFileAttachment email_att = new Messaging.EmailFileAttachment();
            email_att.setBody(att.Body);
            email_att.setContentType(att.ContentType);
            email_att.setFileName(att.Name);
            email_att.setinline(false);
            email_attachments.add(email_att);
        }        
        //generate email here
        List<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>();
        
        //Org wide email address
        owea = [select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName= 'Creditors @ Debt Busters' LIMIT 1];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setToAddresses(arrayEmail );//list of email addresses
        
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        email.setTreatTargetObjectAsRecipient(false);
        //TargetObjectId is required for email out with Template, current Opportunity's Person Account is used though not the recipient
        email.setTargetObjectId( oppDetails.Account.PersonContact.Id );
        email.setWhatId(recordID);
        email.setTemplateId(template_id);
        email.setSaveAsActivity(true);
        if(templateLOAName !=null && email_attachments.size()>0){
            system.debug('!!!Inside Attachment'+templateLOAName );
            email.setFileAttachments(email_attachments);
        }
        return email;
    }
    
    //Send Email
    public void dispatch(Messaging.SingleEmailMessage[] emailList,Map<Id,Integer> mapEmailMessage,Id dispatchTemplateId,Id recordID){
        
        system.debug('!!!emailList before sending'+emailList);
        Messaging.sendEmail(emailList);
        system.debug('!!!emailListsent'+emailList);
        emailTodispatch(emailList,mapEmailMessage,dispatchTemplateId,recordID);

        
    }
    
    //Create EmailMessage record for the Creditors
    public void emailTodispatch(Messaging.SingleEmailMessage[] emailList,Map<Id,Integer> mapEmailMessage,Id template_id,Id recId){
    //List of Email messages to insert
    List<EmailMessage> lstem = new List<EmailMessage>();
    
    //Return Keyset of Ids
    Set<Id> s = mapEmailMessage.keySet();
        system.debug('@@@@ s'+s);
    Integer i = 0;
    
        if(emailList.size()>0){
            for(Id idE : s){
            system.debug('@@@@ idE'+idE);
                if(mapEmailMessage.containsKey(idE)){
                    EmailMessage em = new EmailMessage();
                    em.RelatedToId= idE;
                    em.Related_Opportunity__c = recId;
                    em.subject =emailList[mapEmailMessage.get(idE)].getSubject();
                    em.MessageDate =DateTime.now();
                    em.Status ='3';
                    //em.FromAddress = oppDetails.owner.email;
                    if ( owea.size() > 0 ) {
                        em.FromAddress = owea[0].Address;
                        em.FromName =owea[0].DisplayName;
                    }
                   
                    em.ToAddress =  convertListToString(emailList[mapEmailMessage.get(idE)].getToAddresses());         
                    em.HtmlBody =emailList[mapEmailMessage.get(idE)].getHtmlBody();
                    lstem.add(em);
                    
                }
                i++;
            }//End of For loop
        }
        if(lstem.size()>0){
            insert lstem ;
        }
    }
    
    //Send Email
   public void dispatch1(Messaging.SingleEmailMessage[] emailList,Map<Id,list<Integer>> mapEmailMessage,Id dispatchTemplateId,Id recordID){
        
        system.debug('!!!emailList before sending'+emailList);
        Messaging.sendEmail(emailList);
        system.debug('!!!emailListsent'+emailList);
        emailTodispatch1(emailList,mapEmailMessage,dispatchTemplateId,recordID);

        
    }
    
    //Create EmailMessage record for the Creditors
    public void emailTodispatch1(Messaging.SingleEmailMessage[] emailList,Map<Id,list<Integer>> mapEmailMessage,Id template_id,Id recId){
    //List of Email messages to insert
    List<EmailMessage> lstem = new List<EmailMessage>();
    
    //Return Keyset of Ids
    Set<Id> s = mapEmailMessage.keySet(); 
    Integer i = 0;
    
        if(emailList.size()>0){
            for(Id idE : s){
                            
                if(mapEmailMessage.containsKey(idE)){
                    list<Integer> lstRecCountt = mapEmailMessage.get(idE);
                    Integer j = 0;
                    for(Integer recCount:lstRecCountt){                        
                        EmailMessage em = new EmailMessage();
                        em.RelatedToId= idE;
                        em.Related_Opportunity__c = recId;
                        em.subject =emailList[recCount].getSubject();
                        em.MessageDate =DateTime.now();
                        em.Status ='3';
                        //em.FromAddress = oppDetails.owner.email;
                        if ( owea.size() > 0 ) {
                            em.FromAddress = owea[0].Address;
                            em.FromName =owea[0].DisplayName;
                        }
                       
                        em.ToAddress =  convertListToString(emailList[recCount].getToAddresses());         
                        em.HtmlBody =emailList[recCount].getHtmlBody();
                        system.debug('@@@ em'+em);
                        lstem.add(em);
                        j++;
                    }
                }
                i++;
            }//End of For loop
        }
        if(lstem.size()>0){
            insert lstem ;
        }
    }
    
    //Convert List to String
    private static String convertListToString(list<String> lstStr) {
        String str = '';
        if (lstStr != null) {
            for(String s : lstStr) {
                str += (s + ',');
            }
        }
        str = str.replaceAll(',',';');
        str = str.removeEnd(';');
        return str;
    }
 }
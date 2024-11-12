import { LightningElement, api, wire } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/CreateAndDownloadJson.getRelatedFilesByRecordId';
import {NavigationMixin} from 'lightning/navigation';

export default class filepreviewAndDownloads extends NavigationMixin(LightningElement) {

    @api recordId;
    retrievedRecordId=false;
    retrievedRecord=false;
    hasError=false;
    handleClick(){
        getRelatedFilesByRecordId({ recordId: this.recordId })
        .then((data) => {
            this.retrievedRecord=true
            
        this.filesList = Object.keys(data).map(item=>({"label":data[item],
         "value": item,
         "url":`/sfc/servlet.shepherd/document/download/${item}`
        }))
        console.log(this.filesList)
        })
        .catch((error) => {
            console.log(error)
            this.hasError=true
        });
    }
    renderedCallback(){
        if (!this.retrievedRecordId && this.recordId) {
            
            this.retrievedRecordId = true; // Escape case from recursion
            console.log('Found recordId: ' + this.recordId);
           
            // Execute some function or backend controller call that needs the recordId
        }
    
    }
    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }
}
import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class PopUpLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    
    renderedCallback() {
        if (this.recordId) {
            // Do something with the recordId
            console.log('Record Id:', this.recordId);

            // Construct the pageReference with the recordId
            const pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'opportunity' // Replace with the API name of your object
                },
                // Add other attributes as needed for your use case
            };

            // Use NavigationMixin to generate the URL with recordId
            this[NavigationMixin.GenerateUrl](pageReference).then(url => {
                                const finalUrl = '/apex/SendLOACreditors?id='+ this.recordId; // Add your parameters
                console.log( 'URL is ' + finalUrl );
            let completeURL = window.location.origin + finalUrl;
            let windowFeatures = "menubar=no,resizable=yes,scrollbars=yes";
            windowFeatures  = "width=" + 800;
            windowFeatures += ",height=" + 600;
            console.log( 'Complete URL is ' + completeURL );
            window.open( completeURL, "_blank", windowFeatures );
                // Append additional parameters to the URL if needed

             //   const popupWindow = window.open(finalUrl, 'PopupWindow', 'height=600,width=800,location=yes,menubar=yes,resizable=yes,scrollbars=yes,status=yes,toolbar=yes');

            });
            this.closeQuickAction();
        }
    }
     //Navigate to visualforce page
    navigateToVFPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/SendLOACreditors?id=' + this.recordId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }

}
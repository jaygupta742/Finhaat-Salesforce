import { LightningElement , api} from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';

export default class TicketInProgess extends NavigationMixin(LightningElement) {
    @api recordId;
    userId = USER_ID;

    connectedCallback() {
        console.log('this recordId >> ' + this.recordId);
        this.navigateToViewAccountPage();
    }

    navigateToViewAccountPage() {
        const fields = {};
        fields['Id'] = this.recordId; // Record ID is required
        fields['In_progess__c'] = true; // Set the checkbox to true (checked)
        fields['Ticket_In_Progress_Date_Time__c'] = new Date().toISOString();
        fields['TIcket_User__c'] = this.userId;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Ticket updated to In Progress',
                        variant: 'success',
                    })
                );

                // Redirect to the same record page after the update
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'Ticket__c', // API name of the custom object
                        actionName: 'view'
                    },
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating ticket',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }
}
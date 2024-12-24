//Last Modified by  : Vishal Singh 
//Last Modified Date: 16-07-2024
//Description       : Need to redirect the page on Record page instead of list viw button and page should refresh 
import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import sendCustomNotification from '@salesforce/apex/sendNotificationtosales.sendCustomNotification1'; // Apex method to send notification
import getdeatiils from '@salesforce/apex/sendNotificationtosales.getdetails1';
import createtask from '@salesforce/apex/sendNotificationtosales.createtask';
export default class sendNotificationtosales extends NavigationMixin(LightningElement) {
    @track comment = '';
    @api recordId; // The record ID of the owner to whom the notification will be sent
    @track blocksave = false;
    @track stagevalue = '';
    @track tickets = {};
    @track task;
    @track isModalOpen = false;
    @track salesnotify = true;
    get PriorityOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'High', value: 'High' },
            { label: 'Normal', value: 'Normal' },
            { label: 'Low', value: 'Low' },
        ];
    }

    @track task = {
        Subject: '',
        Description: '',
        Priority: 'Normal',
        ActivityDate: this.getTodayDate(),

    };

    // Method to get today's date in 'dd-mm-yyyy' format
    getTodayDate() {
        const today = new Date();
        const day = String(today.getUTCDate()).padStart(2, '0');
        const month = String(today.getUTCMonth() + 1).padStart(2, '0'); // January is 0!
        const year = today.getUTCFullYear();

        return `${year}-${month}-${day}`;

    }
    handletaskvalue(event) {
        const field = event.target.label; // Get the label of the field that triggered the event
        const value = event.target.value; // Get the value of the field

        // Update the task object based on the field label
        if (field == 'Subject') {
            this.task.Subject = value;
        } else if (field == 'Comment') {
            this.task.Description = value;
        } else if (field == 'Priority') {
            this.task.Priority = value;
        } else if (field == 'Due Date') {
            this.task.ActivityDate = value;
        }
        //  console.log('the task '+JSON.stringify(this.task));
    }

    @wire(getdeatiils, { recordId: '$recordId' })
    async getdt(response) {
        refreshApex(response)
        let data = response.data;
        let error = response.error;
        if (data) {
            this.tickets = data;

        }
        if (error) {
            alert('error fetching details ' + error.body.message)
        }
    }

    handleCommentChange(event) {
        this.comment = event.target.value;
    }

    handleCancel() {
        this.cancle();
        // Close the modal or clear the comment
        this.comment = '';
    }

    get options() {
        return [
            { label: 'Update Stage As Quotation Sent', value: 'Quotation' },
            { label: 'Update Stage As Payment Link Sent', value: 'Payment Link Sent' },
            { label: 'Update Stage As Policy Issued', value: 'Policy Issued' },
            { label: 'Update Stage As Lost', value: 'Hold' },
            { label: 'Notify Somthing To Sales', value: 'sales' },
        ];
    }

    handleChange(event) {
        this.stagevalue = event.detail.value;
        if (this.stagevalue == 'Quotation') this.comment = 'I have sent the quotation to ' + this.tickets.Account__r.Name; this.salesnotify = false;
        if (this.stagevalue == 'Payment Link Sent') this.comment = 'I have updated the payment link and also sent to ' + this.tickets.Account__r.Name; this.salesnotify = false;
        if (this.stagevalue == 'Policy Issued') this.comment = 'I have shared policy with ' + this.tickets.Account__r.Name; this.salesnotify = false;
        if (this.stagevalue == 'Hold') this.comment = 'This stage is Lost.'
        if (this.stagevalue == 'sales') this.salesnotify = true;
    }

    handleSend() {
        if (this.salesnotify == false) {
            if (this.comment.trim() == '') {
                const e = new ShowToastEvent({
                    title: 'Error!',
                    message: 'Kindly enter the comment',
                    variant: 'error',
                });
                this.dispatchEvent(e);
                return;
            }
            if (this.stagevalue == '' && this.isModalOpen == false) {
                this.isModalOpen = true;
                return;
            }
            this.blocksave = true;
            sendCustomNotification({ recordId: this.recordId, comment: this.comment, stage: this.stagevalue })
                .then((result) => {
                    console.log('result ' + result);

                    const e = new ShowToastEvent({
                        title: 'Success!',
                        message: ' Notification send Successfully...!!!',
                        variant: 'success',
                    });
                    this.dispatchEvent(e);


                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            actionName: 'view'
                        },
                    });

                    //window.location.href = `/lightning/r/Ticket__c/${this.recordId}/view`;


                    // Refresh the page after navigation
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);

                })
                .catch(error => {
                    this.blocksave = false;
                    alert('Error sending notification:' + error.body.message);
                });
        }
        if (this.salesnotify == true) {
            //alert('true')
            if (this.task.Subject.trim() == '' || this.task.Priority.trim() == '') {
                alert('Please Select all Mandetory Field.');
                return;
            }
            // alert('this task '+JSON.stringify(this.task))
            createtask({ recordId: this.recordId, taskobject: this.task })
                .then((result) => {
                    console.log('result ' + result);

                    const e = new ShowToastEvent({
                        title: 'Success!',
                        message: ' Task Created Successfully!!!',
                        variant: 'success',
                    });
                    this.dispatchEvent(e);
                    this.cancle();
                })
                .catch(error => {
                    // this.blocksave = false;
                    alert('Error sending notification:');
                });
        }


    }

    cancle() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }

    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
    }

    handleOk() {
        this.handleSend();
    }

}
//Last modified by : vishal singh, On 12-06-2024, to show the create date with tickets in combo box... 
import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getDocumentsForOpportunity from '@salesforce/apex/ticket_Attachments.getDocumentsForOpportunity';
import getTicket from '@salesforce/apex/ticket_Attachments.getAllTickets';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ticketAttach from '@salesforce/apex/ticket_Attachments.attachToTicket';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import LightningAlert from 'lightning/alert';

export default class TicketAttachments extends NavigationMixin(LightningElement) {
    @track cols = [
        {
            fieldName: '',
            label: 'Type',
            cellAttributes: { iconName: { fieldName: 'dynamicIcon' } }
        },
        {
            fieldName: 'Name',
            label: 'Name'
        }
    ];
    @track selectedTicketId;
    @track contactOptions = [];
    @track contentVersions = [];
    @track contactValue = '';
    @track conversion = [];
    @track selectedRecordIds = [];
    @track accId;
    @track showButton = false;
    @track ticketArr = [];
    @track requirementDetail;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.accId = currentPageReference.state.recordId;
        }
    }

    wireServiceResponse;

    @wire(getDocumentsForOpportunity, { AccountId: '$accId' })
    wiredContentVersions(response) {
        refreshApex(response);
        console.log("Response is" + response);
        this.wireServiceResponse = response;
        let data = response.data;
        let error = response.error;
        if (data) {
            refreshApex(data);
            this.conversion = data.map(con => ({
                Id: con.Id,
                contId: con.ContentDocumentId,
                FileName: con.Title,
                Type: this.getFileIcon(con.FileType),
                CreatedBy: con.CreatedBy.Name,
                LastModified: this.formatDateTime(con.LastModifiedDate)
            }));
        }
        else if (error) {
            console.log(error);
        }
    }

    @wire(getTicket, { accountId: '$accId' })
    wiredContacts(response) {
        refreshApex(response);
        console.log("Response is" + response);
        this.wireServiceResponse = response;
        let datas = response.data;
        let errors = response.error;
        if (datas) {
            this.contactOptions = datas.map(contact => {
                //return { label: contact.Name, value: contact.Id };
                return {
                    label: `${contact.Name} (Created on: ${new Date(contact.CreatedDate).toLocaleDateString()})`,
                    value: contact.Id
                }
            });
            this.ticketArr = datas;
            //alert(JSON.stringify(this.ticketArr));
            this.error = undefined;
        } else if (errors) {
            this.error = errors;
            this.contactOptions = [];
        }
    }

    handleRowSelection(event) {
        const selectedRows = event.target.dataset.id;
        if (event.target.checked && !this.selectedRecordIds.includes(selectedRows)) {
            this.selectedRecordIds = [...this.selectedRecordIds, selectedRows];
        } else if (!event.target.checked) {
            this.selectedRecordIds = this.selectedRecordIds.filter(id => id !== selectedRows);
        }
        console.log(this.selectedRecordIds);
    }

    getFileIcon(fileType) {
        const fileTypeIcons = {
            'JPEG': 'doctype:image',
            'JPG': 'doctype:image',
            'PNG': 'doctype:image',
            'PDF': 'doctype:pdf',
            'WORD': 'doctype:word',
            'vnd.openxmlformats-officedocument.wordprocessingml.document': 'doctype:word',
            'EXCEL': 'doctype:excel',
            'EXCEL_X': 'doctype:excel',
            'XLS': 'doctype:excel',
            'XLSX': 'doctype:excel',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'doctype:excel',
            'POWER_POINT_X': 'doctype:ppt',
            'vnd.openxmlformats-officedocument.presentationml.presentation': 'doctype:ppt',
            'TEXT': 'doctype:txt',
        };

        return fileTypeIcons[fileType] || 'doctype:attachment';
    }

    handleContactChange(event) {
        this.contactValue = event.detail.value;
        let tktId = event.detail.value;
        this.ticketArr.forEach(item => {
            if (tktId === item.Id) {
                this.requirementDetail = item.text__c
            }
        })
        //alert(this.requirementDetail);
    }

    async handleClick() {
        this.showButton = true;

        if (this.contactValue == null || this.contactValue == '' || this.contactValue == undefined) {
            await this.handleAlertClick('Please select a ticked and then click Save', 'error', 'Ticket Not Selected!!');
            this.showButton = false;
            return;
        }else if(this.selectedRecordIds.length == 0){
            await this.handleAlertClick('Please select an attchment and then click Save', 'error', 'Ticket Not Selected!!');
            this.showButton = false;
            return;
        }


        ticketAttach({ accountId: this.accId, ticketId: this.contactValue, selectAttachmentId: this.selectedRecordIds }).
            then(result => {
                this.showtoast();
                this.dispatchEvent(new CloseActionScreenEvent());
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.accId,
                        actionName: 'view',
                        objectApiName: 'Account'
                    }
                });
            }).catch(erro => {

            });
    }

    showtoast() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!!',
            message: 'Attachments Saved to Ticket.',
            variant: 'success',
            mode: 'dismissable'
        }))
    }

    formatDateTime(isoDateTime) {
        const utcTime = new Date(isoDateTime);
        const istTime = new Date(utcTime.getTime() + (5.5 * 60 * 60 * 1000));
        const optionsDate = {
            year: "numeric",
            month: "2-digit",
            day: "2-digit"
        };
        const optionsTime = {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: true,
            timeZone: "UTC"
        };
        const formattedDate = istTime.toLocaleDateString("en-US", optionsDate);
        const formattedTime = istTime.toLocaleTimeString("en-US", optionsTime);

        return `${formattedDate} ${formattedTime}`;
    }

    async handleAlertClick(message, theme, label) {
        await LightningAlert.open({
            message: message,
            theme: theme,
            label: label,
        });
    }

    cancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accId,
                actionName: 'view',
                objectApiName: 'Account'
            }
        });

    }
    previewHandler(event) {
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }
}
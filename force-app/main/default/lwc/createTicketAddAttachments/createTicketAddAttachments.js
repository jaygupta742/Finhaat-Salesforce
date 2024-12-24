import { LightningElement, track, api, wire } from 'lwc';
import LightningAlert from 'lightning/alert';
import { CurrentPageReference } from 'lightning/navigation';
import getDocumentsForOpportunity from '@salesforce/apex/ticket_Attachments.getDocumentsForOpportunity';
import getTicket from '@salesforce/apex/ticket_Attachments.getAllTickets';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ticketAttach from '@salesforce/apex/ticket_Attachments.attachToTicket';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import createTicket from '@salesforce/apex/ticket_Attachments.createTicket';
export default class CreateTicketAddAttachments extends NavigationMixin(LightningElement) {
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
    @track ticketData = {};

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.accId = currentPageReference.state.recordId;
            this.ticketData.Account__c = this.accId;
            this.ticketData.Stage__c = 'Ticket Raised';
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
                contId : con.ContentDocumentId,
                FileName: con.Title,
                Type: this.getFileIcon(con.FileType),
                CreatedBy : con.CreatedBy.Name,
                LastModified : this.formatDateTime(con.LastModifiedDate)
            }));     
        }
        else if(error){
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
                return {label: `${contact.Name} (Created on: ${new Date(contact.CreatedDate).toLocaleDateString()})`, 
                        value: contact.Id}
            });
            this.error = undefined;
        } else if (errors) {
            this.error = errors;
            this.contactOptions = [];
        }
    }
    handleTicketChange(event){
        let fieldName = event.target.fieldName;
        let value = event.target.value;
        if(fieldName == 'Stage__c'){
            this.ticketData.Stage__c = value;
        }
        if(fieldName == 'text__c'){
            this.ticketData.text__c = value;
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
    }
    @track ticketId;
    handleClick(){
        if (this.ticketData.text__c == '' || this.ticketData.text__c == null || this.ticketData.text__c == undefined) {
            console.log('inside 1---->'+this.ticketData.text__c);
            this.showAlert("Ticket Requirement Can't be Empty..!!", 'error', 'Error!', () => {
                return;
            });
            return;
        }
        createTicket({ticket : this.ticketData})
        .then(result =>{
            console.log('ticket id >> '+result);
            this.ticketId = result;
            ticketAttach({accountId : this.accId, ticketId : result,  selectAttachmentId : this.selectedRecordIds}).
        then(result=>{
            this.showtoast();
            this.dispatchEvent(new CloseActionScreenEvent());
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.ticketId,
                    actionName: 'view',
                    objectApiName : 'Ticket__c'
                }
            });
        }).catch(erro=>{

        });
        })
        .catch(error =>{
            console.log('error >> '+error);
        })
        this.showButton = true;
        
    }
    async showAlert(message, theme, label, ff) {
        await LightningAlert.open({
            message: message,
            theme: theme,
            label: label,
        });
        console.log('Alert has been closed');
        ff();
    }


    showtoast(){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!!',
            message: 'A New Ticket is Created.',
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

    cancel(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accId,
                actionName: 'view',
                objectApiName : 'Account'
            }
        });
    
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
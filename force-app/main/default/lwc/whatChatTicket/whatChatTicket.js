import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

import getChats from '@salesforce/apex/TicketWhatsAppChatController.getChats';
import getTemplates from '@salesforce/apex/TicketWhatsAppChatController.getTemplates';
import sendTemplate from '@salesforce/apex/TicketWhatsAppChatController.SendTemplate';
import sendMessage from '@salesforce/apex/TicketWhatsAppChatController.sendMessage';
import sendMessageWithAttchments from '@salesforce/apex/TicketWhatsAppChatController.sendMessageWithAttchments';
import getDate from  '@salesforce/apex/TicketWhatsAppChatController.dateSend';
import UploadFiles from '@salesforce/apex/TicketWhatsAppChatController.UploadFiles';import get_details from '@salesforce/apex/TicketWhatsAppChatController.tempwap';

export default class WhatChatTicket extends NavigationMixin(LightningElement) {
     @api recordId;
    @track ChatMeta;
    @track lstWAMessages = [];
    @track isMenuVisible = false;
    _Wire_GetChat; 
    _Wire_GetTemplate; 
    ChannelName = '/event/Inbound_WhatsApp__e';
    ChannelChannelSubscription;
    @track showMessage = '';
    @track TemplateMeta;
    @track lstWATemplates = [];
    @track SelectedTemplate;
    @track PreviewTemplates = false;
    @track doubleClickMessage = false;
    @track refreshTime ;
    @track FileUploadMeta;
    @track message = null;
    @track emailTemplateList = [];
    @track SendMessage_status = false;
    @track SendMessage_Spinner_status = false;
    @track messageTime = '';
    @track cssStyle = '';
    @track sname = '';
    @track headerColor = '';
    @track flagcheck = '';
    @track emailTemplate = false;
    @track contStyle = '';

    @wire(getChats, {contactId : '$recordId'})
    async onCallback_GetChats(response) {
        this._Wire_GetChat = response;
        let data = response.data;
        let error = response.error;
        if(data) {
            let rval = JSON.parse(data);
            this.ChatMeta = rval;
            this.lstWAMessages = rval.chats;
        }
        if(error) {
            console.error("Error fetching chat data", error);
        }
    }


    @wire(get_details, { recordId: '$recordId' })
    onCallBack_getdetails(response) {
        this._Wire_GetTemplate = response
        this.showSpinner = false; 
        let data = response.data;
        let error = response.error;
        if(data) {
            this.emailTemplateList = data;
        } else if (error) {
            let errorMSG = error.body.message;
            this.handleAlertClick(errorMSG, 'error', 'Error!', () => {});
        }
    }

    async connectedCallback() {
        this.HandleGetTemplates();

        this.TemplateMeta = {
            spinner_flag: false,
        };

        this.FileUploadMeta = {
            AcceptedFormats : ['.pdf', '.png', '.jpg', '.jpeg'],
            Max_FileSize: 3145728,
            Files: [],
        };

        onError(error => {
            console.error('EMP API error: ', JSON.stringify(error));
        });

        this.subscribeToEvent();
    }

    renderedCallback() {
        const containerElement = this.template.querySelector('.Chat-Container');
        if (containerElement) {
            containerElement.scrollTop = containerElement.scrollHeight;
        }
    }

    disconnectedCallback() {
        // Unsubscribe when the component is disconnected or destroyed
        this.unsubscribeFromEvent();
    }

    handleMessage(event) {
        this.message = event.target.value;
        this.SendMessage_status = this.message || this.FileUploadMeta.Files.length > 0 ? true : false;
    }

    HandleClickMenu() {
        this.isMenuVisible = !this.isMenuVisible;
    }

    HandleClickMenuItem(event) {
        let eventname = event.target.dataset.event;
        switch (eventname) {
            case 'add-attachments':
                this.attachment = true;
                this.PreviewTemplates = false;
                const fileinput =  this.template.querySelector('input[type="file"]');
                fileinput.click();
                break;
            case 'add-template': 
                this.attachment = false;
                this.PreviewTemplates = true;
                this.isMenuVisible = false;
                break;
            default:
                break;
        }
    }

    HandleGetTemplates() {
        getTemplates().then(response => {
            this.lstWATemplates = response;
        }) .catch(error => {
            console.log(error);
        });
    }

    HandleFileChange(event) {
        const selectedFiles = event.target.files;
        let files = Array.from(selectedFiles);

        for(let item of files) {
            console.log(item.size);
            if(item.size > this.FileUploadMeta.Max_FileSize) {
                item.has_error = true;
                item.error_message = `File size ${(item.size / (1024 * 1024)).toFixed(2)} exceeds the maximum allowed limit. Maximum: 3 mb. File will not send.`;
            }
        }

        this.FileUploadMeta.Files = this.FileUploadMeta.Files.concat(files);
        this.isMenuVisible = false;
        this.SendMessage_status = this.message || this.FileUploadMeta.Files.length > 0 ? true : false;
    }

    HandleRemoveFiles(event) {
        const index = parseInt(event.target.dataset.index);
        this.FileUploadMeta.Files.splice(index, 1);
        this.SendMessage_status = this.message || this.FileUploadMeta.Files.length > 0 ? true : false;
    }

    // Method run to close the Template Preview Page
    HandleCancelInsertTemplate() {
        this.PreviewTemplates = false;
        this.message = null;
    }

    HandleSelectTemplate(event) {
        let templateId = event.detail.name;
        let template = this.lstWATemplates.filter(item => {
            return item.Id === templateId;
        });

        if (template.length > 0) {
            this.SelectedTemplate = template[0];
            this.message = template[0].Text__c;
        }
    }

    async HandleSendTemplate() {
        if(!this.SelectedTemplate) {
            alert('Please select one template before send.');
            return;
        }

        this.TemplateMeta.spinner_flag = true;
        await sendTemplate({
            TemplateId: this.SelectedTemplate.Id,
            ContactId: this.recordId,
            Message: this.message
        }) .then(response => {
            console.log(response);
        }) .catch(error => {
            console.log(error);
        });

        this.TemplateMeta.spinner_flag = false;
        this.PreviewTemplates = false;
        this.message = null;
        refreshApex(this._Wire_GetChat);
    }

    async captionAttachment(){

    }

    async HandleSendMessage() {       

        if(this.flagcheck == 'red'){
            let shortMessage = this.message
            this.message = 'Your Comment was : ' + this.showMessage + ' on ' + this.messageTime +  '\n\nMy Reply : ' + shortMessage;
        }
        else if(this.flagcheck == 'green'  && this.doubleClickMessage == true){
            
            let shortMessage = this.message;
            let text = this.showMessage;
            
            let firstOccurrence = text.indexOf('My Reply');
            console.log('Message in firstOccurrence >> ' + firstOccurrence);
            if(firstOccurrence !== -1){
                let secondOccurrence = text.indexOf('My Reply', firstOccurrence + 1);
                if (secondOccurrence !== -1) {
                    text = text.substring(secondOccurrence + 'My Reply'.length).trim();
                    text = text.replace(':', '');
                } else {
                    text = text.substring(firstOccurrence + 'My Reply'.length).trim();
                    text = text.replace(':', '');
                }
            }
            this.message = 'My Msg was : ' + text + ' on ' + this.messageTime + '\n\nMy Reply : ' + shortMessage;
        
        }
        this.SendMessage_Spinner_status = true;
        
        this.SendMessage_status = false;
            if(this.FileUploadMeta.Files.length > 0) {
                for(let item of this.FileUploadMeta.Files) {
                    await this.ReadFile(item)
                    .then(async response => {
                        await this.FileUpload_Handler(item.name, response) 
                        .then(response => {
                            console.log(`return id : ${response}`);
                            item.documentId = response;
                        }) .catch(error => {
                            console.error('on file upload : ' + error);
                        });
                    }) .catch(error => {
                        console.error('on file read : ' + error);
                    });
                }

                let DocumentIds = [];
                for(let item of this.FileUploadMeta.Files) {
                    if(item.documentId) DocumentIds.push(item.documentId);
                }
                await this.SendMessage_WithAttachments(DocumentIds);
            } else {
                await this.SendMessage_Helper();
            }
        this.SendMessage_Spinner_status = false;
        this.FileUploadMeta.Files = [];
        this.doubleClickMessage = false;
        this.message = null;
        refreshApex(this._Wire_GetChat);
    }

    async ReadFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
    
            reader.onload = () => {
                resolve(reader.result.split(',')[1]);
            };
            reader.onerror = (error) => {
                reject(error);
            };
    
            reader.readAsDataURL(file);
        });
    }

    async SendMessage_Helper() {
        this.SendMessage_status = false;
        this.SendMessage_Spinner_status = true;
        await sendMessage({
            message: this.message,
            contactId: this.recordId, buttonClicked : this.doubleClickMessage
        }) .then(success => {
            console.log(success);
        }) .catch(error => {
            console.log(error);
        });
        this.message = '';
        if(this.emailTemplate == true){
            this.cancle();
        }
        this.message = null;
        refreshApex(this._Wire_GetChat);
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
    
    async SendMessage_WithAttachments(DocumentIds) {
        console.log('Send Message with Attachment running');
        return new Promise((resolve, reject) => {
            sendMessageWithAttchments({
                Message: this.message,
                contactId: this.recordId,
                lstDocumentId: DocumentIds
            }) .then(response => {
                console.log(`Send Message with Attachment response : ${response}`);
                resolve(response);
                refreshApex(this._Wire_GetChat);
                this.SendMessage_status = true;
            }) .catch(error => {
                reject(error);
            });
        });
    }

    async FileUpload_Handler(FileName, FileContent) {
        console.log('File Upload Handler running');
        return new Promise((resolve, reject) => {
            UploadFiles({
                FileContent: FileContent,
                FileName: FileName
            }) .then(response => {
                console.log(response);
                resolve(response);
            }) .catch(error => {
                console.log(error.body.message);
                reject(error);
            });
        });
    }

    HandlePreviewAttachment(event) {
        const documetId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: documetId
            }
        });
    }

    previewHandler(event){
        const documetId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: documetId
            }
        });
    }

    subscribeToEvent() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            // Handle the incoming message
            const payload = response.data.payload;
            console.log('Received new chat message: ', payload.MessageId__c);
            refreshApex(this._Wire_GetChat);
            console.log('Apex refresh');
            // Update your UI with the new message
        };

        // Subscribe to the platform event
        subscribe(this.ChannelName, -1, messageCallback)
        .then(response => {
            this.ChannelSubscription = response;
            console.log('Subscribed to channel:', this.ChannelName);
        }) .catch(error => {
            console.error('Error subscribing to channel:', this.ChannelName, JSON.stringify(error));
        });
    }

    unsubscribeFromEvent() {
        if (this.ChannelSubscription) {
            unsubscribe(this.ChannelSubscription, response => {
                console.log('Unsubscribed from channel:', this.ChannelName);
            });
        }
    }

 
    
    async handleClickReplyMessage(event){
        this.cssStyle = "width:90%;border-left: 5px solid #f6688f;"
        this.headerColor = "color:#f6688f";
         const documetId = event.target.dataset.id;
         const sename = event.target.dataset.name;
         let lstmessage = event.target.dataset.message
         console.log('Message Id >> ' + documetId);
         this.showMessage = lstmessage;
         this.sname = sename;
         this.doubleClickMessage = true;
         this.flagcheck = 'red';
        this.messageDateTime(documetId);
        
    }

    handleClose(event){
         this.doubleClickMessage = false;
    }

    handleGreenclick(event){
        this.cssStyle = "width:90%;border-left: 5px solid #25D366;"
        this.headerColor = "color:#25D366";
        const documetId = event.target.dataset.id;
         const sename = event.target.dataset.name;
         const lstmessage = event.target.dataset.message
         console.log('Message Last >> ' + lstmessage);
         this.showMessage = lstmessage;
         this.sname = sename;
         this.doubleClickMessage = true;
         this.flagcheck = 'green';
         this.messageDateTime(documetId);
         this.handleButtonClick();
    }

    @track templateValue = '';
    @track txtareaStyle = '';
    onSelectEmailTemplate(event) {
        let value = event.target.value;
        this.templateValue = value;
        let tempaltebody = '';
        for (let item of this.emailTemplateList) {
            if (item.Name == value) {
                tempaltebody = item.Text__c;
            }
        }
        this.message = tempaltebody;
        this.SendMessage_status =  true ;
        this.emailTemplate = true;
        if(value !== ''){
            this.contStyle = 'height: 250px;';
            this.txtareaStyle = ' --sds-c-textarea-sizing-min-height:200px;';
        }
        else{
            this.contStyle = 'height: 350px;';
            this.txtareaStyle = ' --sds-c-textarea-sizing-min-height:50px;';
        }
        
    }

    async messageDateTime(documetId){
        await getDate({
            recordId : documetId
         }) .then(success => {
             this.messageTime = this.formatDate(success);
         }) .catch(error => {
             console.log(error);
         });
    }

    handleButtonClick() {
        const selectElement = this.template.querySelector('#select-Template');
        selectElement.value = '';
    }

    formatDate(dateString) {
        const date = new Date(dateString);
        const istOffset = 5.5 * 60 * 60 * 1000; 
        const istDate = new Date(date.getTime() + istOffset);
        const day = istDate.getUTCDate();
        const month = istDate.getUTCMonth() + 1; 
        const year = istDate.getUTCFullYear();
        let hours = istDate.getUTCHours();
        const minutes = istDate.getUTCMinutes().toString().padStart(2, '0');
        const ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12; 
        const formattedDate = `${day}/${month}/${year}, ${hours}:${minutes} ${ampm}`;
    
        return formattedDate;
    }


    refreshComponent() {
        refreshApex(this._Wire_GetChat);
        refreshApex(this._Wire_GetTemplate);
        this.getCurrentISTTime();
        this.cancle();
    }

    getCurrentISTTime() {
        const now = new Date();

        // Convert to IST (UTC+5:30)
        const istOffset = 5.5 * 60 * 60 * 1000; // IST is UTC + 5:30
        const istTime = new Date(now.getTime() + istOffset);

        const options = { hour: '2-digit', minute: '2-digit', hour12: true };
        const timeString = istTime.toLocaleTimeString('en-IN', options);

        this.refreshTime = timeString;
    }
    
}
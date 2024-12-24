import { LightningElement, api, track, wire } from 'lwc';
import LightningAlert from 'lightning/alert';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import get_details from '@salesforce/apex/SendDocSampleEmailApex.getStudentEmail';
import DeleteAttachments from '@salesforce/apex/SendDocSampleEmailApex.DeleteAttachments';
import sendEmail from '@salesforce/apex/SendDocSampleEmailApex.sendEmailmethod';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class SendLinktoUpdate extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showSpinner;
    @track pageName;
    @track EmailBody;
    @track Subject;
   // @track iframeUrl;
    @api lstRecipients = [];
    @track lstAdditionRecipients = [];
    @track lstCCAddress = [];
    @track lstBCCAddress = [];
    @track emailAddress;
    @track ccAddress;
    @track bccAddress;
    @track attachments = [];
    @track enableCC;
    @track enableBCC;
    @track lstAttachments = [];
    @track _lstAttachments_master = [];
    @track attachments = [];
    @track btnDisable = false;
    @track showdisconeted = false;
    @track isBodyChanged = false;

    _WireResponseEmailTemplate;
    @wire(get_details, { recId: '$recordId' })
    onCallBack_getdetails(response) {
        this.lstCCAddress = [];
        this.lstAdditionRecipients = [];
        refreshApex(response);
        this._WireResponseEmailTemplate = response;
        let data = response.data;
        let error = response.error;
        if (data) {
            let rval = JSON.parse(data);
          //  console.log('data'+JSON.stringify(data));
            this.EmailBody = rval.body;
            this.Subject = rval.subject;

            if (rval.email != '') {
                this.lstAdditionRecipients.push({
                    emailId: rval.email
                });
            }

            

            if(rval.ccmail != ''){
                this.lstCCAddress.push({
                    emailId: rval.ccmail
                });
            }

            


        } else if (error) {
            let errorMSG = error.body.message;
            console.log('error');
            console.log(JSON.stringify(error));

        }
    }
    connectedCallback() {

        this.pageName = 'Sending Email ';
        this.emailAddress = '';
        this.enableCC = false;
        this.enableBCC = false;
        this.ccAddress = '';
        this.bccAddress = '';
        // alert('inside component ')
    }
    disconnectedCallback() {
        if (this.showdisconeted == true) {
            // console.log("Unmount Send Email");
            let lstDocuments = this._lstAttachments_master.map(item => {
                return String(item.documentId);
            });

            if (lstDocuments.length > 0) {
                DeleteAttachments({
                    lstDocumentId: lstDocuments
                }).then(response => {
                   // console.log(response);
                }).catch(error => {
                    console.log(error);
                });
            }
        }

    }
    handleOnChangeAddress(event) {
        let fieldName = event.target.name;
        let value = event.target.value;
        if (fieldName === 'recipient') this.emailAddress = value;
        if (fieldName === 'cc') this.ccAddress = value;
        if (fieldName === 'bcc') this.bccAddress = value;
        if (fieldName === 'subject') this.Subject = value;
        if (fieldName === 'body') {
            this.EmailBody = value;
            this.isBodyChanged = true;
        }

    }
    handleKeyDown(event) {

        if (event.key === 'Enter') {
            const emailValue = event.target.value;
            const fieldName = event.target.name;
            //  alert('emailValue.fieldName'+fieldName+ '  '+emailValue);
            if (emailValue) {
                // alert('inside email value '+emailValue);
                if (fieldName === 'recipient') {
                    this.lstAdditionRecipients.push({
                        emailId: emailValue,
                        recordId: null
                    });
                    this.emailAddress = '';
                }
                if (fieldName === 'cc') {
                    //this.lstCCAddress.push(emailValue);
                    this.lstCCAddress.push({
                        emailId: emailValue,
                        recordId: null
                    });
                    this.ccAddress = '';
                }
                if (fieldName === 'bcc') {
                    this.lstBCCAddress.push(emailValue);
                    this.bccAddress = '';
                }
            }
        }
    }
    handleCCClick() {
        this.enableCC = true;
    }

    handleBCCClick() {
        this.enableBCC = true;
    }
    removePill(event) {
        const index = event.target.dataset.index;
        const name = event.target.dataset.name;
        if (name === 'recipients') {
            this.lstRecipients = [];
        }
        if (name === 'addtional recipients') {
            if (index !== undefined) {
                this.lstAdditionRecipients.splice(index, 1);
                this.lstAdditionRecipients = [...this.lstAdditionRecipients];
            }
        }
        if (name === 'cc') {
            if (index !== undefined) {
                this.lstCCAddress.splice(index, 1);
                this.lstCCAddress = [...this.lstCCAddress];
            }
        }
        if (name === 'bcc') {
            if (index !== undefined) {
                this.lstBCCAddress.splice(index, 1);
                this.lstBCCAddress = [...this.lstBCCAddress];
            }
        }
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        //  console.log('inside get uploadedFiles ' + uploadedFiles);
        if (uploadedFiles.length > 0) {
            this.lstAttachments = this.lstAttachments.concat(uploadedFiles);
            this._lstAttachments_master = this._lstAttachments_master.concat(uploadedFiles);
        }


        //   console.log('inside get attachments')
        let files = this._lstAttachments_master.map(item => {
            let filetype = this.getFileTypeFromName(item.name);
            return {
                name: item.name,
                type: filetype,
                iconName: this.getFileIconName(filetype)
            };
        });

        this.attachments = files;

        // console.log('inside get this.attachments  ' + this.attachments);
    }
    handleRemoveAttachment(event) {
        const attachmentIndex = event.target.dataset.attachmentIndex;
        let removedAttachmentId = null;
        if (attachmentIndex !== undefined) {
            removedAttachmentId = this._lstAttachments_master[attachmentIndex].documentId;
            // this._lstAttachments_master.splice(attachmentIndex, 1);
            // this._lstAttachments_master = [...this._lstAttachments_master];
            // console.log('_lstAttachments_master'+JSON.stringify(this._lstAttachments_master));
            let lstDocuments = [removedAttachmentId];
            // console.log('lstDocuments'+JSON.stringify(lstDocuments));
            this._lstAttachments_master.splice(attachmentIndex, 1);
            this._lstAttachments_master = [...this._lstAttachments_master];
            // console.log('_lstAttachments_master'+JSON.stringify(this._lstAttachments_master));
            if (lstDocuments.length > 0) {
                DeleteAttachments({
                    lstDocumentId: lstDocuments
                }).then(response => {
                    // console.log(response);
                    //  console.log('delete');
                    // After successful deletion, remove the attachment from _lstAttachments_master

                }).catch(error => {
                    console.log(error);
                });
            }
            // console.log('_lstAttachments_master1'+JSON.stringify(this._lstAttachments_master));

        }
        let files = this._lstAttachments_master.map(item => {
            let filetype = this.getFileTypeFromName(item.name);
            return {
                name: item.name,
                type: filetype,
                iconName: this.getFileIconName(filetype)
            };
        });

        this.attachments = files;


        // alert('this._lstAttachments_master sizecheck '+this._lstAttachments_master.length);

    }
    getFileIconName(fileType) {
        const iconMapping = {
            pdf: 'doctype:pdf',
            xlsx: 'doctype:excel',
            excel: 'doctype:excel',
            png: 'doctype:image',
            jpg: 'doctype:image',
            jpeg: 'doctype:image',
            csv: 'doctype:csv',
            mp3: 'doctype:audio',
            html: 'doctype:html',
            mp4: 'doctype:mp4',
            ppt: 'doctype:ppt',
            txt: 'doctype:txt',
            docx: 'doctype:word',
            zip: 'doctype:zip',
            xml: 'doctype:xml',
        };
        return iconMapping[fileType] || 'doctype:unknown';
    }
    getFileTypeFromName(fileName) {
        const fileParts = fileName.split('.');
        if (fileParts.length > 1) {
            return fileParts[fileParts.length - 1].toLowerCase();
        }
        return 'unknown';
    }
    navigateToRecord() {
        this.showdisconeted = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view',
            },
        });
    }
    async handleAlertClick(message, theme, label, ff) {
        await LightningAlert.open({
            message: message,
            theme: theme,
            label: label,
        });
        ff();
    }

    handleSendEmail(showToast = true) {
        this.btnDisable = true;
        // alert('this._lstAttachments_master sizecheck '+this._lstAttachments_master.length);
        let lstDocuments = this._lstAttachments_master.map(item => {
            this.btnDisable = false;
            return String(item.documentId);
        });

        if (this.lstAdditionRecipients.length > 0) this.lstRecipients = this.lstRecipients.concat(this.lstAdditionRecipients);

        if (this.lstAdditionRecipients.length === 0) {
            this.handleAlertClick("Add at least one recipient", "error", "Recipients Error!", () => {
                this.btnDisable = false;
                return;
            });
            return;
        }

        if (!this.Subject) {
            this.handleAlertClick("Subject can not be empty. Please give a subject to the mail.", "error", "Subject Error!", () => {
               this.btnDisable = false;
                return;
            });
            return;
        }

        if (!this.EmailBody) {
            this.handleAlertClick("Email body can not be empty. Please give a body to the mail.", "error", "Email Body Error!", () => {
               this.btnDisable = false;
                return;
            });
            return;
        }

        this.showSpinner = true;
        sendEmail({
            Subject: String(this.Subject),
            EmailBody: String(this.EmailBody),
            recipients: JSON.stringify(this.lstAdditionRecipients),
            ccaddress: JSON.stringify(this.lstCCAddress),
            documentIds: JSON.stringify(lstDocuments),
            recid: String(this.recordId),
            isBodyChanged : this.isBodyChanged
        }).then(response => {    
            if(showToast){        
                this.showToast('Success', 'Email Sent Successfully.', 'success');
            }
            this.navigateToRecord();
            this.showdisconeted = false;
        }).catch(error => {
            let errorMessage = error.body.message;
            
            this.showToast('Error', errorMessage, 'error');
            return;
        })
         .finally(() => {
             this.btnDisable = false;
        });
        this.showSpinner = false;
    }


    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    

}
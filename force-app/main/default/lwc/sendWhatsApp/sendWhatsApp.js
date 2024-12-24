import { LightningElement, api, track, wire } from 'lwc';
import LightningAlert from 'lightning/alert';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import myResource from '@salesforce/resourceUrl/whatsapp';
import { loadStyle } from 'lightning/platformResourceLoader';
import get_details from '@salesforce/apex/Send_WA_In_Account.tempwap';
import on_save from '@salesforce/apex/Send_WA_In_Account.onsave';
import getDocumentSize from '@salesforce/apex/Send_WA_In_Account.getDocumentSize1';
export default class SendWhatsApp extends NavigationMixin(LightningElement) {
    @track attachments = [];
    @api recordId;
    @track emailbody = '';
    @track lstAttachments = [];
    @track _lstAttachments_master = [];
    @track attachments = [];
    @track showSpinner = true;
    @track blocksave = false;
    @track emailTemplateList = []
    whatsappicon = myResource;
    @track documentId = '';
    @track uploadedFileName = 'Not Uploaded';
    acceptedFormats = [
        '.pdf',   // Adobe PDF
        '.doc',   // Microsoft Word document
        '.docx',  // Microsoft Word Open XML document
        '.xls',   // Microsoft Excel spreadsheet
        '.xlsx',  // Microsoft Excel Open XML spreadsheet
        '.ppt',   // Microsoft PowerPoint presentation
        '.pptx',  // Microsoft PowerPoint Open XML presentation
        '.txt',   // Plain text document
        '.rtf',   // Rich Text Format document
        '.csv',   // Comma-separated values file
        '.xml',   // XML document
        '.html',  // HTML document
        '.zip',   // ZIP archive
        '.jpeg',  // JPEG image
        '.jpg',  // JPG image
        '.png',   // PNG image
        '.gif',
        '.ods',
        '.mp3',
        '.mp4',   // GIF image
        '.bmp'    // BMP image
        // Add more document and image file extensions as needed
    ];


    /*@wire(get_details)
    onCallBack_getdetails(response) {
        refreshApex(response);

        let data = response.data;
        let error = response.error;
        if (data) {
            let rval = data;
            this.emailTemplateList = rval;
            this.showSpinner = false;
            // alert('get details ' + rval);
        } else if (error) {
            this.showSpinner = false;
            let errorMSG = error.body.message;
            this.handleAlertClick(errorMSG, 'error', 'Error!', () => {
                return
            });
        }
    }*/

     @wire(get_details, { recordId: '$recordId' })
    onCallBack_getdetails({ error, data }) {
        this.showSpinner = false; // Hide spinner by default when data or error is available
        if (data) {
            this.emailTemplateList = data;
        } else if (error) {
            let errorMSG = error.body.message;
            this.handleAlertClick(errorMSG, 'error', 'Error!', () => {});
        }
    }



    onSelectEmailTemplate(event) {
        let value = event.target.value;
        let tempaltebody = '';
        for (let item of this.emailTemplateList) {
            if (item.Name == value) {
                tempaltebody = item.Text__c;
            }
        }

        this.emailbody = tempaltebody;
    }
    assignemailbody(event) {
        let value = event.target.value;
        this.emailbody = value;
    }


    doSave() {

        if (this.emailbody.trim() == '' && this._lstAttachments_master.length == 0) {
            const e = new ShowToastEvent({
                title: 'Error!',
                message: "Please provide a template body or attachment.",
                variant: 'error',
            });
            this.dispatchEvent(e);
            return
        }

        if (this.emailbody.trim() == '') {
            this.emailbody = 'Hi, We have sent documents kindly review...!!!'
        }
        let lstDocuments = this._lstAttachments_master.map(item => {
            return String(item.documentId);
        });
        this.showSpinner = true;

        on_save({ recordId: this.recordId, text_body: this.emailbody, docid: String(lstDocuments) })
            .then((result) => {

                const e = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Whats App Notification Send Successfully to ' + result + '...!!!',
                    variant: 'success',
                });
                this.dispatchEvent(e);

                this.cancle();
                this.showSpinner = false;
            }).catch((error) => {
                this.showSpinner = false;
                let errorMSG = error.body.message;
                const e = new ShowToastEvent({
                    title: 'Error!',
                    message: errorMSG,
                    variant: 'error',
                });
                this.dispatchEvent(e);
            })
    }
    handleButtonClick(messages, theme, label) {
        const event = new ShowToastEvent({
            title: label,
            message: messages,
            variant: theme,
        });
        this.dispatchEvent(event);
    }

    async handleAlertClick(message, theme, label, ff) {
        await LightningAlert.open({
            message: message,
            theme: theme,
            label: label,
        });
        ff();
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

    /* handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            this.uploadedFileName = uploadedFiles[0].name;
            const fileId = uploadedFiles[0].documentId;
            this.documentId = fileId;
            
        }
        
    
    } */

    /* handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('inside get uploadedFiles '+ uploadedFiles );
        if (uploadedFiles.length > 0) {
            this.lstAttachments = this.lstAttachments.concat(uploadedFiles);
            this._lstAttachments_master = this._lstAttachments_master.concat(uploadedFiles);
        }
            
        
            console.log('inside get attachments')
            let files = this._lstAttachments_master.map(item => {
                let filetype = this.getFileTypeFromName(item.name);
                return {
                    name: item.name,
                    type: filetype,
                    iconName: this.getFileIconName(filetype)
                };
            });
    
            this.attachments = files;
        
        console.log('inside get this.attachments  '+ this.attachments  );
    }*/
    /* handleUploadFinished(event) {
    const uploadedFiles = event.detail.files;
    console.log('inside get uploadedFiles', uploadedFiles);
    console.log('Uploaded Files:'+ JSON.stringify(uploadedFiles));
    
    const MAX_FILE_SIZE = 3 * 1024 * 1024; // 3 MB in bytes
    const validFiles = uploadedFiles.filter(file => file.size <= MAX_FILE_SIZE);
    
    if (validFiles.length < uploadedFiles.length) {
        alert('Some files were not added because they exceed the 3MB size limit.');
    }
    
    if (validFiles.length > 0) {
        this.lstAttachments = this.lstAttachments.concat(validFiles);
        this._lstAttachments_master = this._lstAttachments_master.concat(validFiles);
    }
    
    console.log('inside get attachments');
    let files = this._lstAttachments_master.map(item => {
        let filetype = this.getFileTypeFromName(item.name);
        return {
            name: item.name,
            type: filetype,
            iconName: this.getFileIconName(filetype)
        };
    });
    
    this.attachments = files;
    
    console.log('inside get this.attachments', this.attachments);
    } */

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const documentIds = uploadedFiles.map(file => file.documentId);
        const MAX_FILE_SIZE = 3  // 3 MB in bytes
        // Fetch sizes asynchronously and handle them
        Promise.all(documentIds.map(docId => this.fetchFileSize(docId)))
            .then(sizes => {
                uploadedFiles.forEach((file, index) => {
                  //  alert(sizes[index] + ' ' + MAX_FILE_SIZE)
                    if (sizes[index] <= MAX_FILE_SIZE) {
                        // File size is within limit, add to attachments
                        this.lstAttachments.push(file);
                        this._lstAttachments_master.push(file);
                    } else {
                        // File size exceeds limit, show alert
                        alert(`File "${file.name}" exceeds the 3MB size limit and was not added.`);
                    }
                });

                let files = this._lstAttachments_master.map(item => {
                    let filetype = this.getFileTypeFromName(item.name);
                    return {
                        name: item.name,
                        type: filetype,
                        iconName: this.getFileIconName(filetype)
                    };
                });

                this.attachments = files;

            })
            .catch(error => {
                console.error('Error fetching file sizes:', error);
            });
    }

    async fetchFileSize(docId) {
        try {
            const size = await getDocumentSize({ documentId: docId });
            return size;
        } catch (error) {
            console.error(`Error fetching size for document ${docId}:`, error);
            return 0; // Handle error appropriately
        }
    }


    getFileTypeFromName(fileName) {
        const fileParts = fileName.split('.');
        if (fileParts.length > 1) {
            return fileParts[fileParts.length - 1].toLowerCase();
        }
        return 'unknown';
    }

    getFileIconName(fileType) {
        const iconMapping = {
            pdf: 'doctype:pdf',
            xlsx: 'doctype:excel',
            excel: 'doctype:excel',
            png: 'doctype:image',
            jpg: 'doctype:image',
            jpeg: 'doctype:image',
            jpg: 'doctype:image',
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

    handleRemoveAttachment(event) {
        const attachmentIndex = event.target.dataset.attachmentIndex;
        if (attachmentIndex !== undefined) {
            this._lstAttachments_master.splice(attachmentIndex, 1);
            this._lstAttachments_master = [...this._lstAttachments_master];
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

}
import { LightningElement, api, track, wire } from 'lwc';
import LightningAlert from 'lightning/alert';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import DeleteAttachments from '@salesforce/apex/QuoteSubmiitedStageApi.DeleteAttachments'
import on_save from '@salesforce/apex/QuoteSubmiitedStageApi.sendDoc'
export default class QuoteSubmiitedStageApi extends  NavigationMixin(LightningElement) {
@api recordId;
    @track fileUploaded = false;
    fileData;
    @track attachments = [];
    @track lstAttachments = [];
    @track _lstAttachments_master = [];
    @track attachments = [];
    showSpinner = false;
    acceptedFormats = [
        '.pdf',   // Adobe PDF
    //     '.doc',   // Microsoft Word document
    //     '.docx',  // Microsoft Word Open XML document
    //     '.xls',   // Microsoft Excel spreadsheet
    //     '.xlsx',  // Microsoft Excel Open XML spreadsheet
    //     '.ppt',   // Microsoft PowerPoint presentation
    //     '.pptx',  // Microsoft PowerPoint Open XML presentation
    //     '.txt',   // Plain text document
    //     '.rtf',   // Rich Text Format document
    //     '.csv',   // Comma-separated values file
    //     '.xml',   // XML document
    //    // '.html',  // HTML document
    //     '.zip',   // ZIP archive
    //     '.jpeg',  // JPEG image
    //     '.png',   // PNG image
    //     '.gif', 
    //     '.ods',
       // '.mp3', 
      //  '.mp4',   // GIF image
       // '.bmp'    // BMP image
        // Add more document and image file extensions as needed
    ];
    disconnectedCallback() {
        console.log("Unmount Send Email");
        let lstDocuments = this._lstAttachments_master.map(item => {
            return String(item.documentId);
        });

        if(lstDocuments.length > 0) {
            DeleteAttachments({
                lstDocumentId: lstDocuments
            }) .then(response => {
                console.log(response);
            }) .catch(error => {
                console.log(error);
            });
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
        this.disconnectedCallback();
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



    handleUploadFinished(event) {
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
    }

    doSave() {

        if(this._lstAttachments_master.length == 0){
            const e = new ShowToastEvent({
                title: 'Error!',
                message: "Please provide a file.",
                variant: 'error',
            });
            this.dispatchEvent(e);
            return
        }
         
        let lstDocuments = this._lstAttachments_master.map(item => {
            return String(item.documentId);
        });
        this.showSpinner = true;
       
        on_save({ recordId: this.recordId,  docid: String( lstDocuments) })
            .then((result) => {

                const e = new ShowToastEvent({
                    title: 'Success!',
                    message: 'File Uploaded Successfuly...!!!',
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

    cancle() {

        window.location.href = '/' + this.recordId;
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.recordId,
        //         actionName: 'view'
        //     }
        // });
    }

}
import { LightningElement, api, track } from "lwc";

import getRecordsUsingRestApi from '@salesforce/apex/changeAccountOwnerController.getRecordsUsingRestApi';
import changeOwner from '@salesforce/apex/changeAccountOwnerController.changeOwner';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';

export default class ChangeOwnerLwc extends NavigationMixin(LightningElement) {


    @api selectedAccounts;
    @api sessionKey;
    @api filterName;

    @track selectedAccountSet = [];

    showToastBoolean = false;

    ownerId = '';

    label = '';

    openOpp = false;
    allOpp = false;
    contacts = false;

    @track filter = {};

    async connectedCallback() {
        console.log('Hello');
        console.log("Filter Name: " + this.filterName);
        console.log("Selected Accounts: " + this.selectedAccounts);

        if (this.selectedAccounts != '[]') {
            let newSelected = this.selectedAccounts.substring(1, this.selectedAccounts.length - 1);
            const arrayOfStrings = newSelected.split(", ");
            console.log("Selected Accounts: " + arrayOfStrings);
            this.selectedAccountSet = arrayOfStrings;
            console.log("Session Id: " + this.sessionKey);
        }

        this.filter = {
            criteria: [
                {
                    fieldPath: 'IsActive',
                    operator: 'eq',
                    value: true,
                },
            ],
        }

        console.log(this.selectedAccountSet.length);

        if (this.selectedAccountSet.length == 0) {
            await getRecordsUsingRestApi({ filterId: this.filterName, sessionId: this.sessionKey }).then(result => {
                console.log(JSON.parse(result));
                this.selectedAccountSet = JSON.parse(result).map(element => {
                    return element.Id;
                });

            });
        }

        this.label = `${this.selectedAccountSet.length} ${this.selectedAccountSet.length != 1 ? 'Account\'s' : 'Account'} Are Selected`


        console.log(JSON.stringify(this.selectedAccountSet));

    }

    handleChange(event) {
        console.log(event.detail.recordId);
        this.ownerId = event.detail.recordId;
    }

    handleCheck(event) {

        let name = event.target.name;

        if (name == 'openOpp') {
            this.openOpp = !this.openOpp;
        } else if (name == 'allOpp') {
            this.allOpp = !this.allOpp;
        } else if (name == 'contact') {
            this.contacts = !this.contacts;
        }

    }

    handleSave() {
        console.log(this.openOpp, this.allOpp, this.contacts);

        if (this.ownerId == '') {
            this.handleAlertClick('Please Select A New Owner', 'error', 'Error');
            return;
        }

        changeOwner({ openOpp: this.openOpp, allOpp: this.allOpp, contacts: this.contacts, listOfAccountInJson: JSON.stringify(this.selectedAccountSet), newOwnerId: this.ownerId }).then(result => {
            console.log(result);
            this.showToast('All Items Are Shared With The New Owner', 'Success', 'success');

            this.showToastBoolean = true;

            setTimeout(() => {
                const a = document.createElement('a');
                a.href = '/lightning/o/Account/list?filterName=' + this.filterName;
                a.target = '_self';
                a.click();
            }, 2000);


            this.handleListViewNavigation();
        });
    }

    async handleAlertClick(message, theme, label) {
        await LightningAlert.open({
            message: message,
            theme: theme,
            label: label,
        });
    }

    showToast(message, title, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleListViewNavigation() {
        // Navigate to the Accounts object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            },
            state: {
                filterName: this.filterName
            }
        });
    }

}
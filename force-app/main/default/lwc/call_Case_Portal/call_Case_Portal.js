import { LightningElement } from 'lwc';
import getUserAndOrgInfo from '@salesforce/apex/call_Create_Case_Portal_Apex.getUserAndOrgInfo';
export default class Call_Case_Portal extends LightningElement {
userName;
    userEmail;
    userMobile;
    orgName;
    orgId;
    accountId;
    paymentChekbox;
    error;


    fetchUserAndOrgInfo() {
        // alert('Calling fetchUserAndOrgInfo')
        getUserAndOrgInfo()
            .then((result) => {
                console.log('result - ' + result)
                this.userName = result.userName;
                this.orgName = result.orgName;
                this.userEmail = result.userEmail;
                this.userMobile = result.userMobile;
                this.paymentChekbox = result.paymentCheckboxes;
                // alert('paymentChekbox - '+this.paymentChekbox)

                //   alert('userName - '+this.userName)
                //   alert('orgName - '+this.orgName)
                //   alert('userEmail - '+this.userEmail)
                //   alert('userMobile - '+this.userMobile)

                this.navigateToLink();
            })
            .catch((error) => {
                this.error = error;
                console.error('Error fetching user and org info:', error);
            });
    }



    hasRedirected = false; // Flag to track if redirection has occurred


    navigateToLink() {
        window.open(
            `https://cloudacademyindia.my.site.com/s/?orgid=00D5j00000DrZta&accountId=001GB000039d6QeYAI&orgname=${this.orgName}&username=${this.userName}&useremail=${this.userEmail}&usermobile=${this.userMobile}&paymentChekbox=${this.paymentChekbox}`,

            '_blank'
        );
    }




    connectedCallback() {
        if (!this.hasRedirected) {
            this.fetchUserAndOrgInfo();

            // Perform redirection only once

            this.hasRedirected = true; // Set the flag to true
        }
    }
}
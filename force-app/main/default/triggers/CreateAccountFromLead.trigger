trigger CreateAccountFromLead on Lead (After insert) {

    CreateAccountFromLead_helper.insert_Account(Trigger.New);
}
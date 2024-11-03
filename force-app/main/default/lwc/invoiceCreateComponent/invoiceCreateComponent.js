import { LightningElement } from 'lwc';
import createInvoiceAndLineItems from '@salesforce/apex/InvoiceController.createInvoiceAndLineItems';

export default class InvoiceCreateComponent extends LightningElement {
    result;
    error;

    connectedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        const params = {};
        urlParams.forEach((value, key) => {
            params[key] = value;
        });

        this.createInvoiceRecords(params);
    }

    createInvoiceRecords(params) {
        createInvoiceAndLineItems({ params: JSON.stringify(params) })
            .then(result => {
                this.result = JSON.parse(result);
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.result = undefined;
            });
    }
}

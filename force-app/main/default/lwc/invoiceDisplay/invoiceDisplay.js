import { LightningElement, track, wire } from 'lwc';
import getInvoiceData from '@salesforce/apex/InvoiceController.getInvoiceData';
import { CurrentPageReference } from 'lightning/navigation';

export default class InvoiceDisplay extends LightningElement {
    @track params = {};
    @track invoiceWrapper; // Change from invoiceWrapperList to a single invoiceWrapper
    @track error; 

    // Define columns for the line item datatable (not used anymore since line items are displayed individually)
    columns = [
        { label: 'ID', fieldName: 'id' },
        { label: 'Description', fieldName: 'lineDescription' },
        { label: 'Quantity', fieldName: 'quantity' },
        { label: 'Unit Price', fieldName: 'unitPrice' }
    ];

    @wire(CurrentPageReference)
    pageRef(pageRef) {
        if (pageRef) {
            const state = pageRef.state;
            this.params = {
                origin_record: state.origin_record,
            };
        }
    }

    connectedCallback() {
        // Fetch invoice data using the params
        getInvoiceData({ params: this.params })
            .then(result => {
                this.invoiceWrapper = result; // Update to store the single invoiceWrapper
            })
            .catch(error => {
                this.error = error;
            });
    }
}

public with sharing class InvoiceController {
    @AuraEnabled(cacheable=true)
    public static InvoiceWrapper getInvoiceData(Map<String, String> params) {
        // Initialize the wrapper
        InvoiceWrapper wrapper = new InvoiceWrapper();
        
        // Use a try-catch block for error handling
        try {
            // Extract parameters from the incoming map
            String originRecordId = params.get('origin_record');

            // Query invoices where BillingAccountId is not null and match the originRecordId
            List<Invoice__c> invoices = [
                SELECT Id, AccountId__c, Invoice_Date__c, Due_Date__c,
                       (SELECT Id, Line_Description__c, Quantity__c, Unit_Price__c FROM Line_Items__r)
                FROM Invoice__c
                WHERE AccountId__c != null
                AND Id = :originRecordId
                LIMIT 1 // Assuming we want to fetch only one invoice
            ];

            // Check if any invoices were returned
            if (!invoices.isEmpty()) {
                Invoice__c invoice = invoices[0]; // Get the first invoice

                // Populate the wrapper fields
                wrapper.invoiceId = invoice.Id;
                wrapper.billingAccountId = invoice.AccountId__c;
                wrapper.invoiceDate = invoice.Invoice_Date__c;
                wrapper.dueDate = invoice.Due_Date__c;

                // Initialize the lineItems list
                wrapper.lineItems = new List<InvoiceWrapper.LineItemWrapper>();

                // Populate line items from the InvoiceLines relationship
                for (InvoiceLine lineItem : invoice.Line_Items__r) {
                    InvoiceWrapper.LineItemWrapper lineItemWrapper = new InvoiceWrapper.LineItemWrapper();
                    lineItemWrapper.id = lineItem.Id;
                    lineItemWrapper.lineDescription = lineItem.Line_Description__c;
                    lineItemWrapper.quantity = lineItem.Quantity__c;
                    lineItemWrapper.unitPrice = lineItem.Unit_Price__c;
                    lineItemWrapper.amount = lineItem.Amount__c; 

                    // Add the line item wrapper to the list
                    wrapper.lineItems.add(lineItemWrapper);
                }
            }
        } catch (Exception e) {
            // Log the error and return a user-friendly message
            System.debug('Error fetching invoice data: ' + e.getMessage());
            // Optionally, you could throw a custom exception or return an error wrapper
            throw new AuraHandledException('An error occurred while retrieving invoice data. Please try again later.');
        }
        
        return wrapper; // Return the populated wrapper
    }
}

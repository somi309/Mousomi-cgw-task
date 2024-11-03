public with sharing class InvoiceController {
    @AuraEnabled
    public static String createInvoiceAndLineItems(String params) {
        Map<String, String> paramMap = (Map<String, String>) JSON.deserializeUntyped(params);

        // Required fields from URL parameters
        String opportunityId = paramMap.get('origin_record');
        String accountId = paramMap.get('account');
        Date invoiceDate = Date.valueOf(paramMap.get('invoice_date'));
        Date invoiceDueDate = Date.valueOf(paramMap.get('invoice_due_date'));
        String childRelationshipName = paramMap.get('child_relationship_name');
        String lineItemDescriptionField = paramMap.get('line_item_description');
        String lineItemQuantityField = paramMap.get('line_item_quantity');
        String lineItemUnitPriceField = paramMap.get('line_item_unit_price');

        // Query Opportunity
        Opportunity opp = [
            SELECT Id, AccountId
            FROM Opportunity 
            WHERE Id = :opportunityId 
            LIMIT 1
        ];

        // Create Invoice record
        Invoice__c invoice = new Invoice__c();
        invoice.Opportunity__c = opp.Id;
        invoice.Account__c = accountId != null ? Id.valueOf(accountId) : opp.AccountId;
        invoice.Invoice_Date__c = invoiceDate;
        invoice.Due_Date__c = invoiceDueDate;
        insert invoice;

        // Query Opportunity Line Items dynamically
        String oppLineItemQuery = 'SELECT Id, ' + lineItemDescriptionField + ', ' + lineItemQuantityField + ', ' + lineItemUnitPriceField +
            ' FROM ' + childRelationshipName + ' WHERE OpportunityId = :opportunityId';
        
        List<SObject> oppLineItems = Database.query(oppLineItemQuery);
        List<Line_Item__c> lineItems = new List<Line_Item__c>();
        
        // Create Line Items associated with the Invoice
        for (SObject lineItem : oppLineItems) {
            Line_Item__c newItem = new Line_Item__c();
            newItem.Invoice__c = invoice.Id;
            newItem.Description__c = (String)lineItem.get(lineItemDescriptionField);
            newItem.Quantity__c = (Decimal)lineItem.get(lineItemQuantityField);
            newItem.Unit_Price__c = (Decimal)lineItem.get(lineItemUnitPriceField);
            lineItems.add(newItem);
        }
        
        insert lineItems;

        // Generate JSON response with created records
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('Invoice', invoice);
        resultMap.put('LineItems', lineItems);
        
        return JSON.serialize(resultMap);
    }
}

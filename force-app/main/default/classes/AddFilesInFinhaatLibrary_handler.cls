public class AddFilesInFinhaatLibrary_handler {
    
    public static boolean runOn = false;
    
    public static void addFiles(List<ContentDocumentLink> triggerNewList){
        if(runOn == false || Test.isRunningTest()){
            // Get the Id of the Finhaat Library
            ContentWorkspace library = [SELECT Id FROM ContentWorkspace WHERE Name = 'Finhaat Library' LIMIT 1];
            
            // Create a set to hold ContentDocument IDs that need to be processed
            Set<Id> documentIds = new Set<Id>();
            
            // Collect all ContentDocument IDs from the triggered records
            for (ContentDocumentLink cdl : triggerNewList) {
                documentIds.add(cdl.ContentDocumentId);
            }
            
            // Query existing ContentWorkspaceDoc records for the given library and document IDs
            Map<Id, ContentWorkspaceDoc> existingDocsMap = new Map<Id, ContentWorkspaceDoc>();
            for (ContentWorkspaceDoc cwd : [
                SELECT ContentDocumentId
                FROM ContentWorkspaceDoc
                WHERE ContentWorkspaceId = :library.Id
                AND ContentDocumentId IN :documentIds
            ]) {
                existingDocsMap.put(cwd.ContentDocumentId, cwd);
            }
            
            // List to hold new ContentWorkspaceDoc records to insert
            List<ContentWorkspaceDoc> libraryDocs = new List<ContentWorkspaceDoc>();
            
            // Add records only if they are not already present
            for (Id docId : documentIds) {
                if (!existingDocsMap.containsKey(docId)) {
                    libraryDocs.add(new ContentWorkspaceDoc(
                        ContentWorkspaceId = library.Id,
                        ContentDocumentId = docId
                    ));
                }
            }
            
            // Insert new records to link files to the library
            if (libraryDocs.size() > 0) {
                insert libraryDocs;
            }
        }
    }
    
}
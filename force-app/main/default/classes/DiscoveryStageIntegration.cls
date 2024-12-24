public class DiscoveryStageIntegration {
    @InvocableMethod(label='Discovery Stage Integration')
    public static void sendpostmethod(list<id> ids){
        system.debug('Opportunity ids llist '+ids.Size());
        
        if(ids.Size()>0){  Set<Id> setids = new Set<Id>(ids);  Database.ExecuteBatch(New DiscoveryStageIntegration_Batch(setids),1);   }
    }
}
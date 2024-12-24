@isTest
public class BatchUpdateTask_Test {
	@isTest
    static void BatchUpdateTask_Test() {
        // Create test tasks
        List<Task> testTasks = new List<Task>();
        for(Integer i = 0; i < 200; i++) {
            Task t = new Task(Subject = 'Test Task ' + i);
            testTasks.add(t);
        }
        insert testTasks;
        Set<Id> ids = new Set<Id>();
		for(Task t : testTasks) {
            ids.add(t.Id);
        }


        // Test start method
        Test.startTest();
        Id batchJobId = Database.executeBatch(new BatchUpdateTask(testTasks), 200);
        Test.stopTest();
        
    }
}
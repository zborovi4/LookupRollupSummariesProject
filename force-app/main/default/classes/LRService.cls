/**
 * Created by OleksandrZborovskyi on 01.02.2022.
 */

public with sharing class LRService {
    static String ROLLUP_SUMMARY_SETTING_OBJECT_NAME = 'Rollup_Summary_Setting';

    public static void recalculateRollupSummaryByParent(List<SObject> parentObjectList){

    }

    public static void recalculateRollupSummaryByChild(List<SObject> childObjectList){

    }

    public static void recalculateRollupSummaryByParent(List<Id> parentObjectIds){

    }

    public static void recalculateRollupSummaryByChild(List<Id> childObjectIds){
    }

    private static List<Metadata.Metadata> getCustomMetadataRecords(List<SObject> sobjects, Boolean isChild){
        Set<String> objectNames = new Set<String>();
        for(SObject sObj : sobjects){
            objectNames.add(sObj.getSObjectType().getDescribe().getName());
        }
        Map<String, Rollup_Summary_Setting__mdt> RSSByApiName = new Map<String, Schema.Rollup_Summary_Setting__mdt>();
        List<Rollup_Summary_Setting__mdt> RssList = new List<Schema.Rollup_Summary_Setting__mdt>();
        if(isChild){
            RssList = getRSSByChild(objectNames);
        }
        else{
            RssList = getRSSByParent(objectNames);
        }
        for(Rollup_Summary_Setting__mdt rss : RssList){
            RSSByApiName.put(rss.DeveloperName, rss);
        }
        List<String> rssFullNames = new List<String>();
        for(String recordName : RSSByApiName.keySet()){
            rssFullNames.add(ROLLUP_SUMMARY_SETTING_OBJECT_NAME + '.' + recordName);
        }
        return Metadata.Operations.retrieve(Metadata.MetadataType.CustomMetadata, rssFullNames);
    }

    private static List<Rollup_Summary_Setting__mdt> getRSSByChild(Set<String> objectNames){
        return [SELECT Id, DeveloperName from Rollup_Summary_Setting__mdt WHERE Child_Object__c IN :objectNames];
    }

    private static List<Rollup_Summary_Setting__mdt> getRSSByParent(Set<String> objectNames){
        return [SELECT Id, DeveloperName from Rollup_Summary_Setting__mdt WHERE Parent_Object__c IN :objectNames];
    }
}
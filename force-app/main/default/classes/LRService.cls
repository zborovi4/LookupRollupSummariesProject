/**
 * Created by OleksandrZborovskyi on 01.02.2022.
 */

public with sharing class LRService {
    static String ROLLUP_SUMMARY_SETTING_OBJECT_NAME = 'Rollup_Summary_Setting';

    public static void recalculateRollupSummaryByParent(List<SObject> parentObjectList){

    }

    public static void recalculateRollupSummaryByChild(List<SObject> childObjectList){
        List<Metadata.Metadata> customMetadataRecords = getCustomMetadataRecords(childObjectList, true);
        SObject[] sobj = getSojectsToUpdate(customMetadataRecords);
    }

    public static void recalculateRollupSummaryByParent(List<Id> parentObjectIds){

    }

    public static void recalculateRollupSummaryByChild(List<Id> childObjectIds){
    }

    public static List<Metadata.Metadata> getCustomMetadataRecords(List<SObject> sobjects, Boolean isChild){
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
        return [SELECT Id, DeveloperName from Rollup_Summary_Setting__mdt WHERE Active__c = TRUE AND Child_Object__c IN :objectNames];
    }

    private static List<Rollup_Summary_Setting__mdt> getRSSByParent(Set<String> objectNames){
        return [SELECT Id, DeveloperName from Rollup_Summary_Setting__mdt WHERE Active__c = TRUE AND Parent_Object__c IN :objectNames];
    }

    private static List<SObject> getSojectsToUpdate(List<Metadata.Metadata> lrsRecords){
        List<SObject> sobjectsToUpdate = new List<SObject>();
        for (Metadata.Metadata record : lrsRecords){
            Metadata.CustomMetadata lrsRecord = (Metadata.CustomMetadata) record;
            Map<String, String> lrsRecValuesMap = new Map<String, String>();
            for (Metadata.CustomMetadataValue lrsRecValue : lrsRecord.values){
                lrsRecValuesMap.put((String)lrsRecValue.field, (String)lrsRecValue.value);
            }

        }
        return null;
    }

    private static SObject[] invokeLRSEgine(Map<String, String> lrsRecValuesMap){
        SObjectType parentObj = ((SObject) Type.forName(lrsRecValuesMap.get('Parent_Object__c')).newInstance()).getSObjectType();
        SObjectType childObj = ((SObject) Type.forName(lrsRecValuesMap.get('Child_Object__c')).newInstance()).getSObjectType();
        Map<String, Schema.SObjectField> schemaFieldMap = childObj.getDescribe().fields.getMap();
        Schema.DescribeFieldResult relationshipField = schemaFieldMap.get('Lookup_Field__c').getDescribe();
        LREngine.Context ctx = new LREngine.Context(parentObj, childObj, relationshipField);
        return null;
    }
}
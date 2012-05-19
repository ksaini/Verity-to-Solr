Verity-to-Solr
==============

This is a migration tool for Veirty to Solr for ColdFusion collections
=== Name ===
Contributors: Kunal Saini
Language: CFML



== Usage ==
* Place the zip to CF webroot and expand it.
* From index page go to Export Collection from Verity and export individual collections
* Now copy this parent folder and place it to CF10 webroot.
* From index page go to Import Collection to Solr and import individual collections.
 


== Note ==
* While migrating from CF8/801/9 make sure Verity is up and running.
* In CF webroot where this folder is placed has write permissions.
* While importing to Solr, it will create a collection with same name as was in Verity. If there is already a collection of same name it will be purged.
* This code holds your collection information in a csv file at {solr}/data/{collection name}_file.csv. This could be an security issue. So delete these files from CF8 and CF10 locations.
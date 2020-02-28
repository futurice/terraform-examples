/*
Adapted from 
https://stackoverflow.com/questions/46742020/what-jsonpath-expressions-are-supported-in-bigquery
*/
CREATE OR REPLACE FUNCTION
    ${dataset}.CUSTOM_JSON_EXTRACT_ARRAY_FLOAT(json STRING, path STRING)
RETURNS ARRAY<FLOAT64>
LANGUAGE js AS """
    try {
        return jsonPath(JSON.parse(json), path);
    } catch (e) { return null }
"""
OPTIONS (
    library="${library}"
);
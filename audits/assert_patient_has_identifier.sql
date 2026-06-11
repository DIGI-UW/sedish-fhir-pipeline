AUDIT (
  name assert_patient_has_identifier
);
-- fail any Patient with no identifier array
SELECT * FROM @this_model
WHERE JSON_EXTRACT(resource, '$.identifier') IS NULL

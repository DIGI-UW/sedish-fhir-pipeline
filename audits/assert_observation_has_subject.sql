AUDIT (
  name assert_observation_has_subject
);
-- fail any Observation missing a subject reference
SELECT * FROM @this_model
WHERE JSON_EXTRACT(resource, '$.subject.reference') IS NULL

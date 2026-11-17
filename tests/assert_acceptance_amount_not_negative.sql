-- Payment amounts should be positive. Checked on the raw source, because staging applies ABS()
{{ config(severity = 'warn') }}

SELECT
    external_ref,
    amount,
    currency
FROM {{ source('globepay', 'raw_acceptance_report') }}
WHERE amount < 0

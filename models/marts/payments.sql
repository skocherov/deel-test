WITH acceptance AS (

    SELECT * FROM {{ ref('stg_globepay__acceptance') }}

),

chargeback AS (

    SELECT * FROM {{ ref('stg_globepay__chargeback') }}

)

SELECT
    acceptance.external_ref,
    acceptance.status,
    acceptance.source,
    acceptance.ref,
    acceptance.transacted_at,
    acceptance.transaction_date,
    acceptance.state,
    acceptance.is_accepted,
    acceptance.is_cvv_provided,
    acceptance.amount,
    acceptance.country,
    acceptance.currency,
    acceptance.fx_rate_to_usd,
    acceptance.amount_usd,
    chargeback.is_chargeback,
    IF(chargeback.external_ref IS NULL, FALSE, TRUE) AS has_chargeback_data
FROM acceptance
LEFT JOIN chargeback
    ON acceptance.external_ref = chargeback.external_ref

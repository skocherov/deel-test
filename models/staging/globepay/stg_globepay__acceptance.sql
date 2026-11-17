WITH source AS (

    SELECT * FROM {{ source('globepay', 'raw_acceptance_report') }}

),

renamed AS (

    SELECT
        external_ref,
        status,
        source,
        ref,
        date_time AT TIME ZONE 'UTC' AS transacted_at, 
        LOWER(state) AS state,
        cvv_provided AS is_cvv_provided,
        ABS(amount) AS amount,  -- one negative GBP amount in the source, assumed to be a sign error
        CASE country WHEN 'UK' THEN 'GB' ELSE country END AS country, -- According to ISO the alpha-2 country code for UK is GB
        CASE WHEN country = 'AE' AND currency = 'USD' THEN 'AED' ELSE currency END AS currency,  -- AE amounts are AED, assumed mislabeled as USD
        CASE
            WHEN country = 'AE' AND currency = 'USD' THEN 3.672500  -- AED is pegged to USD at 3.6725 (no AED in rates)
            ELSE CAST(JSON_EXTRACT_STRING(rates, '$.' || currency) AS DECIMAL(18, 6))
        END AS fx_rate_to_usd  -- local currency units per 1 USD
    FROM source

)

SELECT
    external_ref,
    status,
    source,
    ref,
    transacted_at,
    transacted_at::DATE AS transaction_date,
    state,
    IF(state = 'accepted', TRUE, FALSE) AS is_accepted,
    is_cvv_provided,
    amount,
    country,
    currency,
    fx_rate_to_usd,
    CAST(ROUND(amount / fx_rate_to_usd, 2) AS DECIMAL(18, 2)) AS amount_usd
FROM renamed

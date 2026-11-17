WITH source AS (

    SELECT * FROM {{ source('globepay', 'raw_chargeback_report') }}

),

renamed AS (

    SELECT
        external_ref,
        status,
        source,
        chargeback AS is_chargeback
    FROM source

)

SELECT
    external_ref,
    status,
    source,
    is_chargeback
FROM renamed

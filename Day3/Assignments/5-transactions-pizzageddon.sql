-- 03, Pizzageddon

-- et view til menukort
CREATE OR REPLACE VIEW menu AS
SELECT p."name" AS "Pizza",
       STRING_AGG(pi."ingredientDescription", ', ') AS "Toppings"
FROM "Pizzas" p
JOIN "PizzaIngredients" pi ON p."name" = pi."pizzaName"
GROUP BY p."name";

SELECT * FROM menu;

-- et andet view efter eget valg
CREATE OR REPLACE VIEW orders AS
SELECT r."orderId" || ':' || r."requestId" AS "Order",
       r."quantity" AS "Quantity",
       r."crustSize" || ' ' || r."crustType" || ' ' || r."pizzaName" AS "Pizza",
       STRING_AGG(rao."addOnIngredientDescription" || '(' || rao."quantity" || ')', ', ') AS "Toppings",
       STRING_AGG(ei."ingredientDescription", ', ') AS "Excluded toppings"
FROM "Requests" r
LEFT JOIN "RequestAddOns" rao ON r."orderId" = rao."orderId" AND r."requestId" = rao."requestId"
LEFT JOIN "ExcludeIngredients" ei ON r."orderId" = ei."orderId" AND r."requestId" = ei."requestId"
GROUP BY r."orderId", r."requestId";

-- en stored procedure til at oprette ordrer (med transactions)
CREATE TYPE toppingRequest AS (
    ingredient VARCHAR,
    quantity INTEGER
);

CREATE OR REPLACE PROCEDURE orderRequest(
    INOUT orderId INTEGER,
    pizza VARCHAR,
    crust VARCHAR,
    pizzaSize VARCHAR,
    quantity INTEGER,
    extraToppings toppingRequest[],
    excludeToppings VARCHAR[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    requestId INTEGER;
    violatingConstraint VARCHAR;
    topping toppingRequest;
    exclusion VARCHAR;
BEGIN
    IF orderId IS NULL THEN
        INSERT INTO "PizzaOrders" DEFAULT VALUES RETURNING id INTO orderId;
    END IF;

    SELECT COALESCE(MAX("requestId"), 0) FROM "Requests" WHERE "orderId" = orderId INTO requestId;
    requestId = requestId + 1;
    
    INSERT INTO "Requests" ("orderId", "requestId", "pizzaName", "crustSize", "crustType", "quantity") VALUES
    (orderId, requestId, pizza, pizzaSize, crust, quantity);

    IF extraToppings IS NOT NULL THEN
        FOREACH topping IN ARRAY extraToppings
        LOOP
            BEGIN -- So we can handle an exception and continue
                INSERT INTO "RequestAddOns" ("orderId", "requestId", "addOnIngredientDescription", "quantity") VALUES
                    (orderId, requestId, topping.ingredient, topping.quantity);
                EXCEPTION
                    WHEN foreign_key_violation THEN
                        GET STACKED DIAGNOSTICS violatingConstraint = CONSTRAINT_NAME;
                        IF violatingConstraint = 'fk_addOnIngredientDescription_AddOnIngredients_description' THEN
                            RAISE NOTICE 'We don''t offer % for our pizzas.', topping.ingredient;
                        END IF;
            END;
        END LOOP;
    END IF;

    IF excludeToppings IS NOT NULL THEN
        FOREACH exclusion IN ARRAY excludeToppings
        LOOP
            BEGIN -- So we can handle an exception and continue
                INSERT INTO "ExcludeIngredients" ("orderId", "requestId", "ingredientDescription") VALUES
                    (orderId, requestId, exclusion);
                EXCEPTION
                    WHEN foreign_key_violation THEN
                        GET STACKED DIAGNOSTICS violatingConstraint = CONSTRAINT_NAME;
                        IF violatingConstraint = 'fk_ingredientDescription_Ingredients_description' THEN
                            RAISE NOTICE 'You''re in luck! We don''t even offer % for our pizzas in the first place.', exclusion;
                        END IF;
            END;
        END LOOP;
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        GET STACKED DIAGNOSTICS violatingConstraint = CONSTRAINT_NAME;
        IF violatingConstraint = 'fk_orderId_PizzaOrders_id' THEN
            RAISE NOTICE 'Order no. % exists.', orderId;
        ELSIF violatingConstraint = 'fk_Crusts_size_type' THEN
            RAISE NOTICE 'Combination of % and % is not possible.', pizzaSize, crust;
        ELSE
            RAISE;
        END IF;
    WHEN OTHERS THEN
        RAISE;
END;
$$;

-- Error - unknown order
CALL orderRequest(11, 'Eviscerator', 'Deep pan', 'Small', 1, NULL, NULL);

-- Error - unknown type/size combination
CALL orderRequest(NULL, 'Eviscerator', 'Regular', 'Small', 1, NULL, NULL);

DO $$
DECLARE
    orderId INTEGER := NULL;
BEGIN
    CALL orderRequest(
        orderId,
        'Flaming hot',
        'Regular',
        'Medium',
        1,
        ARRAY[ROW('Chili', 1)::toppingRequest, ROW('Pineapple', 2)::toppingRequest, ROW('Motor oil', 100)::toppingRequest],
        NULL
    );
    --RAISE NOTICE 'orderId: %', orderId;

    -- Add to previous order
    CALL orderRequest(
        orderId,
        'Bambolino',
        'Deep pan',
        'Family',
        2,
        NULL,
        ARRAY['Chili', 'Hair', 'Bacon']
    );
END;
$$;

SELECT * FROM orders;
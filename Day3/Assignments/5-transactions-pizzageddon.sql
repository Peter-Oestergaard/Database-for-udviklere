-- 03, Pizzageddon
CREATE OR REPLACE VIEW menu AS
SELECT p."name" AS "Pizza",
       STRING_AGG(pi."ingredientDescription", ', ') AS "Toppings"
FROM "Pizzas" p
JOIN "PizzaIngredients" pi ON p."name" = pi."pizzaName"
GROUP BY p."name";

SELECT * FROM menu;

CREATE OR REPLACE PROCEDURE orderRequest(INOUT orderId INTEGER, pizza VARCHAR, extraToppings VARCHAR[], excludeToppings VARCHAR[])
LANGUAGE plpgsql
AS $$
BEGIN
    IF orderId IS NULL THEN
        INSERT INTO "PizzaOrders" DEFAULT VALUES RETURNING id into orderId;
        RAISE NOTICE 'New order made: %', orderId;
    ELSE
        RAISE NOTICE 'order id is not null: %', orderId;
    END IF;
END;
$$;

CALL orderRequest(NULL, 'Flaming hot', NULL, NULL);
CALL orderRequest(11, 'Flaming hot', NULL, NULL);
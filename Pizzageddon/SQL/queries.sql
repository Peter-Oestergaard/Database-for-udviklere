-- The naive "get all permutations" query
SELECT p."name",c."size",c."type",c."price",c."leadTime" FROM "Pizzas" p CROSS JOIN "Crusts" c;

-- But it does not account for surcharges and lead time extensions. This does
SELECT
    p."name" AS "Pizza",
    c."size" AS "Size",
    c."type" AS "Crust",
    (c."price" + p."surcharge") AS "Price",
    (c."leadTime" + p."leadTimeExtension") AS "Time"
FROM "Pizzas" p
CROSS JOIN "Crusts" c;

-- An order can't be placed with a query... so here is a couple of INSERTs

-- First order - A plain Bambolino with no addons or exclusions
DO $$
DECLARE orderId INTEGER;
DECLARE orderLine INTEGER := 1;
BEGIN
    INSERT INTO "PizzaOrders" DEFAULT VALUES RETURNING id INTO orderId;

    INSERT INTO "OrderLines" ("orderId", "lineNumber", "quantity") VALUES
    (orderId, orderLine, 1);

    INSERT INTO "Requests" ("orderId", "orderLineNumber", "pizzaName", "crustSize", "crustType") VALUES
    (orderId, orderLine, 'Bambolino', 'Large', 'Regular');
END;
$$;

-- Second order - A Discodasko without mushrooms
DO $$
DECLARE orderId INTEGER;
DECLARE orderLine INTEGER := 1;
BEGIN
    INSERT INTO "PizzaOrders" DEFAULT VALUES RETURNING id INTO orderId;

    INSERT INTO "OrderLines" ("orderId", "lineNumber", "quantity") VALUES
    (orderId, orderLine, 1);

    INSERT INTO "Requests" ("orderId", "orderLineNumber", "pizzaName", "crustSize", "crustType") VALUES
    (orderId, orderLine, 'Discodasko', 'Medium', 'Regular');

    INSERT INTO "ExcludeIngredients" ("orderId", "orderLineNumber", "ingredientDescription") VALUES
    (orderId, orderLine, 'Mushrooms');
END;
$$;

-- Third order - A Flaming hot with extra chili and bacon
DO $$
DECLARE orderId INTEGER;
DECLARE orderLine INTEGER := 1;
BEGIN
    INSERT INTO "PizzaOrders" DEFAULT VALUES RETURNING id INTO orderId;

    INSERT INTO "OrderLines" ("orderId", "lineNumber", "quantity") VALUES
    (orderId, orderLine, 1);

    INSERT INTO "Requests" ("orderId", "orderLineNumber", "pizzaName", "crustSize", "crustType") VALUES
    (orderId, orderLine, 'Flaming hot', 'Small', 'Deep pan');

    INSERT INTO "RequestAddOns" ("orderId", "orderLineNumber", "addOnIngredientDescription", "quantity") VALUES
    (orderId, orderLine, 'Chili', 3),
    (orderId, orderLine, 'Bacon', 1);
END;
$$;

-- Find the prices and times for each order
SELECT o."id" AS "Order ID", c."price" AS "Price", c."leadTime" AS "Time" FROM "PizzaOrders" o
JOIN "OrderLines" ol ON o."id" = ol."orderId"
JOIN "Requests" r ON o."id" = r."orderId" AND ol."lineNumber" = r."orderLineNumber"
JOIN "Crusts" c ON r."crustSize" = c."size" AND r."crustType" = c."type";

-- But wait! Again we missed the add-ons
SELECT
    o."id" AS "Order ID",
    (c."price" + (COALESCE(SUM(aoi."surcharge" * rao."quantity"), 0))) AS "Price",
    (c."leadTime" + COALESCE(SUM(aoi."leadTimeExtension"), INTERVAL '0')) AS "Time" -- Correct, we don't multiply lead time extension by quantityf
FROM "PizzaOrders" o
JOIN "OrderLines" ol ON o."id" = ol."orderId"
JOIN "Requests" r ON o."id" = r."orderId" AND ol."lineNumber" = r."orderLineNumber"
JOIN "Crusts" c ON r."crustSize" = c."size" AND r."crustType" = c."type"
LEFT JOIN "RequestAddOns" rao ON o."id" = rao."orderId" AND ol."lineNumber" = rao."orderLineNumber"
LEFT JOIN "AddOnIngredients" aoi ON rao."addOnIngredientDescription" = aoi."description"
GROUP BY o."id", c."price", c."leadTime"
ORDER BY o."id" ASC
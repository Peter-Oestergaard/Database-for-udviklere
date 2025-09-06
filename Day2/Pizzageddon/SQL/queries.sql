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
DECLARE requestId INTEGER := 1;
BEGIN
    INSERT INTO "PizzaOrders" DEFAULT VALUES RETURNING id INTO orderId;

    INSERT INTO "Requests" ("orderId", "requestId", "pizzaName", "crustSize", "crustType", "quantity") VALUES
    (orderId, requestId, 'Bambolino', 'Large', 'Regular', 1);
END;
$$;

-- Second order - A Discodasko without mushrooms
DO $$
DECLARE orderId INTEGER;
DECLARE requestId INTEGER := 1;
BEGIN
    INSERT INTO "PizzaOrders" DEFAULT VALUES RETURNING id INTO orderId;

    INSERT INTO "Requests" ("orderId", "requestId", "pizzaName", "crustSize", "crustType", "quantity") VALUES
    (orderId, requestId, 'Discodasko', 'Medium', 'Regular', 1);

    INSERT INTO "ExcludeIngredients" ("orderId", "requestId", "ingredientDescription") VALUES
    (orderId, requestId, 'Mushrooms');
END;
$$;

-- Third order - A Flaming hot with extra chili and bacon
DO $$
DECLARE orderId INTEGER;
DECLARE requestId INTEGER := 1;
BEGIN
    INSERT INTO "PizzaOrders" DEFAULT VALUES RETURNING id INTO orderId;

    INSERT INTO "Requests" ("orderId", "requestId", "pizzaName", "crustSize", "crustType", "quantity") VALUES
    (orderId, requestId, 'Flaming hot', 'Small', 'Deep pan', 1);

    INSERT INTO "RequestAddOns" ("orderId", "requestId", "addOnIngredientDescription", "quantity") VALUES
    (orderId, requestId, 'Chili', 3),
    (orderId, requestId, 'Bacon', 1);
END;
$$;

-- Find the prices and times for each order
SELECT o."id" AS "Order ID", c."price" AS "Price", c."leadTime" AS "Time" FROM "PizzaOrders" o
JOIN "Requests" r ON o."id" = r."orderId"
JOIN "Crusts" c ON r."crustSize" = c."size" AND r."crustType" = c."type";

-- But wait! Again we missed the add-ons
SELECT
    o."id" AS "Order ID",
    (c."price" + (COALESCE(SUM(aoi."surcharge" * rao."quantity"), 0))) AS "Price",
    (c."leadTime" + COALESCE(SUM(aoi."leadTimeExtension"), INTERVAL '0')) AS "Time" -- Correct, we don't multiply lead time extension by quantityf
FROM "PizzaOrders" o
JOIN "Requests" r ON o."id" = r."orderId"
JOIN "Crusts" c ON r."crustSize" = c."size" AND r."crustType" = c."type"
LEFT JOIN "RequestAddOns" rao ON o."id" = rao."orderId" AND r."requestId" = rao."requestId"
LEFT JOIN "AddOnIngredients" aoi ON rao."addOnIngredientDescription" = aoi."description"
GROUP BY o."id", c."price", c."leadTime"
ORDER BY o."id" ASC;

-- All vegetarian pizzas
SELECT DISTINCT p."name" AS "Vegetarian pizzas" FROM "Pizzas" p
JOIN "PizzaIngredients" i ON p."name" = i."pizzaName"
LEFT JOIN "IngredientTags" it ON i."ingredientDescription" = it."ingredientDescription"
WHERE NOT EXISTS (
    SELECT 1 FROM "PizzaIngredients" i2
    LEFT JOIN "IngredientTags" it2 ON i2."ingredientDescription" = it2."ingredientDescription"
    WHERE i2."pizzaName" = p."name"
    AND (it2."tagDescription" IS NULL OR it2."tagDescription" NOT IN ('Vegetarian', 'Vegan'))
)
ORDER BY p."name" ASC;

-- Pizzas without soy
SELECT DISTINCT p."name" AS "Pizzas without soy" FROM "Pizzas" p
JOIN "PizzaIngredients" i ON p."name" = i."pizzaName"
LEFT JOIN "IngredientAllergens" it ON i."ingredientDescription" = it."ingredientDescription"
WHERE NOT EXISTS (
    SELECT 1 FROM "PizzaIngredients" i2
    LEFT JOIN "IngredientAllergens" it2 ON i2."ingredientDescription" = it2."ingredientDescription"
    WHERE i2."pizzaName" = p."name"
    AND (it2."allergenDescription" IN ('Soy'))
)
ORDER BY p."name" ASC;
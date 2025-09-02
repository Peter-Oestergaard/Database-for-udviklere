CREATE TABLE "PizzaOrders" (
    "id" INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);

CREATE TABLE "OrderLines" (
    "orderId" INTEGER NOT NULL,
    "lineNumber" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    CONSTRAINT "pk_OrderLine_orderId_lineNumber" PRIMARY KEY ("orderId", "lineNumber"),
    CONSTRAINT "fk_orderId_PizzaOrders_id" FOREIGN KEY("orderId") REFERENCES "PizzaOrders"("id")
);

CREATE TABLE "CrustTypes" (
    "type" VARCHAR NOT NULL PRIMARY KEY
);

CREATE TABLE "CrustSizes" (
    "size" VARCHAR NOT NULL PRIMARY KEY
);

CREATE TABLE "Crusts" (
    "size" VARCHAR NOT NULL,
    "type" VARCHAR NOT NULL,
    "price" NUMERIC NOT NULL,
    "leadTime" INTERVAL NOT NULL,
    CONSTRAINT "pk_Crusts_size_type" PRIMARY KEY ("size", "type"),
    CONSTRAINT "fk_size_CrustSizes_size" FOREIGN KEY("size") REFERENCES "CrustSizes"("size"),
    CONSTRAINT "fk_type_CrustTypes_type" FOREIGN KEY("type") REFERENCES "CrustTypes"("type")
);

CREATE TABLE "Tags" (
    "description" VARCHAR NOT NULL PRIMARY KEY
);

CREATE TABLE "Allergens" (
    "description" VARCHAR NOT NULL PRIMARY KEY
);

CREATE TABLE "CrustTags" (
    "size" VARCHAR NOT NULL,
    "type" VARCHAR NOT NULL,
    "tagDescription" VARCHAR NOT NULL,
    CONSTRAINT "pk_CrustTags_size_type_description" PRIMARY KEY ("size", "type", "tagDescription"),
    CONSTRAINT "fk_Crusts_size_type" FOREIGN KEY("size", "type") REFERENCES "Crusts"("size", "type"),
    CONSTRAINT "fk_tagDescription_Tags_description" FOREIGN KEY("tagDescription") REFERENCES "Tags"("description")
);

CREATE TABLE "Ingredients" (
    "description" VARCHAR NOT NULL PRIMARY KEY
);

CREATE TABLE "IngredientTags" (
    "ingredientDescription" VARCHAR NOT NULL,
    "tagDescription" VARCHAR NOT NULL,
    CONSTRAINT "pk_IngredientTags_ingredientDescription_tagDescription" PRIMARY KEY ("ingredientDescription", "tagDescription"),
    CONSTRAINT "fk_ingredientDescription_Ingredients_description" FOREIGN KEY("ingredientDescription") REFERENCES "Ingredients"("description"),
    CONSTRAINT "fk_tagDescription_Tags_description" FOREIGN KEY("tagDescription") REFERENCES "Tags"("description")
);

CREATE TABLE "IngredientAllergens" (
    "ingredientDescription" VARCHAR NOT NULL,
    "allergenDescription" VARCHAR NOT NULL,
    CONSTRAINT "pk_IngredientAllergens_ingredientDescription_allergenDesc" PRIMARY KEY ("ingredientDescription", "allergenDescription"),
    CONSTRAINT "fk_ingredientDescription_Ingredients_description" FOREIGN KEY("ingredientDescription") REFERENCES "Ingredients"("description"),
    CONSTRAINT "fk_allergenDescription_Allergens_description" FOREIGN KEY("allergenDescription") REFERENCES "Allergens"("description")
);

CREATE TABLE "CrustAllergens" (
    "crustType" VARCHAR NOT NULL,
    "allergenDescription" VARCHAR NOT NULL,
    CONSTRAINT "pk_CrustAllergens_crustType_allergenDescription" PRIMARY KEY ("crustType", "allergenDescription"),
    CONSTRAINT "fk_crustType_CrustTypes_type" FOREIGN KEY("crustType") REFERENCES "CrustTypes"("type"),
    CONSTRAINT "fk_allergenDescription_Allergens_description" FOREIGN KEY("allergenDescription") REFERENCES "Allergens"("description")
);

CREATE TABLE "Pizzas" (
    "name" VARCHAR NOT NULL PRIMARY KEY,
    "surcharge" NUMERIC NOT NULL DEFAULT 0,
    "leadTimeExtension" INTERVAL NOT NULL DEFAULT INTERVAL '0'
);

CREATE TABLE "PizzaIngredients" (
    "pizzaName" VARCHAR NOT NULL,
    "ingredientDescription" VARCHAR NOT NULL,
    CONSTRAINT "pk_PizzaIngredients_pizzaName_ingredientDescription" PRIMARY KEY ("pizzaName", "ingredientDescription"),
    CONSTRAINT "fk_pizzaName_Pizzas_name" FOREIGN KEY("pizzaName") REFERENCES "Pizzas"("name"),
    CONSTRAINT "fk_ingredientDescription_Ingredients_description" FOREIGN KEY("ingredientDescription") REFERENCES "Ingredients"("description")
);

CREATE TABLE "Requests" (
    "orderId" INTEGER NOT NULL,
    "orderLineNumber" INTEGER NOT NULL,
    "pizzaName" VARCHAR NOT NULL,
    "crustSize" VARCHAR NOT NULL,
    "crustType" VARCHAR NOT NULL,
    CONSTRAINT "pk_Requests_orderId_orderLineNumber" PRIMARY KEY ("orderId", "orderLineNumber"),
    CONSTRAINT "fk_OrderLines_orderId_lineNumber" FOREIGN KEY("orderId", "orderLineNumber") REFERENCES "OrderLines"("orderId", "lineNumber"),
    CONSTRAINT "fk_pizzaName_Pizzas_name" FOREIGN KEY("pizzaName") REFERENCES "Pizzas"("name"),
    --CONSTRAINT "fk_crustSize_CrustSizes_size" FOREIGN KEY("crustSize") REFERENCES "CrustSizes"("size"),
    --CONSTRAINT "fk_crustType_CrustTypes_type" FOREIGN KEY("crustType") REFERENCES "CrustTypes"("type")
    -- During testing I discovered that I could put in an order for a small regular - because my foreign keys were referencing the wrong thing.
    CONSTRAINT "fk_Crusts_size_type" FOREIGN KEY("crustSize", "crustType") REFERENCES "Crusts"("size", "type")
);

CREATE TABLE "ExcludeIngredients" (
    "orderId" INTEGER NOT NULL,
    "orderLineNumber" INTEGER NOT NULL,
    "ingredientDescription" VARCHAR NOT NULL,
    CONSTRAINT "pk_ExcludeIngredients_orderId_orderLineNumber_ingredientDesc" PRIMARY KEY ("orderId", "orderLineNumber", "ingredientDescription"),
    CONSTRAINT "fk_OrderLines_orderId_lineNumber" FOREIGN KEY("orderId", "orderLineNumber") REFERENCES "OrderLines"("orderId", "lineNumber"),
    CONSTRAINT "fk_ingredientDescription_Ingredients_description" FOREIGN KEY("ingredientDescription") REFERENCES "Ingredients"("description")
);

CREATE TABLE "AddOnIngredients" (
    "description" VARCHAR NOT NULL PRIMARY KEY,
    "surcharge" NUMERIC NOT NULL,
    "leadTimeExtension" INTERVAL NOT NULL DEFAULT INTERVAL '0',
    CONSTRAINT "fk_description_Ingredients_description" FOREIGN KEY("description") REFERENCES "Ingredients"("description")
);

CREATE TABLE "RequestAddOns" (
    "orderId" INTEGER NOT NULL,
    "orderLineNumber" INTEGER NOT NULL,
    "addOnIngredientDescription" VARCHAR NOT NULL,
    "quantity" INTEGER NOT NULL,
    CONSTRAINT "pk_RequestsAddOns_orderId_orderLineNumber_addOnIngredientDesc" PRIMARY KEY ("orderId", "orderLineNumber", "addOnIngredientDescription"),
    CONSTRAINT "fk_OrderLines_orderId_lineNumber" FOREIGN KEY("orderId", "orderLineNumber") REFERENCES "OrderLines"("orderId", "lineNumber"),
    CONSTRAINT "fk_addOnIngredientDescription_AddOnIngredients_description" FOREIGN KEY("addOnIngredientDescription") REFERENCES "AddOnIngredients"("description")
);
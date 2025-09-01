-- Opgave 02: Data

--     Indsæt et datasæt, som dækker:
--         Mindst 6 pizzaer
--         Mindst 3 størrelser
--         Mindst 2 bundtyper
--         Mindst 12 toppings (med vegetar-/vegan-/allergen-flags)

--     Sørg for at indsatte data dækker alle relationer og inkluderer edge cases (fx pizza med allergen, pizza uden toppings).

-- Lav mindst tre konkrete bestillinger (fx Carpaccio Large på Deep Pan).


-- We have these awesome pizzas in our pizzafactory
INSERT INTO "Pizzas" ("name", "surcharge", "leadTimeExtension") VALUES
('Almeida', DEFAULT, DEFAULT),
('Bambolino', DEFAULT, DEFAULT),
('Cheesy Yum Yum', 10.5, DEFAULT),
('Discodasko', DEFAULT, DEFAULT),
('Eviscerator', DEFAULT, DEFAULT),
('Flaming hot', DEFAULT, '10 minutes');

-- Pretty bland pizzas. Let's create some ingredients
INSERT INTO "Ingredients" ("description") VALUES
('Lettuce'),
('Peanuts'),
('Sliced tomatoes'),
('Mushrooms'),
('Mozarella'),
('Bacon'),
('Ham'),
('Chili'),
('Sour cream dressing'),
('Tomato sauce'),
('Garlic'),
('Pineapple');

-- For our model to be able to tell which pizzas are vegan/vegetarian/carnivorous
-- we need to assign vegan/vegetarian tags to all applicable ingredients

-- First the tags
INSERT INTO "Tags" ("description") VALUES
('Vegan'),
('Vegetarian');

-- Then assign the tags to the ingredients
INSERT INTO "IngredientTags" ("ingredientDescription", "tagDescription") VALUES
('Lettuce', 'Vegan'),
('Sliced tomatoes', 'Vegan'),
('Mushrooms', 'Vegan'),
('Mozarella', 'Vegetarian'),
('Chili', 'Vegan'),
('Sour cream dressing', 'Vegetarian'),
('Tomato sauce', 'Vegan'),
('Garlic', 'Vegan'),
('Pineapple', 'Vegan');

-- We also need the allergens - yay!
INSERT INTO "Allergens" ("description") VALUES
('Peanuts'),
('Milk/dairy'),
('Eggs'),
('Gluten'), -- For the crusts later
('Soy'),
('Sulfites'),
('God knows what!');

-- Assign the allergens to the ingredients
INSERT INTO "IngredientAllergens" ("ingredientDescription", "allergenDescription") VALUES
('Peanuts', 'Peanuts'),
('Mozarella', 'Milk/dairy'),
('Bacon', 'Soy'),
('Ham', 'Sulfites'),
('Sour cream dressing', 'Milk/dairy'),
('Sour cream dressing', 'Soy'),
('Tomato sauce', 'God knows what!');

-- And finally use the ingredients to make our pizzas nice to eat
INSERT INTO "PizzaIngredients" ("pizzaName", "ingredientDescription") VALUES
('Almeida', 'Tomato sauce'),
('Almeida', 'Lettuce'),
('Almeida', 'Garlic'),
('Almeida', 'Peanuts'),
('Bambolino', 'Tomato sauce'),
('Bambolino', 'Lettuce'),
('Bambolino', 'Pineapple'),
('Bambolino', 'Sliced tomatoes'),
('Cheesy Yum Yum', 'Mozarella'),
('Cheesy Yum Yum', 'Sour cream dressing'),
('Cheesy Yum Yum', 'Mushrooms'),
('Discodasko', 'Tomato sauce'),
('Discodasko', 'Mushrooms'),
('Discodasko', 'Mozarella'),
('Discodasko', 'Ham'),
('Discodasko', 'Bacon'),
('Eviscerator', 'Tomato sauce'),
('Eviscerator', 'Sour cream dressing'),
('Flaming hot', 'Tomato sauce'),
('Flaming hot', 'Chili');

-- What is a pizza without a crust?
INSERT INTO "CrustTypes" ("type") VALUES
('Regular'),
('Deep pan');

INSERT INTO "CrustSizes" ("size") VALUES
('Small'),
('Medium'),
('Large'),
('Family');

INSERT INTO "Crusts" ("size", "type", "price", "leadTime") VALUES
-- Why don't we provide the regular in small?
('Medium', 'Regular', 90, '15 minutes'),
('Large', 'Regular', 110, '20 minutes'),
('Family', 'Regular', 200, '30 minutes'),
('Small', 'Deep pan', 85, '15 minutes'),
('Medium', 'Deep pan', 100, '15 minutes'),
('Large', 'Deep pan', 140, '20 minutes'),
('Family', 'Deep pan', 240, '35 minutes');

INSERT INTO "CrustAllergens" ("crustType", "allergenDescription") VALUES
('Deep pan', 'Gluten');

-- Before we can let customers make pizza requests we still need to allow them
-- to include extra toppings
INSERT INTO "AddOnIngredients" ("description", "surcharge", "leadTimeExtension") VALUES
('Peanuts', 4, DEFAULT),
('Sliced tomatoes', 5, DEFAULT),
('Mushrooms', 8, DEFAULT),
('Mozarella', 10, DEFAULT),
('Bacon', 10, '5 minutes'),
('Ham', 10, DEFAULT),
('Chili', 8, DEFAULT),
('Sour cream dressing', 8, DEFAULT),
('Garlic', 3, DEFAULT),
('Pineapple', 5, DEFAULT);
Spørgsmål 01

Hvordan kan man anvende ER-modellering som grundlag for at strukturere og tilrettelægge en databases design? Hvordan relaterer ER-modellerne til normaliseringsprincipperne, og hvilken rolle spiller nøgler og constraints i den samlede model?

Inkludér eksempler fra egne projekter.

---

Emne gennemgået [KJCL, 02 ER Diagrammer og Normalisering](https://ucl.itslearning.com/plans/courses/22203/plan/723310)

---

Forskellige diagram former og notationer

---

Generelt for flere spørgsmål
SQL dialekter


---

Pizza eksempel fra 0NF til BCNF

- Overholder 3NF men ikke BCNF

| Customer | Pizzatype | Chef    |
|----------|-----------|---------|
| 1        | Hawai     | Anders  |
| 2        | Pamplona  | Bente   |
| 3        | Peperoni  | Carsten |
| 4        | Peperoni  | Carsten |
| 3        | Hawai     | Martin  |
| 3        | Garlic    | Niels   |
| 4        | Garlic    | Niels   |

Overholder 3NF fordi Chef er en funktionel afhængighed af Customer+PizzaType.

Og i vores pizzeria kan en chef kun lave en slags pizza. Det kan ses i tabellen ovenfor. Men vi kan bryde den regel ved at tilføje en række:

| 1 | Garlic | Anders |

Vi overholder constraints, men pludselig ser det ud som om Anders kan lave to forskellige pizzaer.

To nye tabeller:

| Customer | Chef    |
|----------|---------|
| 1        | Anders  |
| 2        | Bente   |
| 3        | Carsten |
| 4        | Carsten |
| 3        | Martin  |
| 3        | Niels   |
| 4        | Niels   |

| Chef    | PizzaType |
|---------|-----------|
| Anders  | Hawai     |
| Bente   | Pamplona  |
| Carsten | Peperoni  |
| Martin  | Hawai     |
| Niels   | Garlic    |

Denne overholder BCNF
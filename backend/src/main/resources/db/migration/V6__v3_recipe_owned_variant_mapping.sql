ALTER TABLE ingredient_variant
    DROP COLUMN is_base;

CREATE TABLE recipe_ingredient_accepted_variant (
    recipe_ingredient_id BIGINT NOT NULL,
    ingredient_variant_id BIGINT NOT NULL,
    CONSTRAINT pk_recipe_ingredient_accepted_variant
        PRIMARY KEY (recipe_ingredient_id, ingredient_variant_id),
    CONSTRAINT fk_recipe_ingredient_accepted_variant_ingredient
        FOREIGN KEY (recipe_ingredient_id)
            REFERENCES recipe_ingredient (recipe_ingredient_id) ON DELETE CASCADE,
    CONSTRAINT fk_recipe_ingredient_accepted_variant_variant
        FOREIGN KEY (ingredient_variant_id)
            REFERENCES ingredient_variant (ingredient_variant_id)
);

CREATE INDEX idx_recipe_ingredient_accepted_variant_variant_id
    ON recipe_ingredient_accepted_variant (ingredient_variant_id);

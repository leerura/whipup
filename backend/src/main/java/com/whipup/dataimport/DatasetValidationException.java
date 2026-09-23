package com.whipup.dataimport;

import java.util.List;

public class DatasetValidationException extends RuntimeException {

    private final List<String> errors;

    public DatasetValidationException(List<String> errors) {
        super("Dataset validation failed:%n- %s".formatted(String.join("%n- ", errors)));
        this.errors = List.copyOf(errors);
    }

    public List<String> getErrors() {
        return errors;
    }
}

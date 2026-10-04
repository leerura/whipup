package com.whipup.dataimport;

import java.util.List;

public class DatasetValidationException extends RuntimeException {
    private final List<DatasetValidationError> errors;

    public DatasetValidationException(List<DatasetValidationError> errors) {
        super("Dataset validation failed:%n- %s".formatted(
            String.join("%n- ", errors.stream().map(DatasetValidationError::toString).toList())
        ));
        this.errors = List.copyOf(errors);
    }

    public List<DatasetValidationError> getErrors() {
        return errors;
    }
}

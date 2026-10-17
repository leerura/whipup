package com.whipup.dataimport;

public record DatasetValidationError(String code, String file, String path, String message) {
    @Override
    public String toString() {
        return "%s %s%s: %s".formatted(code, file, path == null ? "" : " " + path, message);
    }
}

package com.whipup.generated.api;

import com.whipup.generated.model.ErrorResponse;
import com.whipup.generated.model.IngredientOptionListResponse;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.constraints.*;
import jakarta.validation.Valid;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import jakarta.annotation.Generated;

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", date = "2026-09-23T01:37:49.076375542Z[Etc/UTC]", comments = "Generator version: 7.19.0")
@Controller
@RequestMapping("${openapi.whipUp.base-path:/api/v1}")
public class IngredientsApiController implements IngredientsApi {

    private final IngredientsApiDelegate delegate;

    public IngredientsApiController(@Autowired(required = false) IngredientsApiDelegate delegate) {
        this.delegate = Optional.ofNullable(delegate).orElse(new IngredientsApiDelegate() {});
    }

    @Override
    public IngredientsApiDelegate getDelegate() {
        return delegate;
    }

}

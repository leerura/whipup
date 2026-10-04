package com.whipup.generated.api;

import com.whipup.generated.model.AddOwnedIngredientRequest;
import com.whipup.generated.model.ErrorResponse;
import com.whipup.generated.model.OwnedIngredient;
import com.whipup.generated.model.OwnedIngredientListResponse;


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

@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
@Controller
@RequestMapping("${openapi.whipUp.base-path:}")
public class OwnedIngredientApiController implements OwnedIngredientApi {

    private final OwnedIngredientApiDelegate delegate;

    public OwnedIngredientApiController(@Autowired(required = false) OwnedIngredientApiDelegate delegate) {
        this.delegate = Optional.ofNullable(delegate).orElse(new OwnedIngredientApiDelegate() {});
    }

    @Override
    public OwnedIngredientApiDelegate getDelegate() {
        return delegate;
    }

}
